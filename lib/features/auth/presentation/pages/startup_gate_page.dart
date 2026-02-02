/// Startup gate page for Clean Architecture authentication flow.
///
/// This page serves as the entry point for the app, checking authentication
/// status and routing to the appropriate page based on the user's state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'auth_welcome_page.dart';

/// Entry point page that checks authentication and routes accordingly.
///
/// This page:
/// - Shows a loading screen with the app branding
/// - Checks authentication status on init
/// - Redirects to AuthWelcomePage if unauthenticated
/// - Redirects to home or onboarding if authenticated
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/',
///   name: StartupGatePage.routeName,
///   builder: (context, state) => const StartupGatePage(),
/// )
/// ```
class StartupGatePage extends StatefulWidget {
  /// Creates a startup gate page.
  const StartupGatePage({super.key});

  /// The route name for navigation.
  static const routeName = 'StartupGate';

  /// The route path for navigation.
  static const routePath = '/';

  @override
  State<StartupGatePage> createState() => _StartupGatePageState();
}

class _StartupGatePageState extends State<StartupGatePage> {
  @override
  void initState() {
    super.initState();
    // Check auth status on init
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state) {
          case Unauthenticated():
            context.goNamed(AuthWelcomePage.routeName);
          case Authenticated(:final profile):
            if (profile == null || !profile.isOnboardingComplete) {
              _navigateToOnboarding(profile?.role ?? UserRole.bride);
            } else {
              _navigateToHome(profile.role);
            }
          case AuthError(:final message):
            // Show error and redirect to welcome
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            context.goNamed(AuthWelcomePage.routeName);
          case AuthInitial():
          case AuthLoading():
            // Stay on loading screen
            break;
        }
      },
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LYNEWED',
                style: LynewedTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOnboarding(UserRole role) {
    switch (role) {
      case UserRole.bride:
        context.goNamed('OnboardingBridesWizard');
      case UserRole.professional:
      case UserRole.admin:
        context.goNamed('DashboardPro');
      case UserRole.guest:
        // Guests have no onboarding, go straight to home
        context.goNamed('GuestHomePage');
    }
  }

  void _navigateToHome(UserRole role) {
    switch (role) {
      case UserRole.bride:
        context.goNamed('HomeBrides');
      case UserRole.professional:
      case UserRole.admin:
        context.goNamed('DashboardPro');
      case UserRole.guest:
        context.goNamed('GuestHomePage');
    }
  }
}
