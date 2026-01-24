# Story S13: Auth - Presentation Layer Setup

## Description

En tant que developpeur, je veux mettre en place la couche presentation du module Auth avec le state management afin de gerer l'etat d'authentification de maniere reactive.

## Criteres d'Acceptance (Gherkin)

- [ ] Given le module Auth When je cree le state management Then `AuthCubit` gere l'etat d'authentification

- [ ] Given `AuthState` When je le definis Then tous les etats possibles sont couverts (initial, loading, authenticated, unauthenticated, error)

- [ ] Given `AuthCubit` When l'app demarre Then il verifie automatiquement l'etat d'authentification

- [ ] Given un changement d'auth state When il se produit Then l'app reagit correctement

- [ ] Given le provider When je l'integre Then `AuthCubit` est accessible partout dans l'app

## Fichiers Concernes

### A Creer
- `lib/features/auth/presentation/bloc/auth_cubit.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`
- `lib/features/auth/presentation/bloc/bloc.dart` - Barrel

### A Modifier
- `lib/main.dart` - Provider setup

## Notes Techniques

### Auth State
```dart
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final AuthUser user;
  final UserProfile? profile;

  const Authenticated({
    required this.user,
    this.profile,
  });

  bool get hasProfile => profile != null;
  bool get needsOnboarding => profile?.isOnboardingComplete == false;
  UserRole get role => profile?.role ?? UserRole.bride;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
```

### Auth Cubit
```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    _watchAuthState();
  }

  void _watchAuthState() {
    _authSubscription = _repository.watchAuthState().listen((user) async {
      if (user == null) {
        emit(const Unauthenticated());
      } else {
        await _loadProfile(user);
      }
    });
  }

  Future<void> _loadProfile(AuthUser user) async {
    final result = await _repository.getCurrentProfile();
    result.when(
      success: (profile) {
        emit(Authenticated(user: user, profile: profile));
      },
      failure: (failure) {
        // User authenticated but profile error
        emit(Authenticated(user: user, profile: null));
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());

    final result = await _repository.signInWithEmail(email, password);
    result.when(
      success: (user) async {
        await _loadProfile(user);
      },
      failure: (failure) {
        emit(AuthError(failure.message));
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthLoading());

    final result = await _repository.signUpBride(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.when(
      success: (user) async {
        await _loadProfile(user);
      },
      failure: (failure) {
        emit(AuthError(failure.message));
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const Unauthenticated());
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await _repository.getCurrentUser();
    result.when(
      success: (user) async {
        if (user == null) {
          emit(const Unauthenticated());
        } else {
          await _loadProfile(user);
        }
      },
      failure: (failure) {
        emit(const Unauthenticated());
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```

### Integration Main
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init dependencies
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            repository: getIt<AuthRepository>(),
          )..checkAuthStatus(),
        ),
        // ... autres providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### Auth Guard
```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? unauthenticatedChild;

  const AuthGuard({
    required this.child,
    this.unauthenticatedChild,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          return child;
        }

        return unauthenticatedChild ?? const AuthWelcomePage();
      },
    );
  }
}
```

## Definition of Done

- [ ] AuthState sealed class creee
- [ ] AuthCubit implemente
- [ ] Integration dans main.dart
- [ ] AuthGuard widget
- [ ] Tests bloc
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Eleve (auth = critique)

## Dependances

- S01 : Setup infrastructure
- S11 : Auth - Domain
- S12 : Auth - Data

## Stories Dependantes

- S14 : Auth - Login/Signup pages
- S15 : Auth - Password reset
- S16 : Auth - Startup gate
