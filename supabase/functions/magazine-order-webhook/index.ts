// EPIC-12 S11: Magazine Order Webhook
// Handles checkout.session.completed for magazine orders
// Creates magazine_orders, magazine_order_items (photo snapshots), clears selections
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_MAGAZINE_WEBHOOK_SECRET")!;
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req: Request) => {
  // 1. Verify Stripe signature
  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    console.error("Missing stripe-signature header");
    return new Response("Missing signature", { status: 400 });
  }

  let event: Stripe.Event;
  const body = await req.text();

  try {
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret,
      undefined,
      cryptoProvider,
    );
  } catch (err) {
    console.error("Signature verification failed:", (err as Error).message);
    return new Response("Invalid signature", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 2. Log event for audit trail and idempotency check
  const { error: upsertError } = await supabase.from("stripe_events").upsert(
    {
      stripe_event_id: event.id,
      event_type: event.type,
      api_version: event.api_version,
      payload: event.data.object,
      livemode: event.livemode,
      stripe_created_at: new Date(event.created * 1000).toISOString(),
    },
    { onConflict: "stripe_event_id" }
  );

  if (upsertError) {
    console.error("Failed to log event:", upsertError);
  }

  // 3. Check if already processed (idempotency)
  const { data: existing } = await supabase
    .from("stripe_events")
    .select("processed")
    .eq("stripe_event_id", event.id)
    .single();

  if (existing?.processed) {
    console.log("Event already processed:", event.id);
    return new Response("Already processed", { status: 200 });
  }

  // 4. Only process checkout.session.completed
  if (event.type !== "checkout.session.completed") {
    console.log("Ignoring event type:", event.type);
    return new Response("Event type ignored", { status: 200 });
  }

  const session = event.data.object as Stripe.Checkout.Session;
  const metadata = session.metadata || {};

  // 5. Validate this is a magazine order (check metadata)
  if (metadata.product_type !== "magazine") {
    console.log("Not a magazine order, skipping");
    return new Response("Not a magazine order", { status: 200 });
  }

  try {
    await processMagazineOrder(supabase, session, metadata);

    // Mark event as processed
    await supabase
      .from("stripe_events")
      .update({
        processed: true,
        processed_at: new Date().toISOString(),
      })
      .eq("stripe_event_id", event.id);

    console.log(`Magazine order created for session: ${session.id}`);
    return new Response(
      JSON.stringify({ success: true, session_id: session.id }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Failed to process magazine order:", err);

    // Update error info
    const { data: eventData } = await supabase
      .from("stripe_events")
      .select("processing_attempts")
      .eq("stripe_event_id", event.id)
      .single();

    const attempts = (eventData?.processing_attempts || 0) + 1;
    await supabase
      .from("stripe_events")
      .update({
        error_message: (err as Error).message,
        processing_attempts: attempts,
      })
      .eq("stripe_event_id", event.id);

    // Return 500 to trigger Stripe retry (up to their limit)
    return new Response("Processing failed", { status: 500 });
  }
});

async function processMagazineOrder(
  db: SupabaseClient,
  session: Stripe.Checkout.Session,
  metadata: Record<string, string>
): Promise<void> {
  const {
    wedding_id,
    bride_user_id,
    magazine_format,
    photo_count,
    magazine_price_cents,
    magazine_title,
    magazine_date,
    cover_photo_id,
    quantity,
  } = metadata;

  // Extract shipping cost from Stripe session (set by shipping_options)
  const shippingCostCents =
    session.total_details?.amount_shipping ??
    (session as any).shipping_cost?.amount_total ??
    0;

  // Extract shipping details (Stripe API 2025-07-30+ moved to collected_information)
  const shippingInfo =
    session.shipping_details ??
    (session as any).collected_information?.shipping_details ??
    null;

  // Validate required fields
  if (!wedding_id || !bride_user_id || !magazine_format) {
    throw new Error("Missing required metadata fields");
  }

  // 1. Verify wedding belongs to bride (security check)
  const { data: wedding, error: weddingError } = await db
    .from("weddings")
    .select("bride_profile_id")
    .eq("id", wedding_id)
    .single();

  if (weddingError || !wedding) {
    throw new Error(`Wedding not found: ${wedding_id}`);
  }

  if (wedding.bride_profile_id !== bride_user_id) {
    throw new Error("Wedding/bride mismatch - unauthorized");
  }

  // 2. Check if order already exists (additional idempotency)
  const { data: existingOrder } = await db
    .from("magazine_orders")
    .select("id")
    .eq("stripe_checkout_session_id", session.id)
    .single();

  if (existingOrder) {
    console.log("Order already exists for session:", session.id);
    return;
  }

  // 3. Create the magazine order
  const now = new Date().toISOString();
  const paymentIntentId =
    typeof session.payment_intent === "string"
      ? session.payment_intent
      : session.payment_intent?.id || null;

  const { data: order, error: orderError } = await db
    .from("magazine_orders")
    .insert({
      wedding_id,
      bride_user_id,
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: paymentIntentId,
      magazine_format,
      magazine_price_cents: parseInt(magazine_price_cents || "0"),
      shipping_cost_cents: shippingCostCents,
      total_paid_cents: session.amount_total || 0,
      currency: (session.currency || "usd").toUpperCase(),
      shipping_name: shippingInfo?.name || "",
      shipping_address_line1: shippingInfo?.address?.line1 || "",
      shipping_address_line2: shippingInfo?.address?.line2 || null,
      shipping_city: shippingInfo?.address?.city || "",
      shipping_zip: shippingInfo?.address?.postal_code || "",
      shipping_country: shippingInfo?.address?.country || "",
      shipping_phone: session.customer_details?.phone || null,
      magazine_title: magazine_title || "Wedding Magazine",
      magazine_date: magazine_date || null,
      cover_photo_id: cover_photo_id || null,
      photo_count: parseInt(photo_count || "0"),
      quantity: parseInt(quantity || "1"),
      status: "paid",
      paid_at: now,
    })
    .select()
    .single();

  if (orderError || !order) {
    throw new Error(`Failed to create order: ${orderError?.message}`);
  }

  console.log("Created magazine order:", order.id);

  // 4. Get selections and create order items (photo snapshots)
  const { data: selections, error: selError } = await db
    .from("magazine_selections")
    .select("*")
    .eq("wedding_id", wedding_id)
    .eq("user_id", bride_user_id)
    .order("position");

  if (selError) {
    console.error("Failed to fetch selections:", selError);
  }

  const orderItems: Array<{
    order_id: string;
    media_type: string;
    media_id: string;
    position: number;
    storage_url: string;
    caption: string | null;
  }> = [];

  for (const sel of selections || []) {
    let storageUrl = "";

    // Get the actual storage URL based on media type
    if (sel.media_type === "album_image") {
      const { data: img } = await db
        .from("album_images")
        .select("image_url")
        .eq("id", sel.media_id)
        .single();
      storageUrl = img?.image_url || "";
    } else if (sel.media_type === "guest_media") {
      const { data: media } = await db
        .from("guest_media")
        .select("storage_path")
        .eq("id", sel.media_id)
        .single();

      if (media?.storage_path) {
        // Create signed URL for the order item (30 days for security)
        // Admin can regenerate if needed for reprints after expiry
        const { data: urlData } = await db.storage
          .from("wedding-albums")
          .createSignedUrl(media.storage_path, 60 * 60 * 24 * 30); // 30 days
        storageUrl = urlData?.signedUrl || media.storage_path;
      }
    }

    if (storageUrl) {
      orderItems.push({
        order_id: order.id,
        media_type: sel.media_type,
        media_id: sel.media_id,
        position: sel.position,
        storage_url: storageUrl,
        caption: null,
      });
    }
  }

  // Insert order items - CRITICAL operation
  if (orderItems.length > 0) {
    const { error: itemsError } = await db
      .from("magazine_order_items")
      .insert(orderItems);

    if (itemsError) {
      console.error("CRITICAL: Failed to insert order items:", itemsError);
      // Rollback: delete the order to maintain consistency
      // The webhook will retry and recreate everything
      await db.from("magazine_orders").delete().eq("id", order.id);
      throw new Error(`Failed to create order items: ${itemsError.message}`);
    }
    console.log(`Created ${orderItems.length} order items`);
  }

  // 5. Clear magazine selections (they've been snapshotted)
  const { error: deleteError } = await db
    .from("magazine_selections")
    .delete()
    .eq("wedding_id", wedding_id)
    .eq("user_id", bride_user_id);

  if (deleteError) {
    console.error("WARNING: Failed to clear selections:", deleteError);
    // Don't rollback order - photos are saved, order is valid
    // Alert admin via notification for manual cleanup
    await db.from("notifications_outbox").insert({
      recipient_id: bride_user_id,
      event_type: "admin_alert",
      payload: {
        order_id: order.id,
        title: "Magazine Order - Manual Action Needed",
        body: "Order created but selections cleanup failed. Please review.",
        error: deleteError.message,
      },
    });
  } else {
    console.log("Cleared magazine selections");
  }

  // 6. Send push notification to bride
  const { error: notifError } = await db.from("notifications_outbox").insert({
    recipient_id: bride_user_id,
    event_type: "magazine_order_confirmed",
    payload: {
      order_id: order.id,
      title: "Magazine Order Confirmed!",
      body: "Your wedding magazine is being prepared.",
      magazine_format: magazine_format,
      photo_count: orderItems.length,
    },
  });

  if (notifError) {
    console.error("Failed to create notification:", notifError);
    // Don't throw - order is created, notification is not critical
  } else {
    console.log("Created notification for bride");
  }

  console.log(`Magazine order ${order.id} fully processed`);
}
