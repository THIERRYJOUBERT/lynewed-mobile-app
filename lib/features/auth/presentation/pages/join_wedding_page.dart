/// Join wedding page for guest users.
///
/// This page allows invited guests to join a wedding by entering
/// their invitation code or scanning a QR code.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/index.dart';
import '../../../../core/design/design.dart';
import '../../data/repositories/invite_code_repository_impl.dart';
import '../../domain/usecases/validate_invite_code.dart';
import '../widgets/invite_code_input.dart';
import '../widgets/qr_scanner_sheet.dart';

/// Page for guests to join a wedding with an invitation code.
///
/// Provides two ways to join:
/// - Enter an 8-character invitation code manually
/// - Scan a QR code from the invitation email
///
/// This page is accessible from the auth welcome page before login.
class JoinWeddingPage extends StatefulWidget {
  /// Creates a join wedding page.
  const JoinWeddingPage({
    this.initialCode,
    this.validateInviteCode,
    super.key,
  });

  /// The route name for navigation.
  static const routeName = 'JoinWeddingPage';

  /// The route path for navigation.
  static const routePath = '/joinWedding';

  /// Optional initial code (from deep link).
  final String? initialCode;

  /// Optional custom use case for testing.
  final ValidateInviteCode? validateInviteCode;

  @override
  State<JoinWeddingPage> createState() => _JoinWeddingPageState();
}

class _JoinWeddingPageState extends State<JoinWeddingPage> {
  final _codeController = TextEditingController();
  late final ValidateInviteCode _validateInviteCode;

  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _validateInviteCode = widget.validateInviteCode ??
        ValidateInviteCode(InviteCodeRepositoryImpl());

    _codeController.addListener(_onCodeChanged);

    // Handle initial code from deep link
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!.toUpperCase();
      // Auto-validate if pre-filled from deep link
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_codeController.text.length == 8) {
          _validateCode();
        }
      });
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    // Clear error when user types
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
    // Force rebuild to update button state
    setState(() {});
  }

  bool get _isCodeComplete => _codeController.text.length == 8;

  Future<void> _validateCode() async {
    if (!_isCodeComplete) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final result = await _validateInviteCode(
      ValidateInviteCodeParams(code: _codeController.text),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case ValidInviteCode(:final weddingId, :final brideName):
        _onValidCode(weddingId, brideName);
      case InvalidInviteCode():
        setState(() => _errorText = 'Invalid or expired code');
      case RateLimitedInviteCode():
        setState(() => _errorText =
            'Too many attempts. Please try again in a few minutes.');
      case InviteCodeError(:final message):
        setState(() => _errorText = 'Erreur: $message');
    }
  }

  void _onValidCode(String weddingId, String brideName) {
    // Navigate to guest account creation page (new FlutterFlow-style page)
    context.push(
      '/guestSignUp?inviteCode=${_codeController.text}&brideName=${Uri.encodeComponent(brideName)}',
    );
  }

  Future<void> _openQrScanner() async {
    final code = await showQrScannerSheet(context);
    if (code != null && mounted) {
      _codeController.text = code;
      _validateCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: LynewedColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LynewedSpacing.sheetHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: LynewedSpacing.xl),

              // Title
              Text(
                'Join a Wedding',
                style: LynewedTextStyles.headlineLarge.copyWith(
                  color: LynewedColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: LynewedSpacing.md),

              // Subtitle
              Text(
                'Enter the code from your email or scan the QR code on your invitation',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: LynewedSpacing.xxxl),

              // Code input
              InviteCodeInput(
                controller: _codeController,
                errorText: _errorText,
                enabled: !_isLoading,
              ),

              SizedBox(height: LynewedSpacing.xxl),

              // Continue button
              LynewedButton(
                text: _isLoading ? 'Verifying...' : 'Continue',
                onPressed:
                    _isCodeComplete && !_isLoading ? _validateCode : null,
                width: double.infinity,
              ),

              SizedBox(height: LynewedSpacing.lg),

              // QR Scanner divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: LynewedColors.border),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
                    child: Text(
                      'OR',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: LynewedColors.border),
                  ),
                ],
              ),

              SizedBox(height: LynewedSpacing.lg),

              // QR Scanner button
              LynewedButton(
                text: 'Scan QR Code',
                type: LynewedButtonType.secondary,
                icon: Icons.qr_code_scanner,
                onPressed: _isLoading ? null : _openQrScanner,
                width: double.infinity,
              ),

              const Spacer(),

              // Help text
              Text(
                "Don't have a code? Ask the bride to invite you.",
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: LynewedSpacing.md),

              // Already have account link
              InkWell(
                onTap: () => context.pushNamed(GuestSignInPage.routeName),
                child: Text(
                  'Already have an account? Log in',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: LynewedSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
