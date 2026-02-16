# S09 - Magazine Quantity Selector

> **Epic** : EPIC-15-BUGFIX
> **Status** : ✅ DONE
> **Estimation** : 8 points (M)
> **Domaine** : UI + Edge Function + DB + Webhook
> **Dependances** : Migration DB `magazine_orders.quantity` (BLOQUANTE)
> **Source** : BUG-07
> **MAJ** : 2026-02-16

---

## ⚠️ IMPLÉMENTATION REQUISE

**CRITIQUE** : Cette story nécessite des modifications **NON ENCORE IMPLÉMENTÉES** dans le code source.

Les corrections suivantes DOIVENT être implémentées :

- [ ] **Edge Function** : Interface `CheckoutRequest` avec champ `quantity`, validation serveur-side (clamp 1-10), metadata Stripe
- [ ] **Webhook** : Destructuration `metadata.quantity` + insert dans `magazine_orders.quantity`
- [ ] **Migration DB** : `ALTER TABLE magazine_orders ADD COLUMN quantity integer NOT NULL DEFAULT 1`
- [ ] **Flutter State** : Ajouter `quantity` dans `MagazineCheckoutState` avec computed `totalPriceCents`
- [ ] **Flutter UI** : Widget `QuantitySelector` réutilisable (dropdown 1-10)
- [ ] **Flutter Cubit** : Méthode `updateQuantity(int)` + passer quantity à l'Edge Function
- [ ] **Flutter Entity** : Ajouter `quantity` dans `MagazineOrder.fromJson` avec default = 1
- [ ] **Tests E2E** : Flutter → Edge Function → Webhook → DB (vérifier cohérence quantity)

**État actuel du code** :
- Edge Function hardcode `quantity: 1` (ligne 182)
- Webhook ne lit pas `metadata.quantity`
- Table `magazine_orders` n'a pas de colonne `quantity`
- `MagazineCheckoutState` n'a pas de champ `quantity`

---

## Description

Actuellement, la page de checkout magazine (`MagazineCheckoutPage`) ne permet de commander qu'un seul exemplaire (quantity hardcode à 1 dans l'Edge Function `create-magazine-checkout`). Thierry demande que la mariée puisse choisir une quantité (1 à 10) avec un recalcul dynamique du prix total.

### Problème actuel

- `create-magazine-checkout/index.ts` ligne 182 : `quantity: 1` hardcode
- `MagazineCheckoutState` : aucun champ `quantity`
- `OrderSummaryCard` : affiche le prix unitaire sans notion de quantité
- `MagazineOrder` entity : pas de champ `quantity`
- Table `magazine_orders` DB : pas de colonne `quantity`

### Solution

Ajouter un sélecteur de quantité (dropdown 1-10) sur l'écran de checkout. Le prix affiché se recalcule dynamiquement. La quantité est passée à l'Edge Function qui la transmet à Stripe (`quantity: N`). La commande DB enregistre la quantité. Les frais de port Stripe s'adaptent car Stripe les calcule par session (pas par item).

---

## Analyse Frais de Port (CRITIQUE)

### Poids et Tarifs FedEx

Selon les dimensions du magazine (21x30cm ou 30x30cm, ~200g par exemplaire) :

| Quantité | Poids Total | FedEx Ground | FedEx 2-Day | FedEx Express | Recommandation |
|----------|-------------|--------------|-------------|---------------|----------------|
| 1 magazine | ~600g | $15 | $25 | $35 | ✅ OK (flat-rate actuel) |
| 3 magazines | ~1.8kg | $18-20 | $28-32 | $40-45 | ⚠️ Limite raisonnable |
| 5 magazines | ~3kg | $22-25 | $35-40 | $50-60 | ⚠️ Coût élevé pour mariée |
| 10 magazines | ~6kg | $28-32 | $45-55 | $70-85 | ❌ Coût prohibitif |

**Note** : Les tarifs FedEx utilisent le **dimensional weight** (LxWxH/139 pour pouces) ou poids réel, selon le plus élevé. Un paquet de 10 magazines (30x30x10cm) peut être facturé au dimensional weight (~4kg) même si le poids réel est 2kg.

