# Story S10: Implementer handlers transfers + refunds

## Description
En tant que developpeur, je veux implementer les handlers pour les events `transfer.*` et `charge.refund*`, afin de tracker les transferts vers les vendeurs et les remboursements.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event transfer.created When une purchase est associee Then purchase.stripe_transfer_id est mis a jour
- [ ] Given un event transfer.created When il est traite Then l'event est logge
- [ ] Given un event transfer.updated When il est traite Then l'event est logge
- [ ] Given un event transfer.reversed When il est traite Then l'event est logge et une notification est envoyee au seller
- [ ] Given un event charge.refunded When une purchase est associee Then purchase.status='refunded' et refunded_at est mis a jour
- [ ] Given un event charge.refunded When il est traite Then une notification est envoyee au buyer
- [ ] Given un event charge.refund.updated When il est traite Then l'event est logge

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/transfer.ts`
- `supabase/functions/stripe-webhook/handlers/refund.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Transfer Handlers

```typescript
// supabase/functions/stripe-webhook/handlers/transfer.ts
import Stripe from "npm:stripe@14";

export async function handleTransferCreated(
  supabase: any,
  transfer: Stripe.Transfer
) {
  // Find purchase by source_transaction (charge ID)
  const sourceTransaction = transfer.source_transaction as string;

  if (sourceTransaction) {
    const { data: purchase } = await supabase
      .from("purchases")
      .select("id, seller_id")
      .eq("stripe_charge_id", sourceTransaction)
      .single();

    if (purchase) {
      // Update purchase with transfer ID
      await supabase
        .from("purchases")
        .update({
          stripe_transfer_id: transfer.id,
          updated_at: new Date().toISOString(),
        })
        .eq("id", purchase.id);

      console.log(`Transfer ${transfer.id} linked to purchase ${purchase.id}`);
    }
  }

  console.log(`Transfer created: ${transfer.id}`, {
    amount: transfer.amount,
    currency: transfer.currency,
    destination: transfer.destination,
  });
}

export async function handleTransferUpdated(
  supabase: any,
  transfer: Stripe.Transfer
) {
  console.log(`Transfer updated: ${transfer.id}`, {
    amount: transfer.amount,
    currency: transfer.currency,
  });
}

export async function handleTransferReversed(
  supabase: any,
  transfer: Stripe.Transfer
) {
  // Find purchase and seller
  const { data: purchase } = await supabase
    .from("purchases")
    .select("id, seller_id")
    .eq("stripe_transfer_id", transfer.id)
    .single();

  console.log(`Transfer reversed: ${transfer.id}`, {
    amount: transfer.amount,
    reversed: transfer.reversed,
  });

  // Notify seller
  if (purchase?.seller_id) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.seller_id,
      event_type: "transfer_reversed",
      payload: {
        message: "A transfer to your account has been reversed.",
        transfer_id: transfer.id,
        amount: transfer.amount / 100,
        currency: transfer.currency.toUpperCase(),
        reason: "Customer refund or dispute",
      },
    });
  }

  // Update purchase metadata
  if (purchase) {
    await supabase
      .from("purchases")
      .update({
        metadata: supabase.sql`metadata || ${JSON.stringify({
          transfer_reversed: true,
          transfer_reversed_at: new Date().toISOString(),
        })}`,
        updated_at: new Date().toISOString(),
      })
      .eq("id", purchase.id);
  }
}
```

### Refund Handlers

