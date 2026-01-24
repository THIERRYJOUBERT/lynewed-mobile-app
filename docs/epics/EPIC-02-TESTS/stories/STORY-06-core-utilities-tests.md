# Story STORY-06: Tests Core Utilities

## Description

En tant que developpeur, je veux avoir des tests unitaires pour les utilitaires Core afin de garantir la fiabilite des services de formatage (budget, distance) et des constantes.

## Points : 3

## Priorite : Moyenne

## Fichiers source a tester

### Core Utils

| Fichier | Composant | Responsabilite |
|---------|-----------|----------------|
| `lib/core/utils/budget_formatter.dart` | BudgetFormatter | Formatage montants avec conversion devise |
| `lib/core/utils/distance_formatter.dart` | DistanceFormatter | Formatage distances (si existe) |
| `lib/core/utils/video_url_helpers.dart` | Video URL helpers | Helpers pour URLs video |

### Core Services

| Fichier | Composant | Responsabilite |
|---------|-----------|----------------|
| `lib/core/services/distance_service.dart` | DistanceService | Conversion km/miles, formatage |
| `lib/core/services/currency_service.dart` | CurrencyService | Conversion devises |

### Core Constants

| Fichier | Composant | Responsabilite |
|---------|-----------|----------------|
| `lib/core/constants/currencies.dart` | CurrencyData | Donnees devises (symbols, rates) |
| `lib/core/constants/country_coordinates.dart` | CountryCoordinates | Coordonnees pays |

## Criteres d'Acceptance

### AC1: Tests BudgetFormatter
- [ ] Test `formatAmount()` avec conversion devise
- [ ] Test `formatAmount()` meme devise (pas de conversion)
- [ ] Test `format()` range min-max
- [ ] Test `_formatNumber()` avec suffix k pour milliers
- [ ] Test edge cases (0, negatifs, tres grands nombres)

### AC2: Tests DistanceService
- [ ] Test `kmToMiles()` conversion correcte
- [ ] Test `milesToKm()` conversion correcte
- [ ] Test `formatDistance()` avec km
- [ ] Test `formatDistance()` avec miles
- [ ] Test `formatDistance()` petites distances (metres/feet)
- [ ] Test `formatDistanceRange()`
- [ ] Test `sliderStep` et `maxSliderValue` selon unite
- [ ] Test extension `toFormattedDistance()`

### AC3: Tests CurrencyData
- [ ] Test `getSymbol()` pour devises connues (EUR, USD, GBP)
- [ ] Test `getSymbol()` pour devise inconnue (fallback)
- [ ] Test structure des rates si expose

### AC4: Tests Video URL Helpers
- [ ] Test extraction YouTube ID
- [ ] Test extraction Vimeo ID
- [ ] Test URLs invalides

### AC5: Qualite des tests
- [ ] Coverage > 70% sur core/utils/
- [ ] Coverage > 70% sur core/services/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 3s

## Fichiers de Test a Creer

```
test/core/
├── utils/
│   ├── budget_formatter_test.dart
│   └── video_url_helpers_test.dart
├── services/
│   ├── distance_service_test.dart
│   └── currency_service_test.dart
└── constants/
    └── currencies_test.dart
```

## Notes Techniques

### Tests sans dependances externes

Les utilitaires Core sont principalement des fonctions pures, ideales pour les tests unitaires.

### Pattern de test pour DistanceService

```dart
void main() {
  group('DistanceService', () {
    late DistanceService service;

    setUp(() {
      service = DistanceService.instance;
    });

    group('conversions', () {
      test('kmToMiles should convert correctly', () {
        // 10 km = 6.21371 miles
        expect(service.kmToMiles(10), closeTo(6.21, 0.01));
      });

      test('milesToKm should convert correctly', () {
        // 10 miles = 16.0934 km
        expect(service.milesToKm(10), closeTo(16.09, 0.01));
      });

      test('round trip conversion should be consistent', () {
        const originalKm = 100.0;
        final miles = service.kmToMiles(originalKm);
        final backToKm = service.milesToKm(miles);
        expect(backToKm, closeTo(originalKm, 0.01));
      });
    });

    group('formatDistance', () {
      test('should format large distances without decimals', () {
        // Assuming km mode
        final formatted = service.formatDistance(150);
        expect(formatted, contains('150'));
      });

      test('should show meters for distances < 1km', () {
        final formatted = service.formatDistance(0.5);
        expect(formatted, contains('500'));
        expect(formatted, contains('m'));
      });
    });

    group('slider configuration', () {
      test('sliderStep should be 10 for km', () {
        // Note: depends on user preferences
        // May need to mock FFAppState
      });
    });
  });
}
```

### Pattern de test pour BudgetFormatter

```dart
void main() {
  group('BudgetFormatter', () {
    group('_formatNumber', () {
      test('should format thousands with k suffix', () {
        // Access via reflection or test through public API
        final formatted = BudgetFormatter.formatAmount(
          5000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(formatted, contains('5k'));
      });

      test('should not use k suffix for small numbers', () {
        final formatted = BudgetFormatter.formatAmount(
          500,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(formatted, contains('500'));
        expect(formatted, isNot(contains('k')));
      });
    });

    group('currency conversion', () {
      test('same currency should not show approximation symbol', () {
        final formatted = BudgetFormatter.formatAmount(
          1000,
          sourceCurrency: 'EUR',
          displayCurrency: 'EUR',
        );
        expect(formatted, isNot(startsWith('≈')));
      });

      test('different currency should show approximation symbol', () {
        final formatted = BudgetFormatter.formatAmount(
          1000,
          sourceCurrency: 'EUR',
          displayCurrency: 'USD',
        );
        // Si conversion reussie, devrait avoir ≈
        // Sinon fallback a la devise source
      });
    });
  });
}
```

### Mocking FFAppState

Certains services dependent de FFAppState pour les preferences utilisateur. Options :

1. **Test avec valeurs par defaut** : Ne pas mocker, utiliser les defaults
2. **Injection de dependances** : Refactorer pour injecter les preferences
3. **Test de la logique pure** : Tester les methodes qui ne dependent pas de l'etat

```dart
// Option pragmatique : tester les conversions pures
test('kmToMiles should be pure function', () {
  // Cette methode ne depend pas de FFAppState
  expect(DistanceService.kmToMilesFactor, closeTo(0.621, 0.001));
});
```

## Definition of Done

- [ ] Fichiers de test crees
- [ ] Tests sur fonctions pures (conversions, formatage)
- [ ] Tous les tests passent (`flutter test test/core/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] TRACKING.md mis a jour

## Estimation

- DistanceService tests : ~1h
- BudgetFormatter tests : ~1h
- Autres utils : ~30min
- Review : ~30min

**Total** : ~3h
