// EPIC-11: Complete Stripe Webhook Handler (S04-S10)
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

const MAX_ATTEMPTS = 5;
const PLATFORM_FEE_RATE = 0.10;
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req: Request) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

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
    console.error("Signature failed:", (err as Error).message);
    return new Response("Invalid signature", { status: 400 });
  }

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  await supabase.from("stripe_events").upsert({ stripe_event_id: event.id, event_type: event.type, api_version: event.api_version, payload: event.data.object, livemode: event.livemode, stripe_created_at: new Date(event.created * 1000).toISOString() }, { onConflict: "stripe_event_id" });

  const { data: existing } = await supabase.from("stripe_events").select("processed").eq("stripe_event_id", event.id).single();
  if (existing?.processed) return new Response("Already processed", { status: 200 });

  try {
    await processEvent(supabase, event);
    await supabase.from("stripe_events").update({ processed: true, processed_at: new Date().toISOString() }).eq("stripe_event_id", event.id);
    console.log(`OK: ${event.type} (${event.id})`);
    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error(`Error ${event.type}:`, err);
    return await handleError(supabase, event, err as Error);
  }
});

async function processEvent(db: SupabaseClient, e: Stripe.Event): Promise<void> {
  const o = e.data.object as any;
  switch (e.type) {
    case "payment_intent.created": await piCreated(db, o); break;
    case "payment_intent.processing": await piStatus(db, o, "processing"); break;
    case "payment_intent.succeeded": await piSucceeded(db, o); break;
    case "payment_intent.payment_failed": await piFailed(db, o); break;
    case "payment_intent.canceled": await piStatus(db, o, "canceled"); break;
    case "payment_intent.requires_action": await piRequiresAction(db, o); break;
    case "checkout.session.completed": await checkoutCompleted(db, o); break;
    case "checkout.session.expired": await checkoutExpired(db, o); break;
    case "checkout.session.async_payment_succeeded": await checkoutAsync(db, o, true); break;
    case "checkout.session.async_payment_failed": await checkoutAsync(db, o, false); break;
    case "account.updated": await accountUpdated(db, o); break;
    case "account.application.deauthorized": await accountDeauth(db, o); break;
    case "account.external_account.created":
    case "account.external_account.updated":
    case "account.external_account.deleted": console.log(`External: ${e.type}`); break;
    case "charge.dispute.created": await disputeCreated(db, o); break;
    case "charge.dispute.updated": await disputeUpdated(db, o); break;
    case "charge.dispute.closed": await disputeClosed(db, o); break;
    case "charge.dispute.funds_reinstated":
    case "charge.dispute.funds_withdrawn": await disputeFunds(db, o, e.type); break;
    case "payout.created":
    case "payout.updated": console.log(`Payout: ${e.type} ${o.id}`); break;
    case "payout.paid": await payoutPaid(db, o); break;
    case "payout.failed": await payoutFailed(db, o); break;
    case "payout.canceled": await payoutCanceled(db, o); break;
    case "transfer.created": await transferCreated(db, o); break;
    case "transfer.updated": console.log(`Transfer updated: ${o.id}`); break;
    case "transfer.reversed": await transferReversed(db, o); break;
    case "charge.refunded": await chargeRefunded(db, o); break;
    case "charge.refund.updated": console.log(`Refund updated: ${o.id}`); break;
    default: console.log(`Unhandled: ${e.type}`);
  }
}

async function handleError(db: SupabaseClient, e: Stripe.Event, err: Error): Promise<Response> {
  const { data } = await db.from("stripe_events").select("processing_attempts").eq("stripe_event_id", e.id).single();
  const attempts = (data?.processing_attempts || 0) + 1;
  await db.from("stripe_events").update({ error_message: err.message, processing_attempts: attempts }).eq("stripe_event_id", e.id);
  if (attempts >= MAX_ATTEMPTS) {
    await db.from("notifications_outbox").insert({ event_type: "webhook_dead_letter", payload: { event_id: e.id, event_type: e.type, error: err.message, attempts }, recipient_id: null });
    return new Response("Max retries", { status: 200 });
  }
  return new Response("Error", { status: 500 });
}

