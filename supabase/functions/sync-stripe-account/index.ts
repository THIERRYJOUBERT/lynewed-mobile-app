// Sync Stripe Account Status
// Fetches fresh account data from Stripe API and updates the DB
// Called by the Flutter app when user refreshes their account status
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

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

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Get the user's Stripe account ID from DB
    const { data: sa, error: fetchErr } = await supabaseAdmin
      .from('stripe_accounts')
      .select('stripe_account_id')
      .eq('user_id', user.id)
      .maybeSingle();

    if (fetchErr) {
      console.error('Error fetching stripe_accounts:', fetchErr);
      return new Response(JSON.stringify({ error: 'Database error' }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!sa) {
      return new Response(JSON.stringify({ error: 'No Stripe account found' }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Fetch fresh data from Stripe API
    const account = await stripe.accounts.retrieve(sa.stripe_account_id);
    console.log(`Synced account ${account.id}: charges=${account.charges_enabled}, payouts=${account.payouts_enabled}, details_submitted=${account.details_submitted}`);

    const requirements = account.requirements || {};
    const complete = (account.charges_enabled && account.payouts_enabled) || false;

    // Update DB with fresh data
    const { error: updateErr } = await supabaseAdmin
      .from('stripe_accounts')
      .update({
        charges_enabled: account.charges_enabled || false,
        payouts_enabled: account.payouts_enabled || false,
        details_submitted: account.details_submitted || false,
        onboarding_complete: complete,
        currently_due: requirements.currently_due || [],
        past_due: requirements.past_due || [],
        disabled_reason: requirements.disabled_reason || null,
        country: account.country,
        default_currency: account.default_currency,
        updated_at: new Date().toISOString(),
      })
      .eq('stripe_account_id', sa.stripe_account_id);

    if (updateErr) {
      console.error('Error updating stripe_accounts:', updateErr);
      return new Response(JSON.stringify({ error: 'Update failed' }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        synced: true,
        charges_enabled: account.charges_enabled || false,
        payouts_enabled: account.payouts_enabled || false,
        details_submitted: account.details_submitted || false,
        onboarding_complete: complete,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error syncing Stripe account:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
