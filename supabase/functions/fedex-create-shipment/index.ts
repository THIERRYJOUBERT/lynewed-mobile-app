// EPIC-14 S12: Generate FedEx Shipping Label
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "./fedex-client.ts";

interface CreateShipmentRequest { transaction_id: string; service_type: string; }

const PKG: Record<string, { weight: { units: 'KG'; value: number }; dimensions: { units: 'CM'; length: number; width: number; height: number } }> = {
  dress: { weight: { units: 'KG', value: 3 }, dimensions: { units: 'CM', length: 60, width: 40, height: 20 } },
  shoes: { weight: { units: 'KG', value: 2 }, dimensions: { units: 'CM', length: 35, width: 25, height: 15 } },
  accessories: { weight: { units: 'KG', value: 1 }, dimensions: { units: 'CM', length: 30, width: 20, height: 10 } },
  decoration: { weight: { units: 'KG', value: 5 }, dimensions: { units: 'CM', length: 50, width: 50, height: 30 } },
  other: { weight: { units: 'KG', value: 3 }, dimensions: { units: 'CM', length: 40, width: 30, height: 20 } },
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Authorization" } });
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, { global: { headers: { Authorization: authHeader } } });
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });

    const body: CreateShipmentRequest = await req.json();
    if (!body.transaction_id || !body.service_type) return new Response(JSON.stringify({ error: "Missing transaction_id or service_type" }), { status: 400, headers: { "Content-Type": "application/json" } });

    const supabaseAdmin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: tx, error: txError } = await supabaseAdmin.from('marketplace_transactions').select('id, seller_id, buyer_id, shipping_from_address, shipping_to_address, status, listing:marketplace_listings(id, title, category)').eq('id', body.transaction_id).single();
    if (txError || !tx) return new Response(JSON.stringify({ error: "Transaction not found" }), { status: 404, headers: { "Content-Type": "application/json" } });
    if (tx.seller_id !== user.id) return new Response(JSON.stringify({ error: "Only seller can generate label" }), { status: 403, headers: { "Content-Type": "application/json" } });
    if (tx.status !== 'paid' && tx.status !== 'label_created') return new Response(JSON.stringify({ error: `Cannot generate label for status: ${tx.status}` }), { status: 400, headers: { "Content-Type": "application/json" } });

    const fedex = new FedExClient({ clientId: Deno.env.get('FEDEX_CLIENT_ID')!, clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!, accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!, environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production' });
    const category = (tx.listing as Record<string, string>)?.category || 'other';
    const packageDetails = PKG[category] || PKG.other;

    // Use person_name/personName from addresses, fallback to profile names
    const fromAddr = tx.shipping_from_address as Record<string, unknown>;
    const toAddr = tx.shipping_to_address as Record<string, unknown>;
    const shipperName = (fromAddr.person_name || fromAddr.personName || 'Seller') as string;
    const recipientName = (toAddr.person_name || toAddr.personName || 'Buyer') as string;
    const shipperPhone = (fromAddr.phone_number || fromAddr.phoneNumber || '') as string;
    const recipientPhone = (toAddr.phone_number || toAddr.phoneNumber || '') as string;

    const shipment = await fedex.createShipment({ shipper: { ...fromAddr, personName: shipperName, phoneNumber: shipperPhone || undefined }, recipient: { ...toAddr, personName: recipientName, phoneNumber: recipientPhone || undefined }, serviceType: body.service_type, packageDetails, referenceId: tx.id });

    // Upload label to Storage
    const labelFileName = `${user.id}/${tx.id}_${shipment.trackingNumber}.pdf`;
    const labelBuffer = Uint8Array.from(atob(shipment.labelBase64!), c => c.charCodeAt(0));
    await supabaseAdmin.storage.from('marketplace-labels').upload(labelFileName, labelBuffer, { contentType: 'application/pdf', upsert: true });
    const { data: urlData } = await supabaseAdmin.storage.from('marketplace-labels').createSignedUrl(labelFileName, 60 * 60 * 24 * 30);
    const labelUrl = urlData?.signedUrl || '';

    // Update transaction
    await supabaseAdmin.from('marketplace_transactions').update({ fedex_tracking_number: shipment.trackingNumber, fedex_label_url: labelUrl, status: 'label_created', updated_at: new Date().toISOString() }).eq('id', body.transaction_id);

    // Log event
    await supabaseAdmin.from('fedex_events').insert({ transaction_id: body.transaction_id, tracking_number: shipment.trackingNumber, event_type: 'label_created', event_description: 'Shipping label generated', event_timestamp: new Date().toISOString(), raw_payload: shipment.rawResponse });

    // FIX C-01: Use correct notifications_outbox schema
    const listingTitle = (tx.listing as Record<string, string>)?.title || 'item';
    await supabaseAdmin.from('notifications_outbox').insert({
      event_type: 'marketplace_label_ready',
      event_key: `marketplace:label_ready:${tx.id}`,
      payload: {
        recipient_id: tx.buyer_id,
        transaction_id: tx.id,
        tracking_number: shipment.trackingNumber,
        label_url: labelUrl,
        listing_title: listingTitle,
      },
    });

    return new Response(JSON.stringify({ tracking_number: shipment.trackingNumber, label_url: labelUrl, service_type: body.service_type }), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    console.error("Error creating shipment:", error);
    const msg = (error as Error).message;
    try { const parsed = JSON.parse(msg); return new Response(JSON.stringify(parsed), { status: 500, headers: { "Content-Type": "application/json" } }); } catch { /* not JSON */ }
    return new Response(JSON.stringify({ error: msg }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
