# S06 - Frais de port dynamiques FedEx

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : API
> **Complexite** : L (9 points) - **RE-ESTIMATED apres re-challenge (etait 8 SP)**
> **Status** : Done (2026-02-16)
> **Source** : BUG-03
> **Dependances** : S01 (FedEx OAuth fonctionnel - testable via AC-0)

---

## RESUME CORRECTIONS POST-RE-CHALLENGE

**Date re-challenge** : 2026-02-16

**Problemes detectes** (4 BLOQUANTS + 1 MAJEUR) :

1. **BLOQUANT** : Entity `MarketplaceListing` incomplete
   - Champ `weightKg` totalement absent (field, fromJson, toJson, copyWith)
   - Migration DB va creer colonne mais app ne peut pas lire/ecrire
   - Impact : 6 tests entity manquants

2. **BLOQUANT** : Use case `CalculateShippingRateUseCase` incompatible
   - Retourne `Future<List>` au lieu de `Either<Failure, List>`
   - Code story utilise `.fold()` → ne compile pas
   - Param `weightKg` absent
   - Impact : 3 tests a refactorer + signature interface/repository a modifier

3. **BLOQUANT** : Tests checkout fallback manquants
   - Fichier test checkout contient 0 tests de fallback FedEx
   - 4 tests critiques absents (API error, rates vide, seller KO, buyer KO)
   - Impact : DoD impossible a valider

4. **MAJEUR** : Validator poids UI fantome
   - Fonction `_validateWeight()` referencee mais jamais definie
   - User peut saisir 0 ou 100 kg → crash DB constraint
   - Impact : 8 tests validation manquants + UX degradee

**Actions prises** :

- Estimation corrigee : 8 SP → **9 SP**
- Section "CORRECTIONS POST-CHALLENGE" ajoutee avec code exact requis
- Tests manquants documentes (18 nouveaux tests vs 22 promises)
- Recommendation ajoutee : **split en S06a (Poids, 3 SP) + S06b (Checkout, 6 SP)**

**Fichiers impactes** : 7 (vs 5 initial)

**Decision** : Story reste **Draft** jusqu'a validation explicite de la strategie de split.

---

## Contexte

Le checkout marketplace utilise actuellement un systeme flat-rate statique ($15 domestic, $25 same region, $35 international) qui ne reflete pas les couts reels d'expedition. L'Edge Function `fedex-calculate-rate` et le use case `CalculateShippingRateUseCase` existent deja mais ne sont pas branches dans le flow checkout. De plus, le vendeur ne peut pas renseigner le poids de l'article, information necessaire pour un calcul FedEx precis.

**Objectif** : Brancher le calcul dynamique FedEx dans le checkout et permettre au vendeur de renseigner le poids.

**CHANGEMENT CRITIQUE (Instruction Leo)** : **PAS DE FALLBACK FLAT-RATE**. Si FedEx echoue, afficher "Unable to calculate shipping. Please try again." avec bouton Retry. Raison : les flat-rate ($15/$25/$35) ne couvrent pas les couts reels et causent des pertes d'argent. FedEx DOIT fonctionner ou le checkout est bloque.

**Prerequis** : S01 (FedEx OAuth) doit etre validé en production avant de commencer cette story.

---

## User Stories

**En tant que** acheteuse sur le marketplace,
**je veux** voir les frais de port reels calcules par FedEx au checkout,
**afin de** connaitre le cout exact de l'expedition avant de payer.

**En tant que** vendeuse sur le marketplace,
**je veux** renseigner le poids de mon article lors de la creation du listing,
**afin que** les frais de port calcules soient precis.

---

## Criteres d'Acceptance

### AC-0 : Prerequis FedEx OAuth (PREREQUISITE)

```gherkin
Given S01 est completee et deployee en production
When je teste l'authentification FedEx avec curl
Then je recois un access_token valide
And la commande suivante retourne un token :
  curl -X POST https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-calculate-rate \
    -H "Authorization: Bearer <anon_key>" \
    -H "Content-Type: application/json" \
    -d '{"from_address":{"countryCode":"US"},"to_address":{"countryCode":"US"},"category":"dress"}'
And le status HTTP est 200 ou 400 (pas 401/500)
```

### AC-1 : Champ poids sur le formulaire de creation de listing

```gherkin
Given je suis sur la page "Create Listing"
When je remplis le formulaire
Then je vois un champ "Weight (kg)" dans la section Details
And le champ accepte des valeurs decimales entre 0.1 et 50.0
And le champ affiche un hint avec le poids par defaut de la categorie

Given je suis sur la page "Create Listing"
And j'ai selectionne la categorie "Dress"
When je ne renseigne pas le poids
Then le placeholder affiche "Default: 3.0 kg"
And le listing est sauvegarde avec weight_kg = null (le backend utilisera le defaut)

Given je suis sur la page "Create Listing"
And j'ai selectionne la categorie "Shoes"
When je ne renseigne pas le poids
Then le placeholder affiche "Default: 2.0 kg"
```

### AC-2 : Calcul dynamique FedEx au checkout

```gherkin
Given je suis au checkout (step Address -> Review)
And l'API FedEx est disponible
When je valide mon adresse et passe au step Review
Then le systeme appelle CalculateShippingRateUseCase avec :
  - fromAddress = adresse du vendeur (depuis son profil)
  - toAddress = adresse saisie par l'acheteuse
  - category = categorie du listing
And un loading spinner s'affiche pendant le calcul
And les tarifs FedEx disponibles s'affichent via ShippingRateSelector
And je peux selectionner un service (ex: FedEx Ground, FedEx Express)
And le total se recalcule avec le tarif selectionne
```

### AC-3 : Erreur FedEx → message retry (PAS DE FALLBACK FLAT-RATE)

```gherkin
Given je suis au checkout step Review
And l'API FedEx retourne une erreur (timeout, 500, credentials invalides)
When le calcul dynamique echoue
Then le systeme affiche un message "Unable to calculate shipping costs. Please try again."
And un bouton "Retry" est visible
And le bouton "Continue to Payment" est DESACTIVE (checkout bloque)
And un log d'erreur est envoye cote client

Given je suis au checkout step Review
And l'API FedEx retourne une liste vide de tarifs
When aucun tarif n'est disponible
Then le meme message d'erreur avec bouton Retry est affiche

Given je suis au checkout step Review
And l'adresse vendeur n'a pas de countryCode ou est absente
When le systeme tente de calculer les tarifs FedEx
Then un message "Seller shipping address is incomplete. Please contact the seller." s'affiche
And le checkout est bloque (pas de bouton Retry car probleme cote vendeur)

Given je suis au checkout step Review
And l'adresse acheteuse n'a pas de postalCode
When le systeme valide les adresses avant appel FedEx
Then un message d'erreur s'affiche demandant de completer l'adresse
And l'utilisateur est redirige vers le step Address pour corriger
```

