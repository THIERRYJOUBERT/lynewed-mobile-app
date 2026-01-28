# Story S09: Implementer handlers payout.*

## Description
En tant que developpeur, je veux implementer tous les handlers pour les events `payout.*`, afin de notifier les vendeuses de leurs versements et alerter en cas de probleme.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event payout.created When il est traite Then l'event est logge (pas d'action specifique)
- [ ] Given un event payout.updated When il est traite Then l'event est logge (pas d'action specifique)
- [ ] Given un event payout.paid When le payout est associe a un stripe_account Then une notification "Virement recu" est envoyee a la vendeuse
- [ ] Given un event payout.paid When la notification est envoyee Then elle contient le montant et la date d'arrivee
- [ ] Given un event payout.failed When il est traite Then une notification CRITIQUE est envoyee a la vendeuse
- [ ] Given un event payout.failed When il est traite Then une notification est envoyee a l'admin pour investigation
- [ ] Given un event payout.canceled When il est traite Then l'event est logge et une notification est envoyee

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/payout.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Handlers Implementation

```typescript
// supabase/functions/stripe-webhook/handlers/payout.ts
import Stripe from "npm:stripe@14";

export async function handlePayoutCreated(
  supabase: any,
  payout: Stripe.Payout
) {
  // Just log - payout initiated
  console.log(`Payout created: ${payout.id}`, {
    amount: payout.amount,
    currency: payout.currency,
    arrival_date: payout.arrival_date,
    destination: payout.destination,
  });
}

export async function handlePayoutUpdated(
  supabase: any,
  payout: Stripe.Payout
) {
  // Just log - status update
  console.log(`Payout updated: ${payout.id}`, {
    status: payout.status,
  });
}

export async function handlePayoutPaid(
  supabase: any,
  payout: Stripe.Payout
) {
  // Get destination account
  // For Connect, payout.destination is the bank account,
  // but we need to find the seller by stripe_account_id from the request context
  // The account ID is in the Stripe-Account header or metadata

  // In Connect payouts, we need to use the account from metadata
  // The payout object contains the destination bank account
  const accountId = (payout as any).account; // Connect account ID

  if (!accountId) {
    console.log("Payout without account ID, cannot notify seller");
    return;
  }

  const { data: stripeAccount } = await supabase
    .from("stripe_accounts")
    .select("user_id")
    .eq("stripe_account_id", accountId)
    .single();

  if (!stripeAccount) {
    console.log(`No stripe_account found for ${accountId}`);
    return;
  }

  // Calculate arrival date
  const arrivalDate = payout.arrival_date
    ? new Date(payout.arrival_date * 1000).toLocaleDateString("fr-FR", {
        day: "numeric",
        month: "long",
        year: "numeric",
      })
    : "soon";

  // Send positive notification
  await supabase.from("notifications_outbox").insert({
    recipient_id: stripeAccount.user_id,
    event_type: "payout_paid",
    payload: {
      message: `Your payout of ${(payout.amount / 100).toFixed(2)} ${payout.currency.toUpperCase()} has been sent!`,
      amount: payout.amount / 100,
      currency: payout.currency.toUpperCase(),
      arrival_date: arrivalDate,
      payout_id: payout.id,
    },
  });
}

export async function handlePayoutFailed(
  supabase: any,
  payout: Stripe.Payout
) {
  const accountId = (payout as any).account;
  const failureCode = payout.failure_code;
  const failureMessage = payout.failure_message;

  let sellerUserId: string | null = null;

  if (accountId) {
    const { data: stripeAccount } = await supabase
      .from("stripe_accounts")
      .select("user_id")
      .eq("stripe_account_id", accountId)
      .single();

    sellerUserId = stripeAccount?.user_id;
  }

  // CRITICAL notification to seller
  if (sellerUserId) {
    await supabase.from("notifications_outbox").insert({
      recipient_id: sellerUserId,
      event_type: "payout_failed_critical",
      payload: {
        priority: "critical",
        message: "Your payout could not be processed. Please verify your bank details.",
        amount: payout.amount / 100,
        currency: payout.currency.toUpperCase(),
        failure_reason: failureMessage || failureCode || "Unknown error",
        payout_id: payout.id,
      },
    });
  }

  // ALWAYS notify admin for investigation
  await supabase.from("notifications_outbox").insert({
    recipient_id: null, // Admin
    event_type: "payout_failed_admin",
    payload: {
      priority: "critical",
      payout_id: payout.id,
      account_id: accountId,
      seller_user_id: sellerUserId,
      amount: payout.amount / 100,
      currency: payout.currency,
      failure_code: failureCode,
      failure_message: failureMessage,
      message: "A payout has failed and requires investigation",
    },
  });
}

export async function handlePayoutCanceled(
  supabase: any,
  payout: Stripe.Payout
) {
  const accountId = (payout as any).account;

  console.log(`Payout canceled: ${payout.id}`, {
    amount: payout.amount,
    currency: payout.currency,
  });

  if (accountId) {
    const { data: stripeAccount } = await supabase
      .from("stripe_accounts")
      .select("user_id")
      .eq("stripe_account_id", accountId)
      .single();

    if (stripeAccount?.user_id) {
      await supabase.from("notifications_outbox").insert({
        recipient_id: stripeAccount.user_id,
        event_type: "payout_canceled",
        payload: {
          message: "Your payout has been canceled. A new payout will be scheduled automatically.",
          amount: payout.amount / 100,
          currency: payout.currency.toUpperCase(),
          payout_id: payout.id,
        },
      });
    }
  }
}
```

