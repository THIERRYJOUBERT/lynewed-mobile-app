# Story S07: Implementer handler account.updated (Connect status)

## Description
En tant que developpeur, je veux implementer les handlers pour les events `account.*` de Stripe Connect, afin de suivre l'onboarding et le statut des comptes vendeuses.

## Criteres d'Acceptance (Gherkin)

- [ ] Given un event account.updated When charges_enabled=true et payouts_enabled=true Then stripe_accounts.onboarding_complete=true
- [ ] Given un event account.updated When charges_enabled passe a true Then stripe_accounts.charges_enabled=true
- [ ] Given un event account.updated When payouts_enabled passe a true Then stripe_accounts.payouts_enabled=true
- [ ] Given un event account.updated When details_submitted=true Then stripe_accounts.details_submitted=true
- [ ] Given un event account.updated When currently_due contient des elements Then stripe_accounts.currently_due est mis a jour et notification envoyee
- [ ] Given un event account.updated When past_due contient des elements Then stripe_accounts.past_due est mis a jour et notification urgente envoyee
- [ ] Given un event account.application.deauthorized When il est traite Then stripe_accounts.charges_enabled=false et disabled_reason='deauthorized'
- [ ] Given un event account.application.deauthorized When il est traite Then une notification est envoyee a la vendeuse
- [ ] Given un event account.external_account.* When il est traite Then l'event est logge (pas d'action specifique)

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/handlers/account.ts`

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (import et dispatch)

## Notes Techniques

### Handlers Implementation

```typescript
// supabase/functions/stripe-webhook/handlers/account.ts
import Stripe from "npm:stripe@14";

export async function handleAccountUpdated(
  supabase: any,
  account: Stripe.Account
) {
  // Find user by stripe_account_id
  const { data: stripeAccount } = await supabase
    .from("stripe_accounts")
    .select("user_id, charges_enabled, payouts_enabled, onboarding_complete")
    .eq("stripe_account_id", account.id)
    .single();

  if (!stripeAccount) {
    console.log(`No stripe_account found for ${account.id}`);
    return;
  }

  const requirements = account.requirements || {};
  const chargesEnabled = account.charges_enabled || false;
  const payoutsEnabled = account.payouts_enabled || false;
  const detailsSubmitted = account.details_submitted || false;

  // Calculate onboarding_complete
  const onboardingComplete = chargesEnabled && payoutsEnabled;

  // Track if this is a status change (for notifications)
  const wasOnboardingComplete = stripeAccount.onboarding_complete;
  const becameComplete = !wasOnboardingComplete && onboardingComplete;

  // Update stripe_accounts
  await supabase
    .from("stripe_accounts")
    .update({
      charges_enabled: chargesEnabled,
      payouts_enabled: payoutsEnabled,
      details_submitted: detailsSubmitted,
      onboarding_complete: onboardingComplete,
      currently_due: requirements.currently_due || [],
      past_due: requirements.past_due || [],
      disabled_reason: requirements.disabled_reason || null,
      country: account.country,
      default_currency: account.default_currency,
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_account_id", account.id);

  // Notifications
  if (becameComplete) {
    // Onboarding complete - celebratory notification
    await supabase.from("notifications_outbox").insert({
      recipient_id: stripeAccount.user_id,
      event_type: "stripe_onboarding_complete",
      payload: {
        message: "Your seller account is now active! You can start receiving payments.",
      },
    });
  } else if (requirements.currently_due && requirements.currently_due.length > 0) {
    // Action required
    await supabase.from("notifications_outbox").insert({
      recipient_id: stripeAccount.user_id,
      event_type: "stripe_action_required",
      payload: {
        message: "Additional information is required for your seller account.",
        requirements: requirements.currently_due,
      },
    });
  } else if (requirements.past_due && requirements.past_due.length > 0) {
    // Urgent - past due
    await supabase.from("notifications_outbox").insert({
      recipient_id: stripeAccount.user_id,
      event_type: "stripe_action_urgent",
      payload: {
        message: "URGENT: Your seller account has overdue requirements.",
        requirements: requirements.past_due,
      },
    });
  }
}

export async function handleAccountDeauthorized(
  supabase: any,
  application: any
) {
  // application.account contains the account ID
  const accountId = application.account;

  const { data: stripeAccount } = await supabase
    .from("stripe_accounts")
    .select("user_id")
    .eq("stripe_account_id", accountId)
    .single();

  if (!stripeAccount) {
    console.log(`No stripe_account found for deauthorized account ${accountId}`);
    return;
  }

  // Disable the account
  await supabase
    .from("stripe_accounts")
    .update({
      charges_enabled: false,
      payouts_enabled: false,
      onboarding_complete: false,
      disabled_reason: "deauthorized",
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_account_id", accountId);

  // Notify seller
  await supabase.from("notifications_outbox").insert({
    recipient_id: stripeAccount.user_id,
    event_type: "stripe_account_deauthorized",
    payload: {
      message: "Your seller account has been disconnected. Please contact support if this was not intentional.",
    },
  });

  // Notify admin
  await supabase.from("notifications_outbox").insert({
    recipient_id: null, // Admin notification
    event_type: "stripe_account_deauthorized_admin",
    payload: {
      user_id: stripeAccount.user_id,
      account_id: accountId,
      message: "A seller account has been deauthorized",
    },
  });
}

export async function handleExternalAccountEvent(
  supabase: any,
  externalAccount: any,
  eventType: string
) {
  // Just log these events - no specific action needed
  console.log(`External account event: ${eventType}`, {
    account_id: externalAccount.account,
    bank_name: externalAccount.bank_name,
    last4: externalAccount.last4,
  });
}
```

### Integration dans index.ts

```typescript
import {
  handleAccountUpdated,
  handleAccountDeauthorized,
  handleExternalAccountEvent,
} from "./handlers/account.ts";

// Dans processEvent:
case "account.updated":
  await handleAccountUpdated(supabase, obj);
  break;
case "account.application.deauthorized":
  await handleAccountDeauthorized(supabase, obj);
  break;
case "account.external_account.created":
case "account.external_account.updated":
case "account.external_account.deleted":
  await handleExternalAccountEvent(supabase, obj, event.type);
  break;
```

### Stripe Connect Onboarding Flow

1. User initie onboarding -> Stripe cree account
2. User complete formulaire Stripe
3. Stripe envoie `account.updated` avec `details_submitted: true`
4. Stripe valide le compte
5. Stripe envoie `account.updated` avec `charges_enabled: true`
6. Stripe active les payouts
7. Stripe envoie `account.updated` avec `payouts_enabled: true`

### Notifications Types

| Event | Type | Urgence |
|-------|------|---------|
| Onboarding complete | stripe_onboarding_complete | Positive |
| Action required | stripe_action_required | Normal |
| Past due | stripe_action_urgent | Urgente |
| Deauthorized | stripe_account_deauthorized | Critique |

## Definition of Done

- [ ] Handler account.updated implemente avec tous les champs
- [ ] Handler account.application.deauthorized implemente
- [ ] Handlers external_account.* implementes (log only)
- [ ] Calcul onboarding_complete correct
- [ ] Notifications envoyees pour changements de statut
- [ ] Notification admin pour deauthorization
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

## Stories Dependantes

- S11: Entites Dart (modele StripeAccount avec onboardingComplete)
