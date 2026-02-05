# Story S20: Complete Purchase Flow

## Description
As a buyer, I want to complete a purchase with secure payment, so I can receive the item at my address.

## Acceptance Criteria (Gherkin)

- [ ] Given a buyer clicking "Buy Now" Then checkout flow starts with 5 steps: (1) Enter/confirm shipping address, (2) View shipping options from FedEx, (3) Review order summary (item + shipping + commission breakdown), (4) Accept CGVU if first marketplace purchase, (5) Payment via Stripe with 3DS support
- [ ] Given successful Stripe payment When webhook receives payment_intent.succeeded Then marketplace_transaction should be created with status 'paid' And listing status should become 'reserved' And seller should be notified And buyer should be notified
- [ ] Given checkout with an accepted offer When calculating total Then the agreed price should be used instead of listing price And offer_id should be passed to Edge Function
- [ ] Given invalid shipping address When calculating shipping Then user should see error with FedEx address suggestions
- [ ] Given payment failure (card declined, 3DS failed) Then user should see clear error message And be able to retry And transaction status should be 'failed' with error details
- [ ] Given payment requiring 3DS When Stripe returns requires_action Then client should call confirmPaymentIntent And handle 3DS redirect/popup And complete payment after authentication

## Prerequisites

- [ ] S04 completed (marketplace_transactions table exists)
- [ ] S09 completed (cgvu_acceptances table for buyer CGVU)
- [ ] S10 completed (Stripe Connect onboarding for sellers)
- [ ] S11 completed (Edge Function fedex-rate for shipping options)
- [ ] Design System components available
- [ ] notifications_outbox table exists

## Entity Definitions

### TransactionEntity

```dart
import 'package:flutter/foundation.dart';

/// Represents a marketplace transaction after payment.
@immutable
class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    this.offerId,
    required this.itemPriceCents,
    required this.shippingCents,
    required this.platformFeeCents,
    required this.sellerPayoutCents,
    required this.totalCents,
    required this.status,
    required this.stripePaymentIntentId,
    this.stripeTransferId,
    required this.shippingToAddress,
    required this.shippingFromAddress,
    this.fedexTrackingNumber,
    this.fedexLabelUrl,
    this.errorMessage,
    this.errorCode,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String? offerId;
  final int itemPriceCents;
  final int shippingCents;
  final int platformFeeCents;
  final int sellerPayoutCents;
  final int totalCents;
  final String status; // 'pending', 'paid', 'label_created', 'shipped', 'in_transit', 'delivered', 'completed', 'failed', 'disputed', 'refunded'
  final String stripePaymentIntentId;
  final String? stripeTransferId;
  final Map<String, dynamic> shippingToAddress;
  final Map<String, dynamic> shippingFromAddress;
  final String? fedexTrackingNumber;
  final String? fedexLabelUrl;
  final String? errorMessage;
  final String? errorCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;

  double get itemPriceFormatted => itemPriceCents / 100;
  double get shippingFormatted => shippingCents / 100;
  double get platformFeeFormatted => platformFeeCents / 100;
  double get sellerPayoutFormatted => sellerPayoutCents / 100;
  double get totalFormatted => totalCents / 100;

  bool get isPaid => status == 'paid' || status == 'label_created' || status == 'shipped' || status == 'in_transit' || status == 'delivered' || status == 'completed';
  bool get hasLabel => fedexLabelUrl != null;

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      offerId: json['offer_id'] as String?,
      itemPriceCents: json['item_price_cents'] as int,
      shippingCents: json['shipping_cents'] as int,
      platformFeeCents: json['platform_fee_cents'] as int,
      sellerPayoutCents: json['seller_payout_cents'] as int,
      totalCents: json['total_cents'] as int,
      status: json['status'] as String,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String,
      stripeTransferId: json['stripe_transfer_id'] as String?,
      shippingToAddress: json['shipping_to_address'] as Map<String, dynamic>,
      shippingFromAddress: json['shipping_from_address'] as Map<String, dynamic>,
      fedexTrackingNumber: json['fedex_tracking_number'] as String?,
      fedexLabelUrl: json['fedex_label_url'] as String?,
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  TransactionEntity copyWith({
    String? status,
    String? fedexTrackingNumber,
    String? fedexLabelUrl,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return TransactionEntity(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      offerId: offerId,
      itemPriceCents: itemPriceCents,
      shippingCents: shippingCents,
      platformFeeCents: platformFeeCents,
      sellerPayoutCents: sellerPayoutCents,
      totalCents: totalCents,
      status: status ?? this.status,
      stripePaymentIntentId: stripePaymentIntentId,
      stripeTransferId: stripeTransferId,
      shippingToAddress: shippingToAddress,
      shippingFromAddress: shippingFromAddress,
      fedexTrackingNumber: fedexTrackingNumber ?? this.fedexTrackingNumber,
      fedexLabelUrl: fedexLabelUrl ?? this.fedexLabelUrl,
      errorMessage: errorMessage,
      errorCode: errorCode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'TransactionEntity($id, status: $status, total: \$$totalFormatted)';
}
```

