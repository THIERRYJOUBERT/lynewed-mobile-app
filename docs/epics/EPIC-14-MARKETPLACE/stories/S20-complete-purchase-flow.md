# Story S20: Flow achat complet

## Description
En tant qu'acheteuse, je veux completer un achat avec paiement securise, afin de recevoir l'article chez moi.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a buyer clicking "Buy Now" Then checkout flow starts: Step 1 Enter/confirm shipping address, Step 2 View shipping options from FedEx, Step 3 Review order summary (item + shipping = total), Step 4 Accept CGVU if first purchase, Step 5 Payment via Stripe, Step 6 Confirmation screen
- [ ] Given successful Stripe payment Then transaction should be created with status 'paid' And listing status should be 'reserved' And seller should be notified
- [ ] Given checkout with an accepted offer Then the agreed price should be used instead of listing price
- [ ] Given invalid shipping address When calculating shipping Then user should see error and address suggestions
- [ ] Given payment failure Then user should see error message And be able to retry

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/checkout_page.dart` - Main checkout flow
- `lib/features/marketplace/presentation/widgets/address_form_widget.dart` - Shipping address
- `lib/features/marketplace/presentation/widgets/shipping_options_widget.dart` - FedEx options
- `lib/features/marketplace/presentation/widgets/order_summary_widget.dart` - Price breakdown
- `lib/features/marketplace/presentation/pages/order_confirmation_page.dart` - Success screen
- `lib/features/marketplace/data/datasources/payment_remote_datasource.dart` - Stripe API
- `lib/features/marketplace/domain/usecases/create_payment_intent.dart` - Use case
- `lib/features/marketplace/domain/usecases/complete_purchase.dart` - Use case
- `supabase/functions/marketplace-create-payment/index.ts` - Edge Function

### A Modifier
- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - "Buy Now" navigation

## Notes Techniques

### Checkout Page (Multi-step)
```dart
class CheckoutPage extends ConsumerStatefulWidget {
  final ListingEntity listing;
  final String? offerId;
  final int? agreedPriceCents; // If from accepted offer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        steps: [
          // Step 1: Shipping Address
          Step(
            title: const Text('Shipping Address'),
            content: AddressFormWidget(
              initialAddress: _shippingAddress,
              onChanged: (address) => setState(() => _shippingAddress = address),
            ),
          ),

          // Step 2: Shipping Options
          Step(
            title: const Text('Shipping'),
            content: ShippingOptionsWidget(
              fromAddress: listing.locationAddress,
              toAddress: _shippingAddress,
              onSelected: (option) => setState(() => _selectedShipping = option),
            ),
          ),

          // Step 3: Review
          Step(
            title: const Text('Review'),
            content: OrderSummaryWidget(
              itemPriceCents: agreedPriceCents ?? listing.priceCents,
              shippingCents: _selectedShipping?.rateCents ?? 0,
              listing: listing,
            ),
          ),

          // Step 4: Payment
          Step(
            title: const Text('Payment'),
            content: PaymentWidget(
              totalCents: _totalCents,
              onPaymentSuccess: _handlePaymentSuccess,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Shipping Options Widget
```dart
class ShippingOptionsWidget extends ConsumerWidget {
  final Address fromAddress;
  final Address toAddress;
  final Function(ShippingOption) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(shippingRatesProvider(
      ShippingRateParams(from: fromAddress, to: toAddress),
    ));

    return ratesAsync.when(
      data: (rates) => Column(
        children: rates.map((rate) => RadioListTile<ShippingOption>(
          title: Text(rate.serviceName),
          subtitle: Text('${rate.estimatedDays} days'),
          secondary: Text('\$${rate.priceFormatted}'),
          value: rate,
          groupValue: _selected,
          onChanged: (value) => onSelected(value!),
        )).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

### Order Summary Widget
```dart
class OrderSummaryWidget extends StatelessWidget {
  final int itemPriceCents;
  final int shippingCents;
  final ListingEntity listing;

  int get totalCents => itemPriceCents + shippingCents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Item preview
        ListingMiniCard(listing: listing),

        const Divider(),

        // Price breakdown
        _PriceRow(label: 'Item', amount: itemPriceCents),
        _PriceRow(label: 'Shipping', amount: shippingCents),
        const Divider(),
        _PriceRow(label: 'Total', amount: totalCents, isBold: true),
      ],
    );
  }
}
```

### Edge Function: marketplace-create-payment
```typescript
Deno.serve(async (req) => {
  const {
    listing_id,
    offer_id,
    buyer_id,
    shipping_to_address,
    shipping_option,
  } = await req.json();

  // 1. Get listing and validate
  const { data: listing } = await supabase
    .from('marketplace_listings')
    .select('*')
    .eq('id', listing_id)
    .eq('status', 'active')
    .single();

  if (!listing) throw new Error('Listing not available');

  // 2. Get price (from offer if applicable)
  let itemPriceCents = listing.price_cents;
  if (offer_id) {
    const { data: offer } = await supabase
      .from('marketplace_offers')
      .select('*')
      .eq('id', offer_id)
      .eq('status', 'accepted')
      .single();

    if (offer) itemPriceCents = offer.amount_cents;
  }

  // 3. Calculate commission
  const platformFeeCents = Math.round(itemPriceCents * 0.10);
  const sellerPayoutCents = itemPriceCents - platformFeeCents;
  const totalCents = itemPriceCents + shipping_option.rate_cents;

  // 4. Get seller's Stripe account
  const { data: sellerStripe } = await supabase
    .from('stripe_accounts')
    .select('stripe_account_id')
    .eq('user_id', listing.seller_id)
    .single();

  // 5. Create Payment Intent with destination charges
  const paymentIntent = await stripe.paymentIntents.create({
    amount: totalCents,
    currency: 'usd',
    transfer_data: {
      destination: sellerStripe.stripe_account_id,
      amount: sellerPayoutCents, // Seller gets 90% of item price
    },
    metadata: {
      listing_id,
      offer_id: offer_id || '',
      buyer_id,
      item_price_cents: itemPriceCents,
      shipping_cents: shipping_option.rate_cents,
      platform_fee_cents: platformFeeCents,
    },
  });

  return new Response(JSON.stringify({
    client_secret: paymentIntent.client_secret,
    payment_intent_id: paymentIntent.id,
  }));
});
```

### After Payment Success
```dart
Future<void> _handlePaymentSuccess(String paymentIntentId) async {
  // Edge function webhook will:
  // 1. Create marketplace_transaction
  // 2. Update listing status to 'reserved'
  // 3. Send notification to seller

  // Navigate to confirmation
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OrderConfirmationPage(transactionId: transactionId),
    ),
  );
}
```

## Definition of Done
- [ ] Checkout flow multi-step complete
- [ ] Address form avec validation
- [ ] Shipping options depuis FedEx
- [ ] Order summary avec breakdown
- [ ] CGVU check (S09)
- [ ] Stripe payment integration
- [ ] Transaction creee apres paiement
- [ ] Listing reserve
- [ ] Seller notifie
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 8
**Complexite** : Haute
**Risque** : Haut (paiements, plusieurs integrations)

## Dependances
- S04 (marketplace_transactions)
- S09 (CGVU buyer)
- S10 (Stripe Connect)
- S11 (FedEx Rate API)

## Stories Dependantes
- S21 (generation etiquette - apres paiement)
- S23 (notifications - vente confirmee)
