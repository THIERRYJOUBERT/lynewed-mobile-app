/// Welcome page for authentication.
///
/// The landing page for unauthenticated users that displays:
/// - App branding
/// - Sign in options for bride and professional users
/// - Create account option
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../widgets/auth_header.dart';

/// Welcome page that serves as the entry point for authentication.
///
/// Provides options to:
/// - Sign in as a bride
/// - Sign in as a professional
/// - Create a new account
class AuthWelcomePage extends StatelessWidget {
  /// Creates a welcome page.
  const AuthWelcomePage({super.key});

  /// The route name for navigation.
  static const routeName = 'AuthWelcomePage';

  /// The route path for navigation.
  static const routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LynewedSpacing.sheetHorizontalPadding,
          ),
          child: Column(
            children: [
              // Spacer to push content down
              const Spacer(flex: 2),

              // App branding
              const AuthHeader(
                title: 'LYNEWED',
                subtitle: 'Your perfect wedding, simplified',
                textAlign: TextAlign.center,
              ),

              // Spacer between branding and buttons
              const Spacer(flex: 3),

              // Sign In button (bride)
              LynewedButton(
                text: 'Sign In',
                onPressed: () => _navigateToSignIn(context, isProfessional: false),
                width: double.infinity,
              ),

              SizedBox(height: LynewedSpacing.lg),

              // Create Account button
              LynewedButton(
                text: 'Create Account',
                type: LynewedButtonType.secondary,
                onPressed: () => _navigateToSignUp(context),
                width: double.infinity,
              ),

              SizedBox(height: LynewedSpacing.formSectionGap),

              // Professional sign in link
              TextButton(
                onPressed: () => _navigateToSignIn(context, isProfessional: true),
                child: Text(
                  'Professional? Sign in here',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),

              // Bottom spacer
              SizedBox(height: LynewedSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSignIn(BuildContext context, {required bool isProfessional}) {
    context.pushNamed(
      'SignInPage',
      extra: {'isProfessional': isProfessional},
    );
  }

  void _navigateToSignUp(BuildContext context) {
    context.pushNamed('SignUpPage');
  }
}
