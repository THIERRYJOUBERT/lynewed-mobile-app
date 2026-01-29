# S10 - Checkout Magazine with Stripe

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Flutter UI + Stripe

---

## Description

Formulaire de commande magazine avec paiement Stripe integre. Inclut prix, frais de port, adresse livraison, et acceptation CGVU.

## Dependances

- S03 (magazine_orders table)
- S09 (magazine preview)
- EPIC-11 (Stripe integration)
- S12 (CGVU magazine modal)
- Table `cgvu_acceptances` (EPIC-11)
- Table `app_config` avec pricing dynamique

## Note Technique Importante

**Prix dynamique** : Les prix ($49.00, $15.00, $35.00) ne doivent PAS être hardcodés dans l'app. Ils doivent être récupérés depuis `app_config` au chargement de l'écran :

```dart
// Dans checkout cubit
final pricing = await getMagazinePricingUseCase();
// pricing.basePriceCents, pricing.shippingDomesticCents, pricing.shippingInternationalCents
```

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine checkout with Stripe

  # === ORDER SUMMARY ===
  Scenario: Displaying order summary
    Given bride on checkout screen
    When screen loads
    Then should display:
      - Magazine preview thumbnail
      - Photo count (e.g., "20 photos")
      - Magazine price ($49.00)
      - Shipping cost ($15.00 domestic / $35.00 international)
      - Total with tax if applicable

  Scenario: Shipping cost calculation
    Given bride entering address
    When country is USA
    Then shipping should be $15.00

    When country is not USA
    Then shipping should be $35.00 (international)

  # === SHIPPING ADDRESS ===
  Scenario: Entering shipping address
    Given checkout screen
    When bride fills address form
    Then required fields:
      - Full name *
      - Address line 1 *
      - Address line 2 (optional)
      - City *
      - ZIP/Postal code *
      - Country * (dropdown)
      - Phone (optional)

  Scenario: Validating address
    Given incomplete address
    When bride tries to proceed
    Then error highlights missing fields
    And "Please fill all required fields"

  # === CGVU ===
  Scenario: CGVU acceptance required
    Given address filled correctly
    When bride has not accepted CGVU
    Then pay button should be disabled
    And message "Please accept terms to continue"

  Scenario: Opening CGVU
    Given checkout screen
    When bride taps "Terms of Purchase"
    Then CGVU modal should open (S12)

  # === PAYMENT ===
  Scenario: Initiating Stripe payment
    Given address filled and CGVU accepted
    When bride taps "Pay $XX.XX"
    Then Stripe Checkout should open
    And metadata should include:
      - wedding_id
      - bride_user_id
      - magazine_price_cents
      - shipping_cost_cents
      - photo_count

  Scenario: Successful payment
    Given Stripe payment succeeds
    When Stripe redirects back
    Then confirmation screen should show
    And order number displayed
    And message "Your magazine order is confirmed!"

  Scenario: Payment failure
    Given Stripe payment fails
    When error occurs
    Then error message displayed
    And bride can retry
    And no order created

  Scenario: Payment cancelled
    Given bride cancels in Stripe
    When redirected back
    Then checkout screen returns
    And selections preserved
```

## Details Techniques

### UI Components

```
CHECKOUT SCREEN
┌─────────────────────────────────────────────────────────────────────────┐
│  [←]  Order Magazine                                                    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  ORDER SUMMARY                                                          │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  ┌─────────┐                                                      │ │
│  │  │ [cover] │  Wedding Magazine                                    │ │
│  │  │ preview │  20 photos                                           │ │
│  │  └─────────┘                                                      │ │
│  │                                                                   │ │
│  │  Magazine                                           $49.00        │ │
│  │  Shipping (USA)                                     $15.00        │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │  Total                                              $64.00        │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  SHIPPING ADDRESS                                                       │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Full name *                                                      │ │
│  │  [____________________________________________________]          │ │
│  │                                                                   │ │
│  │  Address line 1 *                                                 │ │
│  │  [____________________________________________________]          │ │
│  │                                                                   │ │
│  │  Address line 2                                                   │ │
│  │  [____________________________________________________]          │ │
│  │                                                                   │ │
│  │  City *                       ZIP *                               │ │
│  │  [_______________________]   [_______________]                    │ │
│  │                                                                   │ │
│  │  Country *                                                        │ │
│  │  [United States                                    ▼]             │ │
│  │                                                                   │ │
│  │  Phone (optional)                                                 │ │
│  │  [____________________________________________________]          │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  [☐] I have read and accept the [Terms of Purchase]               │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│                    [Pay $64.00 with Stripe]                             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