async function piCreated(db: SupabaseClient, pi: Stripe.PaymentIntent) {
  const m = pi.metadata || {};
  if (!m.user_id || !m.product_type) return;
  const fee = m.seller_id ? Math.floor(pi.amount * PLATFORM_FEE_RATE) : 0;
  await db.from("purchases").insert({ user_id: m.user_id, product_type: m.product_type, product_id: m.product_id || null, seller_id: m.seller_id || null, amount_cents: pi.amount, currency: pi.currency.toUpperCase(), platform_fee_cents: fee, seller_amount_cents: m.seller_id ? pi.amount - fee : null, stripe_payment_intent_id: pi.id, status: "pending" });
}
async function piStatus(db: SupabaseClient, pi: Stripe.PaymentIntent, status: string) {
  await db.from("purchases").update({ status, updated_at: new Date().toISOString() }).eq("stripe_payment_intent_id", pi.id);
}
async function piSucceeded(db: SupabaseClient, pi: Stripe.PaymentIntent) {
  const now = new Date().toISOString();
  const { data: p } = await db.from("purchases").update({ status: "succeeded", paid_at: now, updated_at: now, stripe_charge_id: typeof pi.latest_charge === 'string' ? pi.latest_charge : null }).eq("stripe_payment_intent_id", pi.id).select("user_id, amount_cents, currency, product_type").single();
  if (p) await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: "payment_succeeded", payload: { amount: p.amount_cents / 100, currency: p.currency, product_type: p.product_type } });
}
async function piFailed(db: SupabaseClient, pi: Stripe.PaymentIntent) {
  const msg = pi.last_payment_error?.message || "Payment failed";
  const { data: p } = await db.from("purchases").update({ status: "failed", error_message: msg, error_code: pi.last_payment_error?.code || "unknown", updated_at: new Date().toISOString() }).eq("stripe_payment_intent_id", pi.id).select("user_id").single();
  if (p) await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: "payment_failed", payload: { error_message: msg } });
}
async function piRequiresAction(db: SupabaseClient, pi: Stripe.PaymentIntent) {
  const { data: p } = await db.from("purchases").update({ status: "requires_action", updated_at: new Date().toISOString() }).eq("stripe_payment_intent_id", pi.id).select("user_id").single();
  if (p) await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: "payment_requires_action", payload: { message: "Additional authentication required" } });
}

async function checkoutCompleted(db: SupabaseClient, s: Stripe.Checkout.Session) {
  const { data: ex } = await db.from("purchases").select("id").eq("stripe_checkout_session_id", s.id).single();
  const m = s.metadata || {};
  const amt = s.amount_total || 0;
  const fee = m.seller_id ? Math.floor(amt * PLATFORM_FEE_RATE) : 0;
  const now = new Date().toISOString();
  const piId = typeof s.payment_intent === 'string' ? s.payment_intent : null;
  if (ex) {
    await db.from("purchases").update({ status: "succeeded", paid_at: now, updated_at: now, stripe_payment_intent_id: piId }).eq("id", ex.id);
  } else if (m.user_id && m.product_type) {
    await db.from("purchases").insert({ user_id: m.user_id, product_type: m.product_type, product_id: m.product_id || null, seller_id: m.seller_id || null, amount_cents: amt, currency: (s.currency || "usd").toUpperCase(), platform_fee_cents: fee, seller_amount_cents: m.seller_id ? amt - fee : null, stripe_checkout_session_id: s.id, stripe_payment_intent_id: piId, status: "succeeded", paid_at: now });
  }
  if (m.user_id) await db.from("notifications_outbox").insert({ recipient_id: m.user_id, event_type: "checkout_completed", payload: { amount: amt / 100, currency: (s.currency || "usd").toUpperCase() } });
}
async function checkoutExpired(db: SupabaseClient, s: Stripe.Checkout.Session) {
  if (s.metadata?.user_id) await db.from("notifications_outbox").insert({ recipient_id: s.metadata.user_id, event_type: "checkout_expired", payload: { message: "Checkout expired" } });
}
async function checkoutAsync(db: SupabaseClient, s: Stripe.Checkout.Session, success: boolean) {
  const now = new Date().toISOString();
  if (success) { await db.from("purchases").update({ status: "succeeded", paid_at: now, updated_at: now }).eq("stripe_checkout_session_id", s.id); }
  else { await db.from("purchases").update({ status: "failed", error_message: "Async payment failed", updated_at: now }).eq("stripe_checkout_session_id", s.id); }
  if (s.metadata?.user_id) await db.from("notifications_outbox").insert({ recipient_id: s.metadata.user_id, event_type: success ? "async_payment_succeeded" : "async_payment_failed", payload: { message: success ? "Payment confirmed" : "Payment failed" } });
}