### Problématique Range 1-10

**Range actuel proposé** : 1-10 magazines

**Problèmes identifiés** :
1. **Frais de port non recalculés** : Le flat-rate $15 (configuré dans Stripe) ne s'ajuste PAS en fonction de la quantité. Commander 10 magazines = même frais de port qu'1 magazine.
2. **Perte financière** : Si une mariée commande 10 magazines (6kg, $28-32 FedEx), mais ne paie que $15 de shipping, Lynewed perd $13-17 par commande.
3. **Incohérence produit** : Les magazines sont des objets physiques lourds (200g/unité), pas des PDFs. Commander 10 exemplaires = 6kg à expédier.

### Recommandations

| Option | Range | Justification | Impact Shipping |
|--------|-------|---------------|-----------------|
| **A. Conservative (RECOMMANDÉ)** | 1-3 | Cas d'usage réel : mariée + parents + beaux-parents. Poids ≤ 1.8kg = flat-rate $15 reste viable | ✅ Aucun changement shipping |
| **B. Moderate** | 1-5 | Couvre "famille élargie". Nécessite recalcul shipping dynamique (FedEx Rates API) | ⚠️ Intégration FedEx Rates API |
| **C. Aggressive (NON RECOMMANDÉ)** | 1-10 | Cas d'usage flou ("cadeaux témoins" ?). Coût shipping prohibitif ($28-32) | ❌ Pertes ou prix rebutant |

**Décision à prendre** :
- **Si MVP rapide** : Range 1-3 (flat-rate $15 reste valide)
- **Si produit final** : Range 1-5 + intégration FedEx Rates API (calculer shipping dynamique)
- **Si "quantity illimitée"** : Intégration FedEx complète + UI prévenant du coût shipping >$30 pour >5 magazines

**Choix provisoire pour S09** : Range 1-10 (tel que demandé par Thierry), mais **DOCUMENTER** que :
1. Le flat-rate $15 ne couvre pas les commandes >3 magazines
2. Une story future (EPIC-16) doit implémenter le calcul dynamique via FedEx Rates API
3. En production, limiter à 1-3 jusqu'à implémentation du calcul dynamique

---

## Critères d'Acceptance (Gherkin)

```gherkin
Feature: Configurable magazine quantity on checkout

  # === QUANTITY SELECTOR ===

  Scenario: Default quantity is 1
    Given bride opens magazine checkout page
    When the page loads
    Then quantity selector should display "1"
    And total price should equal unit price of selected format

  Scenario: Selecting a different quantity
    Given bride on checkout page with ICONIC format ($59)
    When bride selects quantity 3
    Then displayed unit price should remain "$59.00"
    And displayed total should update to "$177.00"
    And checkout button should display "Checkout — $177.00"

  Scenario: Quantity range is 1 to 10
    Given bride on checkout page
    When bride opens quantity dropdown
    Then options 1 through 10 should be available
    And no other values should be selectable

  Scenario: Quantity persists after cancel and retry
    Given bride selected quantity 4
    And bride initiated checkout but cancelled in Stripe
    When bride returns to checkout page
    Then quantity should still be 4
    And total should reflect quantity 4

  # === PRICE CALCULATION ===

  Scenario: Price recalculates for each format
    Given bride with GUEST EDITION format ($29) and quantity 5
    When checkout page renders
    Then total should display "$145.00"

  Scenario: Price recalculates when quantity changes
    Given bride with COLLECTOR format ($89) and quantity 2
    When bride changes quantity to 3
    Then total should update from "$178.00" to "$267.00"

  # === STRIPE CHECKOUT ===

  Scenario: Quantity sent to Stripe checkout session
    Given bride with quantity 3 and ICONIC format
    When bride taps checkout button
    Then Edge Function receives quantity = 3
    And Stripe line_item has quantity = 3
    And Stripe displays correct total ($59 x 3 = $177 + shipping)

  Scenario: Stripe metadata includes quantity
    Given checkout session created with quantity 3
    When Stripe session metadata is inspected
    Then metadata should contain "quantity": "3"

  # === DATABASE ===

  Scenario: Order records quantity
    Given successful payment for quantity 2 MEMORY magazines
    When webhook creates order in magazine_orders
    Then magazine_orders.quantity should be 2
    And magazine_orders.magazine_price_cents should be 6900 (unit price)
    And magazine_orders.total_paid_cents should reflect 2 x $69 + shipping

  # === EDGE CASES ===

  Scenario: Quantity defaults to 1 if missing
    Given Edge Function receives request without quantity field
    When checkout session is created
    Then quantity should default to 1
    And behavior should be identical to current production

  # === SERVER-SIDE VALIDATION ===

  Scenario: Invalid quantity is clamped server-side
    Given malicious client sends quantity = 999
    When Edge Function processes request
    Then quantity should be clamped to 10
    And Stripe session should be created with quantity = 10

  Scenario: Negative quantity is rejected
    Given malicious client sends quantity = -5
    When Edge Function processes request
    Then quantity should be clamped to 1
    And Stripe session should be created with quantity = 1
```