CONFIRMATION SCREEN
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                              ✓                                          │
│                                                                         │
│                   Order Confirmed!                                      │
│                                                                         │
│                   Order #12345                                          │
│                                                                         │
│    Your magazine is being prepared.                                     │
│    You will receive it within 2-3 weeks.                                │
│                                                                         │
│    We'll send you tracking information                                  │
│    once your order ships.                                               │
│                                                                         │
│                   [View My Orders]                                      │
│                   [Back to Home]                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/presentation/pages/magazine_checkout_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/order_summary_card.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/shipping_address_form.dart` | Nouveau |
| `lib/features/my_wedding/presentation/cubit/magazine_checkout_cubit.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/create_checkout_session_use_case.dart` | Nouveau |

### Stripe Checkout Session

```dart
// Create Stripe Checkout Session via Edge Function
Future<String> createCheckoutSession({
  required String weddingId,
  required String brideUserId,
  required int magazinePriceCents,
  required int shippingCostCents,
  required int photoCount,
  required String magazineTitle,
  required DateTime? magazineDate,
}) async {
  final response = await supabase.functions.invoke(
    'create-magazine-checkout',
    body: {
      'wedding_id': weddingId,
      'bride_user_id': brideUserId,
      'magazine_price_cents': magazinePriceCents,
      'shipping_cost_cents': shippingCostCents,
      'photo_count': photoCount,
      'magazine_title': magazineTitle,
      'magazine_date': magazineDate?.toIso8601String(),
      'success_url': 'lynewed://magazine-order-success',
      'cancel_url': 'lynewed://magazine-checkout',
    },
  );

  return response.data['checkout_url'];
}
```

### Edge Function: create-magazine-checkout

```typescript
// supabase/functions/create-magazine-checkout/index.ts
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

Deno.serve(async (req) => {
  const {
    wedding_id,
    bride_user_id,
    magazine_price_cents,
    shipping_cost_cents,
    photo_count,
    magazine_title,
    magazine_date,
    success_url,
    cancel_url,
  } = await req.json();

  const totalCents = magazine_price_cents + shipping_cost_cents;

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    mode: 'payment',
    line_items: [
      {
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Lynewed Wedding Magazine',
            description: `${photo_count} photos`,
          },
          unit_amount: magazine_price_cents,
        },
        quantity: 1,
      },
      {
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Shipping',
          },
          unit_amount: shipping_cost_cents,
        },
        quantity: 1,
      },
    ],
    shipping_address_collection: {
      allowed_countries: ['US', 'CA', 'GB', 'FR', 'DE', 'IT', 'ES', 'AU'],
    },
    metadata: {
      wedding_id,
      bride_user_id,
      magazine_price_cents: magazine_price_cents.toString(),
      shipping_cost_cents: shipping_cost_cents.toString(),
      photo_count: photo_count.toString(),
      magazine_title,
      magazine_date: magazine_date || '',
    },
    success_url,
    cancel_url,
  });

  return new Response(JSON.stringify({
    checkout_url: session.url,
    session_id: session.id,
  }));
});
```

## Tests

- [ ] Order summary affiche correctement
- [ ] Shipping calcule selon pays
- [ ] Validation adresse
- [ ] CGVU bloque paiement si non accepte
- [ ] Stripe Checkout ouvre
- [ ] Success redirect fonctionne
- [ ] Error handling
- [ ] Cancel preserves data

## Notes

- Prix en centimes dans Stripe
- Metadata passe au webhook pour creer order
- Deep link pour retour app (success/cancel)
- Log cgvu_acceptances avant paiement