async function accountUpdated(db: SupabaseClient, a: Stripe.Account) {
  const { data: sa } = await db.from("stripe_accounts").select("user_id, onboarding_complete").eq("stripe_account_id", a.id).single();
  if (!sa) return;
  const req = a.requirements || {};
  const complete = (a.charges_enabled && a.payouts_enabled) || false;
  const becameComplete = !sa.onboarding_complete && complete;
  await db.from("stripe_accounts").update({ charges_enabled: a.charges_enabled || false, payouts_enabled: a.payouts_enabled || false, details_submitted: a.details_submitted || false, onboarding_complete: complete, currently_due: req.currently_due || [], past_due: req.past_due || [], disabled_reason: req.disabled_reason || null, country: a.country, default_currency: a.default_currency, updated_at: new Date().toISOString() }).eq("stripe_account_id", a.id);
  if (becameComplete) await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "stripe_onboarding_complete", payload: { message: "Your seller account is now active!" } });
  else if (req.currently_due?.length > 0) await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "stripe_action_required", payload: { message: "Action required", requirements: req.currently_due } });
  else if (req.past_due?.length > 0) await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "stripe_action_urgent", payload: { message: "URGENT", requirements: req.past_due } });
}
async function accountDeauth(db: SupabaseClient, o: any) {
  const { data: sa } = await db.from("stripe_accounts").select("user_id").eq("stripe_account_id", o.account).single();
  if (!sa) return;
  await db.from("stripe_accounts").update({ charges_enabled: false, payouts_enabled: false, onboarding_complete: false, disabled_reason: "deauthorized", updated_at: new Date().toISOString() }).eq("stripe_account_id", o.account);
  await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "stripe_account_deauthorized", payload: { message: "Account disconnected" } });
  await db.from("notifications_outbox").insert({ recipient_id: null, event_type: "admin_account_deauthorized", payload: { user_id: sa.user_id, account_id: o.account } });
}

// Helper: find marketplace_transaction by stripe_charge_id (fallback when not in purchases)
async function findMarketplaceTx(db: SupabaseClient, chargeId: string) {
  const { data } = await db.from("marketplace_transactions")
    .select("id, buyer_id, seller_id, listing_id, status")
    .eq("stripe_charge_id", chargeId).maybeSingle();
  return data;
}

async function getListingTitle(db: SupabaseClient, listingId: string): Promise<string> {
  const { data } = await db.from("marketplace_listings").select("title").eq("id", listingId).maybeSingle();
  return data?.title || "item";
}

