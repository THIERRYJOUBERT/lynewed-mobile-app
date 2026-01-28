# Story S10: Stripe Connect onboarding Express vendeurs

## Description
En tant que vendeur, je veux configurer mon compte Stripe Connect Express, afin de recevoir les paiements de mes ventes (moins la commission 10%).

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller without Stripe account When they click "Setup payments" Then they should be redirected to Stripe Connect onboarding And a stripe_accounts record should be created with onboarding_complete=false
- [ ] Given a seller completing Stripe onboarding When Stripe sends account.updated webhook Then stripe_accounts should be updated with onboarding_complete=true, charges_enabled=true, payouts_enabled=true
- [ ] Given a seller with charges_enabled=false When they try to publish a listing Then they should be prompted to complete Stripe setup
- [ ] Given a seller with incomplete Stripe onboarding When they click "Complete setup" Then they should be redirected back to Stripe to continue
- [ ] Given a seller who completed onboarding Then they should see their account status (verified, payouts enabled) in their profile

## Fichiers Concernes

### A Creer
- `supabase/functions/create-stripe-connect-account/index.ts` - Edge Function
- `supabase/functions/stripe-connect-webhook/index.ts` - Webhook handler (ou modifier existant)
- `lib/features/marketplace/presentation/pages/stripe_setup_page.dart` - UI setup
- `lib/features/marketplace/presentation/widgets/stripe_status_widget.dart` - Status display
- `lib/features/marketplace/data/datasources/stripe_connect_datasource.dart` - API calls
- `lib/features/marketplace/domain/usecases/setup_stripe_connect.dart` - Use case
- `lib/features/marketplace/domain/usecases/check_stripe_status.dart` - Use case

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` - Add account.updated handler
- `lib/features/marketplace/presentation/pages/create_listing_page.dart` - Check Stripe status

## Notes Techniques

### Edge Function: create-stripe-connect-account
```typescript
import Stripe from 'stripe';
const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

Deno.serve(async (req) => {
  const { user_id, return_url, refresh_url } = await req.json();

  // Create Express account
  const account = await stripe.accounts.create({
    type: 'express',
    capabilities: {
      card_payments: { requested: true },
      transfers: { requested: true },
    },
  });

  // Store in database
  await supabase.from('stripe_accounts').upsert({
    user_id,
    stripe_account_id: account.id,
    account_type: 'express',
    onboarding_complete: false,
    charges_enabled: false,
    payouts_enabled: false,
  });

  // Create onboarding link
  const accountLink = await stripe.accountLinks.create({
    account: account.id,
    refresh_url,
    return_url,
    type: 'account_onboarding',
  });

  return new Response(JSON.stringify({ url: accountLink.url }));
});
```

### Webhook Handler: account.updated
```typescript
case 'account.updated':
  const account = event.data.object as Stripe.Account;
  await supabase.from('stripe_accounts')
    .update({
      onboarding_complete: account.details_submitted,
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      updated_at: new Date(),
    })
    .eq('stripe_account_id', account.id);
  break;
```

### Table stripe_accounts (EPIC-11)
Doit avoir les colonnes:
- user_id
- stripe_account_id
- account_type ('express')
- onboarding_complete
- charges_enabled
- payouts_enabled

### Deep Link pour return_url
```dart
// Dans l'app, configurer deep link pour recevoir le retour
// lynewed://stripe-connect-return?success=true
```

## Definition of Done
- [ ] Edge Function create-stripe-connect-account deployee
- [ ] Webhook account.updated gere
- [ ] UI setup page complete
- [ ] Deep link retour configure
- [ ] Status widget affiche etat compte
- [ ] Block publication si charges_enabled=false
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 8
**Complexite** : Haute
**Risque** : Haut (integration Stripe, webhooks)

## Dependances
- EPIC-11 (stripe_accounts table)
- Configuration Stripe Connect dans Dashboard Stripe

## Stories Dependantes
- S14 (create listing - check Stripe status)
- S20 (flow achat - paiement vers connected account)
