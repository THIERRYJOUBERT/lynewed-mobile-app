# S06 - Corrections Appliquees (CHALLENGE REPORT)

> Date : 2026-02-16
> Story : S06-fedex-dynamic-shipping-rates.md
> Status : ✅ CORRECTED - Ready for implementation

---

## Problemes BLOQUANTS Corriges

### 1. ✅ Prerequis S01 non testable

**Probleme** : S06 dependait de S01 sans moyen de verifier que S01 est validee en production.

**Correction** :
- Ajout **AC-0 : Prerequis FedEx OAuth** avec test curl verifiable
- Commande curl fournie pour tester l'Edge Function `fedex-calculate-rate`
- Critere de succes : HTTP 200 ou 400 (pas 401/500 = auth broken)

**Localisation** : Ligne 36-48 (AC-0)

---

### 2. ✅ Use Case GetSellerShippingAddress manquant

**Probleme** : La story supposait qu'on recupere l'adresse vendeur mais ne documentait pas le use case.

**Correction** :
- Creation section **"Use Case GetSellerShippingAddress"** complete (ligne 164-252)
- Interface detaillee avec validation exhaustive (countryCode, city, postalCode)
- Pattern `Either<Failure, ShippingAddress>` avec gestion erreurs
- Code exemple d'usage dans `checkout_page.dart` fourni

**Fichiers ajoutes** :
- `lib/features/marketplace/domain/usecases/get_seller_shipping_address.dart` (CREER)
- `test/features/marketplace/domain/usecases/get_seller_shipping_address_test.dart` (CREER)

**Localisation** : Ligne 164-252 (nouvelle section)

---

### 3. ✅ Entity MarketplaceListing incomplet

**Probleme** : La story mentionnait "ajouter weightKg" mais n'incluait pas l'entity dans les fichiers a modifier ni ses tests.

**Correction** :
- Ajout explicite de `marketplace_listing.dart` dans "Fichiers a modifier" (ligne 145-149)
- Documentation serialization `toJson()` / `fromJson()` / `copyWith()`
- Ajout de 3 tests entity dans la table des tests (ligne 240-243)

**Localisation** :
- Ligne 147 (fichiers a modifier)
- Ligne 240-243 (tests)
- Ligne 328 (DoD - Entity section)

---

### 4. ✅ Fallback flat-rate incomplet - Edge cases manquants

**Probleme** : Seulement 2 scenarios de fallback documentes (API error, rates vide). Edge cases critiques manquants :
- Adresse vendeur null
- countryCode manquant
- Adresse acheteuse incomplete

**Correction** :
- **AC-3 etendu** avec 5 scenarios de fallback au lieu de 2 (ligne 87-123)
- **Table de decision complete** dans "Edge Cases a Gerer" (ligne 229-250)
- 10 conditions documentees avec validation, resultat, et log
- Section **"Strategie Fallback Flat-Rate"** detaillee (ligne 377-409)

**Nouveaux scenarios AC-3** :
1. Adresse vendeur null
2. Adresse vendeur sans countryCode
3. Adresse acheteuse sans postalCode
4. API FedEx erreur (existant)
5. API FedEx retourne [] (existant)

**Localisation** :
- Ligne 87-123 (AC-3 etendu)
- Ligne 229-250 (table edge cases)
- Ligne 377-409 (strategie fallback)

---

### 5. ✅ Tests checkout avec fallback manquants

**Probleme** : Les tests de fallback n'etaient pas listes dans la section Tests.

**Correction** :
- Ajout de **4 tests checkout** pour les scenarios de fallback (ligne 240-243)
- Ajout de **4 tests use case** GetSellerShippingAddress (ligne 237-240)
- Ajout de **3 tests widget** pour fallback UI (ligne 249-253)
- Total : **11 tests supplementaires** documentes

**Tests ajoutes** :
- `GetSellerShippingAddress` : 4 tests (valide, countryCode KO, address null, profil null)
- Checkout : 4 tests (API error, rates vide, seller KO, buyer KO)
- Widget : 3 tests (fallback UI, log warning, isFallbackRate state)

**Localisation** :
- Ligne 237-253 (table tests)
- Ligne 308-325 (DoD - Tests section)

---

## Ameliorations Qualite Ajoutees

### 6. ✅ Migration DB - Constraint positive

**Probleme** : La migration manquait le CHECK constraint pour valider le range 0.1-50.0 kg.

**Correction** :
- Ajout CHECK constraint dans la migration SQL (ligne 255-259)
- Justification du range dans Notes Implementation (ligne 493-500)

**Localisation** : Ligne 255-259

---

### 7. ✅ Definition of Done exhaustive

**Probleme** : La DoD initiale etait generique.

