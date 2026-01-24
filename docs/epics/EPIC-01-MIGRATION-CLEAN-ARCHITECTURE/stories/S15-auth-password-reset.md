# Story S15: Auth - Password Reset Flow

## Description

En tant que developpeur, je veux migrer le flow de reset de mot de passe vers Clean Architecture afin de completer le module Auth.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `ForgotPasswordPageWidget` When je la migre Then la nouvelle page utilise AuthCubit

- [ ] Given `ResetPasswordNewPageWidget` When je la migre Then la nouvelle page gere le deep link de reset

- [ ] Given `SetPasswordPageProWidget` When je la migre Then elle partage la logique avec les autres pages

- [ ] Given un email de reset When l'utilisateur clique sur le lien Then l'app ouvre la page de nouveau mot de passe

- [ ] Given le nouveau mot de passe When il est valide Then il est mis a jour avec succes

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/auth/forgot_password_page/`
- `lib/pages/auth/reset_password_new_page/`
- `lib/pages/auth/set_password_page_pro/`

### A Creer
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/reset_password_page.dart`
- `lib/features/auth/presentation/pages/set_password_page.dart`

## Notes Techniques

### Forgot Password Page
```dart
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const routeName = 'ForgotPasswordPage';
  static const routePath = '/forgotPassword';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    final result = await context.read<AuthCubit>().sendPasswordResetEmail(email);

    if (mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) {
      return _buildEmailSentView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FORGOT YOUR PASSWORD?',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we will send you a link to reset your password.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
            const SizedBox(height: 32),
            AuthFormField(
              controller: _emailController,
              label: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Send reset link',
              onPressed: _handleSendResetEmail,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSentView() {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 64),
            const SizedBox(height: 24),
            Text(
              'CHECK YOUR EMAIL',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We have sent a password reset link to ${_emailController.text}',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Back to Login',
              onPressed: () => context.goNamed(SignInPage.routeName),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Reset Password Page (Deep Link Handler)
```dart
class ResetPasswordPage extends StatefulWidget {
  /// Token from deep link (Supabase recovery)
  final String? accessToken;

  const ResetPasswordPage({
    this.accessToken,
    super.key,
  });

  static const routeName = 'ResetPasswordPage';
  static const routePath = '/resetPassword';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void initState() {
    super.initState();
    // Handle the recovery token
    if (widget.accessToken != null) {
      _handleRecoveryToken();
    }
  }

  Future<void> _handleRecoveryToken() async {
    // Supabase handles the token via URL fragment
    // Just need to update password
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthCubit>().updatePassword(_passwordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        context.goNamed(SignInPage.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREATE NEW PASSWORD',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different from previous used passwords.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              AuthFormField(
                controller: _passwordController,
                label: 'New password',
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _confirmController,
                label: 'Confirm password',
                obscureText: !_confirmVisible,
                suffixIcon: IconButton(
                  icon: Icon(_confirmVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 32),
              LynewedButton(
                text: 'Update Password',
                onPressed: _handleUpdatePassword,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
```

### Deep Link Setup
```dart
// Dans navigation/router.dart
GoRoute(
  path: ResetPasswordPage.routePath,
  name: ResetPasswordPage.routeName,
  builder: (context, state) {
    // Supabase envoie le token via fragment URL
    // access_token est automatiquement gere par Supabase
    return const ResetPasswordPage();
  },
),
```

## Definition of Done

- [ ] ForgotPasswordPage migree
- [ ] ResetPasswordPage migree
- [ ] SetPasswordPage migree (pour Pro)
- [ ] Deep link handling fonctionnel
- [ ] Validation mot de passe (8 chars, etc.)
- [ ] Messages de succes/erreur
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Moyen (deep links)

## Dependances

- S03 : Design system
- S04 : Navigation
- S13 : Auth - Presentation setup
- S14 : Auth - Login/Signup

## Stories Dependantes

- Aucune