### CheckoutState (Multi-step state management)

```dart
import 'package:flutter/foundation.dart';

enum CheckoutStep {
  shippingAddress,
  shippingOptions,
  orderReview,
  cgvuAcceptance,
  payment,
}

@immutable
class CheckoutState {
  const CheckoutState({
    this.currentStep = CheckoutStep.shippingAddress,
    this.shippingAddress,
    this.selectedShippingOption,
    this.cgvuAccepted = false,
    this.isLoading = false,
    this.error,
  });

  final CheckoutStep currentStep;
  final Map<String, dynamic>? shippingAddress;
  final ShippingOption? selectedShippingOption;
  final bool cgvuAccepted;
  final bool isLoading;
  final String? error;

  bool get canProceedToNextStep {
    switch (currentStep) {
      case CheckoutStep.shippingAddress:
        return shippingAddress != null;
      case CheckoutStep.shippingOptions:
        return selectedShippingOption != null;
      case CheckoutStep.orderReview:
        return true;
      case CheckoutStep.cgvuAcceptance:
        return cgvuAccepted;
      case CheckoutStep.payment:
        return false; // Final step
    }
  }

  CheckoutState copyWith({
    CheckoutStep? currentStep,
    Map<String, dynamic>? shippingAddress,
    ShippingOption? selectedShippingOption,
    bool? cgvuAccepted,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      selectedShippingOption: selectedShippingOption ?? this.selectedShippingOption,
      cgvuAccepted: cgvuAccepted ?? this.cgvuAccepted,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ShippingOption {
  const ShippingOption({
    required this.serviceName,
    required this.rateCents,
    required this.estimatedDays,
    required this.fedexServiceType,
  });

  final String serviceName;
  final int rateCents;
  final int estimatedDays;
  final String fedexServiceType;

  double get rateFormatted => rateCents / 100;
}
```

## Repository Interface

```dart
abstract class TransactionRepository {
  /// Create payment intent (server-side) and get client secret.
  Future<Either<String, Map<String, dynamic>>> createPaymentIntent({
    required String listingId,
    String? offerId,
    required String buyerId,
    required Map<String, dynamic> shippingToAddress,
    required ShippingOption shippingOption,
  });

  /// Confirm payment after 3DS (if required).
  Future<Either<String, void>> confirmPayment(String paymentIntentId);

  /// Get transaction by ID.
  Future<Either<String, TransactionEntity>> getTransaction(String transactionId);

  /// Get buyer's transactions.
  Future<Either<String, List<TransactionEntity>>> getMyPurchases(String buyerId);

  /// Get seller's transactions.
  Future<Either<String, List<TransactionEntity>>> getMySales(String sellerId);
}
```

## Files to Create/Modify

### To Create

**Domain Layer:**
- `lib/features/marketplace/domain/entities/transaction_entity.dart` - Transaction entity
- `lib/features/marketplace/domain/entities/checkout_state.dart` - Multi-step state
- `lib/features/marketplace/domain/entities/shipping_option.dart` - Shipping option
- `lib/features/marketplace/domain/repositories/transaction_repository.dart` - Repository interface
- `lib/features/marketplace/domain/usecases/create_payment_intent.dart` - Create payment use case
- `lib/features/marketplace/domain/usecases/confirm_payment.dart` - Confirm payment (3DS)
- `lib/features/marketplace/domain/usecases/get_transaction.dart` - Get transaction
- `lib/features/marketplace/domain/usecases/get_my_purchases.dart` - Buyer transactions
- `lib/features/marketplace/domain/usecases/get_my_sales.dart` - Seller transactions