async function disputeCreated(db: SupabaseClient, d: Stripe.Dispute) {
  const chargeId = d.charge as string;
  const { data: p } = await db.from("purchases").select("id, user_id, seller_id").eq("stripe_charge_id", chargeId).maybeSingle();
  if (p) {
    await db.from("purchases").update({ status: "disputed", disputed_at: new Date().toISOString(), updated_at: new Date().toISOString() }).eq("id", p.id);
    if (p.seller_id) await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: "dispute_critical", payload: { priority: "critical", message: "URGENT: Dispute received", reason: d.reason, amount: d.amount / 100 } });
    await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: "dispute_created_buyer", payload: { message: "Dispute received" } });
  } else {
    // Fallback: marketplace_transactions
    const mt = await findMarketplaceTx(db, chargeId);
    if (mt) {
      const now = new Date().toISOString();
      await db.from("marketplace_transactions").update({ status: "disputed", disputed_at: now, updated_at: now }).eq("id", mt.id);
      const title = await getListingTitle(db, mt.listing_id);
      await db.from("notifications_outbox").insert({ event_type: "marketplace_disputed", event_key: `marketplace:disputed:seller:${mt.id}`, payload: { recipient_id: mt.seller_id, transaction_id: mt.id, listing_title: title, reason: d.reason } });
      await db.from("notifications_outbox").insert({ event_type: "marketplace_disputed", event_key: `marketplace:disputed:buyer:${mt.id}`, payload: { recipient_id: mt.buyer_id, transaction_id: mt.id, listing_title: title, reason: d.reason } });
    }
  }
  await db.from("notifications_outbox").insert({ recipient_id: null, event_type: "admin_dispute_created", payload: { dispute_id: d.id, charge_id: chargeId, reason: d.reason, amount: d.amount / 100 } });
}
async function disputeUpdated(db: SupabaseClient, d: Stripe.Dispute) {
  const chargeId = d.charge as string;
  const { data: p } = await db.from("purchases").select("seller_id").eq("stripe_charge_id", chargeId).maybeSingle();
  if (p?.seller_id) {
    await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: "dispute_updated", payload: { status: d.status } });
  } else {
    const mt = await findMarketplaceTx(db, chargeId);
    if (mt) {
      await db.from("notifications_outbox").insert({ event_type: "marketplace_disputed", event_key: `marketplace:dispute_update:${mt.id}:${d.status}`, payload: { recipient_id: mt.seller_id, transaction_id: mt.id, reason: `Dispute status: ${d.status}` } });
    }
  }
}
async function disputeClosed(db: SupabaseClient, d: Stripe.Dispute) {
  const won = d.status === "won";
  const chargeId = d.charge as string;
  const { data: p } = await db.from("purchases").select("id, seller_id, user_id").eq("stripe_charge_id", chargeId).maybeSingle();
  if (p) {
    await db.from("purchases").update({ status: won ? "succeeded" : "refunded", updated_at: new Date().toISOString(), ...(won ? {} : { refunded_at: new Date().toISOString() }) }).eq("id", p.id);
    if (p.seller_id) await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: won ? "dispute_won" : "dispute_lost", payload: { message: won ? "Dispute won!" : "Dispute lost", amount: d.amount / 100 } });
    await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: "dispute_closed_buyer", payload: { message: won ? "Dispute resolved" : "Refund processed" } });
  } else {
    const mt = await findMarketplaceTx(db, chargeId);
    if (mt) {
      const now = new Date().toISOString();
      if (won) {
        // Dispute won: restore previous status (best guess: 'paid' if no tracking, or keep current)
        await db.from("marketplace_transactions").update({ updated_at: now }).eq("id", mt.id);
      } else {
        // Dispute lost: refund the transaction, re-activate listing
        await db.from("marketplace_transactions").update({ status: "refunded", refunded_at: now, updated_at: now }).eq("id", mt.id);
        await db.from("marketplace_listings").update({ status: "active" }).eq("id", mt.listing_id);
      }
      const title = await getListingTitle(db, mt.listing_id);
      await db.from("notifications_outbox").insert({ event_type: "marketplace_dispute_resolved", event_key: `marketplace:dispute_closed:seller:${mt.id}`, payload: { recipient_id: mt.seller_id, transaction_id: mt.id, listing_title: title } });
      await db.from("notifications_outbox").insert({ event_type: "marketplace_dispute_resolved", event_key: `marketplace:dispute_closed:buyer:${mt.id}`, payload: { recipient_id: mt.buyer_id, transaction_id: mt.id, listing_title: title } });
    }
  }
}
async function disputeFunds(db: SupabaseClient, d: Stripe.Dispute, type: string) {
  const reinstated = type.includes("reinstated");
  const chargeId = d.charge as string;
  const { data: p } = await db.from("purchases").select("seller_id").eq("stripe_charge_id", chargeId).maybeSingle();
  if (p?.seller_id) {
    await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: reinstated ? "funds_reinstated" : "funds_withdrawn", payload: { message: reinstated ? "Funds returned" : "Funds withdrawn", amount: d.amount / 100 } });
  } else {
    const mt = await findMarketplaceTx(db, chargeId);
    if (mt) {
      await db.from("notifications_outbox").insert({ event_type: reinstated ? "marketplace_dispute_resolved" : "marketplace_disputed", event_key: `marketplace:dispute_funds:${mt.id}:${reinstated ? 'reinstated' : 'withdrawn'}`, payload: { recipient_id: mt.seller_id, transaction_id: mt.id, reason: reinstated ? "Funds reinstated" : "Funds withdrawn" } });
    }
  }
}

