# RE-CHALLENGE REPORT - S06 FedEx Dynamic Shipping

> **Date** : 2026-02-16
> **Reviewer** : Claude Senior Tech Lead (Adversarial Mode)
> **Story** : S06 - Frais de port dynamiques FedEx
> **Version** : Corrected (post-challenge)

---

## SYNTHÈSE EXÉCUTIVE

**Verdict** : ❌ **STORY NON VALIDÉE - 8 PROBLÈMES BLOQUANTS SUBSISTENT**

La story a été **partiellement corrigée** après le premier challenge, mais **plusieurs problèmes critiques persistent** ou **de nouveaux problèmes sont apparus**.

**Estimation** : 8 SP confirmée (upgrade correct depuis 5 SP)

**Problèmes résolus** : 3/5
**Nouveaux problèmes détectés** : 3
**Problèmes persistants** : 2

---

## VÉRIFICATION DES CORRECTIONS DEMANDÉES

### ✅ CORRECTION 1 : Use Case GetSellerShippingAddress

**Status** : **RÉSOLU**

**Demande initiale** :
- Créer use case `GetSellerShippingAddress` avec validation adresse vendeur
- Valider champs obligatoires (countryCode, city, postalCode)
- Retourner `Either<Failure, ShippingAddress>`

**Vérification** :
- ✅ Use case documenté lignes 198-244 de la story
- ✅ Interface définie avec validation complète
- ✅ Champs obligatoires identifiés (countryCode, city, postalCode)
- ✅ Gestion erreur via `Either<Failure, ShippingAddress>`
- ✅ Usage dans `checkout_page.dart` documenté lignes 260-306

**Problème subsistant** : ⚠️ Le use case **n'existe pas encore** (fichier à CRÉER, pas à modifier)

---

### ✅ CORRECTION 2 : Précondition S01 Testable (AC-0)

**Status** : **RÉSOLU**

**Demande initiale** :
- Ajouter AC-0 avec test curl FedEx OAuth
- Vérifier que S01 est déployé en prod avant de commencer S06

**Vérification** :
- ✅ AC-0 ajouté lignes 36-48
- ✅ Test curl fourni avec commande complète
- ✅ Critère d'acceptation : status HTTP 200 ou 400 (pas 401/500)
- ✅ Dépendances documentées ligne 8 : "S01 (FedEx OAuth fonctionnel - testable via AC-0)"

**Validation** : Parfait. AC-0 est clair et testable.

---

### ✅ CORRECTION 3 : Migration DB Constraint Positive

**Status** : **RÉSOLU**

**Demande initiale** :
- Ajouter `CHECK (weight_kg > 0)` dans la migration
- Permettre NULL mais bloquer valeurs négatives/zéro

**Vérification** :
- ✅ Migration corrigée lignes 322-330
- ✅ Constraint : `CHECK (weight_kg IS NULL OR (weight_kg >= 0.1 AND weight_kg <= 50.0))`
- ✅ Commentaire SQL explicite
- ✅ NULL autorisé (fallback défaut catégorie)

**Validation** : Excellent. Range 0.1-50.0 kg justifié lignes 670-672.

---

### ⚠️ CORRECTION 4 : Entity MarketplaceListing avec weightKg

**Status** : **PARTIELLEMENT RÉSOLU**

**Demande initiale** :
- Ajouter champ `weightKg` dans `MarketplaceListing` entity
- Mettre à jour `toJson()`, `fromJson()`, `copyWith()`
- Tests pour vérifier que les tests existants ne cassent pas

**Vérification** :

**✅ Documentation story complète** :
- Lignes 178-183 : Instructions claires de modification
- Tests définis lignes 436-438
- DoD ligne 514-517

**❌ PROBLÈME BLOQUANT** : Entity actuelle (fichier lu) **NE CONTIENT PAS weightKg**
- Fichier lu : `lib/features/marketplace/domain/entities/marketplace_listing.dart`
- Ligne 38 dernière prop : `coverPhotoStoragePath`
- **Aucune trace de `weightKg`**
- `toJson()` ligne 166-185 : **weightKg absent**
- `fromJson()` ligne 121-163 : **weightKg absent**
- `copyWith()` ligne 205-253 : **weightKg absent**

