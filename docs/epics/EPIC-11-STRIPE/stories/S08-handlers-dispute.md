# Story S08: Implementer handlers charge.dispute.*

## Description
En tant que developpeur, je veux implementer tous les handlers pour les events `charge.dispute.*`, afin de gerer les litiges avec notifications critiques aux vendeurs et admins.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event charge.dispute.created When une purchase est associee au charge Then purchase.status='disputed' et disputed_at est mis a jour
- [ ] Given un event charge.dispute.created When il est traite Then une notification CRITIQUE est envoyee au seller
- [ ] Given un event charge.dispute.created When il est traite Then une notification est envoyee a l'admin
- [ ] Given un event charge.dispute.updated When il est traite Then l'event est logge et une notification est envoyee
- [ ] Given un event charge.dispute.closed avec status='won' When il est traite Then purchase.status revient a 'succeeded'
- [ ] Given un event charge.dispute.closed avec status='won' When il est traite Then une notification positive est envoyee au seller
- [ ] Given un event charge.dispute.closed avec status='lost' When il est traite Then purchase.status='refunded'
- [ ] Given un event charge.dispute.closed avec status='lost' When il est traite Then une notification est envoyee au seller
- [ ] Given un event charge.dispute.funds_reinstated When il est traite Then l'event est logge et notification positive envoyee
- [ ] Given un event charge.dispute.funds_withdrawn When il est traite Then l'event est logge et notification envoyee

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/dispute.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Handlers Implementation

```typescript
// supabase/functions/stripe-webhook/handlers/dispute.ts
import Stripe from "npm:stripe@14";

export async function handleDisputeCreated(
  supabase: any,
  dispute: Stripe.Dispute
) {
  const chargeId = dispute.charge as string;
  const now = new Date().toISOString();

  // Find purchase by charge_id
  const { data: purchase } = await supabase
    .from("purchases")
    .select("id, user_id, seller_id, amount_cents, currency")
    .eq("stripe_charge_id", chargeId)
    .single();

  if (purchase) {
    // Update purchase status
    await supabase
      .from("purchases")
      .update({
        status: "disputed",
        disputed_at: now,
        updated_at: now,
        metadata: supabase.sql`metadata || ${JSON.stringify({
          dispute_id: dispute.id,
          dispute_reason: dispute.reason,
          dispute_amount: dispute.amount,
        })}`,
      })
      .eq("id", purchase.id);

    // CRITICAL notification to seller
    if (purchase.seller_id) {
      await supabase.from("notifications_outbox").insert({
        recipient_id: purchase.seller_id,
        event_type: "dispute_created_critical",
        payload: {
          priority: "critical",
          message: "URGENT: A customer has disputed a charge. Please respond immediately.",
          dispute_id: dispute.id,
          reason: dispute.reason,
          amount: dispute.amount / 100,
          currency: dispute.currency,
          evidence_due: dispute.evidence_details?.due_by
            ? new Date(dispute.evidence_details.due_by * 1000).toISOString()
            : null,
        },
      });
    }

    // Notification to buyer
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: "dispute_created_buyer",
      payload: {
        message: "Your dispute has been received and is being processed.",
        dispute_id: dispute.id,
      },
    });
  }

  // ALWAYS notify admin
  await supabase.from("notifications_outbox").insert({
    recipient_id: null, // Admin
    event_type: "dispute_created_admin",
    payload: {
      priority: "critical",
      dispute_id: dispute.id,
      charge_id: chargeId,
      reason: dispute.reason,
      amount: dispute.amount / 100,
      currency: dispute.currency,
      purchase_id: purchase?.id || null,
      seller_id: purchase?.seller_id || null,
    },
  });
}

export async function handleDisputeUpdated(
  supabase: any,
  dispute: Stripe.Dispute
) {
  const chargeId = dispute.charge as string;

  // Find purchase
  const { data: purchase } = await supabase
    .from("purchases")
    .select("seller_id")
    .eq("stripe_charge_id", chargeId)
    .single();

  // Log update
  console.log(`Dispute ${dispute.id} updated: status=${dispute.status}`);

  // Notify seller if exists
  if (purchase?.seller_id) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.seller_id,
      event_type: "dispute_updated",
      payload: {
        dispute_id: dispute.id,
        status: dispute.status,
        message: `Dispute status updated: ${dispute.status}`,
      },
    });
  }
}

export async function handleDisputeClosed(
  supabase: any,
  dispute: Stripe.Dispute
) {
  const chargeId = dispute.charge as string;
  const won = dispute.status === "won";
  const now = new Date().toISOString();

  const { data: purchase } = await supabase
    .from("purchases")
    .select("id, seller_id, user_id")
    .eq("stripe_charge_id", chargeId)
    .single();

  if (purchase) {
    // Update status based on outcome
    const newStatus = won ? "succeeded" : "refunded";
    await supabase
      .from("purchases")
      .update({
        status: newStatus,
        updated_at: now,
        ...(won ? {} : { refunded_at: now }),
      })
      .eq("id", purchase.id);

    // Notify seller
    if (purchase.seller_id) {
      await supabase.from("notifications_outbox").insert({
        recipient_id: purchase.seller_id,
        event_type: won ? "dispute_won" : "dispute_lost",
        payload: {
          priority: won ? "normal" : "high",
          message: won
            ? "Good news! The dispute has been resolved in your favor."
            : "Unfortunately, the dispute was resolved against you. The payment has been refunded.",
          dispute_id: dispute.id,
          amount: dispute.amount / 100,
          currency: dispute.currency,
        },
      });
    }

    // Notify buyer
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.user_id,
      event_type: won ? "dispute_closed_buyer" : "dispute_refunded_buyer",
      payload: {
        message: won
          ? "The dispute has been resolved. The original charge stands."
          : "Your dispute has been resolved. A refund has been processed.",
        dispute_id: dispute.id,
      },
    });
  }

  // Notify admin
  await supabase.from("notifications_outbox").insert({
    recipient_id: null,
    event_type: "dispute_closed_admin",
    payload: {
      dispute_id: dispute.id,
      outcome: won ? "won" : "lost",
      amount: dispute.amount / 100,
      currency: dispute.currency,
    },
  });
}

export async function handleDisputeFunds(
  supabase: any,
  dispute: Stripe.Dispute,
  eventType: string
) {
  const reinstated = eventType === "charge.dispute.funds_reinstated";
  const chargeId = dispute.charge as string;

  const { data: purchase } = await supabase
    .from("purchases")
    .select("seller_id")
    .eq("stripe_charge_id", chargeId)
    .single();

  if (purchase?.seller_id) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: purchase.seller_id,
      event_type: reinstated ? "dispute_funds_reinstated" : "dispute_funds_withdrawn",
      payload: {
        message: reinstated
          ? "Good news! Disputed funds have been returned to your account."
          : "Disputed funds have been withdrawn from your account.",
        dispute_id: dispute.id,
        amount: dispute.amount / 100,
        currency: dispute.currency,
      },
    });
  }
}
```

