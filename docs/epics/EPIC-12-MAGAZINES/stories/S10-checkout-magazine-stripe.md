# S10 - Checkout Magazine with Stripe

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Flutter UI + Stripe
> **MAJ** : 2026-02-03

---

## Description

Formulaire de commande magazine avec paiement Stripe integre. Inclut prix dynamique selon format selectionne, frais de port FedEx, adresse livraison, et acceptation CGVU.

## Dependances

- S03 (magazine_orders table)
- S09 (magazine preview + format selection)
- EPIC-11 ✅ (Stripe integration)
- S12 (CGVU magazine modal)
- Table `cgvu_acceptances` (EPIC-11) ✅
- Table `app_config` avec pricing dynamique

## Note Importante (MAJ 2026-02-03)

> **4 formats avec prix differents** - Le format est selectionne dans S09 (Preview) et passe au checkout.
> Les frais de port sont calcules dynamiquement via FedEx API.

| Format | Prix |
|--------|------|
| GUEST EDITION | $29 |
| ICONIC | $59 |
| MEMORY | $69 |
| COLLECTOR | $89 |

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine checkout with Stripe (4 formats)

  # === ORDER SUMMARY ===
  Scenario: Displaying order summary with selected format
    Given bride on checkout screen with ICONIC format selected
    When screen loads
    Then should display:
      - Magazine preview thumbnail
      - Format name "ICONIC"
      - Photo count (e.g., "25 photos")
      - Magazine price ($59.00)
      - Shipping cost (calculated by FedEx)
      - Total with tax if applicable

  Scenario: Shipping cost calculation via FedEx
    Given bride entering address
    When address is complete
    Then FedEx API should be called to calculate shipping
    And shipping cost should update dynamically
    And estimated delivery time should display

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

  Scenario: Address validation via FedEx
    Given address entered
    When bride proceeds
    Then FedEx Address Validation API should verify
    And if invalid, suggestion should appear

  Scenario: Validating incomplete address
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
      - magazine_format (guest_edition|iconic|memory|collector)
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
CHECKOUT SCREEN (with selected format)
┌─────────────────────────────────────────────────────────────────────────┐
│  [←]  Order Magazine                                                    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  ORDER SUMMARY                                                          │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  ┌─────────┐                                                      │ │
│  │  │ [cover] │  ICONIC Wedding Magazine                            │ │
│  │  │ preview │  21×30cm • 40 spreads                               │ │
│  │  └─────────┘  25 photos                                          │ │
│  │                                                                   │ │
│  │  Magazine (ICONIC)                                    $59.00      │ │
│  │  Shipping (FedEx Express)                            $18.50      │ │
│  │  Estimated delivery: Feb 15-18                                   │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │  Total                                               $77.50      │ │
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
│                    [Pay $77.50 with Stripe]                             │
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
│    Your ICONIC magazine is being prepared.                              │
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
| `lib/features/my_wedding/domain/usecases/calculate_shipping_use_case.dart` | Nouveau (FedEx) |

### FedEx Shipping Calculation

```dart
// Calculate shipping via FedEx Rates API
Future<ShippingQuote> calculateShipping({
  required ShippingAddress fromAddress,  // Thierry's warehouse
  required ShippingAddress toAddress,    // Customer
  required String magazineFormat,        // For weight/dimensions
}) async {
  // Magazine dimensions vary by format
  final dimensions = switch (magazineFormat) {
    'guest_edition' || 'iconic' || 'memory' => PackageDimensions(
      length: 30, width: 21, height: 2, // cm
      weight: 0.8, // kg
    ),
    'collector' => PackageDimensions(
      length: 32, width: 25, height: 2, // cm
      weight: 1.2, // kg
    ),
    _ => throw ArgumentError('Unknown format'),
  };

  final response = await fedexClient.getRates(
    shipper: fromAddress,
    recipient: toAddress,
    package: dimensions,
  );

  return ShippingQuote(
    priceCents: response.totalCents,
    estimatedDelivery: response.estimatedDelivery,
    carrier: 'FedEx',
  );
}
```

### Stripe Checkout Session

```dart
// Create Stripe Checkout Session via Edge Function
Future<String> createCheckoutSession({
  required String weddingId,
  required String brideUserId,
  required String magazineFormat,     // NEW: format ID
  required int magazinePriceCents,    // Price varies by format
  required int shippingCostCents,     // FedEx calculated
  required int photoCount,
  required String magazineTitle,
  required DateTime? magazineDate,
}) async {
  final response = await supabase.functions.invoke(
    'create-magazine-checkout',
    body: {
      'wedding_id': weddingId,
      'bride_user_id': brideUserId,
      'magazine_format': magazineFormat,
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

// Format display names
const formatNames: Record<string, string> = {
  guest_edition: 'GUEST EDITION',
  iconic: 'ICONIC',
  memory: 'MEMORY',
  collector: 'COLLECTOR',
};

Deno.serve(async (req) => {
  const {
    wedding_id,
    bride_user_id,
    magazine_format,
    magazine_price_cents,
    shipping_cost_cents,
    photo_count,
    magazine_title,
    magazine_date,
    success_url,
    cancel_url,
  } = await req.json();

  const formatName = formatNames[magazine_format] || magazine_format;

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    mode: 'payment',
    line_items: [
      {
        price_data: {
          currency: 'usd',
          product_data: {
            name: `Lynewed Magazine - ${formatName}`,
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
            name: 'Shipping (FedEx)',
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
      magazine_format,
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

- [ ] Order summary affiche format selectionne
- [ ] Prix correct selon format (29/59/69/89)
- [ ] Shipping calcule via FedEx
- [ ] Validation adresse (FedEx Address Validation)
- [ ] CGVU bloque paiement si non accepte
- [ ] Stripe Checkout ouvre avec bon montant
- [ ] Success redirect fonctionne
- [ ] Error handling
- [ ] Cancel preserves data
- [ ] Metadata inclut magazine_format

## Notes

- Prix en centimes dans Stripe
- Metadata passe au webhook pour creer order (S11)
- Deep link pour retour app (success/cancel)
- Log cgvu_acceptances avant paiement
- **FedEx API** pour frais de port dynamiques (voir CLAUDE.md)
- **4 formats** avec prix differents (MAJ 2026-02-03)
