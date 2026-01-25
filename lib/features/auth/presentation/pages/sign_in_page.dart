/// Sign-in page for authentication.
///
/// Allows users to sign in with email and password.
/// Uses AuthCubit for state management and handles:
/// - Form validation
/// - Loading state display
/// - Error messages via SnackBar
/// - Navigation on successful authentication
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';

/// Sign-in page that supports both bride and professional users.
///
/// Example usage:
/// ```dart
/// // For bride sign in
/// SignInPage()
///
/// // For professional sign in
/// SignInPage(isProfessional: true)
/// ```
class SignInPage extends StatefulWidget {
  /// Creates a sign-in page.
  const SignInPage({
    this.isProfessional = false,
    super.key,
  });

  /// Whether this is a professional sign-in (affects title and styling).
  final bool isProfessional;

  /// The route name for navigation.
  static const routeName = 'SignInPage';

  /// The route path for navigation.
  static const routePath = '/signIn';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Simple email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate to StartupGate on successful authentication
          context.goNamed('StartupGate');
        } else if (state is AuthError) {
          // Show error in SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.sheetHorizontalPadding,
              vertical: LynewedSpacing.xxxl,
            ),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    AuthHeader(
                      title: widget.isProfessional
                          ? 'Professional Sign In'
                          : 'Welcome Back',
                      subtitle: widget.isProfessional
                          ? 'Sign in to your professional account'
                          : 'Sign in to continue',
                    ),

                    SizedBox(height: LynewedSpacing.formSectionGap),

                    // Email field
                    AuthFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocusNode,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                      onFieldSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                    ),

                    SizedBox(height: LynewedSpacing.xl),

                    // Password field
                    AuthFormField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFocusNode,
                      autofillHints: const [AutofillHints.password],
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _handleSignIn(),
                    ),

                    SizedBox(height: LynewedSpacing.formSectionGap),

                    // Sign in button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return LynewedButton(
                          text: 'Sign In',
                          onPressed: isLoading ? null : _handleSignIn,
                          isLoading: isLoading,
                          width: double.infinity,
                        );
                      },
                    ),

                    SizedBox(height: LynewedSpacing.lg),

                    // Forgot password link (navigation handled by router)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Forgot password flow is handled separately
                          // Will be integrated when password reset feature is implemented
                        },
                        child: Text(
                          'Forgot password?',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
