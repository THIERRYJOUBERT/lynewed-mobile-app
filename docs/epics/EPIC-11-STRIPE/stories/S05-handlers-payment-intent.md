# Story S05: Implementer handlers payment_intent.*

## Description
En tant que developpeur, je veux implementer tous les handlers pour les events `payment_intent.*`, afin de gerer le cycle de vie complet des paiements et notifier les utilisateurs.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event payment_intent.created When il est traite Then une purchase est creee en status 'pending' si metadata contient les infos necessaires
- [ ] Given un event payment_intent.processing When il est traite Then la purchase associee passe en status 'processing'
- [ ] Given un event payment_intent.succeeded When il est traite Then la purchase passe en 'succeeded' et paid_at est mis a jour
- [ ] Given un event payment_intent.succeeded When il est traite Then une notification est envoyee au buyer
- [ ] Given un event payment_intent.payment_failed When il est traite Then la purchase passe en 'failed' avec error_message
- [ ] Given un event payment_intent.payment_failed When il est traite Then une notification est envoyee au buyer avec le message d'erreur
- [ ] Given un event payment_intent.canceled When il est traite Then la purchase passe en 'canceled'
- [ ] Given un event payment_intent.requires_action When il est traite Then la purchase passe en 'requires_action' et une notification est envoyee
- [ ] Given un event payment_intent.amount_capturable_updated When il est traite Then l'event est logge (pas d'action specifique)

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/payment-intent.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Handlers Implementation

```typescript
// supabase/functions/stripe-webhook/handlers/payment-intent.ts
import Stripe from "npm:stripe@14";

export async function handlePaymentIntentCreated(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  // Only create purchase if metadata contains required info
  const { user_id, product_type, product_id, seller_id } = paymentIntent.metadata || {};

  if (!user_id || !product_type) {
    console.log("PaymentIntent without required metadata, skipping purchase creation");
    return;
  }

  const amountCents = paymentIntent.amount;
  const platformFeeCents = seller_id ? Math.floor(amountCents * 0.10) : 0;
  const sellerAmountCents = seller_id ? amountCents - platformFeeCents : null;

  await supabase.from("purchases").insert({
    user_id,
    product_type,
    product_id: product_id || null,
    seller_id: seller_id || null,
    amount_cents: amountCents,
    currency: paymentIntent.currency.toUpperCase(),
    platform_fee_cents: platformFeeCents,
    seller_amount_cents: sellerAmountCents,
    stripe_payment_intent_id: paymentIntent.id,
    status: "pending",
  });
}

export async function handlePaymentIntentProcessing(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  await supabase
    .from("purchases")
    .update({ status: "processing", updated_at: new Date().toISOString() })
    .eq("stripe_payment_intent_id", paymentIntent.id);
}

export async function handlePaymentIntentSucceeded(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  const now = new Date().toISOString();

  // Update purchase
  const { data: purchase } = await supabase
    .from("purchases")
    .update({
      status: "succeeded",
      paid_at: now,
      updated_at: now,
      stripe_charge_id: paymentIntent.latest_charge,
    })
    .eq("stripe_payment_intent_id", paymentIntent.id)
    .select("user_id, amount_cents, currency, product_type")
    .single();

  // Send notification to buyer
  if (purchase) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: "payment_succeeded",
      payload: {
        amount: purchase.amount_cents / 100,
        currency: purchase.currency,
        product_type: purchase.product_type,
      },
    });
  }
}

export async function handlePaymentIntentFailed(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  const errorMessage = paymentIntent.last_payment_error?.message || "Payment failed";
  const errorCode = paymentIntent.last_payment_error?.code || "unknown";

  const { data: purchase } = await supabase
    .from("purchases")
    .update({
      status: "failed",
      error_message: errorMessage,
      error_code: errorCode,
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_payment_intent_id", paymentIntent.id)
    .select("user_id")
    .single();

  // Notify buyer
  if (purchase) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: "payment_failed",
      payload: {
        error_message: errorMessage,
        payment_intent_id: paymentIntent.id,
      },
    });
  }
}

export async function handlePaymentIntentCanceled(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  await supabase
    .from("purchases")
    .update({ status: "canceled", updated_at: new Date().toISOString() })
    .eq("stripe_payment_intent_id", paymentIntent.id);
}

export async function handlePaymentIntentRequiresAction(
  supabase: any,
  paymentIntent: Stripe.PaymentIntent
) {
  const { data: purchase } = await supabase
    .from("purchases")
    .update({ status: "requires_action", updated_at: new Date().toISOString() })
    .eq("stripe_payment_intent_id", paymentIntent.id)
    .select("user_id")
    .single();

  // Notify buyer action required (3DS, etc.)
  if (purchase) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: "payment_requires_action",
      payload: {
        payment_intent_id: paymentIntent.id,
        message: "Additional authentication required",
      },
    });
  }
}
```

### Integration dans index.ts

```typescript
import {
  handlePaymentIntentCreated,
  handlePaymentIntentProcessing,
  handlePaymentIntentSucceeded,
  handlePaymentIntentFailed,
  handlePaymentIntentCanceled,
  handlePaymentIntentRequiresAction,
} from "./handlers/payment-intent.ts";

async function processEvent(supabase: any, event: Stripe.Event) {
  const obj = event.data.object as any;

  switch (event.type) {
    case "payment_intent.created":
      await handlePaymentIntentCreated(supabase, obj);
      break;
    case "payment_intent.processing":
      await handlePaymentIntentProcessing(supabase, obj);
      break;
    case "payment_intent.succeeded":
      await handlePaymentIntentSucceeded(supabase, obj);
      break;
    case "payment_intent.payment_failed":
      await handlePaymentIntentFailed(supabase, obj);
      break;
    case "payment_intent.canceled":
      await handlePaymentIntentCanceled(supabase, obj);
      break;
    case "payment_intent.requires_action":
      await handlePaymentIntentRequiresAction(supabase, obj);
      break;
    case "payment_intent.amount_capturable_updated":
      console.log("payment_intent.amount_capturable_updated logged");
      break;
    // ... autres handlers
  }
}
```

### Commission 10%

La commission est calculee lors de la creation:
- `platform_fee_cents = amount_cents * 0.10`
- `seller_amount_cents = amount_cents - platform_fee_cents`

### Notifications

Toutes les notifications passent par `notifications_outbox` pour traitement async par FCM.

## Definition of Done

- [ ] Handler payment_intent.created implemente
- [ ] Handler payment_intent.processing implemente
- [ ] Handler payment_intent.succeeded implemente avec notification
- [ ] Handler payment_intent.payment_failed implemente avec notification
- [ ] Handler payment_intent.canceled implemente
- [ ] Handler payment_intent.requires_action implemente avec notification
- [ ] Commission 10% calculee correctement
- [ ] Edge Function redployee
- [ ] Tests avec Stripe CLI (stripe trigger payment_intent.succeeded)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Moyen (logique paiement critique)

## Dependances

- S02: Table purchases doit exister
- S03: Table stripe_events doit exister
- S04: Edge Function de base deployee

## Stories Dependantes

- S10: Handlers transfers (utilise stripe_charge_id)
- S11: Entites Dart (modele Purchase avec status)
