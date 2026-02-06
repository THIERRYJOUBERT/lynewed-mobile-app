/// Edge Function: marketplace-refund
/// Handles refund requests and approvals for marketplace transactions.
/// Actions:
///   - request: Buyer requests a refund (sets refund_requested_at + refund_reason)
///   - approve: Seller approves → Stripe refund + status update
///   - reject: Seller rejects → clears refund request
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@17.7.0?target=deno&no-check";

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
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return jsonResponse({ error: "Invalid token" }, 401);
    }

    const { action, transaction_id, reason } = await req.json();
    if (!action || !transaction_id) {
      return jsonResponse(
        { error: "Missing action or transaction_id" },
        400
      );
    }

    // Fetch the transaction
    const { data: tx, error: txError } = await supabase
      .from("marketplace_transactions")
      .select("*")
      .eq("id", transaction_id)
      .single();

    if (txError || !tx) {
      return jsonResponse({ error: "Transaction not found" }, 404);
    }

    switch (action) {
      case "request":
        return await handleRequest(supabase, user.id, tx, reason);
      case "approve":
        return await handleApprove(supabase, user.id, tx);
      case "reject":
        return await handleReject(supabase, user.id, tx);
      default:
        return jsonResponse({ error: `Unknown action: ${action}` }, 400);
    }
  } catch (error) {
    console.error("Marketplace refund error:", error);
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});

async function handleRequest(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  tx: Record<string, unknown>,
  reason: string | undefined
) {
  // Only the buyer can request a refund
  if (tx.buyer_id !== userId) {
    return jsonResponse(
      { error: "Only the buyer can request a refund" },
      403
    );
  }

  // Cannot request refund on completed, refunded, or disputed transactions
  const blockedStatuses = ["completed", "refunded", "disputed", "expired"];
  if (blockedStatuses.includes(tx.status as string)) {
    return jsonResponse(
      {
        error: `Cannot request refund on a ${tx.status} transaction`,
      },
      400
    );
  }

  // Cannot request if already requested
  if (tx.refund_requested_at) {
    return jsonResponse(
      { error: "A refund has already been requested" },
      400
    );
  }

  const now = new Date().toISOString();
  await supabase
    .from("marketplace_transactions")
    .update({
      refund_requested_at: now,
      refund_reason: reason || null,
      updated_at: now,
    })
    .eq("id", tx.id);

  // Fetch listing title for notification
  const listingTitle = await getListingTitle(supabase, tx.listing_id as string);

  // Notify the seller
  await supabase.from("notifications_outbox").insert({
    event_type: "marketplace_refund_requested",
    event_key: `marketplace:refund_requested:${tx.id}`,
    payload: {
      recipient_id: tx.seller_id,
      transaction_id: tx.id,
      listing_id: tx.listing_id,
      listing_title: listingTitle,
      buyer_id: tx.buyer_id,
      refund_reason: reason || null,
    },
  });

  console.log(`Refund requested for transaction ${tx.id} by buyer ${userId}`);

  return jsonResponse({
    success: true,
    transaction_id: tx.id,
    action: "request",
  });
}

async function handleApprove(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  tx: Record<string, unknown>
) {
  // Only the seller can approve a refund
  if (tx.seller_id !== userId) {
    return jsonResponse(
      { error: "Only the seller can approve a refund" },
      403
    );
  }

  // Must have a pending refund request
  if (!tx.refund_requested_at) {
    return jsonResponse(
      { error: "No refund request pending" },
      400
    );
  }

  // Must have a Stripe payment intent to refund
  if (!tx.stripe_payment_intent_id) {
    return jsonResponse(
      { error: "No payment found to refund" },
      400
    );
  }

  // Process the Stripe refund
  const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
    apiVersion: "2024-12-18.acacia",
  });

  await stripe.refunds.create({
    payment_intent: tx.stripe_payment_intent_id as string,
  });

  const now = new Date().toISOString();
  await supabase
    .from("marketplace_transactions")
    .update({
      status: "refunded",
      refunded_at: now,
      updated_at: now,
    })
    .eq("id", tx.id);

  // Re-activate the listing
  await supabase
    .from("marketplace_listings")
    .update({ status: "active", updated_at: now })
    .eq("id", tx.listing_id);

  // Cancel FedEx label if label_created
  if (tx.status === "label_created" && tx.fedex_tracking_number) {
    try {
      // Call fedex-cancel-shipment internally
      const cancelResponse = await supabase.functions.invoke(
        "fedex-cancel-shipment",
        {
          body: { transaction_id: tx.id },
          headers: {
            Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
          },
        }
      );
      console.log("FedEx cancel result:", cancelResponse.data);
    } catch (e) {
      console.warn("FedEx cancel failed (non-blocking):", e);
    }
  }

  const listingTitle = await getListingTitle(supabase, tx.listing_id as string);

  // Notify the buyer
  await supabase.from("notifications_outbox").insert({
    event_type: "marketplace_refund_approved",
    event_key: `marketplace:refund_approved:${tx.id}`,
    payload: {
      recipient_id: tx.buyer_id,
      transaction_id: tx.id,
      listing_id: tx.listing_id,
      listing_title: listingTitle,
    },
  });

  console.log(`Refund approved for transaction ${tx.id} by seller ${userId}`);

  return jsonResponse({
    success: true,
    transaction_id: tx.id,
    action: "approve",
  });
}

async function handleReject(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  tx: Record<string, unknown>
) {
  // Only the seller can reject a refund
  if (tx.seller_id !== userId) {
    return jsonResponse(
      { error: "Only the seller can reject a refund" },
      403
    );
  }

  // Must have a pending refund request
  if (!tx.refund_requested_at) {
    return jsonResponse(
      { error: "No refund request pending" },
      400
    );
  }

  const now = new Date().toISOString();
  await supabase
    .from("marketplace_transactions")
    .update({
      refund_requested_at: null,
      refund_reason: null,
      updated_at: now,
    })
    .eq("id", tx.id);

  const listingTitle = await getListingTitle(supabase, tx.listing_id as string);

  // Notify the buyer
  await supabase.from("notifications_outbox").insert({
    event_type: "marketplace_refund_rejected",
    event_key: `marketplace:refund_rejected:${tx.id}`,
    payload: {
      recipient_id: tx.buyer_id,
      transaction_id: tx.id,
      listing_id: tx.listing_id,
      listing_title: listingTitle,
    },
  });

  console.log(`Refund rejected for transaction ${tx.id} by seller ${userId}`);

  return jsonResponse({
    success: true,
    transaction_id: tx.id,
    action: "reject",
  });
}

async function getListingTitle(
  supabase: ReturnType<typeof createClient>,
  listingId: string
): Promise<string> {
  const { data: listing } = await supabase
    .from("marketplace_listings")
    .select("title")
    .eq("id", listingId)
    .maybeSingle();
  return listing?.title || "item";
}

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
