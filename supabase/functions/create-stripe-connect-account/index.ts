// EPIC-14 S10: Create Stripe Connect Express Account
// Creates a Stripe Connect Express account and returns onboarding link
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

interface CreateAccountRequest {
  user_id: string;
  email: string;
  return_url: string;
  refresh_url: string;
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
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const body: CreateAccountRequest = await req.json();

    // Security: user_id must match authenticated user
    if (body.user_id !== user.id) {
      return new Response(JSON.stringify({ error: "User ID mismatch" }), {
        status: 403,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!body.return_url || !body.refresh_url) {
      return new Response(JSON.stringify({ error: "Missing return_url or refresh_url" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Check if user already has a Stripe account
    const { data: existingAccount } = await supabaseAdmin
      .from('stripe_accounts')
      .select('stripe_account_id, onboarding_complete')
      .eq('user_id', body.user_id)
      .single();

    let stripeAccountId: string;

    if (existingAccount?.stripe_account_id) {
      stripeAccountId = existingAccount.stripe_account_id;
      console.log(`Reusing existing Stripe account ${stripeAccountId} for user ${body.user_id}`);
    } else {
      const account = await stripe.accounts.create({
        type: 'express',
        email: body.email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        business_type: 'individual',
      });

      stripeAccountId = account.id;
      console.log(`Created new Stripe Connect account ${stripeAccountId} for user ${body.user_id}`);

      const { error: insertError } = await supabaseAdmin
        .from('stripe_accounts')
        .insert({
          user_id: body.user_id,
          stripe_account_id: stripeAccountId,
          account_type: 'express',
          onboarding_complete: false,
          charges_enabled: false,
          payouts_enabled: false,
          created_at: new Date().toISOString(),
        });

      if (insertError) {
        console.error('Error inserting stripe_accounts record:', insertError);
      }
    }

    const accountLink = await stripe.accountLinks.create({
      account: stripeAccountId,
      refresh_url: body.refresh_url,
      return_url: body.return_url,
      type: 'account_onboarding',
    });

    console.log(`Created onboarding link for account ${stripeAccountId}`);

    return new Response(
      JSON.stringify({
        url: accountLink.url,
        stripe_account_id: stripeAccountId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error creating Stripe Connect account:", error);

    let errorMessage = (error as Error).message;
    if (errorMessage.includes('rate_limit')) {
      errorMessage = 'Too many requests. Please try again in a few minutes.';
    } else if (errorMessage.includes('api_key')) {
      errorMessage = 'Stripe configuration error. Please contact support.';
    }

    return new Response(
      JSON.stringify({ error: errorMessage }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