**Data Layer:**
- `lib/features/marketplace/data/repositories/transaction_repository_impl.dart` - Repository implementation
- `lib/features/marketplace/data/datasources/transaction_remote_datasource.dart` - API calls

**Presentation Layer:**
- `lib/features/marketplace/presentation/pages/checkout_page.dart` - Multi-step checkout
- `lib/features/marketplace/presentation/widgets/address_form_widget.dart` - Shipping address form
- `lib/features/marketplace/presentation/widgets/shipping_options_widget.dart` - FedEx options
- `lib/features/marketplace/presentation/widgets/order_summary_widget.dart` - Price breakdown
- `lib/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart` - CGVU checkbox
- `lib/features/marketplace/presentation/widgets/payment_widget.dart` - Stripe payment
- `lib/features/marketplace/presentation/pages/order_confirmation_page.dart` - Success screen
- `lib/features/marketplace/presentation/providers/checkout_providers.dart` - Riverpod providers

**Edge Functions:**
- `supabase/functions/marketplace-create-payment/index.ts` - Create PaymentIntent with commission (SERVER-SIDE)
- `supabase/functions/marketplace-payment-webhook/index.ts` - Handle Stripe webhook (payment_intent.succeeded)

### To Modify

- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - "Buy Now" button
- `lib/core/di/injection_container.dart` - Register transaction dependencies
- `lib/core/navigation/routes.dart` - Add checkout routes

## Race Condition Handling

### Purchase Race Condition

**Problem**: 2 buyers click "Buy Now" simultaneously, both create payments for same listing.

**Solution**: Lock listing in Edge Function before creating PaymentIntent.

```sql
-- SQL function: reserve_listing_for_purchase
CREATE OR REPLACE FUNCTION reserve_listing_for_purchase(
  p_listing_id UUID,
  p_buyer_id UUID
)
RETURNS TABLE(
  id UUID,
  seller_id UUID,
  price_cents INT,
  status TEXT,
  location_address JSONB
) AS $$
DECLARE
  v_listing RECORD;
BEGIN
  -- Lock listing row (prevents concurrent purchases)
  SELECT * INTO v_listing
  FROM marketplace_listings
  WHERE marketplace_listings.id = p_listing_id
    AND marketplace_listings.status = 'active'
  FOR UPDATE NOWAIT;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Listing not available';
  END IF;

  -- Verify buyer is not the seller
  IF v_listing.seller_id = p_buyer_id THEN
    RAISE EXCEPTION 'Cannot purchase your own listing';
  END IF;

  -- Listing stays 'active' until payment_intent.succeeded webhook
  -- This function only validates and locks

  RETURN QUERY
  SELECT v_listing.id, v_listing.seller_id, v_listing.price_cents, v_listing.status, v_listing.location_address;
END;
$$ LANGUAGE plpgsql;
```

## Edge Function: marketplace-create-payment

**CRITICAL**: Commission calculation MUST be server-side (never trust client).