---

## Fichiers à Modifier

| Fichier | Action | Détail |
|---------|--------|--------|
| `lib/features/my_wedding/presentation/bloc/magazine_checkout_state.dart` | **MODIFIER** | Ajouter champ `quantity` (default 1), computed `totalPriceCents` |
| `lib/features/my_wedding/presentation/bloc/magazine_checkout_cubit.dart` | **MODIFIER** | Ajouter méthode `updateQuantity(int)`, passer quantity à l'Edge Function |
| `lib/features/my_wedding/presentation/pages/magazine_checkout_page.dart` | **MODIFIER** | Ajouter widget sélecteur quantité dans `_buildContent()` |
| `lib/features/my_wedding/presentation/widgets/order_summary_card.dart` | **MODIFIER** | Accepter `quantity` + afficher prix unitaire, quantité, et total |
| `lib/features/my_wedding/domain/entities/magazine_order.dart` | **MODIFIER** | Ajouter champ `quantity` (default 1), adapter `fromJson` |
| `supabase/functions/create-magazine-checkout/index.ts` | **MODIFIER** | Accepter `quantity`, **clamp 1-10**, passer à Stripe `quantity: N`, ajouter en metadata |
| `supabase/functions/magazine-order-webhook/index.ts` | **MODIFIER** | Lire `metadata.quantity` et insérer dans `magazine_orders.quantity` |

### Migration DB (OBLIGATOIRE)

| Table | Modification |
|-------|-------------|
| `magazine_orders` | `ALTER TABLE magazine_orders ADD COLUMN quantity integer NOT NULL DEFAULT 1;` |

**CRITIQUE - Migration obligatoire** :

La migration DB n'est **PAS** optionnelle, elle est **BLOQUANTE** pour les raisons suivantes :

1. **Le webhook échouerait sans la colonne** : Si `magazine_orders.quantity` n'existe pas, l'insert du webhook (`quantity: parseInt(quantity || "1")`) provoquera une erreur PostgreSQL `column "quantity" does not exist`. Le webhook retournera HTTP 500, Stripe retentera, et aucune commande ne sera créée.

2. **Impossible de tester S09 sans la migration** : Les tests d'intégration qui créent des `MagazineOrder` échoueront car la DB ne peut pas accepter le champ `quantity`.

3. **Backward-compatibility garantie** : Le `DEFAULT 1` garantit que les commandes existantes (0 actuellement, mais potentiellement > 0 si déployé avant S09) auront `quantity = 1`, ce qui est correct (le code actuel hardcode `quantity: 1` ligne 182).

**Action requise avant toute implémentation de S09** :
```sql
-- Appliquer cette migration AVANT de déployer le code S09
ALTER TABLE magazine_orders ADD COLUMN quantity integer NOT NULL DEFAULT 1;
```

**Rollback plan** (si besoin de revert S09) :
```sql
-- La colonne peut être supprimée sans impact si S09 est revert
ALTER TABLE magazine_orders DROP COLUMN quantity;
```

