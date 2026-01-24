# Story S16: Auth - Startup Gate Refactoring

## Description

En tant que developpeur, je veux refactorer le StartupGate pour utiliser Clean Architecture afin d'avoir un point d'entree propre qui gere l'authentification, les Terms of Service, et le routing initial.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `StartupGateWidget` When je la refactore Then elle utilise AuthCubit pour determiner l'etat

- [ ] Given un utilisateur non authentifie When l'app demarre Then il est redirige vers AuthWelcomePage

- [ ] Given un utilisateur authentifie sans profil complete When l'app demarre Then il est redirige vers Onboarding

- [ ] Given un utilisateur authentifie avec profil When l'app demarre Then il est redirige vers HomePage (bride/pro)

- [ ] Given les Terms of Service When ils ne sont pas acceptes Then l'utilisateur doit les accepter avant de continuer

## Fichiers Concernes

### Page Legacy a Refactorer
- `lib/pages/auth/startup_gate/startup_gate_widget.dart`
- `lib/pages/auth/startup_gate/startup_gate_model.dart`

### A Creer/Modifier
- `lib/features/auth/presentation/pages/startup_gate_page.dart`
- `lib/features/auth/presentation/widgets/tos_sheet.dart` - Bottom sheet Terms

### Actions Custom Code a Integrer
- `lib/custom_code/actions/check_tos_accepted.dart`
- `lib/custom_code/actions/insert_legal_acceptance.dart`
- `lib/custom_code/actions/load_initial_session_data.dart`

## Notes Techniques

### Startup Gate Logic
```dart
class StartupGatePage extends StatefulWidget {
  const StartupGatePage({super.key});

  static const routeName = 'StartupGate';
  static const routePath = '/';

  @override
  State<StartupGatePage> createState() => _StartupGatePageState();
}

class _StartupGatePageState extends State<StartupGatePage> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Wait for auth state to be determined
    final authCubit = context.read<AuthCubit>();

    // Check current state
    await authCubit.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        _handleStateChange(state);
      },
      builder: (context, state) {
        // Show loading while determining state
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LYNEWED', style: TextStyle(fontSize: 32)),
                SizedBox(height: 24),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleStateChange(AuthState state) async {
    if (state is Unauthenticated) {
      context.goNamed(AuthWelcomePage.routeName);
      return;
    }

    if (state is Authenticated) {
      // Check Terms of Service
      final tosAccepted = await _checkTermsOfService();
      if (!tosAccepted) {
        final accepted = await _showTermsSheet();
        if (!accepted) {
          // User declined, sign out
          context.read<AuthCubit>().signOut();
          return;
        }
      }

      // Load initial session data
      await _loadSessionData();

      // Route based on profile
      if (state.needsOnboarding) {
        _navigateToOnboarding(state);
      } else {
        _navigateToHome(state);
      }
    }
  }

  Future<bool> _checkTermsOfService() async {
    final authRepo = getIt<AuthRepository>();
    final result = await authRepo.hasAcceptedTerms();
    return result.when(
      success: (accepted) => accepted,
      failure: (_) => false,
    );
  }

  Future<bool> _showTermsSheet() async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const TermsOfServiceSheet(),
    );
    return accepted ?? false;
  }

  Future<void> _loadSessionData() async {
    // Load initial data needed across the app
    // - User preferences
    // - Notification settings
    // - Unread counts
    // etc.
  }

  void _navigateToOnboarding(Authenticated state) {
    if (state.role == UserRole.bride) {
      context.goNamed(OnboardingBridesPage.routeName);
    } else {
      // Pro doesn't have onboarding in app
      context.goNamed(DashboardProPage.routeName);
    }
  }

  void _navigateToHome(Authenticated state) {
    if (state.role == UserRole.bride) {
      context.goNamed(HomeBridesPage.routeName);
    } else {
      context.goNamed(DashboardProPage.routeName);
    }
  }
}
```

### Terms of Service Sheet
```dart
class TermsOfServiceSheet extends StatefulWidget {
  const TermsOfServiceSheet({super.key});

  @override
  State<TermsOfServiceSheet> createState() => _TermsOfServiceSheetState();
}

class _TermsOfServiceSheetState extends State<TermsOfServiceSheet> {
  bool _accepted = false;
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);

    final authRepo = getIt<AuthRepository>();
    final result = await authRepo.acceptTerms();

    result.when(
      success: (_) {
        Navigator.of(context).pop(true);
      },
      failure: (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Terms of Service',
                  style: context.textTheme.titleLarge,
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    // Terms content
                    '...',
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _accepted,
                      onChanged: (value) => setState(() => _accepted = value ?? false),
                      title: const Text('I accept the Terms of Service and Privacy Policy'),
                    ),
                    const SizedBox(height: 16),
                    LynewedButton(
                      text: 'Continue',
                      onPressed: _accepted && !_isLoading ? _handleAccept : null,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Route Guard Integration
```dart
// Dans router configuration
GoRouter(
  initialLocation: StartupGatePage.routePath,
  redirect: (context, state) {
    // La redirection est geree par StartupGatePage
    // Mais on peut ajouter des guards ici si necessaire
    return null;
  },
  routes: [
    GoRoute(
      path: StartupGatePage.routePath,
      name: StartupGatePage.routeName,
      builder: (context, state) => const StartupGatePage(),
    ),
    // ... autres routes
  ],
)
```

## Definition of Done

- [ ] StartupGatePage refactoree
- [ ] Logic auth state handling
- [ ] Terms of Service sheet
- [ ] Session data loading
- [ ] Routing conditionnel (bride/pro, onboarding)
- [ ] Tests integration
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Eleve (point d'entree critique)

## Dependances

- S03 : Design system
- S04 : Navigation
- S13 : Auth - Presentation setup
- S14 : Auth - Login/Signup

## Stories Dependantes

- Toutes les pages qui dependent de l'auth state