```typescript
// supabase/functions/marketplace-create-payment/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const PLATFORM_FEE_PERCENT = 0.10; // 10% commission

interface PaymentRequest {
  listing_id: string;
  offer_id?: string;
  buyer_id: string;
  shipping_to_address: Record<string, any>;
  shipping_option: {
    service_name: string;
    rate_cents: number;
    estimated_days: number;
    fedex_service_type: string;
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    // Verify authorization
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const body: PaymentRequest = await req.json();

    // Validate required fields
    if (!body.listing_id || !body.buyer_id || !body.shipping_to_address || !body.shipping_option) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Reserve listing with lock (prevents race condition)
    const { data: listing, error: lockError } = await supabase.rpc('reserve_listing_for_purchase', {
      p_listing_id: body.listing_id,
      p_buyer_id: body.buyer_id,
    }).single();

    if (lockError || !listing) {
      return new Response(JSON.stringify({ error: lockError?.message || 'Listing not available' }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Get price (from offer if applicable)
    let itemPriceCents = listing.price_cents;
    if (body.offer_id) {
      const { data: offer } = await supabase
        .from('marketplace_offers')
        .select('amount_cents, status')
        .eq('id', body.offer_id)
        .eq('buyer_id', body.buyer_id)
        .eq('status', 'accepted')
        .single();

      if (!offer) {
        return new Response(JSON.stringify({ error: 'Offer not found or not accepted' }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        });
      }

      itemPriceCents = offer.amount_cents;
    }

    // SERVER-SIDE: Calculate commission (10% of item price)
    const platformFeeCents = Math.round(itemPriceCents * PLATFORM_FEE_PERCENT);
    const sellerPayoutCents = itemPriceCents - platformFeeCents;
    const totalCents = itemPriceCents + body.shipping_option.rate_cents;

    // Get seller's Stripe account
    const { data: sellerStripe, error: stripeError } = await supabase
      .from('stripe_accounts')
      .select('stripe_account_id')
      .eq('user_id', listing.seller_id)
      .single();

    if (stripeError || !sellerStripe) {
      return new Response(JSON.stringify({ error: 'Seller not onboarded to Stripe' }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Create Payment Intent with destination charges (Stripe Connect)
    const paymentIntent = await stripe.paymentIntents.create({
      amount: totalCents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
      transfer_data: {
        destination: sellerStripe.stripe_account_id,
        amount: sellerPayoutCents, // Seller gets item_price - 10%
      },
      metadata: {
        product_type: 'marketplace',
        listing_id: body.listing_id,
        offer_id: body.offer_id || '',
        buyer_id: body.buyer_id,
        seller_id: listing.seller_id,
        item_price_cents: itemPriceCents.toString(),
        shipping_cents: body.shipping_option.rate_cents.toString(),
        platform_fee_cents: platformFeeCents.toString(),
        seller_payout_cents: sellerPayoutCents.toString(),
        shipping_to_address: JSON.stringify(body.shipping_to_address),
        shipping_from_address: JSON.stringify(listing.location_address),
        shipping_service: body.shipping_option.fedex_service_type,
      },
    });

    console.log(`Created PaymentIntent ${paymentIntent.id} for listing ${body.listing_id}`);

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        payment_intent_id: paymentIntent.id,
        platform_fee_cents: platformFeeCents,
        seller_payout_cents: sellerPayoutCents,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error creating payment:", error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
```

## Edge Function: marketplace-payment-webhook

**CRITICAL**: This webhook updates listing status and creates transaction. Called by Stripe after payment_intent.succeeded.

```typescript
// supabase/functions/marketplace-payment-webhook/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

Deno.serve(async (req: Request) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response(JSON.stringify({ error: "No signature" }), { status: 400 });
  }

  const body = await req.text();

  try {
    const event = stripe.webhooks.constructEvent(body, signature, webhookSecret);

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const metadata = paymentIntent.metadata;

      if (metadata.product_type !== 'marketplace') {
        console.log('Not a marketplace payment, skipping');
        return new Response(JSON.stringify({ received: true }), { status: 200 });
      }

      const supabase = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
      );

      // Create marketplace_transaction
      const { data: transaction, error: txError } = await supabase
        .from('marketplace_transactions')
        .insert({
          listing_id: metadata.listing_id,
          offer_id: metadata.offer_id || null,
          buyer_id: metadata.buyer_id,
          seller_id: metadata.seller_id,
          item_price_cents: parseInt(metadata.item_price_cents),
          shipping_cents: parseInt(metadata.shipping_cents),
          platform_fee_cents: parseInt(metadata.platform_fee_cents),
          seller_payout_cents: parseInt(metadata.seller_payout_cents),
          total_cents: paymentIntent.amount,
          status: 'paid',
          stripe_payment_intent_id: paymentIntent.id,
          shipping_to_address: JSON.parse(metadata.shipping_to_address),
          shipping_from_address: JSON.parse(metadata.shipping_from_address),
          paid_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (txError) {
        console.error('Failed to create transaction:', txError);
        return new Response(JSON.stringify({ error: txError.message }), { status: 500 });
      }

      // Update listing status to 'reserved'
      await supabase
        .from('marketplace_listings')
        .update({ status: 'reserved' })
        .eq('id', metadata.listing_id);

      // Notify seller via notifications_outbox
      await supabase.from('notifications_outbox').insert({
        user_id: metadata.seller_id,
        title: 'Item sold!',
        body: `Your item sold for $${parseInt(metadata.item_price_cents) / 100}`,
        data: {
          type: 'marketplace',
          subtype: 'item_sold',
          transaction_id: transaction.id,
          listing_id: metadata.listing_id,
        },
      });

      // Notify buyer
      await supabase.from('notifications_outbox').insert({
        user_id: metadata.buyer_id,
        title: 'Order confirmed',
        body: 'Your order has been confirmed and paid',
        data: {
          type: 'marketplace',
          subtype: 'order_confirmed',
          transaction_id: transaction.id,
          listing_id: metadata.listing_id,
        },
      });

      console.log(`Created transaction ${transaction.id} for payment ${paymentIntent.id}`);
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (error) {
    console.error('Webhook error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), { status: 400 });
  }
});
```