### Integration dans index.ts

```typescript
import {
  handleDisputeCreated,
  handleDisputeUpdated,
  handleDisputeClosed,
  handleDisputeFunds,
} from "./handlers/dispute.ts";

// Dans processEvent:
case "charge.dispute.created":
  await handleDisputeCreated(supabase, obj);
  break;
case "charge.dispute.updated":
  await handleDisputeUpdated(supabase, obj);
  break;
case "charge.dispute.closed":
  await handleDisputeClosed(supabase, obj);
  break;
case "charge.dispute.funds_reinstated":
case "charge.dispute.funds_withdrawn":
  await handleDisputeFunds(supabase, obj, event.type);
  break;
```

### Dispute Flow

1. Customer initie dispute aupres de sa banque
2. Stripe recoit le chargeback -> `charge.dispute.created`
3. Seller peut soumettre des preuves
4. Banque decide -> `charge.dispute.closed` (won/lost)
5. Si perdu, fonds retires -> `charge.dispute.funds_withdrawn`

### Priorites Notifications

| Event | Priorite | Raison |
|-------|----------|--------|
| dispute.created | CRITIQUE | Action immediate requise |
| dispute.updated | Normal | Informatif |
| dispute.closed (lost) | Haute | Impact financier |
| dispute.closed (won) | Normal | Bonne nouvelle |

## Definition of Done

- [ ] Handler charge.dispute.created avec notifications critiques
- [ ] Handler charge.dispute.updated avec notification
- [ ] Handler charge.dispute.closed (won/lost) avec update status
- [ ] Handler charge.dispute.funds_reinstated/withdrawn
- [ ] Notifications seller, buyer et admin appropriees
- [ ] Purchase status mis a jour correctement
- [ ] Edge Function redployee
- [ ] Tests avec Stripe CLI
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Moyen (impact financier des disputes)

## Dependances

- S02: Table purchases doit exister (pour stripe_charge_id)
- S04: Edge Function de base deployee
- S05: Handlers payment_intent (pour stripe_charge_id)

## Stories Dependantes

- S11: Entites Dart (status 'disputed')