**IMPORTANT (Instruction Leo)** : PAS de fallback flat-rate. Les tarifs fixes ($15/$25/$35) ne couvrent pas les couts reels → perte d'argent. FedEx DOIT fonctionner ou l'utilisateur doit reessayer.

### AC-4 : Poids par defaut par categorie

```gherkin
Given un listing de categorie "dress" sans weight_kg renseigne
When le systeme appelle fedex-calculate-rate
Then le poids utilise est 3.0 kg
And les dimensions sont 60x40x20 cm

Given un listing de categorie "shoes" sans weight_kg renseigne
When le systeme appelle fedex-calculate-rate
Then le poids utilise est 2.0 kg
And les dimensions sont 35x25x15 cm

Given un listing avec weight_kg = 4.5
When le systeme appelle fedex-calculate-rate
Then le poids utilise est 4.5 kg
And les dimensions restent celles par defaut de la categorie
```

### AC-5 : Persistance du poids en base de donnees

```gherkin
Given je cree un listing avec un poids de 2.5 kg
When je publie le listing
Then la colonne weight_kg de marketplace_listings contient 2.5

Given je cree un listing sans renseigner le poids
When je publie le listing
Then la colonne weight_kg de marketplace_listings contient null
And le backend utilise le defaut de la categorie pour les calculs
```

### AC-6 : Validation du champ poids

```gherkin
Given je suis sur le formulaire de creation
When je saisis un poids de 0 ou negatif
Then un message d'erreur "Weight must be between 0.1 and 50 kg" s'affiche

When je saisis un poids de 55
Then un message d'erreur "Weight must be between 0.1 and 50 kg" s'affiche

When je saisis un poids de 2.5
Then aucune erreur ne s'affiche
And le champ est valide
```

---

## CORRECTIONS POST-CHALLENGE (CRITIQUE)

### Probleme 1 : Entity MarketplaceListing manquante champ weightKg (BLOQUANT)

**Constat** : Le fichier actuel `lib/features/marketplace/domain/entities/marketplace_listing.dart` ne contient PAS le champ `weightKg`.

**Impact** :
- Migration DB va creer colonne `weight_kg` mais l'app ne pourra pas la lire
- `fromJson()` ne deserialise pas le champ → `weightKg` toujours null meme si renseigne en BDD
- `toJson()` ne serialise pas le champ → impossible de persister via l'app
- `copyWith()` ne preserve pas le champ → perte de donnee lors de modifications

**Corrections requises** :

1. **Ajouter field dans constructor** :
```dart
class MarketplaceListing {
  // ...champs existants...

  /// Item weight in kilograms (optional).
  ///
  /// If null, FedEx API will use category defaults:
  /// - dress: 3.0 kg
  /// - shoes: 2.0 kg
  ///
  /// Valid range: 0.1 - 50.0 kg (enforced by DB constraint).
  final double? weightKg;

  const MarketplaceListing({
    // ...params existants...
    this.weightKg,
  });
```

2. **Mettre a jour fromJson()** :
```dart
factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
  // ...code existant...

  return MarketplaceListing(
    // ...fields existants...
    weightKg: json['weight_kg'] != null
        ? double.parse(json['weight_kg'].toString())
        : null,
  );
}
```

3. **Mettre a jour toJson()** :
```dart
Map<String, dynamic> toJson() {
  return {
    // ...fields existants...
    if (weightKg != null) 'weight_kg': weightKg,
  };
}
```

4. **Mettre a jour copyWith()** :
```dart
MarketplaceListing copyWith({
  // ...params existants...
  double? weightKg,
}) {
  return MarketplaceListing(
    // ...fields existants...
    weightKg: weightKg ?? this.weightKg,
  );
}
```

**Specs completes des 6 tests entity manquants** :

```dart
// Dans test/features/marketplace/domain/entities/marketplace_listing_test.dart

group('weightKg field', () {
  test('toJson should include weight_kg when non-null', () {
    final listing = MarketplaceListing(
      id: 'id',
      sellerId: 'seller',
      title: 'Dress',
      category: 'dress',
      priceCents: 10000,
      condition: 'excellent',
      country: 'France',
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      weightKg: 2.5,
    );

    final json = listing.toJson();

    expect(json['weight_kg'], 2.5);
  });

  test('toJson should exclude weight_kg when null', () {
    final listing = MarketplaceListing(
      id: 'id',
      sellerId: 'seller',
      title: 'Dress',
      category: 'dress',
      priceCents: 10000,
      condition: 'excellent',
      country: 'France',
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      weightKg: null,
    );

    final json = listing.toJson();

    expect(json.containsKey('weight_kg'), false);
  });

  test('fromJson should parse weight_kg when null', () {
    final json = {
      'id': 'id',
      'seller_id': 'seller',
      'title': 'Dress',
      'category': 'dress',
      'price_cents': 10000,
      'condition': 'excellent',
      'country': 'France',
      'status': 'active',
      'created_at': '2025-01-01T00:00:00Z',
      'updated_at': '2025-01-01T00:00:00Z',
      // weight_kg absent
    };

    final listing = MarketplaceListing.fromJson(json);

    expect(listing.weightKg, isNull);
  });

  test('fromJson should parse weight_kg when non-null', () {
    final json = {
      'id': 'id',
      'seller_id': 'seller',
      'title': 'Dress',
      'category': 'dress',
      'price_cents': 10000,
      'condition': 'excellent',
      'country': 'France',
      'status': 'active',
      'created_at': '2025-01-01T00:00:00Z',
      'updated_at': '2025-01-01T00:00:00Z',
      'weight_kg': 3.5,
    };

    final listing = MarketplaceListing.fromJson(json);

    expect(listing.weightKg, 3.5);
  });

  test('copyWith should preserve weightKg when not provided', () {
    final original = MarketplaceListing(
      id: 'id',
      sellerId: 'seller',
      title: 'Dress',
      category: 'dress',
      priceCents: 10000,
      condition: 'excellent',
      country: 'France',
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      weightKg: 2.5,
    );

    final updated = original.copyWith(title: 'New Dress');

    expect(updated.weightKg, 2.5);
  });

  test('copyWith should override weightKg when provided', () {
    final original = MarketplaceListing(
      id: 'id',
      sellerId: 'seller',
      title: 'Dress',
      category: 'dress',
      priceCents: 10000,
      condition: 'excellent',
      country: 'France',
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      weightKg: 2.5,
    );

    final updated = original.copyWith(weightKg: 4.0);

    expect(updated.weightKg, 4.0);
  });
});
```

---

### Probleme 2 : Use case CalculateShippingRate incompatible avec pattern Either (BLOQUANT)

**Constat** : Le fichier actuel `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart` :
- Retourne `Future<List<ShippingRate>>` (throws exceptions)
- Code story utilise `.fold()` → necessite `Either<Failure, List<ShippingRate>>`
- Pas de param `weightKg`