---

## Détails Techniques

### 1. State (`magazine_checkout_state.dart`)

**À IMPLÉMENTER** - Ajouter au constructeur et aux champs :

```dart
/// Number of copies to order (1-10).
final int quantity;

/// Total price in cents = unit price x quantity.
int get totalPriceCents => format.priceCents * quantity;

/// Formatted total price.
String get totalPriceFormatted {
  final dollars = totalPriceCents ~/ 100;
  final cents = totalPriceCents % 100;
  if (cents == 0) return '\$$dollars';
  return '\$$dollars.${cents.toString().padLeft(2, '0')}';
}

/// canProceed updated:
bool get canProceed => cgvuAccepted && !isProcessing && quantity >= 1;
```

### 2. Cubit (`magazine_checkout_cubit.dart`)

**À IMPLÉMENTER** :

```dart
/// Updates the quantity of magazines to order.
void updateQuantity(int quantity) {
  if (quantity < 1 || quantity > 10) return;
  emit(state.copyWith(quantity: quantity));
}
```

Dans `initiateCheckout()`, ajouter `'quantity': state.quantity` au body de l'appel Edge Function.

### 3. UI - Quantity Selector (`magazine_checkout_page.dart`)

**À IMPLÉMENTER** - Ajouter entre ORDER SUMMARY et CGVU dans `_buildContent()` :

```dart
// Quantity Selector
const SizedBox(height: 30),
Text(
  'QUANTITY',
  style: LynewedTextStyles.sectionTitle.copyWith(
    letterSpacing: 1.2,
    fontSize: 12,
  ),
),
const SizedBox(height: 12),
_buildQuantitySelector(state),
```

Widget dropdown utilisant le Design System :

```dart
Widget _buildQuantitySelector(MagazineCheckoutState state) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: LynewedColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: LynewedColors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Number of copies', style: LynewedTextStyles.bodyMedium),
        DropdownButton<int>(
          value: state.quantity,
          underline: const SizedBox.shrink(),
          items: List.generate(10, (i) => i + 1)
              .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
              .toList(),
          onChanged: (value) {
            if (value != null) _cubit.updateQuantity(value);
          },
        ),
      ],
    ),
  );
}
```

### 4. OrderSummaryCard (`order_summary_card.dart`)

**À IMPLÉMENTER** - Ajouter paramètre `quantity` (default 1). Modifier l'affichage pricing :

```
Magazine (ICONIC)              $59.00
Quantity                       x 3
─────────────────────────────────────
Subtotal                       $177.00
Shipping calculated at checkout
```

### 5. Edge Function (`create-magazine-checkout/index.ts`)

**À IMPLÉMENTER** :

```typescript
interface CheckoutRequest {
  // ... existing fields ...
  quantity?: number; // NEW - defaults to 1
}

// After parsing body (ligne 91):
const quantity = Math.min(Math.max(body.quantity || 1, 1), 10); // Clamp 1-10

// In stripe.checkout.sessions.create (ligne 168):
line_items: [
  {
    price_data: {
      currency: "usd",
      product_data: {
        name: `Lynewed Magazine - ${formatName}`,
        description: `${formatSize} • ${body.photo_count} photos`,
        images: ["https://lynewed.com/images/magazine-preview.jpg"],
      },
      unit_amount: magazinePriceCents,
    },
    quantity: quantity, // WAS: 1 (ligne 182)
  },
],

// In metadata (ligne 223):
metadata: {
  product_type: "magazine",
  wedding_id: body.wedding_id,
  bride_user_id: body.bride_user_id,
  magazine_format: body.magazine_format,
  magazine_price_cents: magazinePriceCents.toString(),
  photo_count: body.photo_count.toString(),
  magazine_title: body.magazine_title,
  magazine_date: body.magazine_date || "",
  cover_photo_id: body.cover_photo_id || "",
  quantity: quantity.toString(), // NEW
},
```

**Justifications** :