**Impact** :
- La story dit "modifier" mais le code **n'a pas été modifié**
- Tests marketplace vont **casser** quand on ajoutera le champ
- Migration DB va créer la colonne mais l'app Flutter ne saura pas la lire

**Action requise** :
```dart
// lib/features/marketplace/domain/entities/marketplace_listing.dart
class MarketplaceListing {
  // ... existing fields ...

  /// Item weight in kilograms (optional).
  ///
  /// If null, FedEx API will use category defaults:
  /// - dress: 3.0 kg
  /// - shoes: 2.0 kg
  ///
  /// Valid range: 0.1 to 50.0 kg.
  final double? weightKg;

  const MarketplaceListing({
    // ... existing params ...
    this.weightKg,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    // ... existing parsing ...
    return MarketplaceListing(
      // ... existing fields ...
      weightKg: json['weight_kg'] != null
          ? double.parse(json['weight_kg'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... existing fields ...
      if (weightKg != null) 'weight_kg': weightKg,
    };
  }

  MarketplaceListing copyWith({
    // ... existing params ...
    double? weightKg,
  }) {
    return MarketplaceListing(
      // ... existing fields ...
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
```

**Tests existants** :
- `test/features/marketplace/domain/entities/marketplace_listing_test.dart`
- **DOIT être mis à jour** pour tester `weightKg` null-safety

---

### ❌ CORRECTION 5 : Fallback Flat-Rate Complet

**Status** : **NON RÉSOLU - INCOMPLET**

**Demande initiale** :
- Documenter tous les edge cases de fallback (10 conditions)
- Ajouter tests checkout avec fallback (22 tests au lieu de 11)

**Vérification Documentation** :

**✅ Table de décision complète** lignes 380-394 :
- 10 conditions documentées
- Validation répartie entre `GetSellerShippingAddress` et `checkout_page._fetchFedExRates()`
- Logs précis définis

**✅ Stratégie fallback** lignes 570-592 :
- Comportement documenté (MarketplaceShippingCosts, message UI, log warning)
- 8 scénarios détaillés avec détection et action

**❌ PROBLÈME BLOQUANT 1 : Tests checkout manquants**

**Tests documentés** lignes 430-438 :
- 4 tests checkout fallback (API error, rates vide, seller KO, buyer KO)
- **Mais fichier de test actuel n'a PAS ces tests**

**Vérification fichier** `test/features/marketplace/presentation/pages/checkout_page_test.dart` :
- Ligne 3 : "Verifies multi-step checkout flow: address, review (with **flat-rate** shipping)"
- **Aucun test FedEx** présent
- **Aucun test fallback** présent
- Tests actuels : navigation, flat-rate statique (lignes 167-217)

**Tests manquants** :
```dart
group('FedEx dynamic rates with fallback', () {
  testWidgets('should fallback when FedEx API throws', (tester) async {
    when(() => mockFedExRepo.calculateRates(...))
        .thenThrow(ServerException('FedEx API error'));
    // ...
    expect(find.text('Estimated shipping (standard rates)'), findsOneWidget);
  });

  testWidgets('should fallback when seller address missing', (tester) async {
    when(() => mockAuthDataSource.getProfile(sellerId))
        .thenAnswer((_) async => profileWithoutShippingAddress);
    // ...
  });

  testWidgets('should fallback when buyer address incomplete', (tester) async {
    // Buyer address without postalCode
    // ...
  });

  testWidgets('should fallback when FedEx returns empty list', (tester) async {
    when(() => mockFedExRepo.calculateRates(...))
        .thenAnswer((_) async => []);
    // ...
  });
});
```

**❌ PROBLÈME BLOQUANT 2 : DoD incomplet**

**DoD checkout** lignes 500-512 :
- ✅ Liste les 4 cas de fallback
- ✅ Message fallback
- ✅ Log warning
- ❌ **Ne mentionne PAS** : "Tests checkout fallback passent (0 failure)"