## CGVU Acceptance Check

Before payment, check if buyer has accepted marketplace CGVU (from S09).

```dart
Future<bool> hasAcceptedMarketplaceCGVU(String userId) async {
  final response = await supabase
    .from('cgvu_acceptances')
    .select()
    .eq('user_id', userId)
    .eq('cgvu_type', 'marketplace_buyer')
    .maybeSingle();

  return response != null;
}
```

## 3DS (3D Secure) Handling

Stripe automatically triggers 3DS when required. Client must handle `requires_action` status.

```dart
import 'package:stripe_sdk/stripe_sdk.dart';

Future<void> _handlePayment(String clientSecret) async {
  try {
    // Confirm payment (Stripe SDK handles 3DS automatically)
    final paymentIntent = await Stripe.instance.confirmPayment(
      clientSecret,
      PaymentMethodParams.card(),
    );

    if (paymentIntent.status == PaymentIntentStatus.succeeded) {
      // Payment successful
      _navigateToConfirmation();
    } else if (paymentIntent.status == PaymentIntentStatus.requiresAction) {
      // 3DS authentication required
      final confirmedIntent = await Stripe.instance.handleCardAction(clientSecret);

      if (confirmedIntent.status == PaymentIntentStatus.succeeded) {
        _navigateToConfirmation();
      } else {
        throw Exception('Payment authentication failed');
      }
    } else {
      throw Exception('Payment failed: ${paymentIntent.status}');
    }
  } catch (e) {
    setState(() => _error = e.toString());
  }
}
```

## Design System Usage

### Checkout Page (Multi-step)

```dart
import '/core/design/design.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final ListingEntity listing;
  final String? offerId;
  final int? agreedPriceCents;

  const CheckoutPage({
    required this.listing,
    this.offerId,
    this.agreedPriceCents,
    super.key,
  });

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int _currentStep = 0;
  Map<String, dynamic>? _shippingAddress;
  ShippingOption? _selectedShippingOption;
  bool _cgvuAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: LynewedComponentStyles.backButton(context),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                LynewedButton(
                  label: _currentStep == 4 ? 'Complete Payment' : 'Continue',
                  onPressed: details.onStepContinue,
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  LynewedButton(
                    label: 'Back',
                    type: LynewedButtonType.secondary,
                    onPressed: details.onStepCancel,
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Shipping Address'),
            content: AddressFormWidget(
              initialAddress: _shippingAddress,
              onChanged: (address) => setState(() => _shippingAddress = address),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Shipping'),
            content: ShippingOptionsWidget(
              fromAddress: widget.listing.locationAddress,
              toAddress: _shippingAddress!,
              onSelected: (option) => setState(() => _selectedShippingOption = option),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review'),
            content: OrderSummaryWidget(
              itemPriceCents: widget.agreedPriceCents ?? widget.listing.priceCents,
              shippingCents: _selectedShippingOption?.rateCents ?? 0,
              listing: widget.listing,
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Terms'),
            content: CGVUAcceptanceWidget(
              cgvuType: 'marketplace_buyer',
              accepted: _cgvuAccepted,
              onChanged: (value) => setState(() => _cgvuAccepted = value),
            ),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Payment'),
            content: PaymentWidget(
              totalCents: (widget.agreedPriceCents ?? widget.listing.priceCents) + (_selectedShippingOption?.rateCents ?? 0),
              onPaymentSuccess: _handlePaymentSuccess,
            ),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Trigger payment
      _processPayment();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _processPayment() async {
    // Implementation in PaymentWidget
  }

  void _handlePaymentSuccess(String transactionId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationPage(transactionId: transactionId),
      ),
    );
  }
}
```