1. **Validation serveur-side** : Le clamp `Math.min(Math.max(...))` garantit que quantity est toujours entre 1 et 10, même si un client malveillant envoie une valeur invalide (0, -5, 999, etc.). **OBLIGATOIRE** pour sécurité.

2. **Metadata complète** : La quantity est ajoutée aux metadata Stripe pour être lue par le webhook. Sans cela, le webhook ne peut pas enregistrer la quantité dans `magazine_orders.quantity`.

3. **Range 1-10 justifié** :
   - **Cas d'usage réel** : Une mariée commande typiquement 1-3 magazines (elle-même, parents, beaux-parents). 10 exemplaires couvre largement les cas "famille élargie" ou "cadeaux témoins".
   - **Fraude/abus** : Limiter à 10 évite les commandes aberrantes (999 magazines = $59,000+) qui pourraient être des tests de cartes volées ou des bugs.
   - **Stripe line_item quantity** : Stripe accepte des quantités élevées, mais le clamp protège contre les erreurs UX (slider à 1000 par accident).
   - **Si besoin > 10** : La mariée peut passer plusieurs commandes, ou contacter le support pour une commande bulk (traitement manuel).
   - **⚠️ Shipping flat-rate** : Le flat-rate $15 actuel ne couvre pas les commandes >3 magazines. Voir section "Analyse Frais de Port" ci-dessus.

   **Recommandation** : Garder 1-10 pour MVP. Documenter que >3 magazines nécessite recalcul shipping dynamique (story future EPIC-16).

### 6. MagazineOrder Entity

**À IMPLÉMENTER** :

```dart
// Add to constructor:
this.quantity = 1,

// Add field:
final int quantity;

// Update fromJson:
quantity: json['quantity'] as int? ?? 1,
```

### 7. Webhook (`magazine-order-webhook/index.ts`)

**À IMPLÉMENTER** - Le webhook doit lire `metadata.quantity` et l'enregistrer dans `magazine_orders.quantity`.

**Modifications requises** :

```typescript
// Dans processMagazineOrder, ligne 134 (destructuring metadata):
const {
  wedding_id,
  bride_user_id,
  magazine_format,
  photo_count,
  magazine_price_cents,
  magazine_title,
  magazine_date,
  cover_photo_id,
  quantity, // NEW - ajouter cette ligne
} = metadata;

// Dans l'insert magazine_orders, ligne 198:
const { data: order, error: orderError } = await db
  .from("magazine_orders")
  .insert({
    wedding_id,
    bride_user_id,
    stripe_checkout_session_id: session.id,
    stripe_payment_intent_id: paymentIntentId,
    magazine_format,
    magazine_price_cents: parseInt(magazine_price_cents || "0"),
    shipping_cost_cents: shippingCostCents,
    total_paid_cents: session.amount_total || 0,
    currency: (session.currency || "usd").toUpperCase(),
    shipping_name: shippingInfo?.name || "",
    shipping_address_line1: shippingInfo?.address?.line1 || "",
    shipping_address_line2: shippingInfo?.address?.line2 || null,
    shipping_city: shippingInfo?.address?.city || "",
    shipping_zip: shippingInfo?.address?.postal_code || "",
    shipping_country: shippingInfo?.address?.country || "",
    shipping_phone: session.customer_details?.phone || null,
    magazine_title: magazine_title || "Wedding Magazine",
    magazine_date: magazine_date || null,
    cover_photo_id: cover_photo_id || null,
    photo_count: parseInt(photo_count || "0"),
    quantity: parseInt(quantity || "1"), // NEW - default 1 si absent (backward-compat)
    status: "paid",
    paid_at: now,
  })
  .select()
  .single();
```

**Justifications** :

Sans lire `metadata.quantity`, le webhook créerait toujours des commandes avec `quantity = NULL` (ou défaut DB = 1), même si la mariée a payé 5 magazines. **BLOQUANT** car :
- **Cohérence données** : Impossible de savoir combien de magazines ont été payés
- **Service client** : En cas de litige, aucune traçabilité du nombre commandé
- **Comptabilité** : Le `total_paid_cents` inclut 5 magazines, mais la DB dit "quantity = 1"

