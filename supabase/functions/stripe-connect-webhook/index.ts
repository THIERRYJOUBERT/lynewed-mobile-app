// EPIC-14 S10: Stripe Connect Webhook Handler
// Handles account.updated and other Stripe Connect events
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_CONNECT_WEBHOOK_SECRET")!;
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req: Request) => {
  try {
    // Get the signature from headers
    const signature = req.headers.get("stripe-signature");
    if (!signature) {
      return new Response(JSON.stringify({ error: "No signature" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Get raw body
    const body = await req.text();

    // Verify webhook signature (async required for Deno/SubtleCrypto)
    let event: Stripe.Event;
    try {
      event = await stripe.webhooks.constructEventAsync(
        body,
        signature,
        webhookSecret,
        undefined,
        cryptoProvider,
      );
    } catch (err) {
      console.error('Webhook signature verification failed:', (err as Error).message);
      return new Response(JSON.stringify({ error: 'Invalid signature' }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.log(`Received Stripe event: ${event.type}`);

    // Initialize Supabase admin client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Handle different event types
    switch (event.type) {
      case 'account.updated': {
        const account = event.data.object as Stripe.Account;
        console.log(`account.updated for ${account.id}`);

        const { data: sa } = await supabase
          .from('stripe_accounts')
          .select('user_id, onboarding_complete')
          .eq('stripe_account_id', account.id)
          .single();

        if (sa) {
          const req = account.requirements || {};
          const complete = (account.charges_enabled && account.payouts_enabled) || false;
          const becameComplete = !sa.onboarding_complete && complete;

          const { error: updateErr } = await supabase
            .from('stripe_accounts')
            .update({
              charges_enabled: account.charges_enabled || false,
              payouts_enabled: account.payouts_enabled || false,
              details_submitted: account.details_submitted || false,
              onboarding_complete: complete,
              currently_due: req.currently_due || [],
              past_due: req.past_due || [],
              disabled_reason: req.disabled_reason || null,
              country: account.country,
              default_currency: account.default_currency,
              updated_at: new Date().toISOString(),
            })
            .eq('stripe_account_id', account.id);

          if (updateErr) {
            console.error('Error updating stripe_accounts:', updateErr);
          } else {
            console.log(`Updated stripe_accounts for ${account.id}: charges=${account.charges_enabled}, payouts=${account.payouts_enabled}, details_submitted=${account.details_submitted}`);
          }

          if (becameComplete) {
            await supabase.from('notifications_outbox').insert({
              recipient_id: sa.user_id,
              event_type: 'stripe_onboarding_complete',
              payload: { message: 'Your seller account is now active!' },
            });
          } else if ((req.currently_due?.length ?? 0) > 0) {
            await supabase.from('notifications_outbox').insert({
              recipient_id: sa.user_id,
              event_type: 'stripe_action_required',
              payload: { message: 'Action required', requirements: req.currently_due },
            });
          }
        } else {
          console.log(`No stripe_accounts record found for ${account.id}`);
        }
        break;
      }

      case 'account.external_account.created':
      case 'account.external_account.updated':
      case 'account.external_account.deleted': {
        const account = event.account;
        console.log(`External account event for ${account} - refreshing account data`);

        // Fetch fresh account data
        const fullAccount = await stripe.accounts.retrieve(account as string);

        const { error } = await supabase
          .from('stripe_accounts')
          .update({
            onboarding_complete: fullAccount.details_submitted ?? false,
            charges_enabled: fullAccount.charges_enabled ?? false,
            payouts_enabled: fullAccount.payouts_enabled ?? false,
            updated_at: new Date().toISOString(),
          })
          .eq('stripe_account_id', account);

        if (error) {
          console.error('Error updating stripe_accounts:', error);
        }
        break;
      }

      case 'capability.updated': {
        const capability = event.data.object as Stripe.Capability;
        console.log(`Capability ${capability.id} updated for account ${capability.account}`);

        // Refresh account data
        const account = await stripe.accounts.retrieve(capability.account as string);

        const { error } = await supabase
          .from('stripe_accounts')
          .update({
            onboarding_complete: account.details_submitted ?? false,
            charges_enabled: account.charges_enabled ?? false,
            payouts_enabled: account.payouts_enabled ?? false,
            updated_at: new Date().toISOString(),
          })
          .eq('stripe_account_id', capability.account);

        if (error) {
          console.error('Error updating stripe_accounts:', error);
        }
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error processing webhook:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