**Impact** :
- Développeur peut valider la story sans écrire les tests fallback
- Tests checkout actuels sont tous flat-rate statique
- Risque : Code fallback jamais testé → bugs en prod

---

## NOUVEAUX PROBLÈMES DÉTECTÉS

### 🔴 NP-1 : Use Case CalculateShippingRate ne retourne pas Either

**Fichier** : `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart`

**Problème** :
- Ligne 31 signature : `Future<List<ShippingRate>>` (throws si erreur)
- **Pas de retour `Either<Failure, List<ShippingRate>>`**
- Story ligne 287 utilise `ratesResult.fold()` → **va casser** car le use case ne retourne pas `Either`

**Code actuel** :
```dart
Future<List<ShippingRate>> call({
  required ShippingAddress fromAddress,
  required ShippingAddress toAddress,
  required String category,
}) async {
  return _repository.calculateRates(...);
}
```

**Code attendu par la story** :
```dart
ratesResult.fold(
  (failure) => _fallbackToFlatRate('FedEx API error'),
  (rates) { ... },
)
```

**Impact** :
- Code story ligne 283-304 va **compiler KO** (fold() n'existe pas sur Future)
- Pattern Clean Architecture rompu (use cases doivent retourner Either)

**Correction requise** :
```dart
class CalculateShippingRateUseCase {
  Future<Either<Failure, List<ShippingRate>>> call({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
    double? weightKg,
  }) async {
    try {
      final rates = await _repository.calculateRates(
        fromAddress: fromAddress,
        toAddress: toAddress,
        category: category,
        weightKg: weightKg,
      );
      return Right(rates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to calculate rates: $e'));
    }
  }
}
```

---

### 🔴 NP-2 : CalculateShippingRate ne supporte pas weightKg

**Fichier** : `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart`

**Problème** :
- Ligne 31-35 signature : pas de param `weightKg`
- Story ligne 285-288 appelle le use case avec `weightKg: widget.listing.weightKg`
- **Appel va casser** car param non reconnu

**Impact** :
- Code ne compilera pas
- Edge Function FedEx attend `weightKg` (documenté story ligne 338)

**Correction requise** :
```dart
Future<Either<Failure, List<ShippingRate>>> call({
  required ShippingAddress fromAddress,
  required ShippingAddress toAddress,
  required String category,
  double? weightKg, // NOUVEAU PARAM
}) async {
  return _repository.calculateRates(
    fromAddress: fromAddress,
    toAddress: toAddress,
    category: category,
    weightKg: weightKg, // PASSER À REPOSITORY
  );
}
```

**Cascade** : Repository et DataSource doivent aussi être mis à jour.

---

### 🟡 NP-3 : Validation Poids UI Incohérente

**Fichier story** : Lignes 159-170 (AC-6)

**Problème** :
- AC-6 dit : "Weight must be between 0.1 and 50 kg"
- Migration ligne 326 : `CHECK (weight_kg >= 0.1 AND weight_kg <= 50.0)`
- **Mais validation UI ligne 406-413 manque le validator**

**Code story ligne 410-413** :
```dart
LynewedTextField(
  controller: _weightController,
  label: 'Weight (kg)',
  hint: 'Default: ${_selectedCategory == 'shoes' ? '2.0' : '3.0'} kg',
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
  validator: _validateWeight, // ← Référencé mais PAS DÉFINI
)
```

**Manque** : Implémentation de `_validateWeight()` :
```dart
String? _validateWeight(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Optional field
  }

  final weight = double.tryParse(value);
  if (weight == null) {
    return 'Invalid number';
  }

  if (weight < 0.1 || weight > 50.0) {
    return 'Weight must be between 0.1 and 50 kg';
  }

  return null;
}
```

**Impact** : Utilisateur peut saisir 0 ou 100 → erreur DB au moment de l'insert (CHECK constraint)

---

## ANALYSE PAR CRITÈRE INVEST

### Independent ✅
- Dépend de S01 (FedEx OAuth)
- AC-0 testable (curl)
- Pas de conflit fichier avec autres stories
- **OK** après correction S01

### Negotiable ✅
- Champ poids optionnel (fallback défauts)
- Range 0.1-50kg ajustable
- Nombre de services FedEx négociable
- **OK**

### Valuable ✅
- Frais réels vs estimations fixes
- Réduction litiges
- Vendeur peut optimiser
- **OK**

### Estimable ⚠️
- **8 SP correct** (upgrade depuis 5 SP justifié)
- Use case GetSellerShippingAddress à créer
- **Mais** : code existant (CalculateShippingRate) **PAS ready** (retour type KO)
- **Risque sous-estimation** si refactoring use case nécessaire

### Small ⚠️
- 5 fichiers à modifier/créer
- **Mais** : Entity MarketplaceListing **PAS encore modifié** (risque cascade)
- **Mais** : Use case CalculateShippingRate à refactorer (Either + weightKg)
- **Estimation réelle** : 8-10 SP si refactoring

### Testable ❌
- **BLOQUANT** : Tests checkout fallback **manquants**
- **BLOQUANT** : Tests entity weightKg **non définis**
- 7 critères Gherkin OK
- **KO** tant que tests pas écrits/documentés

---

## MÉTRIQUES PROBLÈMES

| Sévérité | Nombre | Détails |
|----------|--------|---------|
| 🔴 BLOQUANT | 3 | NP-1 (Either), NP-2 (weightKg), Correction 4 (entity), Correction 5 (tests) |
| 🟡 MAJEUR | 2 | NP-3 (validator), Correction 4 (tests entity) |
| 🟢 MINEUR | 1 | DoD incomplet (mention tests) |

---

## VERDICT DÉTAILLÉ

### ✅ Points Positifs

1. **AC-0 ajouté** : Dépendance S01 testable (curl FedEx OAuth)
2. **Use case GetSellerShippingAddress documenté** : Validation complète, interface claire
3. **Migration DB correcte** : CHECK constraint 0.1-50.0 kg, NULL autorisé
4. **Table de décision fallback exhaustive** : 10 conditions, logs précis
5. **Estimation upgrade justifiée** : 5 SP → 8 SP (use case manquant, tests complexes)

### ❌ Points Bloquants

1. **Entity MarketplaceListing PAS modifié** : weightKg manquant dans code actuel
2. **Use case CalculateShippingRate incompatible** :
   - Retourne `Future<List>` au lieu de `Either<Failure, List>`
   - Param `weightKg` manquant
3. **Tests checkout fallback absents** : Fichier test actuel 100% flat-rate statique
4. **Validator poids UI non défini** : Référencé mais pas implémenté
5. **Tests entity weightKg manquants** : Risque casser tests existants

### ⚠️ Points d'Attention

- DoD ne mentionne pas "tests fallback passent"
- Code story utilise `ratesResult.fold()` mais use case ne retourne pas Either
- Repository FedEx devra aussi être modifié pour supporter `weightKg`

---

## ACTIONS REQUISES AVANT VALIDATION

### Critiques (AVANT développement)

1. ✅ **Modifier MarketplaceListing entity** :
   - Ajouter `weightKg: double?`
   - Mettre à jour `toJson()`, `fromJson()`, `copyWith()`
   - **Créer tests** : `marketplace_listing_test.dart` avec cas weightKg null/non-null

2. ✅ **Refactorer CalculateShippingRateUseCase** :
   - Retourner `Either<Failure, List<ShippingRate>>`
   - Ajouter param `weightKg: double?`
   - Wrapper try/catch → Left(ServerFailure)

3. ✅ **Ajouter tests checkout fallback** :
   - 4 tests minimum (API error, rates vide, seller KO, buyer KO)
   - Mock GetSellerShippingAddress
   - Mock FedExRepository
   - Vérifier message "Estimated shipping (standard rates)" en fallback

4. ✅ **Implémenter validator poids UI** :
   - Fonction `_validateWeight()` dans `create_listing_page.dart`
   - Range 0.1-50.0 kg
   - Null OK (optionnel)

### Améliorations DoD

5. ✅ **Compléter DoD ligne 520** :
   ```markdown
   - [ ] Tests checkout : 4 cas de fallback (API error, rates vide, seller KO, buyer KO)
   - [ ] Tests checkout fallback passent (0 failure)
   ```

6. ✅ **Ajouter section "Code Existant à Modifier"** dans spec technique :
   ```markdown
   | Fichier | Action | Raison |
   |---------|--------|--------|
   | `calculate_shipping_rate_use_case.dart` | REFACTORER | Retour Either + param weightKg |
   | `fedex_repository.dart` | MODIFIER | Interface param weightKg |
   | `fedex_repository_impl.dart` | MODIFIER | Impl param weightKg |
   ```

---

## ESTIMATION FINALE

| Composant | Estimation Initiale | Estimation Réelle | Justification |
|-----------|---------------------|-------------------|---------------|
| Use case GetSellerShippingAddress | 1 SP | 1 SP | Nouveau, bien spécifié |
| Migration DB + Entity | 1 SP | 1.5 SP | Entity + tests entity |
| UI Create Listing | 1 SP | 1 SP | Champ + validator |
| Refactoring CalculateShippingRate | 0 SP (oublié) | 1 SP | Either + weightKg + tests |
| UI Checkout + Fallback | 2 SP | 2.5 SP | Loading, selector, 10 cas fallback |
| Tests checkout fallback | 0 SP (oublié) | 1.5 SP | 4 tests complexes avec mocks |
| Tests integration | 0.5 SP | 0.5 SP | Migration + curl |
| **TOTAL** | **5.5 SP** | **9 SP** | **+63%** |

**Recommandation** : **Upgrade à 9 SP** (au lieu de 8 SP actuels)

**Raison** : Refactoring use case + tests fallback sous-estimés

---

## RECOMMANDATIONS STRATÉGIQUES

### Option 1 : Diviser en 2 Stories

**S06a - Poids Listing (3 SP)** :
- Migration DB weight_kg
- Entity MarketplaceListing + weightKg
- UI Create Listing + validator
- Tests entity

**S06b - FedEx Checkout (6 SP)** :
- Use case GetSellerShippingAddress
- Refactoring CalculateShippingRateUseCase
- UI Checkout + ShippingRateSelector
- Fallback 10 cas
- Tests checkout (4 fallback + loading)

**Bénéfice** : S06a peut être fait AVANT S01, S06b dépend de S01

### Option 2 : Corriger et Valider en Bloc (9 SP)

- Corriger les 4 problèmes bloquants
- Ajouter tests manquants
- Re-challenger
- Développer en TDD strict

**Risque** : Si S01 échoue, S06 bloqué

---

## CONCLUSION FINALE

**Verdict** : ❌ **STORY NON VALIDÉE**

**Raison** :
- **3/5 corrections appliquées** (AC-0, migration, use case GetSellerShippingAddress documenté)
- **2/5 corrections non appliquées** (entity weightKg, tests checkout fallback)
- **3 nouveaux problèmes critiques** (use case Either, param weightKg, validator UI)

**Peut-on démarrer le développement ?** **NON**

**Bloqueurs** :
1. Entity MarketplaceListing ne contient pas weightKg → tests vont casser
2. Use case CalculateShippingRate incompatible (retour type + param)
3. Tests checkout fallback non définis → DoD incomplet

**Durée corrections estimée** : 0.5 jour (4h)

**Actions immédiates** :
1. Modifier `marketplace_listing.dart` (+ tests)
2. Refactorer `calculate_shipping_rate_use_case.dart` (+ cascade repository)
3. Créer tests checkout fallback (au moins squelettes dans story)
4. Implémenter `_validateWeight()` dans story (snippet code)

**Après corrections** : Re-challenge obligatoire avant développement

---

**Rapport généré par** : Review Adversariale APEX (Round 2)
**Méthodologie** : Vérification exhaustive corrections + analyse code existant + détection nouveaux problèmes
**Règle** : 0 complaisance, cohérence Clean Architecture stricte