### Integration dans index.ts

```typescript
import {
  handlePayoutCreated,
  handlePayoutUpdated,
  handlePayoutPaid,
  handlePayoutFailed,
  handlePayoutCanceled,
} from "./handlers/payout.ts";

// Dans processEvent:
case "payout.created":
  await handlePayoutCreated(supabase, obj);
  break;
case "payout.updated":
  await handlePayoutUpdated(supabase, obj);
  break;
case "payout.paid":
  await handlePayoutPaid(supabase, obj);
  break;
case "payout.failed":
  await handlePayoutFailed(supabase, obj);
  break;
case "payout.canceled":
  await handlePayoutCanceled(supabase, obj);
  break;
```

### Payout Flow (Connect)

1. Stripe calcule les fonds disponibles sur le compte Connect
2. Payout cree automatiquement selon le schedule -> `payout.created`
3. Payout traite par la banque -> `payout.updated` (in_transit)
4. Fonds arrives sur le compte bancaire -> `payout.paid`

### Cas d'Echec Payout

| Code | Raison | Action |
|------|--------|--------|
| `account_closed` | Compte bancaire ferme | Verifier details |
| `account_frozen` | Compte bancaire gele | Contacter banque |
| `bank_account_restricted` | Restrictions | Verifier compte |
| `insufficient_funds` | Fonds insuffisants | Ne devrait pas arriver |

### Notifications Types

| Event | Type | Urgence |
|-------|------|---------|
| payout.paid | payout_paid | Positive |
| payout.failed | payout_failed_critical | CRITIQUE |
| payout.canceled | payout_canceled | Normal |

## Definition of Done

- [ ] Handler payout.created implemente (log)
- [ ] Handler payout.updated implemente (log)
- [ ] Handler payout.paid avec notification positive
- [ ] Handler payout.failed avec notification critique seller + admin
- [ ] Handler payout.canceled avec notification
- [ ] Recherche seller par stripe_account_id fonctionne
- [ ] Edge Function redployee
- [ ] Tests avec Stripe CLI
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S01: Table stripe_accounts doit exister
- S04: Edge Function de base deployee
- S07: Handler account.updated (stripe_accounts populated)

## Stories Dependantes

- S11: Entites Dart (pas directement lie)
