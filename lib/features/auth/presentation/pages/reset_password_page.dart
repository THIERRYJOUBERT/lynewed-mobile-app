/// Reset password page for authentication.
///
/// Allows users to create a new password after receiving a reset link.
/// Uses AuthCubit for state management and handles:
/// - Form validation (min 8 chars, password match)
/// - Password visibility toggle
/// - Loading state display
/// - Success navigation to sign in
/// - Error messages via SnackBar
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';

/// Page for creating a new password after reset.
///
/// Example usage:
/// ```dart
/// ResetPasswordPage()
/// ```
class ResetPasswordPage extends StatefulWidget {
  /// Creates a reset password page.
  const ResetPasswordPage({super.key});

  /// The route name for navigation.
  static const routeName = 'ResetPasswordPage';

  /// The route path for navigation.
  static const routePath = '/resetPassword';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final password = _passwordController.text;
    final result = await context.read<AuthCubit>().updatePassword(password);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        // Show success message and navigate to sign in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password updated successfully'),
            backgroundColor: LynewedColors.primary,
          ),
        );
        context.goNamed('SignInPage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failureOrNull()!.message),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
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
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const AuthHeader(
                  title: 'Create New Password',
                  subtitle: 'Enter your new password below',
                ),

                SizedBox(height: LynewedSpacing.formSectionGap),

                // New password field
                AuthFormField(
                  controller: _passwordController,
                  label: 'New Password',
                  hint: 'Enter your new password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  focusNode: _passwordFocusNode,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: _validatePassword,
                  onFieldSubmitted: (_) {
                    _confirmPasswordFocusNode.requestFocus();
                  },
                ),

                SizedBox(height: LynewedSpacing.xl),

                // Confirm password field
                AuthFormField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your new password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  focusNode: _confirmPasswordFocusNode,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),

                SizedBox(height: LynewedSpacing.formSectionGap),

                // Reset password button
                LynewedButton(
                  text: 'Reset Password',
                  onPressed: _isLoading ? null : _handleResetPassword,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
