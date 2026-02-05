// EPIC-14 S13: FedEx Tracking Poller
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "./fedex-client.ts";

interface TrackRequest { mode: 'cron' | 'manual'; tracking_number?: string; }

function mapFedExEvent(code: string): string {
  const m: Record<string, string> = { 'PU': 'picked_up', 'IT': 'in_transit', 'AR': 'arrived_at_facility', 'DP': 'departed_facility', 'OD': 'out_for_delivery', 'DL': 'delivered', 'DE': 'delivery_exception', 'CA': 'cancelled', 'RS': 'return_to_shipper', 'OC': 'shipment_created' };
  return m[code] || 'unknown';
}

function getStatus(eventType: string): string | null {
  const m: Record<string, string> = { 'picked_up': 'shipped', 'in_transit': 'in_transit', 'out_for_delivery': 'out_for_delivery', 'delivered': 'delivered', 'delivery_exception': 'exception' };
  return m[eventType] || null;
}

// FIX C-01: Use correct notifications_outbox schema (event_type, event_key, payload)
async function sendNotification(supabase: ReturnType<typeof createClient>, tx: Record<string, string>, status: string) {
  const msgs: Record<string, { title: string; body: string }> = {
    'shipped': { title: 'Package Shipped', body: 'Your package has been picked up and is on its way!' },
    'in_transit': { title: 'Package in Transit', body: 'Your package is moving through the FedEx network.' },
    'out_for_delivery': { title: 'Out for Delivery', body: 'Your package is out for delivery today!' },
    'delivered': { title: 'Package Delivered', body: 'Your package has been delivered. Enjoy!' },
    'exception': { title: 'Delivery Exception', body: 'There was an issue with your delivery.' },
  };
  const msg = msgs[status];
  if (!msg) return;

  // Notify buyer
  await supabase.from('notifications_outbox').insert({
    event_type: 'marketplace_tracking_update',
    event_key: `marketplace:tracking:${tx.id}:${status}:buyer`,
    payload: {
      recipient_id: tx.buyer_id,
      transaction_id: tx.id,
      tracking_number: tx.fedex_tracking_number,
      status,
      title: msg.title,
      body: msg.body,
    },
  });

  // Notify seller on delivery
  if (status === 'delivered') {
    await supabase.from('notifications_outbox').insert({
      event_type: 'marketplace_tracking_update',
      event_key: `marketplace:tracking:${tx.id}:${status}:seller`,
      payload: {
        recipient_id: tx.seller_id,
        transaction_id: tx.id,
        tracking_number: tx.fedex_tracking_number,
        status,
        title: 'Package Delivered',
        body: 'Your package was delivered to the buyer.',
      },
    });
  }
}

async function trackTx(supabase: ReturnType<typeof createClient>, fedex: FedExClient, tx: Record<string, string>) {
  try {
    const events = await fedex.trackShipment(tx.fedex_tracking_number);
    if (events.length === 0) return { success: true, newEventsCount: 0 };
    const { data: lastEvent } = await supabase.from('fedex_events').select('event_timestamp').eq('transaction_id', tx.id).order('event_timestamp', { ascending: false }).limit(1).maybeSingle();
    const newEvents = lastEvent ? events.filter(e => new Date(e.timestamp) > new Date(lastEvent.event_timestamp)) : events;
    if (newEvents.length === 0) return { success: true, newEventsCount: 0 };
    let latestStatus: string | null = null;
    for (const event of newEvents) {
      const eventType = mapFedExEvent(event.code);
      await supabase.from('fedex_events').insert({ transaction_id: tx.id, tracking_number: tx.fedex_tracking_number, event_type: eventType, event_description: event.description, event_code: event.code, location: event.location, location_city: event.city, location_country: event.country, event_timestamp: event.timestamp, raw_payload: event, created_at: new Date().toISOString() });
      const ns = getStatus(eventType);
      if (ns) latestStatus = ns;
    }
    if (latestStatus && latestStatus !== tx.status) {
      const upd: Record<string, string> = { status: latestStatus, updated_at: new Date().toISOString() };
      if (latestStatus === 'shipped') upd.shipped_at = new Date().toISOString();
      if (latestStatus === 'delivered') upd.delivered_at = new Date().toISOString();
      await supabase.from('marketplace_transactions').update(upd).eq('id', tx.id);
      await sendNotification(supabase, tx, latestStatus);
    }
    return { success: true, newEventsCount: newEvents.length };
  } catch (error) {
    console.error(`Error tracking ${tx.id}:`, error);
    return { success: false, newEventsCount: 0 };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Authorization" } });
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });
    const body: TrackRequest = await req.json();
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const fedex = new FedExClient({ clientId: Deno.env.get('FEDEX_CLIENT_ID')!, clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!, accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!, environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production' });

    let transactions;
    if (body.tracking_number) {
      const { data } = await supabase.from('marketplace_transactions').select('id, fedex_tracking_number, status, buyer_id, seller_id').eq('fedex_tracking_number', body.tracking_number).single();
      transactions = data ? [data] : [];
    } else {
      const { data } = await supabase.from('marketplace_transactions').select('id, fedex_tracking_number, status, buyer_id, seller_id').in('status', ['shipped', 'in_transit', 'out_for_delivery', 'label_created']).not('fedex_tracking_number', 'is', null);
      transactions = data || [];
    }
    console.log(`Tracking ${transactions.length} transactions...`);
    const results = [];
    for (const tx of transactions) {
      const result = await trackTx(supabase, fedex, tx);
      results.push({ transaction_id: tx.id, ...result });
    }
    const totalNew = results.reduce((s, r) => s + r.newEventsCount, 0);
    return new Response(JSON.stringify({ tracked: transactions.length, successful: results.filter(r => r.success).length, total_new_events: totalNew, results }), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    console.error("Error tracking:", error);
    return new Response(JSON.stringify({ error: (error as Error).message }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