## Screen States

### Checkout Page
- **Loading**: Stepper disabled during API calls
- **Step Navigation**: Enabled/disabled based on validation
- **Error**: Error message at top of current step
- **Success**: Navigate to confirmation page

### Order Summary Widget
- **Data**: Item + shipping + commission breakdown
- **Empty**: N/A (always has data from previous steps)

### Payment Widget
- **Loading**: "Processing payment..." spinner
- **3DS Required**: Stripe SDK handles automatically
- **Error**: Display clear error message with retry button
- **Success**: Navigate to confirmation

## Tests Required

### Unit Tests (transaction_repository_impl_test.dart)
- `createPaymentIntent_validListing_returnsClientSecret`
- `createPaymentIntent_listingSold_returnsError`
- `createPaymentIntent_withOffer_usesOfferedPrice`
- `createPaymentIntent_buyerIsSeller_returnsError`
- `confirmPayment_valid_succeeds`
- `getTransaction_exists_returnsTransaction`

### Widget Tests (checkout_page_test.dart)
- `checkoutPage_step1_showsAddressForm`
- `checkoutPage_step2_showsShippingOptions`
- `checkoutPage_step3_showsOrderSummary`
- `checkoutPage_step4_showsCGVUAcceptance`
- `checkoutPage_step5_showsPaymentWidget`
- `checkoutPage_continueButton_disabledWhenInvalid`

### Integration Tests
- `checkout_flow_buyNow_createsTransaction`
- `checkout_flow_withOffer_usesAgreedPrice`
- `checkout_flow_paymentFails_showsError`

## Definition of Done

- [ ] TransactionEntity complete
- [ ] CheckoutState entity for multi-step
- [ ] ShippingOption entity
- [ ] TransactionRepository interface
- [ ] TransactionRepositoryImpl with Supabase calls
- [ ] All use cases implemented
- [ ] Checkout page with 5 steps (Design System)
- [ ] Address form widget
- [ ] Shipping options widget (calls S11 fedex-rate)
- [ ] Order summary widget with commission breakdown
- [ ] CGVU acceptance widget (checks S09 table)
- [ ] Payment widget with 3DS support
- [ ] Order confirmation page
- [ ] Edge Function marketplace-create-payment deployed
- [ ] Edge Function marketplace-payment-webhook deployed
- [ ] SQL function reserve_listing_for_purchase created
- [ ] Stripe webhook configured in Stripe Dashboard
- [ ] Commission calculation server-side (10%)
- [ ] Race condition handling with FOR UPDATE NOWAIT
- [ ] 3DS support via Stripe SDK
- [ ] Listing status updated to 'reserved' after payment
- [ ] Notifications via notifications_outbox
- [ ] Navigation from listing detail
- [ ] Routes registered
- [ ] Dependencies registered in injection_container
- [ ] All tests passing
- [ ] `flutter analyze --fatal-infos` passes

## Estimation
**Points**: 8
**Complexity**: High
**Risk**: High (payments, multiple integrations, race conditions)

## Dependencies
- S04 (marketplace_transactions table)
- S09 (cgvu_acceptances table)
- S10 (Stripe Connect onboarding)
- S11 (FedEx Rate API Edge Function)

## Dependent Stories
- S21 (FedEx label generation - after payment)
- S23 (notifications - sale confirmed)

## Notes

**COMMISSION SERVER-SIDE ONLY**: Never trust client-side price calculations. Always calculate commission in Edge Function.

**RACE CONDITIONS**: Use SELECT FOR UPDATE NOWAIT in SQL function to prevent concurrent purchases.

**3DS**: Stripe SDK handles automatically. Client must call `confirmPaymentIntent` when `requires_action` status returned.

**WEBHOOK IDEMPOTENCY**: Stripe may send duplicate webhooks. Use payment_intent_id as idempotency key (check if transaction already exists before creating).

**ENGLISH ONLY**: All UI text must be in English.