Le `|| "1"` dans `parseInt(quantity || "1")` garantit la **backward-compatibility** : Si le webhook reçoit un ancien événement Stripe (avant implémentation S09), il enregistre quantity = 1 par défaut.

---

## UI Wireframe

```
CHECKOUT SCREEN (with quantity selector)
+-------------------------------------------+
|  [<-]  Order Magazine                      |
|-------------------------------------------|
|                                            |
|  ORDER SUMMARY                             |
|  +--------------------------------------+  |
|  | [cover]  ICONIC Wedding Magazine      |  |
|  | preview  21x30cm - 40 spreads         |  |
|  |          25 photos                    |  |
|  |                                       |  |
|  | Magazine (ICONIC)          $59.00     |  |
|  | Quantity                   x 3        |  |
|  | --------------------------------      |  |
|  | Subtotal                   $177.00    |  |
|  | Shipping calculated at checkout       |  |
|  +--------------------------------------+  |
|                                            |
|  QUANTITY                                  |
|  +--------------------------------------+  |
|  | Number of copies            [3  v]   |  |
|  +--------------------------------------+  |
|                                            |
|  ⚠️ Note: Shipping cost may increase for  |
|     orders >3 magazines due to weight     |
|                                            |
|  +--------------------------------------+  |
|  | [x] I have read and accept the       |  |
|  |     Terms of Purchase                |  |
|  +--------------------------------------+  |
|                                            |
|         [Checkout -- $177.00]              |
|                                            |
+-------------------------------------------+
```

---

## Tests à Écrire

### Unit Tests

| Fichier test | Scénarios |
|-------------|-----------|
| `test/features/my_wedding/presentation/bloc/magazine_checkout_cubit_test.dart` | `updateQuantity` clamp 1-10, quantity dans initiateCheckout body |
| `test/features/my_wedding/presentation/bloc/magazine_checkout_state_test.dart` | `totalPriceCents` = unit x quantity, `totalPriceFormatted`, copyWith quantity |
| `test/features/my_wedding/presentation/widgets/order_summary_card_test.dart` | Affichage avec quantity > 1, subtotal correct |
| `test/features/my_wedding/domain/entities/magazine_order_test.dart` | `fromJson` avec et sans quantity, default = 1 |

### Widget Tests

| Fichier test | Scénarios |
|-------------|-----------|
| `test/features/my_wedding/presentation/pages/magazine_checkout_page_test.dart` | Dropdown présent, sélection met à jour le prix, bouton affiche total |

### Integration Tests

| Fichier test | Scénarios |
|-------------|-----------|
| `test/integration/magazine_checkout_flow_test.dart` | E2E : Flutter → Edge Function → Stripe → Webhook → DB (vérifier quantity cohérent à chaque étape) |

### Stratégie TDD

1. **RED** : Test `totalPriceCents` avec quantity = 3 et format ICONIC -> expect 17700
2. **GREEN** : Ajouter champ `quantity` au state, computed `totalPriceCents`
3. **REFACTOR** : Extraire formatting dans helper si nécessaire
4. Répéter pour cubit, widget, entity

---

## Validation INVEST

| Critère | Validation |
|---------|------------|
| **Independent** | Dépend uniquement de la migration DB (peut être appliquée indépendamment). Aucune autre story EPIC-15 ne modifie ces fichiers |
| **Negotiable** | Le range 1-10 est négociable (recommandation : 1-3 pour MVP). Le widget (dropdown vs stepper) est négociable |
| **Valuable** | Permet de commander plusieurs exemplaires d'un magazine (cadeau famille, témoins). Demande explicite de Thierry (BUG-07) |
| **Estimable** | 8 points - modifications sur 7 fichiers identifiés + migration DB + tests E2E + analyse shipping |
| **Small** | Pas de nouvelle page/feature. Ajout d'un champ + widget dans un flow existant. Peut être complété en 1-2 jours |
| **Testable** | Critères Gherkin précis, calculs mathématiques vérifiables, tests unitaires clairs, tests E2E pour cohérence |