**Correction** :
- DoD divisee en **8 sections** thematiques (ligne 287-342)
- **42 checkboxes** au lieu de 13
- Chaque section correspond a un aspect de la story (Prerequis, Migration, Use Cases, UI, Entity, Tests, Qualite)

**Localisation** : Ligne 287-342

---

### 8. ✅ Estimation corrigee (5 SP -> 8 SP)

**Probleme** : L'estimation 5 SP etait sous-evaluee (code pas "pret a brancher").

**Correction** :
- Estimation passee a **8 SP** dans INVEST (ligne 345-356)
- Note explicative des 4 raisons de l'augmentation
- Header mis a jour avec "Upgraded from 5 SP after challenge review"

**Localisation** :
- Ligne 5 (header)
- Ligne 345-356 (INVEST)

---

### 9. ✅ Risques etendus

**Probleme** : Seulement 4 risques identifies.

**Correction** :
- **8 risques** documentes avec mitigations precises (ligne 359-367)
- Tous les edge cases couverts
- Mitigation detaillee pour chaque risque

**Localisation** : Ligne 359-367

---

### 10. ✅ Notes Implementation detaillees

**Probleme** : Notes implementation generiques.

**Correction** :
- **6 sections detaillees** au lieu de 4 (ligne 370-500)
- Section 1 : **Strategie Fallback** avec table complete (8 scenarios)
- Section 2 : **Use Case GetSellerShippingAddress** avec pattern validation
- Section 3 : **Adresse vendeur - Source de verite** avec edge cases rares
- Section 4 : **Categories et poids par defaut** avec categories futures
- Section 5 : **ShippingRateSelector** integration
- Section 6 : **Migration DB - Constraint** avec justification range

**Localisation** : Ligne 370-500

---

## Metriques Avant/Apres

| Metric | Avant | Apres | Delta |
|--------|-------|-------|-------|
| **Estimation** | 5 SP | 8 SP | +3 SP |
| **Criteres d'Acceptance** | 6 (AC-1 a AC-6) | 7 (AC-0 a AC-6) | +1 AC |
| **Scenarios Gherkin** | 12 | 17 | +5 |
| **Fichiers a modifier** | 4 | 5 | +1 |
| **Use Cases documentes** | 1 | 2 | +1 |
| **Tests unitaires** | 6 | 13 | +7 |
| **Tests widget** | 5 | 9 | +4 |
| **Edge cases documentes** | 2 | 10 | +8 |
| **Risques identifies** | 4 | 8 | +4 |
| **DoD checkboxes** | 13 | 42 | +29 |

---

## Validation Finale

### ✅ Tous les problemes BLOQUANTS corriges

1. ✅ Prerequis S01 testable via AC-0
2. ✅ Use case GetSellerShippingAddress documente
3. ✅ Entity MarketplaceListing dans fichiers + tests
4. ✅ Tous les edge cases fallback documentes
5. ✅ Tests checkout avec fallback ajoutes

### ✅ Story INVEST validee

| Critere | Status |
|---------|--------|
| **I**ndependent | ✅ Depend uniquement de S01 (testable AC-0) |
| **N**egotiable | ✅ Range poids, nombre services FedEx negotiables |
| **V**aluable | ✅ Frais reels vs estimations fixes |
| **E**stimable | ✅ 8 SP justifies (use case + validation + tests) |
| **S**mall | ✅ 5 fichiers, 1 migration, 22 tests - 1 sprint |
| **T**estable | ✅ 7 AC Gherkin, 22 tests, prerequis testable |

### ✅ Peut demarrer apres S01

- Prerequis S01 testable via curl
- Code existant verifie (CalculateShippingRateUseCase, ShippingRateSelector)
- Use case manquant (GetSellerShippingAddress) documente
- Tous les edge cases anticipes
- Migration DB prete

---

## Actions pour le Developpeur

### Ordre d'implementation recommande

1. **Migration DB** (5 min) : Ajouter colonne weight_kg avec CHECK constraint
2. **Use Case** (30 min) : Creer GetSellerShippingAddress avec validation
3. **Entity** (15 min) : Ajouter weightKg a MarketplaceListing
4. **UI Create Listing** (30 min) : Ajouter champ Weight avec validation
5. **UI Checkout** (2h) : Integrer FedEx rates + fallback + edge cases
6. **Tests** (2h30) : 13 tests unitaires + 9 tests widget
7. **Validation** (30 min) : flutter analyze + tests

**Total estime** : ~6.5h (8 SP realiste)

---

**Status Final** : ✅ **STORY READY FOR IMPLEMENTATION**

Tous les problemes du challenge report sont corriges. La story peut etre assignee a un developpeur.