**Impact** :
- Code checkout impossible a implementer comme specifie (`.fold()` ne compile pas)
- Impossible de passer poids custom au vendeur
- Pattern inconsistent avec reste de l'app (Clean Architecture utilise Either)

**Corrections requises** :

1. **Ajouter import Either** :
```dart
import 'package:dartz/dartz.dart';
import '/core/error/failures.dart';
```

2. **Modifier signature call()** :
```dart
Future<Either<Failure, List<ShippingRate>>> call({
  required ShippingAddress fromAddress,
  required ShippingAddress toAddress,
  required String category,
  double? weightKg, // NOUVEAU
}) async {
  try {
    final rates = await _repository.calculateRates(
      fromAddress: fromAddress,
      toAddress: toAddress,
      category: category,
      weightKg: weightKg,
    );
    return Right(rates);
  } catch (e) {
    return Left(ServerFailure('Failed to calculate shipping rates: $e'));
  }
}
```

3. **Modifier repository interface** (`fedex_repository.dart`) :
```dart
abstract class FedExRepository {
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
    double? weightKg, // NOUVEAU
  });
  // ...autres methodes inchangees...
}
```

4. **Modifier repository implementation** (`fedex_repository_impl.dart`) :
```dart
@override
Future<List<ShippingRate>> calculateRates({
  required ShippingAddress fromAddress,
  required ShippingAddress toAddress,
  required String category,
  double? weightKg,
}) async {
  final body = {
    'from_address': fromAddress.toJson(),
    'to_address': toAddress.toJson(),
    'category': category,
    if (weightKg != null) 'weight_kg': weightKg,
  };
  // ...reste du code...
}
```

**Tests a mettre a jour** : Voir section Tests ci-dessous.

---

### Probleme 3 : Tests checkout fallback manquants (BLOQUANT)

**Constat** : Le fichier actuel `test/features/marketplace/presentation/pages/checkout_page_test.dart` contient 0 tests de fallback FedEx.

**Impact** :
- Comportement critique non teste (8 scenarios de fallback)
- Risque de regression lors de modifications
- DoD impossible a valider

**Tests manquants** :

| Test | Description | Assertion |
|------|-------------|-----------|
| `should show retry error when FedEx API throws` | Mock repository.calculateRates() throws exception | Verify error message + Retry button + payment button disabled |
| `should show retry error when FedEx returns empty list` | Mock repository.calculateRates() returns [] | Verify error message + Retry button + payment button disabled |
| `should show seller error when seller address invalid` | Mock GetSellerShippingAddress returns Left(ValidationFailure) | Verify seller error message + NO Retry button |
| `should redirect to address step when buyer address incomplete` | Buyer address missing postalCode | Verify redirect to address step |

**Structure test type** :
```dart
testWidgets('should show retry error when FedEx API throws', (tester) async {
  // Arrange
  final mockFedExRepo = MockFedExRepository();
  final mockGetSellerAddress = MockGetSellerShippingAddress();

  when(() => mockGetSellerAddress(any())).thenAnswer(
    (_) async => Right(validSellerAddress),
  );
  when(() => mockFedExRepo.calculateRates(
    fromAddress: any(named: 'fromAddress'),
    toAddress: any(named: 'toAddress'),
    category: any(named: 'category'),
    weightKg: any(named: 'weightKg'),
  )).thenThrow(Exception('FedEx API error'));

  await tester.pumpWidget(buildPage(
    fedExRepo: mockFedExRepo,
    getSellerAddress: mockGetSellerAddress,
  ));

  // Act
  await fillAddress(tester);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  // Assert - PAS DE FLAT-RATE, message erreur + retry
  expect(find.text('Unable to calculate shipping costs. Please try again.'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
  expect(find.text('Continue to Payment'), findsOneWidget);
  // Bouton payment DESACTIVE
  final paymentButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue to Payment'));
  expect(paymentButton.onPressed, isNull);
  verify(() => logger.warning(contains('FedEx API error'))).called(1);
});
```

**Note** : Cela necessite d'injecter les dependances via constructor de CheckoutPage au lieu de `sl<>()` direct pour permettre le mock en test.

**Specs completes des 4 tests checkout manquants** :

#### Test 1 : Error + Retry quand FedEx API throws

```dart
testWidgets('should show retry error when FedEx API throws', (tester) async {
  when(() => mockGetSellerAddress(any()))
      .thenAnswer((_) async => Right(validSellerAddress));
  when(() => mockFedExUseCase(
        fromAddress: any(named: 'fromAddress'),
        toAddress: any(named: 'toAddress'),
        category: any(named: 'category'),
        weightKg: any(named: 'weightKg'),
      )).thenAnswer((_) async => Left(ServerFailure('FedEx API timeout')));

  await tester.pumpWidget(buildPage());

  await fillAddress(tester);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  // Assert: error message + retry + payment blocked
  expect(find.text('Unable to calculate shipping costs. Please try again.'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
  expect(find.widgetWithText(ElevatedButton, 'Continue to Payment'), findsNothing);
});
```

#### Test 2 : Error + Retry quand rates liste vide

```dart
testWidgets('should show retry error when FedEx returns empty list', (tester) async {
  when(() => mockGetSellerAddress(any()))
      .thenAnswer((_) async => Right(validSellerAddress));
  when(() => mockFedExUseCase(
        fromAddress: any(named: 'fromAddress'),
        toAddress: any(named: 'toAddress'),
        category: any(named: 'category'),
        weightKg: any(named: 'weightKg'),
      )).thenAnswer((_) async => Right([]));

  await tester.pumpWidget(buildPage());

  await fillAddress(tester);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  expect(find.text('No shipping options available. Please try again.'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
});
```

#### Test 3 : Seller address invalid (pas de Retry)

```dart
testWidgets('should show seller error without retry when seller address invalid', (tester) async {
  when(() => mockGetSellerAddress(any())).thenAnswer(
    (_) async => Left(ValidationFailure('Seller address missing countryCode')),
  );

  await tester.pumpWidget(buildPage());

  await fillAddress(tester);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  expect(find.textContaining('Seller shipping address'), findsOneWidget);
  expect(find.text('Retry'), findsNothing); // Pas de retry pour probleme seller
  verifyNever(() => mockFedExUseCase(
        fromAddress: any(named: 'fromAddress'),
        toAddress: any(named: 'toAddress'),
        category: any(named: 'category'),
        weightKg: any(named: 'weightKg'),
      ));
});
```

#### Test 4 : Buyer address incomplete → retour step Address

