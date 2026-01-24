# Story S14: Auth - Login/Signup Pages

## Description

En tant que developpeur, je veux migrer les pages de login et signup vers Clean Architecture afin d'eliminer la dependance FlutterFlow sur ces pages critiques.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `SignInEmailPageWidget` When je la migre Then la nouvelle page utilise AuthCubit

- [ ] Given `SignUpEmailPageWidget` When je la migre Then la nouvelle page utilise AuthCubit

- [ ] Given `AuthWelcomePageWidget` When je la migre Then la nouvelle page utilise le design system

- [ ] Given `SignInEmailPageProWidget` When je la migre Then elle partage la logique avec SignInEmailPage

- [ ] Given la validation des formulaires When je la teste Then les erreurs sont bien affichees

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/auth/sign_in_email_page/` - Login Bride
- `lib/pages/auth/sign_up_email_page/` - Signup Bride
- `lib/pages/auth/auth_welcome_page/` - Welcome page
- `lib/pages/auth/sign_in_email_page_pro/` - Login Pro

### A Creer
- `lib/features/auth/presentation/pages/sign_in_page.dart`
- `lib/features/auth/presentation/pages/sign_up_page.dart`
- `lib/features/auth/presentation/pages/auth_welcome_page.dart`
- `lib/features/auth/presentation/pages/pages.dart` - Barrel
- `lib/features/auth/presentation/widgets/auth_form_field.dart`
- `lib/features/auth/presentation/widgets/auth_header.dart`
- `lib/features/auth/presentation/widgets/widgets.dart` - Barrel

## Notes Techniques

### Pattern Page
```dart
class SignInPage extends StatefulWidget {
  final bool isProfessional;

  const SignInPage({
    this.isProfessional = false,
    super.key,
  });

  static const routeName = 'SignInPage';
  static const routePath = '/signIn';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate based on profile
          if (state.needsOnboarding) {
            context.goNamed(OnboardingPage.routeName);
          } else {
            context.goNamed(HomePage.routeName);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'WE ARE DELIGHTED TO SEE YOU AGAIN',
                    subtitle: 'Log in with your email address and password',
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    controller: _emailController,
                    label: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.pushNamed(ForgotPasswordPage.routeName),
                      child: const Text('Forgot your password?'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return LynewedButton(
                        text: 'Log in with email',
                        onPressed: isLoading ? null : _handleSignIn,
                        isLoading: isLoading,
                        width: double.infinity,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.goNamed(SignUpPage.routeName),
                    child: const Text("Don't have an account? Create your account here"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
```

### Auth Header Widget
```dart
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? backgroundImage;

  const AuthHeader({
    required this.title,
    this.subtitle,
    this.backgroundImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (backgroundImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              backgroundImage!,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),
        Text(
          title,
          style: context.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
```

### Auth Form Field Widget
```dart
class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthFormField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        // Use design system styling
      ),
      validator: validator,
    );
  }
}
```

## Definition of Done

- [ ] SignInPage migree et fonctionnelle
- [ ] SignUpPage migree et fonctionnelle
- [ ] AuthWelcomePage migree
- [ ] Widgets partages crees
- [ ] Validation formulaires
- [ ] Navigation vers onboarding/home
- [ ] Tests widgets
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Eleve (UX critique)

## Dependances

- S03 : Design system
- S04 : Navigation
- S13 : Auth - Presentation setup

## Stories Dependantes

- S15 : Password reset
- S16 : Startup gate
