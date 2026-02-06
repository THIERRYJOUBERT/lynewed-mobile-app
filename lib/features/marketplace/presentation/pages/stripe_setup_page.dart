/// Page for Stripe Connect setup flow.
///
/// Allows sellers to set up their Stripe Connect account to receive
/// payments from marketplace sales. Shows current account status and
/// provides a button to start or continue onboarding.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../payments/domain/entities/stripe_account.dart';
import '../../domain/usecases/check_stripe_status_use_case.dart';
import '../../domain/usecases/setup_stripe_connect_use_case.dart';
import '../widgets/stripe_status_widget.dart';

/// HTTPS URLs for Stripe Connect return flow.
/// Stripe requires HTTP(S) URLs for accountLinks — custom schemes are rejected.
/// The edge function serves a redirect page that deep-links back into the app.
const _returnUrl =
    'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-connect-return?success=true';
const _refreshUrl =
    'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-connect-return?error=refresh_required';

/// Page for managing Stripe Connect payment setup.
///
/// Displays the current account status and allows the seller to:
/// - Start Stripe Connect onboarding (new account)
/// - Continue incomplete onboarding
/// - View current payment status
class StripeSetupPage extends StatefulWidget {
  /// The current user's ID.
  final String userId;

  /// The current user's email.
  final String email;

  /// Use case for creating a Stripe Connect account.
  final SetupStripeConnectUseCase setupUseCase;

  /// Use case for checking the Stripe account status.
  final CheckStripeStatusUseCase checkStatusUseCase;

  const StripeSetupPage({
    required this.userId,
    required this.email,
    required this.setupUseCase,
    required this.checkStatusUseCase,
    super.key,
  });

  @override
  State<StripeSetupPage> createState() => _StripeSetupPageState();
}

class _StripeSetupPageState extends State<StripeSetupPage> {
  bool _isLoading = true;
  bool _isSettingUp = false;
  String? _errorMessage;
  StripeAccount? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await widget.checkStatusUseCase.syncAndGetAccount(widget.userId);
      if (mounted) {
        setState(() {
          _account = account;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load account status. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startSetup() async {
    setState(() {
      _isSettingUp = true;
      _errorMessage = null;
    });

    try {
      // Fetch profile to pre-fill Stripe Connect form
      final authDs = sl<AuthRemoteDatasource>();
      final profile = await authDs.getProfile(widget.userId);

      // Parse display name into first/last
      String? firstName;
      String? lastName;
      if (profile?.displayName != null) {
        final parts = profile!.displayName!.trim().split(' ');
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }

      // Build address from shipping_address if available
      Map<String, String>? addressMap;
      String? country;
      if (profile?.shippingAddress != null) {
        final addr = profile!.shippingAddress!;
        country = addr.countryCode;
        addressMap = {
          if (addr.streetLines.isNotEmpty) 'line1': addr.streetLines.first,
          'city': addr.city,
          'postal_code': addr.postalCode,
          if (addr.stateOrProvinceCode != null)
            'state': addr.stateOrProvinceCode!,
        };
      }

      final result = await widget.setupUseCase(
        userId: widget.userId,
        email: widget.email,
        returnUrl: _returnUrl,
        refreshUrl: _refreshUrl,
        firstName: firstName,
        lastName: lastName,
        phone: profile?.shippingAddress?.phoneNumber,
        country: country,
        address: addressMap,
      );

      final url = result['url'] as String;
      final uri = Uri.parse(url);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not open Stripe setup. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to start payment setup. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSettingUp = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Payment Setup',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          if (!_isLoading)
            LynewedIconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadAccount,
              buttonSize: 40,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (_errorMessage != null) ...[
            _buildErrorBanner(),
            const SizedBox(height: 16),
          ],
          if (_account != null)
            StripeStatusWidget(
              onboardingComplete: _account!.onboardingComplete,
              chargesEnabled: _account!.chargesEnabled,
              payoutsEnabled: _account!.payoutsEnabled,
              onSetupTap: _isSettingUp ? null : _startSetup,
            )
          else
            _buildNoAccountSection(),
          const SizedBox(height: 30),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LynewedColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LynewedColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete your Stripe setup to receive payments from sales.',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _isSettingUp
              ? const Center(
                  child: CircularProgressIndicator(color: LynewedColors.primary),
                )
              : LynewedButton(
                  text: 'Setup Payments',
                  onPressed: _startSetup,
                  width: double.infinity,
                ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: LynewedTextStyles.titleSmall,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          Icons.account_balance,
          'Secure payments powered by Stripe',
        ),
        const SizedBox(height: 8),
        _buildInfoItem(
          Icons.percent,
          '10% platform fee on each sale',
        ),
        const SizedBox(height: 8),
        _buildInfoItem(
          Icons.schedule,
          'Payouts processed within 2-7 business days',
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: LynewedColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
