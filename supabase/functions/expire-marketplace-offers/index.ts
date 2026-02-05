import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

/// Edge Function: expire-marketplace-offers
/// Called hourly by pg_cron to expire pending offers older than 48h.
/// Updates status to 'expired' and notifies buyers via notifications_outbox.

Deno.serve(async (req: Request) => {
  // FIX L-15: Verify cron secret for protection
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (cronSecret) {
    const providedSecret = req.headers.get("x-cron-secret");
    if (providedSecret !== cronSecret) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
      });
    }
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Find expired offers (pending + past expires_at)
    const { data: expiredOffers, error: fetchError } = await supabase
      .from('marketplace_offers')
      .select('id, buyer_id, listing_id, amount_cents')
      .eq('status', 'pending')
      .lt('expires_at', new Date().toISOString());

    if (fetchError) throw new Error(fetchError.message);

    if (!expiredOffers || expiredOffers.length === 0) {
      console.log('No expired offers found');
      return new Response(JSON.stringify({ expired_count: 0 }), {
        status: 200,
        headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
      });
    }

    // FIX C-02: Use .in() instead of .in_() (which doesn't exist in supabase-js)
    const offerIds = expiredOffers.map((o: { id: string }) => o.id);
    const { error: updateError } = await supabase
      .from('marketplace_offers')
      .update({ status: 'expired' })
      .in('id', offerIds);

    if (updateError) throw new Error(updateError.message);

    // FIX C-01: Use correct notifications_outbox schema (event_type, event_key, payload)
    const notifications = expiredOffers.map((offer: { id: string; buyer_id: string; listing_id: string; amount_cents: number }) => ({
      event_type: 'marketplace_offer_expired',
      event_key: `marketplace:offer_expired:${offer.id}`,
      payload: {
        recipient_id: offer.buyer_id,
        offer_id: offer.id,
        listing_id: offer.listing_id,
        amount_cents: offer.amount_cents,
      },
    }));

    const { error: notifError } = await supabase
      .from('notifications_outbox')
      .insert(notifications);

    if (notifError) {
      console.error('Failed to insert notifications:', notifError.message);
      // Don't throw - offers were already expired, notifications are best-effort
    }

    console.log(`Expired ${expiredOffers.length} offers`);

    return new Response(JSON.stringify({ expired_count: expiredOffers.length }), {
      status: 200,
      headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
    });
  } catch (error) {
    console.error('Expire offers error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
    });
  }
});
