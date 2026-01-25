/// Sign-up page for bride users.
///
/// Allows new users to create an account with email, password, and display name.
/// Uses AuthCubit for state management and handles:
/// - Form validation
/// - Loading state display
/// - Error messages via SnackBar
/// - Navigation on successful registration
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';

/// Sign-up page for bride users.
///
/// Example usage:
/// ```dart
/// SignUpPage()
/// ```
class SignUpPage extends StatefulWidget {
  /// Creates a sign-up page.
  const SignUpPage({super.key});

  /// The route name for navigation.
  static const routeName = 'SignUpPage';

  /// The route path for navigation.
  static const routePath = '/signUp';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _displayNameFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _displayNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final displayName = _displayNameController.text.trim();

    await context.read<AuthCubit>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: displayName.isEmpty ? null : displayName,
        );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.goNamed('StartupGate');
        } else if (state is AuthError) {
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
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle: 'Sign up to get started',
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
                      hint: 'Create a password',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordFocusNode,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: _validatePassword,
                      onFieldSubmitted: (_) {
                        _displayNameFocusNode.requestFocus();
                      },
                    ),

                    SizedBox(height: LynewedSpacing.xl),

                    // Display name field (optional)
                    AuthFormField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      hint: 'Enter your name (optional)',
                      textInputAction: TextInputAction.done,
                      focusNode: _displayNameFocusNode,
                      autofillHints: const [AutofillHints.name],
                      onFieldSubmitted: (_) => _handleSignUp(),
                    ),

                    SizedBox(height: LynewedSpacing.formSectionGap),

                    // Sign up button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return LynewedButton(
                          text: 'Sign Up',
                          onPressed: isLoading ? null : _handleSignUp,
                          isLoading: isLoading,
                          width: double.infinity,
                        );
                      },
                    ),

                    SizedBox(height: LynewedSpacing.lg),

                    // Already have account link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          'Already have an account? Sign in',
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