```typescript
// supabase/functions/stripe-webhook/handlers/refund.ts
import Stripe from "npm:stripe@14";

export async function handleChargeRefunded(
  supabase: any,
  charge: Stripe.Charge
) {
  const now = new Date().toISOString();
  const refundAmount = charge.amount_refunded;
  const totalAmount = charge.amount;

  // Determine if fully or partially refunded
  const fullyRefunded = refundAmount >= totalAmount;
  const newStatus = fullyRefunded ? "refunded" : "partially_refunded";

  // Find purchase by charge ID
  const { data: purchase } = await supabase
    .from("purchases")
    .select("id, user_id, seller_id, amount_cents")
    .eq("stripe_charge_id", charge.id)
    .single();

  if (purchase) {
    // Update purchase
    await supabase
      .from("purchases")
      .update({
        status: newStatus,
        refunded_at: fullyRefunded ? now : null,
        updated_at: now,
        metadata: supabase.sql`metadata || ${JSON.stringify({
          refund_amount: refundAmount,
          refund_reason: charge.refunds?.data[0]?.reason || null,
        })}`,
      })
      .eq("id", purchase.id);

    // Notify buyer
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: fullyRefunded ? "purchase_refunded" : "purchase_partially_refunded",
      payload: {
        message: fullyRefunded
          ? "Your purchase has been refunded."
          : `A partial refund of ${(refundAmount / 100).toFixed(2)} has been processed.`,
        refund_amount: refundAmount / 100,
        currency: charge.currency.toUpperCase(),
        original_amount: totalAmount / 100,
      },
    });

    // Notify seller if marketplace
    if (purchase.seller_id) {
      await supabase.from("notifications_outbox").insert({
        recipient_id: purchase.seller_id,
        event_type: "sale_refunded",
        payload: {
          message: fullyRefunded
            ? "A sale has been refunded."
            : "A partial refund has been processed.",
          refund_amount: refundAmount / 100,
          currency: charge.currency.toUpperCase(),
        },
      });
    }
  }

  console.log(`Charge refunded: ${charge.id}`, {
    amount_refunded: refundAmount,
    total_amount: totalAmount,
    fully_refunded: fullyRefunded,
  });
}

export async function handleRefundUpdated(
  supabase: any,
  refund: Stripe.Refund
) {
  // Just log status updates
  console.log(`Refund updated: ${refund.id}`, {
    status: refund.status,
    amount: refund.amount,
  });
}
```

### Integration dans index.ts

```typescript
import {
  handleTransferCreated,
  handleTransferUpdated,
  handleTransferReversed,
} from "./handlers/transfer.ts";

import {
  handleChargeRefunded,
  handleRefundUpdated,
} from "./handlers/refund.ts";

// Dans processEvent:
case "transfer.created":
  await handleTransferCreated(supabase, obj);
  break;
case "transfer.updated":
  await handleTransferUpdated(supabase, obj);
  break;
case "transfer.reversed":
  await handleTransferReversed(supabase, obj);
  break;
case "charge.refunded":
  await handleChargeRefunded(supabase, obj);
  break;
case "charge.refund.updated":
  await handleRefundUpdated(supabase, obj);
  break;
```

### Transfer Flow (Marketplace)

1. Customer paie via payment_intent
2. Payment succeeds -> charge cree
3. Stripe transfere la part vendeur -> `transfer.created`
4. Transfer lie a la purchase via source_transaction

### Refund Flow

1. Admin ou systeme initie remboursement
2. Stripe traite le refund -> `charge.refunded`
3. Si marketplace, transfer est reverse -> `transfer.reversed`

### Statuts Purchase

| Scenario | Status |
|----------|--------|
| Refund total | refunded |
| Refund partiel | partially_refunded |

## Definition of Done

- [ ] Handler transfer.created avec link purchase
- [ ] Handler transfer.updated (log)
- [ ] Handler transfer.reversed avec notification seller
- [ ] Handler charge.refunded avec status update et notifications
- [ ] Handler charge.refund.updated (log)
- [ ] Support refund partiel vs total
- [ ] Notifications buyer et seller appropriees
- [ ] Edge Function redployee
- [ ] Tests avec Stripe CLI
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S02: Table purchases doit exister (stripe_charge_id, stripe_transfer_id)
- S04: Edge Function de base deployee
- S05: Handlers payment_intent (stripe_charge_id populated)

## Stories Dependantes

- S11: Entites Dart (status 'refunded', 'partially_refunded')
