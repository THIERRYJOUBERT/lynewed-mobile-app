// EPIC-14 S12: Generate FedEx Shipping Label
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient, type Address } from "./fedex-client.ts";

interface CreateShipmentRequest { transaction_id: string; service_type: string; }

/** Maps a DB address (snake_case keys) to the FedEx Address interface (camelCase). */
function mapAddress(addr: Record<string, unknown>, name: string, phone: string): Address {
  return {
    streetLines: (addr.street_lines || addr.streetLines || []) as string[],
    city: (addr.city || '') as string,
    postalCode: (addr.postal_code || addr.postalCode || '') as string,
    countryCode: (addr.country_code || addr.countryCode || '') as string,
    stateOrProvinceCode: (addr.state_or_province_code || addr.stateOrProvinceCode) as string | undefined,
    personName: name,
    phoneNumber: phone || undefined,
  };
}

/** Validates that required FedEx address fields are present. Returns error messages. */
function validateAddress(addr: Address, label: string): string[] {
  const errors: string[] = [];
  if (!addr.streetLines?.length || !addr.streetLines[0]) errors.push(`${label}: street address is required`);
  if (!addr.city) errors.push(`${label}: city is required`);
  if (!addr.postalCode) errors.push(`${label}: postal code is required`);
  if (!addr.countryCode) errors.push(`${label}: country code is required`);
  return errors;
}

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

    // Resolve seller address: refresh from profile if transaction has empty address (old transactions)
    let fromAddr = tx.shipping_from_address as Record<string, unknown>;
    const fromStreetLines = (fromAddr.street_lines || fromAddr.streetLines) as string[] | undefined;
    if (!fromAddr.city && (!fromStreetLines?.length)) {
      console.log('Seller address empty in transaction, refreshing from profile...');
      const { data: sellerProfile } = await supabaseAdmin.from('profiles').select('shipping_address, full_name').eq('id', tx.seller_id).single();
      if (sellerProfile?.shipping_address && sellerProfile.shipping_address.city) {
        fromAddr = sellerProfile.shipping_address as Record<string, unknown>;
        await supabaseAdmin.from('marketplace_transactions').update({ shipping_from_address: fromAddr, updated_at: new Date().toISOString() }).eq('id', body.transaction_id);
        console.log('Seller address refreshed from profile');
      }
    }

    const toAddr = tx.shipping_to_address as Record<string, unknown>;
    const shipperName = (fromAddr.person_name || fromAddr.personName || 'Seller') as string;
    const recipientName = (toAddr.person_name || toAddr.personName || 'Buyer') as string;
    const shipperPhone = (fromAddr.phone_number || fromAddr.phoneNumber || '') as string;
    const recipientPhone = (toAddr.phone_number || toAddr.phoneNumber || '') as string;

    // Map snake_case DB fields to camelCase FedEx Address interface
    const shipperAddress = mapAddress(fromAddr, shipperName, shipperPhone);
    const recipientAddress = mapAddress(toAddr, recipientName, recipientPhone);

    // Validate addresses before calling FedEx
    const validationErrors = [...validateAddress(shipperAddress, 'Shipper'), ...validateAddress(recipientAddress, 'Recipient')];
    if (validationErrors.length > 0) {
      console.error('Address validation failed:', validationErrors);
      return new Response(JSON.stringify({ error: `Address validation failed: ${validationErrors.join(', ')}` }), { status: 400, headers: { "Content-Type": "application/json" } });
    }

    const shipment = await fedex.createShipment({ shipper: shipperAddress, recipient: recipientAddress, serviceType: body.service_type, packageDetails, referenceId: tx.id });

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