async function payoutPaid(db: SupabaseClient, p: Stripe.Payout) {
  const accId = (p as any).account;
  if (!accId) return;
  const { data: sa } = await db.from("stripe_accounts").select("user_id").eq("stripe_account_id", accId).single();
  if (sa) await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "payout_paid", payload: { message: `Payout sent: ${(p.amount/100).toFixed(2)} ${p.currency.toUpperCase()}`, amount: p.amount / 100 } });
}
async function payoutFailed(db: SupabaseClient, p: Stripe.Payout) {
  const accId = (p as any).account;
  let userId = null;
  if (accId) {
    const { data: sa } = await db.from("stripe_accounts").select("user_id").eq("stripe_account_id", accId).single();
    userId = sa?.user_id;
    if (userId) await db.from("notifications_outbox").insert({ recipient_id: userId, event_type: "payout_failed_critical", payload: { priority: "critical", message: "Payout failed", reason: p.failure_message || p.failure_code } });
  }
  await db.from("notifications_outbox").insert({ recipient_id: null, event_type: "admin_payout_failed", payload: { payout_id: p.id, account_id: accId, user_id: userId, failure: p.failure_code } });
}
async function payoutCanceled(db: SupabaseClient, p: Stripe.Payout) {
  const accId = (p as any).account;
  if (!accId) return;
  const { data: sa } = await db.from("stripe_accounts").select("user_id").eq("stripe_account_id", accId).single();
  if (sa) await db.from("notifications_outbox").insert({ recipient_id: sa.user_id, event_type: "payout_canceled", payload: { message: "Payout canceled" } });
}

async function transferCreated(db: SupabaseClient, t: Stripe.Transfer) {
  const src = t.source_transaction as string;
  if (src) {
    const { data: p } = await db.from("purchases").select("id").eq("stripe_charge_id", src).maybeSingle();
    if (p) {
      await db.from("purchases").update({ stripe_transfer_id: t.id, updated_at: new Date().toISOString() }).eq("id", p.id);
    } else {
      // Fallback: marketplace_transactions
      const { data: mt } = await db.from("marketplace_transactions").select("id").eq("stripe_charge_id", src).maybeSingle();
      if (mt) await db.from("marketplace_transactions").update({ stripe_transfer_id: t.id, updated_at: new Date().toISOString() }).eq("id", mt.id);
    }
  }
}
async function transferReversed(db: SupabaseClient, t: Stripe.Transfer) {
  const { data: p } = await db.from("purchases").select("seller_id").eq("stripe_transfer_id", t.id).maybeSingle();
  if (p?.seller_id) {
    await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: "transfer_reversed", payload: { message: "Transfer reversed", amount: t.amount / 100 } });
  } else {
    // Fallback: marketplace_transactions
    const { data: mt } = await db.from("marketplace_transactions").select("seller_id").eq("stripe_transfer_id", t.id).maybeSingle();
    if (mt?.seller_id) await db.from("notifications_outbox").insert({ recipient_id: mt.seller_id, event_type: "transfer_reversed", payload: { message: "Transfer reversed", amount: t.amount / 100 } });
  }
}
async function chargeRefunded(db: SupabaseClient, c: Stripe.Charge) {
  const full = c.amount_refunded >= c.amount;
  const { data: p } = await db.from("purchases").select("id, user_id, seller_id").eq("stripe_charge_id", c.id).maybeSingle();
  if (p) {
    await db.from("purchases").update({ status: full ? "refunded" : "partially_refunded", updated_at: new Date().toISOString(), ...(full ? { refunded_at: new Date().toISOString() } : {}) }).eq("id", p.id);
    await db.from("notifications_outbox").insert({ recipient_id: p.user_id, event_type: full ? "purchase_refunded" : "partial_refund", payload: { message: full ? "Refunded" : "Partial refund", amount: c.amount_refunded / 100 } });
    if (p.seller_id) await db.from("notifications_outbox").insert({ recipient_id: p.seller_id, event_type: "sale_refunded", payload: { message: "Sale refunded", amount: c.amount_refunded / 100 } });
  } else {
    // Fallback: marketplace_transactions
    const mt = await findMarketplaceTx(db, c.id);
    if (mt && full) {
      const now = new Date().toISOString();
      await db.from("marketplace_transactions").update({ status: "refunded", refunded_at: now, updated_at: now }).eq("id", mt.id);
      // Re-activate listing so it can be sold again
      await db.from("marketplace_listings").update({ status: "active" }).eq("id", mt.listing_id);
      const title = await getListingTitle(db, mt.listing_id);
      await db.from("notifications_outbox").insert({ event_type: "marketplace_refunded", event_key: `marketplace:refunded:buyer:${mt.id}`, payload: { recipient_id: mt.buyer_id, transaction_id: mt.id, listing_title: title } });
      await db.from("notifications_outbox").insert({ event_type: "marketplace_refunded", event_key: `marketplace:refunded:seller:${mt.id}`, payload: { recipient_id: mt.seller_id, transaction_id: mt.id, listing_title: title } });
    }
  }
}