```dart
testWidgets('should redirect to address step when buyer address incomplete', (tester) async {
  await tester.pumpWidget(buildPage());

  // Remplir adresse SANS postalCode
  await tester.enterText(find.widgetWithText(TextField, 'Full Name *'), 'Jane Doe');
  await tester.enterText(find.widgetWithText(TextField, 'Street Address'), '123 Main St');
  await tester.enterText(find.widgetWithText(TextField, 'City'), 'New York');
  // Pas de postalCode

  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  expect(find.textContaining('complete your shipping address'), findsOneWidget);
});
```

---

### Probleme 4 : Validator poids UI non implemente (MAJEUR)

**Constat** : La spec mentionne `validator: _validateWeight` mais la fonction n'est jamais definie.

**Impact** :
- User peut saisir 0, -1, ou 100 kg → violation constraint DB → crash
- Pas de feedback utilisateur en temps reel
- UX degradee

**Implementation requise** :

```dart
// Dans create_listing_page.dart
String? _validateWeight(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optionnel - OK
  }

  final weight = double.tryParse(value.trim());

  if (weight == null) {
    return 'Please enter a valid number';
  }

  if (weight < 0.1 || weight > 50.0) {
    return 'Weight must be between 0.1 and 50 kg';
  }

  return null; // Valide
}
```

**Tests a ajouter** :
```dart
group('weight validation', () {
  test('should accept null (optional field)', () {
    expect(_validateWeight(null), isNull);
  });

  test('should accept empty string (optional field)', () {
    expect(_validateWeight(''), isNull);
    expect(_validateWeight('  '), isNull);
  });

  test('should reject 0', () {
    expect(_validateWeight('0'), contains('between 0.1 and 50'));
  });

  test('should reject negative', () {
    expect(_validateWeight('-1'), contains('between 0.1 and 50'));
  });

  test('should accept 0.1 (min)', () {
    expect(_validateWeight('0.1'), isNull);
  });

  test('should accept 50 (max)', () {
    expect(_validateWeight('50'), isNull);
  });

  test('should reject 51', () {
    expect(_validateWeight('51'), contains('between 0.1 and 50'));
  });

  test('should reject non-numeric', () {
    expect(_validateWeight('abc'), contains('valid number'));
  });
});
```

---

## Specification Technique

### Fichiers a modifier

| Fichier | Action | Description |
|---------|--------|-------------|
| `lib/features/marketplace/presentation/pages/checkout_page.dart` | MODIFIER | Remplacer `_computeFlatRate()` par appel `CalculateShippingRateUseCase`, ajouter loading state, fallback, et `ShippingRateSelector` |
| `lib/features/marketplace/presentation/pages/create_listing_page.dart` | MODIFIER | Ajouter champ `LynewedTextField` pour le poids (section Details) + fonction `_validateWeight()` |
| `lib/features/marketplace/domain/entities/marketplace_listing.dart` | MODIFIER | **CRITIQUE**: Ajouter champ `double? weightKg` avec `toJson()`/`fromJson()`/`copyWith()` |
| `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart` | MODIFIER | **CRITIQUE**: Changer signature pour retourner `Either<Failure, List<ShippingRate>>` + ajouter param `weightKg` |
| `lib/features/marketplace/domain/usecases/get_seller_shipping_address.dart` | CREER | Use case pour recuperer l'adresse vendeur avec validation |
| `lib/features/marketplace/data/repositories/fedex_repository_impl.dart` | MODIFIER | Adapter `calculateRates()` pour passer `weightKg` a l'Edge Function |
| `lib/features/marketplace/data/sizes_data.dart` | CONSERVER | Utilise comme fallback (aucune modification) |

### Fichiers existants a brancher

| Fichier | Role | Modifications requises |
|---------|------|------------------------|
| `supabase/functions/fedex-calculate-rate/index.ts` | Edge Function - calcul rates | Accepter param `weight_kg` optionnel dans body |
| `supabase/functions/fedex-calculate-rate/fedex-client.ts` | Client FedEx OAuth + Rates API | Utiliser `weight_kg` si fourni au lieu du defaut categorie |
| `lib/features/marketplace/domain/repositories/fedex_repository.dart` | Interface repository | Ajouter param `double? weightKg` a `calculateRates()` |
| `lib/features/marketplace/presentation/widgets/shipping_rate_selector.dart` | Widget selection tarif | Aucune modification (pret) |
| `lib/features/marketplace/domain/entities/shipping_rate.dart` | Entity ShippingRate | Aucune modification (pret) |

### Use Case GetSellerShippingAddress

**Nouveau fichier** : `lib/features/marketplace/domain/usecases/get_seller_shipping_address.dart`

**Responsabilite** : Recuperer et valider l'adresse d'expedition du vendeur avant calcul FedEx.

**Interface** :

```dart
class GetSellerShippingAddress {
  final AuthRemoteDatasource authDataSource;

  GetSellerShippingAddress(this.authDataSource);

  Future<Either<Failure, ShippingAddress>> call(String sellerId) async {
    try {
      final profile = await authDataSource.getProfile(sellerId);

      if (profile == null) {
        return Left(ServerFailure('Seller profile not found'));
      }

      final shippingAddress = profile.shippingAddress;

      if (shippingAddress == null) {
        return Left(ValidationFailure('Seller shipping address not configured'));
      }

      // Validate required fields for FedEx API
      if (shippingAddress.countryCode == null || shippingAddress.countryCode!.isEmpty) {
        return Left(ValidationFailure('Seller address missing countryCode'));
      }

      if (shippingAddress.city == null || shippingAddress.city!.isEmpty) {
        return Left(ValidationFailure('Seller address missing city'));
      }

      if (shippingAddress.postalCode == null || shippingAddress.postalCode!.isEmpty) {
        return Left(ValidationFailure('Seller address missing postalCode'));
      }

      return Right(shippingAddress);
    } catch (e) {
      return Left(ServerFailure('Failed to retrieve seller address: $e'));
    }
  }
}
```

**Validation** :
- Profil vendeur existe
- `shippingAddress` non-null
- `countryCode` present et non-vide (OBLIGATOIRE pour FedEx)
- `city` present et non-vide
- `postalCode` present et non-vide

**Retour** :
- `Right(ShippingAddress)` si valide
- `Left(ValidationFailure)` si champ manquant
- `Left(ServerFailure)` si erreur reseau

**Usage dans checkout_page.dart** :

