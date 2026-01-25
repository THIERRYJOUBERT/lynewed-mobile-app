# Story S01: Setup Infrastructure et Conventions

## Description

En tant que developpeur, je veux mettre en place l'infrastructure de base et les conventions pour la migration Clean Architecture afin de garantir une coherence dans tout le projet.

## Criteres d'Acceptance (Gherkin)

- [x] Given le projet actuel When je cree le dossier `lib/core/` Then il contient les sous-dossiers `error/`, `utils/`, `di/`

- [x] Given le dossier `lib/core/error/` When je cree les classes d'erreur Then `Failure` et `Exception` custom sont disponibles pour tous les modules

- [x] Given le dossier `lib/core/utils/` When je cree les utilitaires Then `Result<T>` (Either pattern simplifie) est disponible

- [x] Given le dossier `lib/core/di/` When je configure l'injection de dependances Then les repositories peuvent etre injectes dans toute l'app

- [x] Given la configuration When je lance `flutter analyze --fatal-infos` Then 0 warnings sont reportes

## Fichiers Concernes

### A Creer
- `lib/core/core.dart` - Barrel export
- `lib/core/error/failures.dart` - Classes Failure
- `lib/core/error/exceptions.dart` - Classes Exception custom
- `lib/core/utils/result.dart` - Result<T, E> pattern
- `lib/core/utils/typedefs.dart` - Typedefs communs
- `lib/core/di/injection_container.dart` - Service locator setup

### A Modifier
- `lib/main.dart` - Initialisation DI

## Notes Techniques

### Pattern Result
```dart
/// Simplified Either/Result pattern
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
```

### Failures
```dart
abstract class AppFailure {
  final String message;
  final String? code;
  const AppFailure(this.message, {this.code});
}

class ServerFailure extends AppFailure { ... }
class CacheFailure extends AppFailure { ... }
class NetworkFailure extends AppFailure { ... }
class ValidationFailure extends AppFailure { ... }
```

### Injection de Dependances
Utiliser `get_it` (deja present) ou Provider pour l'injection :
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // Datasources
  sl.registerLazySingleton<ChatRemoteDatasource>(() => ChatRemoteDatasourceImpl());
}
```

## Definition of Done

- [x] Structure `lib/core/` creee et documentee
- [x] Classes Failure et Exception implementees
- [x] Pattern Result disponible
- [x] DI configure et fonctionnel
- [x] Tests unitaires pour Result
- [x] `flutter analyze --fatal-infos` passe
- [x] Documentation dans le barrel export

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- Aucune (story de fondation)

## Stories Dependantes

- Toutes les autres stories dependent de celle-ci
