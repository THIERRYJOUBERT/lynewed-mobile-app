/// Page for Stripe Connect setup flow.
///
/// Multi-step in-app form that collects seller info (name, DOB, address,
/// IBAN) before redirecting to Stripe only for identity verification.
///
/// Steps:
/// 1. Personal Info (first name, last name, DOB, phone)
/// 2. Address (reuses AddressFormWidget)
/// 3. Bank Details (IBAN)
/// 4. Stripe redirect for ID verification (minimal)
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../payments/domain/entities/stripe_account.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/usecases/check_stripe_status_use_case.dart';
import '../../domain/usecases/setup_stripe_connect_use_case.dart';
import '../widgets/address_form_widget.dart';
import '../widgets/iban_input_widget.dart';
import '../widgets/stripe_status_widget.dart';

/// HTTPS URLs for Stripe Connect return flow.
const _returnUrl =
    'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-connect-return?success=true';
const _refreshUrl =
    'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-connect-return?error=refresh_required';

/// Multi-step payment setup page for sellers.
///
/// If the seller already has a Stripe account, shows account status.
/// Otherwise, shows a 3-step form before a minimal Stripe redirect.
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
  // Account state
  bool _isLoadingAccount = true;
  StripeAccount? _account;

  // Step management (only used when no account exists)
  int _currentStep = 0;
  static const _stepLabels = ['Personal', 'Address', 'Bank'];

  // Step 1: Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;

  // Step 2: Address
  ShippingAddress? _address;

  // Step 3: IBAN
  String? _iban;

  // Setup state
  bool _isSettingUp = false;
  String? _errorMessage;
  bool _tosAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoadingAccount = true;
      _errorMessage = null;
    });

    try {
      final account =
          await widget.checkStatusUseCase.syncAndGetAccount(widget.userId);
      if (!mounted) return;

      // Pre-fill form from profile if no account yet
      if (account == null) {
        await _prefillFromProfile();
      }

      setState(() {
        _account = account;
        _isLoadingAccount = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Still try to pre-fill even on error
      await _prefillFromProfile();

      setState(() {
        _errorMessage = 'Failed to load account status. Please try again.';
        _isLoadingAccount = false;
      });
    }
  }

  Future<void> _prefillFromProfile() async {
    try {
      final authDs = sl<AuthRemoteDatasource>();
      final profile = await authDs.getProfile(widget.userId);
      if (profile == null || !mounted) return;

      if (profile.displayName != null) {
        final parts = profile.displayName!.trim().split(' ');
        _firstNameController.text = parts.first;
        if (parts.length > 1) {
          _lastNameController.text = parts.sublist(1).join(' ');
        }
      }

      if (profile.shippingAddress != null) {
        _address = profile.shippingAddress;
        if (profile.shippingAddress!.phoneNumber != null) {
          _phoneController.text = profile.shippingAddress!.phoneNumber!;
        }
      }
    } catch (_) {
      // Non-critical: form fields just stay empty
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _firstNameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty &&
            _dateOfBirth != null;
      case 1:
        return _address != null;
      case 2:
        return _iban != null && _tosAccepted;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    } else {
      _submitSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitSetup() async {
    setState(() {
      _isSettingUp = true;
      _errorMessage = null;
    });

    try {
      // Build address map for edge function
      Map<String, String>? addressMap;
      String? country;
      if (_address != null) {
        country = _address!.countryCode;
        addressMap = {
          if (_address!.streetLines.isNotEmpty)
            'line1': _address!.streetLines.first,
          'city': _address!.city,
          'postal_code': _address!.postalCode,
          if (_address!.stateOrProvinceCode != null)
            'state': _address!.stateOrProvinceCode!,
        };
      }

      // Build DOB map
      Map<String, int>? dobMap;
      if (_dateOfBirth != null) {
        dobMap = {
          'day': _dateOfBirth!.day,
          'month': _dateOfBirth!.month,
          'year': _dateOfBirth!.year,
        };
      }

      // Save address to profile for shipping label generation later
      if (_address != null) {
        try {
          final authDs = sl<AuthRemoteDatasource>();
          await authDs.updateProfile(widget.userId, {
            'shipping_address': _address!.toJson(),
          });
        } catch (_) {
          // Non-critical: address can be re-entered later
        }
      }

      final result = await widget.setupUseCase(
        userId: widget.userId,
        email: widget.email,
        returnUrl: _returnUrl,
        refreshUrl: _refreshUrl,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        country: country,
        address: addressMap,
        dateOfBirth: dobMap,
        iban: _iban,
        tosAccepted: _tosAccepted,
      );

      final url = result['url'] as String;
      final uri = Uri.parse(url);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not open identity verification. Please try again.';
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

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LynewedColors.primary,
              onPrimary: Colors.white,
              surface: LynewedColors.background,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isLoadingAccount)
              const Expanded(
                child: Center(
                  child:
                      CircularProgressIndicator(color: LynewedColors.primary),
                ),
              )
            else if (_account != null)
              Expanded(child: _buildAccountStatus())
            else ...[
              _buildStepIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildStepContent(),
                ),
              ),
              _buildBottomBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          if (!_isLoadingAccount && _account != null)
            LynewedIconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadAccount,
              buttonSize: 40,
            ),
        ],
      ),
    );
  }

  // -- Account Status (existing account) --

  Widget _buildAccountStatus() {
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
          StripeStatusWidget(
            onboardingComplete: _account!.onboardingComplete,
            chargesEnabled: _account!.chargesEnabled,
            payoutsEnabled: _account!.payoutsEnabled,
            onSetupTap: _isSettingUp ? null : _submitSetup,
          ),
          const SizedBox(height: 30),
          _buildInfoSection(),
        ],
      ),
    );
  }

  // -- Step Indicator --

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_stepLabels.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted || isActive
                              ? LynewedColors.primary
                              : LynewedColors.gray200,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? LynewedColors.primary
                            : LynewedColors.gray200,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 14, color: LynewedColors.background)
                            : Text(
                                '${index + 1}',
                                style: LynewedTextStyles.bodySmall.copyWith(
                                  color: isActive
                                      ? LynewedColors.background
                                      : LynewedColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    if (index < _stepLabels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? LynewedColors.primary
                              : LynewedColors.gray200,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _stepLabels[index],
                  style: LynewedTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: isActive || isCompleted
                        ? LynewedColors.textPrimary
                        : LynewedColors.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // -- Step Content --

  Widget _buildStepContent() {
    if (_errorMessage != null) {
      return Column(
        children: [
          _buildErrorBanner(),
          const SizedBox(height: 20),
          _buildCurrentStep(),
        ],
      );
    }
    return _buildCurrentStep();
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildBankStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your legal name and date of birth to receive payouts.',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        LynewedTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'Your legal first name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        LynewedTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Your legal last name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text('Date of Birth', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDateOfBirth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: LynewedColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
                          '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
                          '${_dateOfBirth!.year}'
                      : 'Select your date of birth',
                  style: _dateOfBirth != null
                      ? LynewedTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w300)
                      : LynewedTextStyles.inputHint,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LynewedTextField(
          controller: _phoneController,
          label: 'Phone Number (optional)',
          hint: '+33 6 12 34 56 78',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your address. This will also be used as your shipping address.',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        AddressFormWidget(
          initialAddress: _address,
          onAddressChanged: (address) {
            setState(() => _address = address);
          },
        ),
      ],
    );
  }

  Widget _buildBankStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your bank details to receive payouts from sales.',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        IbanInputWidget(
          initialValue: _iban,
          onChanged: (value) => setState(() => _iban = value),
        ),
        const SizedBox(height: 30),
        _buildInfoSection(),
        const SizedBox(height: 24),
        // TOS acceptance
        GestureDetector(
          onTap: () => setState(() => _tosAccepted = !_tosAccepted),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _tosAccepted,
                  onChanged: (v) => setState(() => _tosAccepted = v ?? false),
                  activeColor: LynewedColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'I agree to the Stripe Connected Account Agreement '
                  'and authorize Lynewed to facilitate payments on my behalf.',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -- Bottom Bar --

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _stepLabels.length - 1;
    final buttonText = isLastStep ? 'Verify Identity' : 'Continue';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.gray200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: LynewedButton(
                text: 'Back',
                type: LynewedButtonType.secondary,
                onPressed: _previousStep,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: _isSettingUp
                ? const Center(
                    child: CircularProgressIndicator(
                        color: LynewedColors.primary),
                  )
                : LynewedButton(
                    text: buttonText,
                    onPressed: _canProceed ? _nextStep : null,
                    width: double.infinity,
                    icon: isLastStep ? Icons.verified_user_outlined : null,
                  ),
          ),
        ],
      ),
    );
  }

  // -- Shared Widgets --

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
          const Icon(Icons.error_outline,
              color: LynewedColors.error, size: 20),
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
