# EPIC-02: Test Coverage Implementation

## Vue d'ensemble

Cet Epic a pour objectif d'ajouter une couverture de tests complete au projet Lynewed. Actuellement, seul le module `lib/features/map/` dispose de tests (7 fichiers dans `test/features/map/`). L'objectif est d'atteindre une couverture adequate sur les couches domain et data de tous les modules, ainsi que des widget tests pour les composants critiques.

## Objectifs

1. **Garantir la qualite du code** : Tests unitaires pour validation et logique metier
2. **Faciliter le refactoring** : Tests de non-regression
3. **Documenter le comportement** : Les tests servent de documentation executable
4. **Detecter les bugs** : Identifier les problemes avant la production

## Scope

### Modules a tester (par priorite)

| Priorite | Module | Type de tests |
|----------|--------|---------------|
| 1 | `lib/features/chat/` | Domain (entities, enums) + Data (repository) |
| 2 | `lib/features/notifications/` | Domain (entities) |
| 3 | `lib/features/my_wedding/` | Domain (entities) + Data (repository) |
| 4 | `lib/auth/` | Authentication flows |
| 5 | `lib/core/` | Utilities + Design system widgets |

### Structure de tests cible

```
test/
├── features/
│   ├── map/                    # EXISTANT - Reference
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── data/
│   │       └── repositories/
│   ├── chat/                   # A CREER
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── data/
│   │       └── repositories/
│   ├── notifications/          # A CREER
│   │   └── domain/
│   │       └── entities/
│   └── my_wedding/             # A CREER
│       ├── domain/
│       │   └── entities/
│       └── data/
│           └── repositories/
├── auth/                       # A CREER
│   └── auth_manager_test.dart
└── core/                       # A CREER
    ├── utils/
    └── design/
        └── widgets/
```

## Principes de test

### 1. Isolation des tests
- **Mocker Supabase** : Jamais de vrais appels reseau
- **Fixtures de test** : Donnees de test reutilisables
- **Tests independants** : Chaque test fonctionne seul

### 2. Structure de test (AAA)
```dart
test('description claire du comportement', () {
  // Arrange - Preparer les donnees
  final entity = MyEntity(id: 'test-id');

  // Act - Executer l'action
  final result = entity.doSomething();

  // Assert - Verifier le resultat
  expect(result, expectedValue);
});
```

### 3. Nommage des tests
- `should [action] when [condition]`
- Ou description directe du comportement

### 4. Performance
- Tests rapides (< 1s par test)
- Pas de sleep/delay dans les tests

## Reference : Tests existants (Map module)

Les tests du module Map servent de reference pour la structure et le style :

- `test/features/map/domain/entities/map_marker_test.dart`
- `test/features/map/domain/entities/map_filter_test.dart`
- `test/features/map/data/repositories/map_repository_test.dart`

## Criteres de succes

- [ ] Tous les tests passent (`flutter test`)
- [ ] Aucun warning (`flutter analyze --fatal-infos`)
- [ ] Coverage > 80% sur domain/entities
- [ ] Coverage > 60% sur data/repositories
- [ ] Tests rapides (suite complete < 30s)

## Stories

| ID | Story | Points | Statut |
|----|-------|--------|--------|
| STORY-01 | Tests Chat Module | 5 | TODO |
| STORY-02 | Tests Notifications Module | 2 | TODO |
| STORY-03 | Tests My Wedding Domain | 5 | TODO |
| STORY-04 | Tests My Wedding Data | 5 | TODO |
| STORY-05 | Tests Auth Module | 3 | TODO |
| STORY-06 | Tests Core Utilities | 3 | TODO |
| STORY-07 | Tests Core Design Widgets | 3 | TODO |

**Total** : 26 points

## Dependances

- Aucune dependance externe
- Utilise les packages de test existants (flutter_test, mocktail)

## Notes techniques

### Packages de test recommandes

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # Pour les mocks
```

### Pattern de mock pour Supabase

```dart
class MockSupabaseDatasource extends Mock implements SomeDatasource {}

void main() {
  late MockSupabaseDatasource mockDatasource;
  late SomeRepository repository;

  setUp(() {
    mockDatasource = MockSupabaseDatasource();
    repository = SomeRepositoryImpl(datasource: mockDatasource);
  });

  test('should return data when datasource succeeds', () async {
    when(() => mockDatasource.getData()).thenAnswer((_) async => testData);

    final result = await repository.getData();

    expect(result.isSuccess, true);
    verify(() => mockDatasource.getData()).called(1);
  });
}
```

## Timeline estimee

- **Semaine 1** : Stories 01-02 (Chat + Notifications)
- **Semaine 2** : Stories 03-04 (My Wedding)
- **Semaine 3** : Stories 05-07 (Auth + Core)

---

*Epic cree le : 2025-01-24*
*Product Manager : Claude*