```dart
Future<void> _fetchFedExRates() async {
  setState(() {
    _isLoadingRates = true;
    _ratesError = null;
  });

  // 1. Get seller address
  final sellerAddressResult = await sl<GetSellerShippingAddress>()(widget.listing.sellerId);

  if (sellerAddressResult.isLeft()) {
    setState(() {
      _isLoadingRates = false;
      _ratesError = 'Seller shipping address is incomplete. Please contact the seller.';
      _canRetry = false; // Seller issue, retry won't help
    });
    return;
  }

  final sellerAddress = sellerAddressResult.getOrElse(() => throw Exception());

  // 2. Validate buyer address
  if (_buyerAddress.countryCode == null || _buyerAddress.postalCode == null) {
    setState(() {
      _isLoadingRates = false;
      _ratesError = 'Please complete your shipping address.';
      _canRetry = false; // Redirect to address step
    });
    return;
  }

  // 3. Call FedEx API
  final ratesResult = await sl<CalculateShippingRateUseCase>()(
    fromAddress: sellerAddress,
    toAddress: _buyerAddress,
    category: widget.listing.category,
    weightKg: widget.listing.weightKg,
  );

  ratesResult.fold(
    (failure) {
      logger.warning('FedEx API error: $failure');
      setState(() {
        _isLoadingRates = false;
        _ratesError = 'Unable to calculate shipping costs. Please try again.';
        _canRetry = true; // API issue, retry may work
      });
    },
    (rates) {
      if (rates.isEmpty) {
        setState(() {
          _isLoadingRates = false;
          _ratesError = 'No shipping options available. Please try again.';
          _canRetry = true;
        });
      } else {
        setState(() {
          _fedexRates = rates;
          _selectedRate = rates.first;
          _ratesError = null;
          _isLoadingRates = false;
        });
      }
    },
  );
}
```

**IMPORTANT** : PAS de `_fallbackToFlatRate()`. Le bouton "Continue to Payment" est DESACTIVE tant que `_ratesError != null`. Si `_canRetry == true`, afficher bouton "Retry".

### Migration Supabase requise

```sql
-- Ajouter colonne weight_kg a marketplace_listings
ALTER TABLE marketplace_listings
  ADD COLUMN IF NOT EXISTS weight_kg DOUBLE PRECISION
  CHECK (weight_kg IS NULL OR (weight_kg >= 0.1 AND weight_kg <= 50.0));

-- Commentaire
COMMENT ON COLUMN marketplace_listings.weight_kg IS 'Item weight in kg, null = use category default (dress=3kg, shoes=2kg). Valid range: 0.1-50.0 kg';
```

### Poids et dimensions par defaut (Edge Function)

Ces valeurs sont deja definies dans `fedex-calculate-rate/index.ts` :

| Categorie | Poids (kg) | Dimensions (cm) |
|-----------|------------|------------------|
| dress | 3.0 | 60 x 40 x 20 |
| shoes | 2.0 | 35 x 25 x 15 |
| accessories | 1.0 | 30 x 20 x 10 |
| decoration | 5.0 | 50 x 50 x 30 |

### Flow checkout modifie

```
Step 0 (Address)          Step 1 (Review)                    Step 2 (Confirm)
┌─────────────┐    ┌──────────────────────────┐    ┌────────────────────┐
│ Saisie      │    │ 1. Loading spinner       │    │ CGVU + Pay         │
│ adresse     │───>│ 2. Appel FedEx Rates API │───>│                    │
│ acheteuse   │    │ 3a. OK: ShippingRate      │    │                    │
│             │    │    Selector (choix)       │    │                    │
│             │    │ 3b. KO: Flat-rate auto    │    │                    │
│             │    │ 4. Total recalcule        │    │                    │
└─────────────┘    └──────────────────────────┘    └────────────────────┘
```

### Changements dans checkout_page.dart

1. **Ajouter dependances** :
   - Injecter `CalculateShippingRateUseCase` via `sl<>()`
   - Injecter `GetSellerShippingAddress` via `sl<>()`

2. **Nouveau state** :
   - `List<ShippingRate> _fedexRates = []`
   - `ShippingRate? _selectedRate` (remplace `_flatRate`)
   - `bool _isLoadingRates = false`
   - `String? _ratesError`
   - `bool _canRetry = false`

3. **Nouveau flow** dans `_nextStep()` (step 0 -> 1) :
   - Appeler `_fetchFedExRates()` au lieu de `_computeFlatRate()`
   - Si succes : afficher `ShippingRateSelector` avec les rates
   - Si echec : afficher message erreur + bouton Retry (PAS de flat-rate fallback)

4. **Review step** : Afficher `ShippingRateSelector` avec rates FedEx. Si erreur, afficher message retry et bloquer checkout.

5. **Gestion erreurs complete** : 9 scenarios documentes (voir tableau "Strategie Erreur FedEx - Retry")

### Edge Cases a Gerer (CRITIQUE)

**Table de decision complete** :

| Condition | Validation | Resultat | Retry ? | Log |
|-----------|------------|----------|---------|-----|
| `profile == null` | `GetSellerShippingAddress` | Error: "Seller address incomplete" | NON | "Seller profile not found" |
| `shippingAddress == null` | `GetSellerShippingAddress` | Error: "Seller address incomplete" | NON | "Seller shipping address not configured" |
| `countryCode == null` | `GetSellerShippingAddress` | Error: "Seller address incomplete" | NON | "Seller address missing countryCode" |
| `city == null` | `GetSellerShippingAddress` | Error: "Seller address incomplete" | NON | "Seller address missing city" |
| `postalCode == null` | `GetSellerShippingAddress` | Error: "Seller address incomplete" | NON | "Seller address missing postalCode" |
| `_buyerAddress.countryCode == null` | `checkout_page._fetchFedExRates()` | Error: "Complete your address" | NON (retour step Address) | "Buyer address incomplete" |
| `_buyerAddress.postalCode == null` | `checkout_page._fetchFedExRates()` | Error: "Complete your address" | NON (retour step Address) | "Buyer address incomplete" |
| FedEx API throws | `ratesResult.isLeft()` | Error: "Unable to calculate. Try again." | **OUI** | "FedEx API error: $failure" |
| FedEx API returns [] | `rates.isEmpty` | Error: "No shipping options. Try again." | **OUI** | "No FedEx rates available" |

**IMPORTANT (Instruction Leo)** : PAS DE FLAT-RATE FALLBACK. Chaque erreur DOIT :
1. Logger la raison precise avec `logger.warning()`
2. Setter `_ratesError` avec message utilisateur clair
3. Setter `_canRetry` selon le type d'erreur
4. **BLOQUER le checkout** tant que les frais ne sont pas calcules (bouton payment DESACTIVE)

### Changements dans create_listing_page.dart

1. **Ajouter controller** : `_weightController = TextEditingController()`

2. **Ajouter fonction validation** :
   ```dart
   String? _validateWeight(String? value) {
     if (value == null || value.trim().isEmpty) {
       return null; // Optionnel - OK
     }

     final weight = double.tryParse(value.trim());

     if (weight == null) {
       return 'Please enter a valid number';
     }

     if (weight < 0.1 || weight > 50.0) {
       return 'Weight must be between 0.1 and 50 kg';
     }

     return null; // Valide
   }
   ```