---

## Vérification Conflits Fichiers

| Fichier | Aussi modifié par | Risque |
|---------|-------------------|--------|
| `magazine_checkout_page.dart` | Aucune autre story S01-S10 | AUCUN |
| `magazine_checkout_cubit.dart` | Aucune autre story S01-S10 | AUCUN |
| `magazine_checkout_state.dart` | Aucune autre story S01-S10 | AUCUN |
| `order_summary_card.dart` | Aucune autre story S01-S10 | AUCUN |
| `magazine_order.dart` | Aucune autre story S01-S10 | AUCUN |
| `create-magazine-checkout/index.ts` | Aucune autre story S01-S10 | AUCUN |
| `magazine-order-webhook/index.ts` | Aucune autre story S01-S10 | AUCUN |

Aucun conflit de fichiers avec les stories parallèles.

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|-----------|
| **Frais de port flat-rate $15 insuffisant pour >3 magazines** | Pertes financières si mariées commandent 5-10 magazines | ÉLEVÉE | Limiter UI à 1-3 pour MVP OU ajouter warning "Shipping cost may increase" OU intégrer FedEx Rates API |
| **Migration DB oubliée** | Webhook échoue, aucune commande créée | MOYENNE | Ajouter migration dans checklist pré-déploiement, test E2E vérifie colonne existe |
| **Validation client-side contournée** | Client malveillant envoie quantity=999 | FAIBLE | Validation serveur-side (clamp 1-10) dans Edge Function |
| **Backward-compatibility** | Anciens webhooks échouent si quantity obligatoire | FAIBLE | `DEFAULT 1` dans migration + `|| "1"` dans webhook |

---

## Notes Importantes

- **Migration DB OBLIGATOIRE** : Appliquer `ALTER TABLE magazine_orders ADD COLUMN quantity integer NOT NULL DEFAULT 1;` AVANT toute implémentation de S09. Sans cette migration, le webhook échouera avec une erreur PostgreSQL et aucune commande ne sera créée.
- **Backward-compatibility** : Le `DEFAULT 1` de la migration et les `|| 1` dans le code garantissent que le système fonctionne avec les anciennes données et les anciens webhooks Stripe (avant S09).
- **Validation serveur-side** : Le clamp `Math.min(Math.max(quantity, 1), 10)` dans l'Edge Function est **obligatoire** pour éviter les abus (commandes de 999 magazines) et les bugs UX (quantity négative/nulle).
- **Frais de port** : Les shipping_options Stripe sont par session, pas par item. Commander 3 magazines = 1 seul envoi. **ATTENTION** : Le flat-rate $15 actuel ne couvre pas les commandes >3 magazines (voir "Analyse Frais de Port").
- **Prix unitaire vs total** : `magazine_price_cents` dans `magazine_orders` reste le prix UNITAIRE (ex: 5900 pour ICONIC). Le `total_paid_cents` est le montant total payé (quantity × unit + shipping), calculé par Stripe.
- **Webhook** : DOIT lire `metadata.quantity` et l'insérer dans `magazine_orders.quantity`. Sans cela, impossible de tracer combien de magazines ont été commandés.
- **⚠️ SHIPPING LIMITATION** : Le range 1-10 est implémenté côté UI/Edge Function, mais le flat-rate shipping actuel ($15 FedEx Ground) ne s'adapte PAS en fonction de la quantité. **Recommandation** : Limiter à 1-3 pour MVP ou implémenter FedEx Rates API dans une story future (EPIC-16).

---

## Story Suivante Suggérée (EPIC-16)

**S10-dynamic-shipping-calculation** : Intégrer FedEx Rates API pour calculer dynamiquement les frais de port en fonction de quantity, dimensions, et poids. Remplacer le flat-rate $15 par un calcul temps réel. Permet de supporter range 1-10 sans pertes financières.

**Dépendances** : S09 (quantity selector) doit être implémenté en premier.

**Estimation** : 13 points (L) - Intégration API FedEx, Edge Function calcul shipping, tests E2E avec sandbox FedEx.
