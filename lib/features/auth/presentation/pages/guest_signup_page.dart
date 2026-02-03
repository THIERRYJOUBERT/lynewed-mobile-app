/// Guest signup page for creating a guest account.
///
/// Displayed after validating an invite code.
/// Allows signup via email/password or OAuth (Apple/Google).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../data/repositories/guest_repository_impl.dart';
import '../../domain/repositories/guest_repository.dart';
import '../../domain/usecases/create_guest_account.dart';
import '../widgets/guest_signup_form.dart';

/// Page for guest account creation after invite code validation.
class GuestSignupPage extends StatefulWidget {
  /// Route name for navigation.
  static const routeName = 'GuestSignupPage';

  /// Route path for navigation.
  static const routePath = '/guestSignup';

  /// The validated invite code.
  final String inviteCode;

  /// Name of the bride (from code validation).
  final String brideName;

  /// Pre-filled email (if guest was invited by email).
  final String? prefilledEmail;

  /// Optional repository for testing.
  final GuestRepository? guestRepository;

  /// Optional use case for testing.
  final CreateGuestAccount? createGuestAccountUseCase;

  /// Creates a guest signup page.
  const GuestSignupPage({
    required this.inviteCode,
    required this.brideName,
    this.prefilledEmail,
    this.guestRepository,
    this.createGuestAccountUseCase,
    super.key,
  });

  @override
  State<GuestSignupPage> createState() => _GuestSignupPageState();
}

class _GuestSignupPageState extends State<GuestSignupPage> {
  late final CreateGuestAccount _createGuestAccount;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.guestRepository ?? GuestRepositoryImpl.withDefaults();
    _createGuestAccount =
        widget.createGuestAccountUseCase ?? CreateGuestAccount(repository);
  }

  Future<void> _handleEmailSignup(
    String firstName,
    String email,
    String password,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _createGuestAccount(CreateGuestAccountParams(
      firstName: firstName,
      email: email,
      password: password,
      inviteCode: widget.inviteCode,
    ));

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case GuestAccountCreated():
        // Navigate to guest home
        context.go('/guestHome');
      case EmailAlreadyExists():
        setState(() {
          _errorMessage = 'Cet email est déjà utilisé. Voulez-vous vous connecter ?';
        });
      case InvalidEmailFormat():
        setState(() => _errorMessage = 'Format d\'email invalide');
      case WeakPassword():
        setState(() {
          _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
        });
      case InvalidInviteCodeError():
        setState(() => _errorMessage = 'Code d\'invitation invalide ou expiré');
      case CreateGuestAccountError(:final message):
        setState(() => _errorMessage = message);
    }
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google OAuth + join wedding
    // For now, show not implemented message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Google bientôt disponible'),
      ),
    );
  }

  void _handleAppleSignIn() {
    // TODO: Implement Apple OAuth + join wedding
    // For now, show not implemented message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Apple bientôt disponible'),
      ),
    );
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(LynewedSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              Text(
                'Bienvenue au mariage de ${widget.brideName} !',
                style: LynewedTextStyles.headlineMedium.copyWith(
                  color: LynewedColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: LynewedSpacing.sm),
              Text(
                'Créez votre compte pour accéder aux photos, au chat et plus encore.',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: LynewedSpacing.xl),

              // Signup form
              GuestSignupForm(
                initialEmail: widget.prefilledEmail,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onSubmit: _handleEmailSignup,
              ),

              // Divider
              SizedBox(height: LynewedSpacing.lg),
              Row(
                children: [
                  Expanded(child: Divider(color: LynewedColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
                    child: Text(
                      'OU',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: LynewedColors.border)),
                ],
              ),
              SizedBox(height: LynewedSpacing.lg),

              // OAuth buttons
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.g_mobiledata, size: 20),
                ),
                label: const Text('Continuer avec Google'),
              ),
              SizedBox(height: LynewedSpacing.sm),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleAppleSignIn,
                icon: const Icon(Icons.apple, size: 20),
                label: const Text('Continuer avec Apple'),
              ),

              // Login link
              SizedBox(height: LynewedSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ? ',
                    style: LynewedTextStyles.bodySmall,
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _navigateToLogin,
                    child: Text(
                      'Se connecter',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