3. **Ajouter dans section Details** (apres Condition, avant Sleeve Length) :
   ```dart
   LynewedTextField(
     controller: _weightController,
     label: 'Weight (kg)',
     hint: 'Default: ${_selectedCategory == 'shoes' ? '2.0' : '3.0'} kg',
     keyboardType: TextInputType.numberWithOptions(decimal: true),
     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
     validator: _validateWeight,
   )
   ```

4. **Persistance** : Inclure `weightKg` dans le `MarketplaceListing` a la creation :
   ```dart
   final listing = MarketplaceListing(
     // ...autres champs...
     weightKg: _weightController.text.trim().isEmpty
         ? null
         : double.parse(_weightController.text.trim()),
   );
   ```

---

## Tests

### Tests unitaires

| Test | Fichier | Status |
|------|---------|--------|
| `GetSellerShippingAddress` retourne Right si adresse valide | `test/features/marketplace/domain/usecases/get_seller_shipping_address_test.dart` (NOUVEAU) | TODO |
| `GetSellerShippingAddress` retourne Left si countryCode manquant | Meme fichier | TODO |
| `GetSellerShippingAddress` retourne Left si shippingAddress null | Meme fichier | TODO |
| `GetSellerShippingAddress` retourne Left si profil vendeur null | Meme fichier | TODO |
| **`CalculateShippingRateUseCase` retourne Either (pas throws)** | `test/features/marketplace/domain/usecases/calculate_shipping_rate_use_case_test.dart` | **A REFACTORER** |
| **`CalculateShippingRateUseCase` appele avec param weightKg** | Meme fichier | **A AJOUTER** |
| **`CalculateShippingRateUseCase` retourne Left si repository throws** | Meme fichier | **A AJOUTER** |
| **Checkout : Erreur retry quand FedEx API throws** | `test/features/marketplace/presentation/pages/checkout_page_test.dart` | **MANQUANT - BLOQUANT** |
| **Checkout : Erreur retry quand rates list vide** | Meme fichier | **MANQUANT - BLOQUANT** |
| **Checkout : Erreur seller quand seller address invalid** | Meme fichier | **MANQUANT - BLOQUANT** |
| **Checkout : Redirect quand buyer address incomplete** | Meme fichier | **MANQUANT - BLOQUANT** |
| **Validation poids : null OK, 0 KO, -1 KO, 0.1 OK, 50 OK, 51 KO, 'abc' KO** | `test/features/marketplace/presentation/pages/create_listing_page_test.dart` | **MANQUANT - MAJEUR** |
| **`MarketplaceListing.toJson()` inclut `weight_kg` si non-null** | `test/features/marketplace/domain/entities/marketplace_listing_test.dart` | **MANQUANT - BLOQUANT** |
| **`MarketplaceListing.toJson()` exclut `weight_kg` si null** | Meme fichier | **MANQUANT - BLOQUANT** |
| **`MarketplaceListing.fromJson()` parse `weight_kg` null** | Meme fichier | **MANQUANT - BLOQUANT** |
| **`MarketplaceListing.fromJson()` parse `weight_kg` non-null** | Meme fichier | **MANQUANT - BLOQUANT** |
| **`MarketplaceListing.copyWith()` preserve `weight_kg`** | Meme fichier | **MANQUANT - BLOQUANT** |
| **`MarketplaceListing.copyWith()` override `weight_kg`** | Meme fichier | **MANQUANT - BLOQUANT** |

### Tests widget

| Test | Description | Status |
|------|-------------|--------|
| Checkout affiche loading pendant calcul rates | Spinner visible pendant _isLoadingRates == true | TODO |
| Checkout affiche ShippingRateSelector avec rates FedEx | Widget ShippingRateSelector rendu avec liste rates | TODO |
| Checkout affiche erreur + Retry si FedEx echoue | Message "Unable to calculate shipping" + bouton Retry visible | TODO |
| Checkout affiche erreur seller (pas de Retry) si seller address manquante | Message "Seller address incomplete" visible, pas de Retry | TODO |
| Checkout redirige vers step Address si buyer address incomplete | Redirect automatique vers step 0 | TODO |
| Checkout recalcule total avec tarif selectionne | Total mis a jour quand _selectedRate change | TODO |
| Create listing affiche champ Weight | Champ LynewedTextField "Weight (kg)" present | TODO |
| Create listing hint dynamique selon categorie | "Default: 3.0 kg" pour dress, "Default: 2.0 kg" pour shoes | TODO |
| **Create listing affiche erreur si poids invalide** | Validator affiche message si < 0.1 ou > 50.0 | **MANQUANT - MAJEUR** |
| **Create listing accepte poids null (optionnel)** | Pas d'erreur si champ vide | **MANQUANT - MAJEUR** |

### Test integration (Edge Function)

Verifiable via Supabase MCP :

```sql
-- Verifier que la colonne weight_kg existe
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'marketplace_listings' AND column_name = 'weight_kg';
```

Verifiable via curl (apres S01 valide) :

```bash
curl -X POST https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-calculate-rate \
  -H "Authorization: Bearer <anon_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "from_address": {"streetLines":["123 Main St"],"city":"New York","stateOrProvinceCode":"NY","postalCode":"10001","countryCode":"US"},
    "to_address": {"streetLines":["456 Oak Ave"],"city":"Los Angeles","stateOrProvinceCode":"CA","postalCode":"90001","countryCode":"US"},
    "category": "dress"
  }'
```

---

## Definition of Done

### Prerequis
- [ ] AC-0 validé : FedEx OAuth fonctionne en production (S01 deployée)
- [ ] Test curl FedEx retourne 200 ou 400 (pas 401/500)

### Migration DB
- [ ] Colonne `weight_kg` ajoutee a `marketplace_listings` avec CHECK constraint (0.1-50.0)
- [ ] Migration testée sur branche Supabase

### Use Cases
- [ ] `GetSellerShippingAddress` use case créé avec validation complète
- [ ] Validation countryCode, city, postalCode obligatoires
- [ ] Retourne Left(ValidationFailure) si champ manquant
- [ ] Tests unitaires pour tous les cas de validation

### UI - Create Listing
- [ ] Champ "Weight (kg)" visible sur `create_listing_page.dart` avec hint dynamique
- [ ] Validation poids : optionnel, 0.1-50.0 si renseigne
- [ ] Hint affiche defaut categorie (dress=3.0kg, shoes=2.0kg)

### UI - Checkout
- [ ] `checkout_page.dart` appelle `GetSellerShippingAddress` puis `CalculateShippingRateUseCase`
- [ ] Loading spinner pendant le calcul des tarifs
- [ ] `ShippingRateSelector` affiche les tarifs FedEx quand disponibles
- [ ] **PAS DE FLAT-RATE FALLBACK** - Erreur FedEx → message retry + checkout bloque :
  - [ ] API FedEx echoue (500, timeout) → "Unable to calculate. Try again." + bouton Retry
  - [ ] Rates liste vide → "No shipping options. Try again." + bouton Retry
  - [ ] Seller address invalide → "Seller address incomplete. Contact seller." (pas de Retry)
  - [ ] Buyer address incomplete → retour step Address pour corriger
