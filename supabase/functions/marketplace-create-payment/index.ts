import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

/// Edge Function: marketplace-create-payment
/// Creates a Stripe Checkout Session for marketplace purchases.
/// Calculates 10% platform commission server-side using integer division.
/// Supports accepted offers (uses offer price instead of listing price).

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

interface PaymentRequest {
  listing_id: string;
  offer_id?: string;
  shipping_to_address: Record<string, unknown>;
  shipping_option: {
    service_type: string;
    service_name: string;
    rate_cents: number;
    estimated_days: number;
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
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const supabaseUser = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );
    const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }

    const body: PaymentRequest = await req.json();

    if (!body.listing_id || !body.shipping_to_address || !body.shipping_option) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }

    // Reserve listing with lock (prevents race condition)
    const { data: listings, error: lockError } = await supabaseAdmin.rpc('reserve_listing_for_purchase', {
      p_listing_id: body.listing_id,
      p_buyer_id: user.id,
    });

    if (lockError || !listings || listings.length === 0) {
      return new Response(JSON.stringify({ error: lockError?.message || 'Listing not available' }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }

    const listing = listings[0];

    // Get price (from offer if applicable)
    let itemPriceCents = listing.price_cents;
    if (body.offer_id) {
      const { data: offer } = await supabaseAdmin
        .from('marketplace_offers')
        .select('amount_cents, status')
        .eq('id', body.offer_id)
        .eq('buyer_id', user.id)
        .eq('status', 'accepted')
        .single();

      if (!offer) {
        return new Response(JSON.stringify({ error: 'Offer not found or not accepted' }), {
          status: 400,
          headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
        });
      }

      itemPriceCents = offer.amount_cents;
    }

    // FIX C-08/H-01: Integer division for commission (no floating point)
    const platformFeeCents = Math.trunc(itemPriceCents / 10);
    const sellerPayoutCents = itemPriceCents - platformFeeCents;
    const shippingCents = body.shipping_option.rate_cents;
    const totalCents = itemPriceCents + shippingCents;

    // Get seller's Stripe account
    const { data: sellerStripe, error: stripeError } = await supabaseAdmin
      .from('stripe_accounts')
      .select('stripe_account_id')
      .eq('user_id', listing.seller_id)
      .single();

    if (stripeError || !sellerStripe) {
      return new Response(JSON.stringify({ error: 'Seller not onboarded to Stripe' }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }

    // Get seller address from profile for FedEx (FIX H-04)
    const { data: sellerProfile } = await supabaseAdmin
      .from('profiles')
      .select('full_name, city, country')
      .eq('id', listing.seller_id)
      .single();

    const shippingFromAddress = {
      city: sellerProfile?.city || listing.shipping_from_city || '',
      countryCode: sellerProfile?.country || listing.shipping_from_country || '',
      personName: sellerProfile?.full_name || 'Seller',
    };

    // FIX M-02: Idempotency key to prevent duplicate checkout sessions
    const idempotencyKey = `checkout_${body.listing_id}_${user.id}_${Date.now()}`;

    // FIX M-03: Seller receives item payout + shipping costs
    const sellerTransferAmount = sellerPayoutCents + shippingCents;

    // Create Stripe Checkout Session with destination charges
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: { name: 'Marketplace Purchase' },
            unit_amount: itemPriceCents,
          },
          quantity: 1,
        },
        {
          price_data: {
            currency: 'usd',
            product_data: { name: `Shipping (${body.shipping_option.service_name})` },
            unit_amount: shippingCents,
          },
          quantity: 1,
        },
      ],
      payment_intent_data: {
        transfer_data: {
          destination: sellerStripe.stripe_account_id,
          amount: sellerTransferAmount,
        },
        metadata: {
          product_type: 'marketplace',
          listing_id: body.listing_id,
          offer_id: body.offer_id || '',
          buyer_id: user.id,
          seller_id: listing.seller_id,
          item_price_cents: itemPriceCents.toString(),
          shipping_cents: shippingCents.toString(),
          platform_fee_cents: platformFeeCents.toString(),
          seller_payout_cents: sellerPayoutCents.toString(),
          shipping_to_address: JSON.stringify(body.shipping_to_address),
          shipping_from_address: JSON.stringify(shippingFromAddress),
          shipping_service: body.shipping_option.service_type,
        },
      },
      success_url: `lynewed://marketplace/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `lynewed://marketplace/payment-cancel`,
    }, {
      idempotencyKey,
    });

    console.log(`Created Checkout Session ${session.id} for listing ${body.listing_id}`);

    return new Response(
      JSON.stringify({
        checkout_url: session.url,
        session_id: session.id,
        item_price_cents: itemPriceCents,
        shipping_cents: shippingCents,
        platform_fee_cents: platformFeeCents,
        seller_payout_cents: sellerPayoutCents,
        total_cents: totalCents,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      }
    );
  } catch (error) {
    console.error("Error creating payment:", error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    });
  }
});
