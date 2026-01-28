# Story S06: Implementer handlers checkout.session.*

## Description
En tant que developpeur, je veux implementer tous les handlers pour les events `checkout.session.*`, afin de gerer les parcours d'achat complets via Stripe Checkout.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event checkout.session.completed When aucune purchase n'existe pour ce checkout Then une nouvelle purchase est creee avec status 'succeeded'
- [ ] Given un event checkout.session.completed When une purchase existe deja Then elle est mise a jour avec status 'succeeded'
- [ ] Given un event checkout.session.completed When le checkout contient des line_items Then les montants sont extraits correctement
- [ ] Given un event checkout.session.completed When le checkout est marketplace Then la commission 10% est calculee
- [ ] Given un event checkout.session.expired When il est traite Then l'event est logge sans creer de purchase
- [ ] Given un event checkout.session.async_payment_succeeded When il est traite Then la purchase passe en 'succeeded'
- [ ] Given un event checkout.session.async_payment_failed When il est traite Then la purchase passe en 'failed' avec notification

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/checkout-session.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Handlers Implementation

```typescript
// supabase/functions/stripe-webhook/handlers/checkout-session.ts
import Stripe from "npm:stripe@14";

export async function handleCheckoutCompleted(
  supabase: any,
  session: Stripe.Checkout.Session
) {
  // Check if purchase already exists (may have been created by payment_intent.created)
  const { data: existing } = await supabase
    .from("purchases")
    .select("id")
    .eq("stripe_checkout_session_id", session.id)
    .single();

  const metadata = session.metadata || {};
  const {
    user_id,
    product_type,
    product_id,
    seller_id,
  } = metadata;

  // Extract amounts
  const amountCents = session.amount_total || 0;
  const platformFeeCents = seller_id ? Math.floor(amountCents * 0.10) : 0;
  const sellerAmountCents = seller_id ? amountCents - platformFeeCents : null;

  const now = new Date().toISOString();

  if (existing) {
    // Update existing purchase
    await supabase
      .from("purchases")
      .update({
        status: "succeeded",
        paid_at: now,
        updated_at: now,
        stripe_payment_intent_id: session.payment_intent as string,
      })
      .eq("id", existing.id);
  } else if (user_id && product_type) {
    // Create new purchase
    await supabase.from("purchases").insert({
      user_id,
      product_type,
      product_id: product_id || null,
      seller_id: seller_id || null,
      amount_cents: amountCents,
      currency: (session.currency || "usd").toUpperCase(),
      platform_fee_cents: platformFeeCents,
      seller_amount_cents: sellerAmountCents,
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent as string,
      status: "succeeded",
      paid_at: now,
    });
  } else {
    console.log("Checkout completed without required metadata, logging only");
  }

  // Send notification to buyer
  if (user_id) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: user_id,
      event_type: "checkout_completed",
      payload: {
        amount: amountCents / 100,
        currency: (session.currency || "usd").toUpperCase(),
        product_type: product_type || "unknown",
      },
    });
  }
}

export async function handleCheckoutExpired(
  supabase: any,
  session: Stripe.Checkout.Session
) {
  // Just log - no purchase to update/create
  console.log(`Checkout session expired: ${session.id}`);

  // Could notify user if metadata contains user_id
  const userId = session.metadata?.user_id;
  if (userId) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: userId,
      event_type: "checkout_expired",
      payload: {
        session_id: session.id,
        message: "Your checkout session has expired",
      },
    });
  }
}

export async function handleCheckoutAsyncSucceeded(
  supabase: any,
  session: Stripe.Checkout.Session
) {
  // For payment methods with delayed confirmation (bank transfers, etc.)
  const now = new Date().toISOString();

  await supabase
    .from("purchases")
    .update({
      status: "succeeded",
      paid_at: now,
      updated_at: now,
    })
    .eq("stripe_checkout_session_id", session.id);

  // Notification
  const userId = session.metadata?.user_id;
  if (userId) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: userId,
      event_type: "async_payment_succeeded",
      payload: {
        message: "Your payment has been confirmed",
      },
    });
  }
}

export async function handleCheckoutAsyncFailed(
  supabase: any,
  session: Stripe.Checkout.Session
) {
  await supabase
    .from("purchases")
    .update({
      status: "failed",
      error_message: "Async payment failed",
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_checkout_session_id", session.id);

  // Notification
  const userId = session.metadata?.user_id;
  if (userId) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: userId,
      event_type: "async_payment_failed",
      payload: {
        message: "Your payment could not be processed",
      },
    });
  }
}
```

### Integration dans index.ts

```typescript
import {
  handleCheckoutCompleted,
  handleCheckoutExpired,
  handleCheckoutAsyncSucceeded,
  handleCheckoutAsyncFailed,
} from "./handlers/checkout-session.ts";

// Dans processEvent:
case "checkout.session.completed":
  await handleCheckoutCompleted(supabase, obj);
  break;
case "checkout.session.expired":
  await handleCheckoutExpired(supabase, obj);
  break;
case "checkout.session.async_payment_succeeded":
  await handleCheckoutAsyncSucceeded(supabase, obj);
  break;
case "checkout.session.async_payment_failed":
  await handleCheckoutAsyncFailed(supabase, obj);
  break;
```

### Metadata Attendu dans Checkout Session

Lors de la creation du checkout cote Flutter/backend:
```javascript
const session = await stripe.checkout.sessions.create({
  metadata: {
    user_id: "uuid-user",
    product_type: "marketplace_item",
    product_id: "uuid-product",
    seller_id: "uuid-seller", // Optionnel, pour marketplace
  },
  // ...
});
```

### Idempotency

- Si la purchase existe deja (creee par payment_intent), on la met a jour
- Si elle n'existe pas et qu'on a les metadata, on la cree
- Pas de duplication possible grace a stripe_checkout_session_id unique

## Definition of Done

- [ ] Handler checkout.session.completed implemente (create ou update)
- [ ] Handler checkout.session.expired implemente
- [ ] Handler checkout.session.async_payment_succeeded implemente
- [ ] Handler checkout.session.async_payment_failed implemente
- [ ] Commission 10% calculee pour marketplace
- [ ] Notifications envoyees pour chaque event
- [ ] Edge Function redployee
- [ ] Tests avec Stripe CLI
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Moyen

## Dependances

- S02: Table purchases doit exister
- S03: Table stripe_events doit exister
- S04: Edge Function de base deployee
- S05: Handlers payment_intent (complementaires)

## Stories Dependantes

- S11: Entites Dart (modele Purchase)
