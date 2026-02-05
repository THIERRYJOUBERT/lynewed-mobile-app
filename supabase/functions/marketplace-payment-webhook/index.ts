import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

/// Edge Function: marketplace-payment-webhook
/// Handles Stripe webhook events for marketplace payments.
/// Creates marketplace_transaction on payment_intent.succeeded.
/// Updates listing status to 'reserved' and notifies buyer/seller.

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

// FIX C-08: No fallback to empty string - throw if not configured
const webhookSecret = Deno.env.get("STRIPE_MARKETPLACE_WEBHOOK_SECRET");
if (!webhookSecret) {
  console.error("STRIPE_MARKETPLACE_WEBHOOK_SECRET not configured!");
}

// FIX C-07: Use SubtleCryptoProvider for Deno compatibility
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req: Request) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response(JSON.stringify({ error: "No signature" }), {
      status: 400,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    });
  }

  if (!webhookSecret) {
    return new Response(JSON.stringify({ error: "Webhook secret not configured" }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    });
  }

  const body = await req.text();

  try {
    // FIX C-07: Use constructEventAsync with SubtleCryptoProvider
    const event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret,
      undefined,
      cryptoProvider,
    );

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Log event to stripe_events for auditability (FIX L-13)
    await supabase.from("stripe_events").upsert({
      stripe_event_id: event.id,
      event_type: event.type,
      api_version: event.api_version,
      payload: event.data.object,
      livemode: event.livemode,
      stripe_created_at: new Date(event.created * 1000).toISOString(),
    }, { onConflict: "stripe_event_id" });

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const metadata = paymentIntent.metadata;

      if (metadata.product_type !== 'marketplace') {
        console.log('Not a marketplace payment, skipping');
        return new Response(JSON.stringify({ received: true }), {
          status: 200,
          headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
        });
      }

      // Idempotency check: Don't create duplicate transactions
      const { data: existing } = await supabase
        .from('marketplace_transactions')
        .select('id')
        .eq('stripe_payment_intent_id', paymentIntent.id)
        .maybeSingle();

      if (existing) {
        console.log(`Transaction already exists for PaymentIntent ${paymentIntent.id}`);
        return new Response(JSON.stringify({ received: true }), {
          status: 200,
          headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
        });
      }

      let shippingToAddress = {};
      let shippingFromAddress = {};
      try {
        shippingToAddress = JSON.parse(metadata.shipping_to_address || '{}');
        shippingFromAddress = JSON.parse(metadata.shipping_from_address || '{}');
      } catch (e) {
        console.error('Failed to parse shipping addresses:', e);
      }

      // Create marketplace_transaction
      const { data: transaction, error: txError } = await supabase
        .from('marketplace_transactions')
        .insert({
          listing_id: metadata.listing_id,
          offer_id: metadata.offer_id || null,
          buyer_id: metadata.buyer_id,
          seller_id: metadata.seller_id,
          item_price_cents: parseInt(metadata.item_price_cents),
          shipping_cost_cents: parseInt(metadata.shipping_cents),
          platform_fee_cents: parseInt(metadata.platform_fee_cents),
          seller_payout_cents: parseInt(metadata.seller_payout_cents),
          total_paid_cents: paymentIntent.amount,
          status: 'paid',
          stripe_payment_intent_id: paymentIntent.id,
          shipping_to_address: shippingToAddress,
          shipping_from_address: shippingFromAddress,
          paid_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (txError) {
        console.error('Failed to create transaction:', txError);
        return new Response(JSON.stringify({ error: txError.message }), {
          status: 500,
          headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
        });
      }

      // Update listing status to 'reserved'
      await supabase
        .from('marketplace_listings')
        .update({ status: 'reserved' })
        .eq('id', metadata.listing_id);

      // FIX C-01: Use correct notifications_outbox schema (event_type, event_key, payload)
      // Notify seller
      await supabase.from('notifications_outbox').insert({
        event_type: 'marketplace_item_sold',
        event_key: `marketplace:item_sold:${transaction.id}`,
        payload: {
          recipient_id: metadata.seller_id,
          transaction_id: transaction.id,
          listing_id: metadata.listing_id,
          amount_cents: parseInt(metadata.item_price_cents),
        },
      });

      // Notify buyer
      await supabase.from('notifications_outbox').insert({
        event_type: 'marketplace_order_confirmed',
        event_key: `marketplace:order_confirmed:${transaction.id}`,
        payload: {
          recipient_id: metadata.buyer_id,
          transaction_id: transaction.id,
          listing_id: metadata.listing_id,
          amount_cents: parseInt(metadata.item_price_cents),
        },
      });

      console.log(`Created transaction ${transaction.id} for PaymentIntent ${paymentIntent.id}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    });
  } catch (error) {
    console.error('Webhook error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 400,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    });
  }
});