- [ ] Bouton "Continue to Payment" DESACTIVE tant que `_ratesError != null`
- [ ] Log warning pour chaque erreur avec raison precise
- [ ] Total recalcule selon le tarif selectionne

### Entity
- [ ] `MarketplaceListing` entity inclut `weightKg: double?` avec doc comment
- [ ] `toJson()` serialise weightKg avec condition `if (weightKg != null)`
- [ ] `fromJson()` deserialise weightKg avec `double.parse()` null-safe
- [ ] `copyWith()` preserve weightKg avec param optionnel

### Use Case CalculateShippingRateUseCase
- [ ] Signature retourne `Either<Failure, List<ShippingRate>>` (pas `Future<List>`)
- [ ] Param `weightKg` optionnel ajoute
- [ ] Gestion erreur avec try/catch → Left(ServerFailure)
- [ ] Repository appele avec param `weightKg`

### Validator UI
- [ ] Fonction `_validateWeight()` implementee dans `create_listing_page.dart`
- [ ] Accepte null (champ optionnel)
- [ ] Rejette < 0.1 avec message clair
- [ ] Rejette > 50.0 avec message clair
- [ ] Rejette valeurs non-numeriques avec message clair

### Tests
- [ ] Tests `GetSellerShippingAddress` : 4 cas (valide, countryCode KO, address null, profil null)
- [ ] **Tests checkout : 4 cas de fallback (API error, rates vide, seller KO, buyer KO)** - MANQUANTS
- [ ] **Tests validation poids : 8 cas (null, '', 0, -1, 0.1, 50, 51, 'abc')** - MANQUANTS
- [ ] **Tests entity MarketplaceListing : toJson (null/non-null), fromJson (null/non-null), copyWith (preserve/override)** - MANQUANTS (6 tests)
- [ ] Tests use case CalculateShippingRateUseCase : Either return + weightKg param + error handling - A REFACTORER
- [ ] Tests widget : loading, ShippingRateSelector, fallback UI, hint dynamique, validation UI
- [ ] Tous les tests passent (0 failure)

### Qualité
- [ ] `flutter analyze --fatal-infos` = 0 warnings
- [ ] Code en anglais, commentaires en anglais
- [ ] Design System respecte (LynewedTextField, LynewedButton)

---

## Estimation INVEST

| Critere | Evaluation |
|---------|------------|
| **Independent** | Depend de S01 (FedEx OAuth validé en prod - prerequis testable AC-0). Pas de conflit fichier avec autres stories |
| **Negotiable** | Champ poids optionnel (fallback defauts). Nombre de services FedEx affiches negotiable. Range 0.1-50kg ajustable |
| **Valuable** | Acheteuse voit frais reels au lieu d'estimations fixes. Reduction litiges sur frais. Vendeur peut optimiser frais en renseignant poids exact |
| **Estimable** | **9 points (correction depuis 8 apres re-challenge)** - Use case GetSellerShippingAddress a creer + **refactoring CalculateShippingRateUseCase vers Either** + validation complete + 8 cas de fallback + **18 tests manquants** + migration DB avec constraint + validator UI |
| **Small** | **7 fichiers a modifier/creer** (vs 5 initial), 1 migration, **31 tests** (vs 22 initial). **Recommande split en 2 stories** (S06a: Poids 3 SP, S06b: Checkout 6 SP) |
| **Testable** | 7 criteres Gherkin (AC-0 a AC-6) verifiables, 31 tests definis, prerequis S01 testable via curl |

**Evolution estimation** :
1. **v1 (initial)** : 5 SP - estimation optimiste
2. **v2 (apres 1er challenge)** : 8 SP - ajout GetSellerShippingAddress + validation 8 fallbacks
3. **v3 (apres re-challenge)** : **9 SP** - corrections majeures :
   - `MarketplaceListing` entity incomplete (weightKg manquant partout : field, fromJson, toJson, copyWith)
   - `CalculateShippingRateUseCase` incompatible (Future<List> vs Either + param weightKg manquant)
   - Validator `_validateWeight()` jamais defini (fonction fantome)
   - **18 tests manquants** vs 22 promises (checkout fallback 4x, validation poids 8x, entity 6x)

**Recommendation de split** :

### S06a : Poids sur listing (3 SP - PREREQUISITE)
- Migration DB weight_kg
- Entity MarketplaceListing complete (field + toJson + fromJson + copyWith)
- UI create_listing_page (champ Weight + validator _validateWeight)
- Tests entity (6 tests) + validation UI (8 tests)
- **BLOQUE** S06b

### S06b : Checkout dynamique FedEx (6 SP)
- Refactoring CalculateShippingRateUseCase → Either + param weightKg
- Use case GetSellerShippingAddress
- Checkout page integration FedEx + 8 fallbacks
- Tests checkout (4 fallback tests) + use case (3 tests refactored)
- **DEPEND** de S06a

---

## RECOMMANDATION : Split en 2 Stories

**Justification** :
- Story actuelle : **9 SP** (trop gros pour 1 sprint)
- **7 fichiers** a modifier (vs 5 initial)
- **31 tests** a ecrire (vs 22 promises)
- **2 domaines distincts** : (1) Gestion poids, (2) Integration FedEx

**Proposition de split** :

### S06a : Gestion poids listing (3 SP - PREREQUISITE)

**Scope** :
- Migration DB : colonne `weight_kg` avec CHECK constraint
- Entity `MarketplaceListing` : field + toJson + fromJson + copyWith
- UI `create_listing_page.dart` : champ Weight + validator `_validateWeight()`
- Tests : 6 entity tests + 8 validation tests = **14 tests**

**Criteres d'acceptance** (extrait de S06) :
- AC-1 : Champ poids sur formulaire creation
- AC-5 : Persistance poids en BDD
- AC-6 : Validation champ poids

**DoD** :
- [ ] Colonne `weight_kg` en BDD avec CHECK
- [ ] Entity complete (field + serialization + copyWith)
- [ ] UI champ Weight avec hint dynamique
- [ ] Validator `_validateWeight()` implemente
- [ ] 14 tests passes

**Delivrable** : Vendeur peut renseigner poids lors creation listing. Poids stocke en BDD. Frontend valide range 0.1-50 kg.

---

### S06b : Checkout dynamique FedEx (6 SP)

**Scope** :
- Refactoring `CalculateShippingRateUseCase` → Either + param weightKg
- Use case `GetSellerShippingAddress` avec validation
- Checkout page : integration FedEx + 8 scenarios fallback
- Repository : adapter signatures pour `weightKg`
- Edge Function : accepter param `weight_kg`
- Tests : 4 checkout tests + 3 use case tests + 4 GetSellerShippingAddress tests + 6 widget tests = **17 tests**

