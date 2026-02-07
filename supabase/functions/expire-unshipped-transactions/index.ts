import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

/// Edge Function: expire-unshipped-transactions
/// Called daily by pg_cron. Two jobs:
/// 1. Expire paid transactions not shipped within 14 days → re-activate listing.
/// 2. Auto-complete delivered transactions after 7 days → set listing to "sold".

Deno.serve(async (req: Request) => {
  // Verify cron secret for protection
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

    // Find transactions paid more than 14 days ago but not shipped
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 14);

    const { data: expiredTxs, error: fetchError } = await supabase
      .from('marketplace_transactions')
      .select('id, listing_id, buyer_id, seller_id, item_price_cents')
      .eq('status', 'paid')
      .lt('paid_at', cutoffDate.toISOString());

    if (fetchError) throw new Error(fetchError.message);

    if (!expiredTxs || expiredTxs.length === 0) {
      console.log('No unshipped transactions to expire');
      return new Response(JSON.stringify({ expired_count: 0 }), {
        status: 200,
        headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
      });
    }

    const txIds = expiredTxs.map((tx: { id: string }) => tx.id);
    const listingIds = expiredTxs.map((tx: { listing_id: string }) => tx.listing_id);

    // Update transactions to expired
    const { error: updateError } = await supabase
      .from('marketplace_transactions')
      .update({ status: 'expired', updated_at: new Date().toISOString() })
      .in('id', txIds);

    if (updateError) throw new Error(updateError.message);

    // Re-activate listings
    const { error: listingError } = await supabase
      .from('marketplace_listings')
      .update({ status: 'active' })
      .in('id', listingIds);

    if (listingError) {
      console.error('Failed to re-activate listings:', listingError.message);
    }

    // Fetch listing titles for notifications
    const { data: listings } = await supabase
      .from('marketplace_listings')
      .select('id, title')
      .in('id', listingIds);

    const titleMap = new Map((listings || []).map((l: { id: string; title: string }) => [l.id, l.title]));

    // Notify both buyer and seller for each expired transaction
    const notifications = expiredTxs.flatMap((tx: { id: string; listing_id: string; buyer_id: string; seller_id: string }) => {
      const listingTitle = titleMap.get(tx.listing_id) || 'item';
      return [
        {
          event_type: 'marketplace_transaction_expired',
          event_key: `marketplace:tx_expired:buyer:${tx.id}`,
          payload: {
            recipient_id: tx.buyer_id,
            transaction_id: tx.id,
            listing_id: tx.listing_id,
            listing_title: listingTitle,
            reason: 'Item was not shipped within 14 days',
          },
        },
        {
          event_type: 'marketplace_transaction_expired',
          event_key: `marketplace:tx_expired:seller:${tx.id}`,
          payload: {
            recipient_id: tx.seller_id,
            transaction_id: tx.id,
            listing_id: tx.listing_id,
            listing_title: listingTitle,
            reason: 'Item was not shipped within 14 days',
          },
        },
      ];
    });

    const { error: notifError } = await supabase
      .from('notifications_outbox')
      .insert(notifications);

    if (notifError) {
      console.error('Failed to insert notifications:', notifError.message);
    }

    console.log(`Expired ${expiredTxs.length} unshipped transactions`);

    // --- Auto-complete: delivered transactions > 7 days → completed + listing "sold" ---
    const completionCutoff = new Date();
    completionCutoff.setDate(completionCutoff.getDate() - 7);

    const { data: deliveredTxs, error: deliveredError } = await supabase
      .from('marketplace_transactions')
      .select('id, listing_id, buyer_id, seller_id')
      .eq('status', 'delivered')
      .lt('delivered_at', completionCutoff.toISOString());

    if (deliveredError) {
      console.error('Failed to fetch delivered txs:', deliveredError.message);
    }

    let completedCount = 0;
    if (deliveredTxs && deliveredTxs.length > 0) {
      const now = new Date().toISOString();
      const completedIds = deliveredTxs.map((tx: { id: string }) => tx.id);
      const completedListingIds = deliveredTxs.map((tx: { listing_id: string }) => tx.listing_id);

      // Complete transactions
      await supabase.from('marketplace_transactions')
        .update({ status: 'completed', completed_at: now, updated_at: now })
        .in('id', completedIds);

      // Set listings to "sold"
      await supabase.from('marketplace_listings')
        .update({ status: 'sold' })
        .in('id', completedListingIds);

      // Fetch listing titles for notifications
      const { data: completedListings } = await supabase
        .from('marketplace_listings')
        .select('id, title')
        .in('id', completedListingIds);

      const completedTitleMap = new Map(
        (completedListings || []).map((l: { id: string; title: string }) => [l.id, l.title])
      );

      // Notify both parties
      const completionNotifs = deliveredTxs.flatMap(
        (tx: { id: string; listing_id: string; buyer_id: string; seller_id: string }) => {
          const title = completedTitleMap.get(tx.listing_id) || 'item';
          return [
            {
              event_type: 'marketplace_transaction_complete',
              event_key: `marketplace:complete:buyer:${tx.id}`,
              payload: { recipient_id: tx.buyer_id, transaction_id: tx.id, listing_title: title },
            },
            {
              event_type: 'marketplace_transaction_complete',
              event_key: `marketplace:complete:seller:${tx.id}`,
              payload: { recipient_id: tx.seller_id, transaction_id: tx.id, listing_title: title },
            },
          ];
        }
      );

      const { error: completionNotifError } = await supabase
        .from('notifications_outbox')
        .insert(completionNotifs);

      if (completionNotifError) {
        console.error('Failed to insert completion notifications:', completionNotifError.message);
      }

      completedCount = deliveredTxs.length;
      console.log(`Auto-completed ${completedCount} delivered transactions`);
    }

    return new Response(JSON.stringify({ expired_count: expiredTxs.length, completed_count: completedCount }), {
      status: 200,
      headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
    });
  } catch (error) {
    console.error('Transaction maintenance error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Connection': 'keep-alive' },
    });
  }
});
