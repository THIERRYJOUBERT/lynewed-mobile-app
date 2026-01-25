/// Forgot password page for authentication.
///
/// Allows users to request a password reset email.
/// Uses AuthCubit for state management and handles:
/// - Form validation
/// - Loading state display
/// - Success confirmation view
/// - Error messages via SnackBar
/// - Navigation back to sign in
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';

/// Page for requesting a password reset email.
///
/// Example usage:
/// ```dart
/// ForgotPasswordPage()
/// ```
class ForgotPasswordPage extends StatefulWidget {
  /// Creates a forgot password page.
  const ForgotPasswordPage({super.key});

  /// The route name for navigation.
  static const routeName = 'ForgotPasswordPage';

  /// The route path for navigation.
  static const routePath = '/forgotPassword';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _emailSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final result = await context.read<AuthCubit>().sendPasswordResetEmail(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _emailSent = true;
        }
      });

      if (result.isFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failureOrNull()!.message),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
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

  void _navigateToSignIn() {
    context.goNamed('SignInPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: LynewedSpacing.sheetHorizontalPadding,
            vertical: LynewedSpacing.xxxl,
          ),
          child: _emailSent ? _buildConfirmationView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const AuthHeader(
            title: 'Forgot Password',
            subtitle: 'Enter your email to receive a password reset link',
          ),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Email field
          AuthFormField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            focusNode: _emailFocusNode,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
            onFieldSubmitted: (_) => _handleSendResetEmail(),
          ),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Send reset link button
          LynewedButton(
            text: 'Send Reset Link',
            onPressed: _isLoading ? null : _handleSendResetEmail,
            isLoading: _isLoading,
            width: double.infinity,
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Back to sign in link
          Center(
            child: TextButton(
              onPressed: _navigateToSignIn,
              child: Text(
                'Back to Sign In',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: LynewedColors.primary,
        ),

        SizedBox(height: LynewedSpacing.xl),

        // Success header
        const AuthHeader(
          title: 'Check Your Email',
          subtitle: 'We sent a password reset link to your email address',
          textAlign: TextAlign.center,
        ),

        SizedBox(height: LynewedSpacing.formSectionGap),

        // Return to sign in button
        LynewedButton(
          text: 'Back to Sign In',
          onPressed: _navigateToSignIn,
          width: double.infinity,
        ),
      ],
    );
  }
}