**Criteres d'acceptance** (extrait de S06) :
- AC-0 : Prerequis FedEx OAuth (S01)
- AC-2 : Calcul dynamique FedEx au checkout
- AC-3 : Erreur + retry si FedEx echoue (PAS de flat-rate)
- AC-4 : Poids par defaut par categorie

**DoD** :
- [ ] CalculateShippingRateUseCase retourne Either
- [ ] GetSellerShippingAddress valide adresses
- [ ] Checkout appelle FedEx et affiche rates
- [ ] Erreur + retry (PAS de flat-rate) dans tous les cas d'echec
- [ ] 17 tests passes

**Delivrable** : Acheteuse voit frais reels FedEx au checkout. Message erreur + retry si FedEx echoue (PAS de flat-rate).

**Dependance** : **BLOQUE par S06a** (necessite weightKg dans entity).

---

**Decision requise** : Valider ce split ou garder story monolithique 9 SP ?

---

## Risques

| Risque | Probabilite | Impact | Mitigation |
|--------|-------------|--------|------------|
| FedEx sandbox renvoie des tarifs irrealistes | Moyenne | Faible | Tarifs sandbox = approximation. En prod, tarifs reels |
| Adresse vendeur absente du profil | Faible | Moyen | `GetSellerShippingAddress` retourne Left → message erreur "Seller address incomplete" (pas de Retry) |
| Adresse vendeur incomplete (countryCode manquant) | Faible | Moyen | Validation dans `GetSellerShippingAddress` → message erreur (pas de Retry, probleme vendeur) |
| Adresse acheteuse incomplete (postalCode manquant) | Faible | Moyen | Validation avant appel FedEx → redirect vers step Address pour completer |
| Latence API FedEx > 5s | Moyenne | Moyen | Retry avec backoff (deja dans Edge Function, 3 tentatives). Timeout 30s. Si timeout → message erreur + Retry |
| API FedEx retourne liste vide | Moyenne | Faible | Detection `rates.isEmpty` → message erreur + Retry |
| Colonne weight_kg non retrocompatible | Nulle | Nul | Colonne nullable avec CHECK constraint, null = utiliser defaut categorie |
| Migration CHECK constraint bloque INSERT existants | Nulle | Nul | Constraint autorise NULL explicitement. Listings existants ont weight_kg=NULL (OK) |

---

## Notes Implementation

### 1. Strategie Erreur FedEx - Retry (CRITIQUE - PAS DE FLAT-RATE)

**INSTRUCTION LEO** : Pas de flat-rate backup. FedEx doit fonctionner ou le checkout est bloque avec message retry.

**Tous les cas d'erreur** :

| Scenario | Detection | Action | Retry ? |
|----------|-----------|--------|---------|
| API FedEx erreur (500, timeout) | `ratesResult.isLeft()` | Error message + Retry button | **OUI** |
| API FedEx retourne [] | `rates.isEmpty` | Error message + Retry button | **OUI** |
| Seller address null | `profile.shippingAddress == null` | "Seller address incomplete" | NON |
| Seller countryCode manquant | `shippingAddress.countryCode == null` | "Seller address incomplete" | NON |
| Seller city manquant | `shippingAddress.city == null` | "Seller address incomplete" | NON |
| Seller postalCode manquant | `shippingAddress.postalCode == null` | "Seller address incomplete" | NON |
| Buyer countryCode manquant | `_buyerAddress.countryCode == null` | Redirect to Address step | NON |
| Buyer postalCode manquant | `_buyerAddress.postalCode == null` | Redirect to Address step | NON |

**Comportement erreur** :
- Logger la raison precise avec `logger.warning()`
- Afficher message d'erreur clair en anglais
- **BLOQUER le checkout** (bouton payment DESACTIVE)
- Si `_canRetry == true` : bouton "Retry" appelle `_fetchFedExRates()` a nouveau
- Si erreur seller : pas de retry (contacter le vendeur)
- Si erreur buyer : retour au step Address pour corriger

### 2. Use Case GetSellerShippingAddress

**Responsabilite** : Valider l'adresse vendeur AVANT d'appeler FedEx.

**Champs obligatoires** (pour FedEx API) :
- `countryCode` (CRITIQUE - calcul zones)
- `city`
- `postalCode`

**Champs optionnels** (FedEx fonctionne sans) :
- `streetLines` (peut etre vide)
- `stateOrProvinceCode` (optionnel hors US)

**Pattern validation** :
```dart
if (field == null || field.isEmpty) {
  return Left(ValidationFailure('Seller address missing $fieldName'));
}
```

### 3. Adresse vendeur - Source de verite

Recuperer via `AuthRemoteDatasource.getProfile(listing.sellerId)?.shippingAddress`.

**IMPORTANT** : Le vendeur est oblige de renseigner une adresse avant publication du listing (flow existant `_checkShippingAddress` dans `create_listing_page.dart`). Le cas "adresse manquante" est **rare mais possible** si :
- Vendeur supprime son adresse apres publication
- Bug data (corruption BDD)
- Migration profile incomplet

→ **Fallback obligatoire** meme si theoriquement impossible.

### 4. Categories et poids par defaut

**Categories actuelles** : `dress`, `shoes` (voir `sizes_data.dart`)

**Poids par defaut** (si `weightKg == null`) :

| Categorie | Poids | Dimensions | Usage |
|-----------|-------|------------|-------|
| dress | 3.0 kg | 60x40x20 cm | Robe de mariee (moyenne) |
| shoes | 2.0 kg | 35x25x15 cm | Chaussures avec boite |

**Categories futures** (deja dans Edge Function) :
- `accessories` : 1.0 kg, 30x20x10 cm
- `decoration` : 5.0 kg, 50x50x30 cm

### 5. ShippingRateSelector - Widget existant

Le widget existe deja (`lib/features/marketplace/presentation/widgets/shipping_rate_selector.dart`) et est teste.

**Integration** : Afficher dans checkout step Review si `_fedexRates.isNotEmpty`.

**Props** :
```dart
ShippingRateSelector(
  rates: _fedexRates,
  selectedRate: _selectedRate,
  onRateSelected: (rate) {
    setState(() {
      _selectedRate = rate;
      // Recalculer total
    });
  },
)
```

### 6. Migration DB - Constraint IMPORTANT

```sql
CHECK (weight_kg IS NULL OR (weight_kg >= 0.1 AND weight_kg <= 50.0))
```

**Pourquoi** :
- `NULL` = utiliser defaut categorie (OK)
- `< 0.1` = poids invalide pour expedition
- `> 50.0` = poids irrealiste pour marketplace mode (robes, chaussures)

**Range justifie** :
- Min 0.1 kg : Accessoires legers (voile, bijoux)
- Max 50.0 kg : Robe tres volumineuse avec accessoires (edge case)
