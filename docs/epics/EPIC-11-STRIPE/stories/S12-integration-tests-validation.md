# Story S12: Tests d'integration et validation finale

## Description
En tant que developpeur, je veux executer des tests d'integration complets et valider l'ensemble de l'implementation Stripe, afin de garantir que tous les composants fonctionnent ensemble en mode test Stripe.

## Criteres d'Acceptance (Gherkin)

- [ ] Given l'Edge Function stripe-webhook deployee When je trigger un event via Stripe CLI Then l'event est logge dans stripe_events
- [ ] Given le webhook endpoint configure dans Stripe Dashboard When Stripe envoie un event Then la signature est validee correctement
- [ ] Given un payment_intent.succeeded simule When il est traite Then la purchase est creee/mise a jour correctement
- [ ] Given un checkout.session.completed simule When il est traite Then la purchase est finalisee avec commission 10%
- [ ] Given un account.updated simule avec onboarding complete When il est traite Then stripe_accounts est mis a jour et notification envoyee
- [ ] Given un charge.dispute.created simule When il est traite Then notifications critiques sont envoyees au seller et admin
- [ ] Given un payout.paid simule When il est traite Then notification "Virement recu" est envoyee
- [ ] Given les entites Dart creees When j'appelle le repository Then les donnees sont retournees correctement
- [ ] Given tous les tests passes When flutter analyze est execute Then 0 warnings
- [ ] Given toute la documentation When je verifie Then les secrets requis sont documentes

## Fichiers Concernes

### A Creer
- `test/integration/stripe_webhook_test.dart` (tests e2e si possible)
- Documentation: Mise a jour du README ou doc specifique

### A Modifier
- `supabase/functions/stripe-webhook/index.ts` (bugs eventuels)
- Potentiellement tous les handlers (corrections)

## Notes Techniques

### Tests avec Stripe CLI

```bash
# Installer Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks vers Edge Function locale
stripe listen --forward-to http://localhost:54321/functions/v1/stripe-webhook

# Trigger des events
stripe trigger payment_intent.succeeded
stripe trigger checkout.session.completed
stripe trigger account.updated
stripe trigger charge.dispute.created
stripe trigger payout.paid
stripe trigger charge.refunded
stripe trigger transfer.created
```

### Checklist de Validation

#### 1. Tables Supabase

```sql
-- Verifier que les tables existent
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('stripe_accounts', 'purchases', 'stripe_events');

-- Verifier les colonnes stripe_accounts
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'stripe_accounts';

-- Verifier les colonnes purchases
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'purchases';

-- Verifier les index
SELECT indexname FROM pg_indexes WHERE tablename IN ('stripe_accounts', 'purchases', 'stripe_events');

-- Verifier RLS active
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('stripe_accounts', 'purchases', 'stripe_events');
```

#### 2. RLS Policies

```sql
-- Verifier les policies
SELECT tablename, policyname, cmd, qual
FROM pg_policies
WHERE tablename IN ('stripe_accounts', 'purchases', 'stripe_events');
```

#### 3. Edge Function

```bash
# Verifier deploiement
supabase functions list

# Logs
supabase functions logs stripe-webhook

# Test direct (sans signature - doit echouer)
curl -X POST https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-webhook \
  -H "Content-Type: application/json" \
  -d '{"type": "test"}'
# Expected: 400 Invalid signature
```

#### 4. Secrets Configures

Verifier dans Supabase Dashboard > Edge Functions > Secrets:
- [ ] `STRIPE_SECRET_KEY` (sk_live_... ou sk_test_...)
- [ ] `STRIPE_WEBHOOK_SECRET` (whsec_...)

#### 5. Webhook Endpoint dans Stripe

Verifier dans Stripe Dashboard > Developers > Webhooks:
- [ ] Endpoint URL correcte
- [ ] Events selectionnes (tous ceux listes dans l'Epic)
- [ ] Mode correct (Test/Live)

### Tests Dart

```dart
// test/integration/stripe_webhook_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ... imports

void main() {
  group('Stripe Integration', () {
    late SupabaseClient supabase;

    setUpAll(() async {
      // Initialize with test credentials
      supabase = SupabaseClient(
        'https://hekyovgnovhfhmkpfrna.supabase.co',
        'test-anon-key', // Use test key
      );
    });

    test('StripeAccount.fromJson parses correctly', () {
      final json = {
        'user_id': 'test-user-id',
        'stripe_account_id': 'acct_test123',
        'account_type': 'express',
        'onboarding_complete': true,
        'charges_enabled': true,
        'payouts_enabled': true,
        'details_submitted': true,
        'currently_due': [],
        'past_due': [],
        'country': 'FR',
        'default_currency': 'EUR',
        'created_at': '2026-01-28T10:00:00Z',
        'updated_at': '2026-01-28T10:00:00Z',
      };

      final account = StripeAccount.fromJson(json);

      expect(account.userId, 'test-user-id');
      expect(account.stripeAccountId, 'acct_test123');
      expect(account.isActive, true);
    });

    test('Purchase.fromJson parses correctly', () {
      final json = {
        'id': 'purchase-123',
        'user_id': 'user-456',
        'product_type': 'marketplace_item',
        'product_id': 'product-789',
        'seller_id': 'seller-abc',
        'amount_cents': 10000,
        'currency': 'USD',
        'platform_fee_cents': 1000,
        'seller_amount_cents': 9000,
        'status': 'succeeded',
        'created_at': '2026-01-28T10:00:00Z',
        'updated_at': '2026-01-28T10:00:00Z',
        'paid_at': '2026-01-28T10:05:00Z',
      };

      final purchase = Purchase.fromJson(json);

      expect(purchase.amountInCurrency, 100.0);
      expect(purchase.platformFeeInCurrency, 10.0);
      expect(purchase.sellerAmountInCurrency, 90.0);
      expect(purchase.isMarketplace, true);
      expect(purchase.isPaid, true);
    });

    test('Commission calculation is correct', () {
      // 10% of 10000 cents = 1000 cents
      final amountCents = 10000;
      final platformFeeCents = (amountCents * 0.10).floor();
      final sellerAmountCents = amountCents - platformFeeCents;

      expect(platformFeeCents, 1000);
      expect(sellerAmountCents, 9000);
    });
  });
}
```

### Documentation des Secrets

| Secret | Usage | Ou le trouver |
|--------|-------|---------------|
| `STRIPE_SECRET_KEY` | API Stripe | Stripe Dashboard > API Keys |
| `STRIPE_WEBHOOK_SECRET` | Verification signature | Stripe Dashboard > Webhooks > Endpoint > Signing secret |

### Rapport de Validation Finale

```markdown
## Rapport de Validation EPIC-11-STRIPE

### Tables
- [ ] stripe_accounts: OK
- [ ] purchases: OK
- [ ] stripe_events: OK

### RLS
- [ ] stripe_accounts RLS: OK
- [ ] purchases RLS: OK
- [ ] stripe_events RLS: OK (no public access)

### Edge Function
- [ ] Deployed: OK
- [ ] Signature verification: OK
- [ ] Idempotency: OK
- [ ] Error handling: OK

### Handlers
- [ ] payment_intent.*: OK
- [ ] checkout.session.*: OK
- [ ] account.*: OK
- [ ] charge.dispute.*: OK
- [ ] payout.*: OK
- [ ] transfer.*: OK
- [ ] charge.refund*: OK

### Dart Layer
- [ ] StripeAccount entity: OK
- [ ] Purchase entity: OK
- [ ] Enums: OK
- [ ] Repository: OK

### Tests
- [ ] Unit tests: X passed
- [ ] Integration tests: X passed
- [ ] flutter analyze: 0 warnings

### Secrets
- [ ] STRIPE_SECRET_KEY: Configured
- [ ] STRIPE_WEBHOOK_SECRET: Configured
```

## Definition of Done

- [ ] Tous les events testes via Stripe CLI
- [ ] Webhook endpoint configure dans Stripe Dashboard
- [ ] Signature verification fonctionnelle
- [ ] Toutes les tables creees et RLS actif
- [ ] Tous les handlers fonctionnels
- [ ] Entites Dart testees
- [ ] Repository teste
- [ ] `flutter analyze --fatal-infos` = 0 warnings
- [ ] `flutter test` = tous tests passent
- [ ] Documentation secrets a jour
- [ ] Rapport de validation complete

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible (validation, pas de nouveau code)

## Dependances

- S01-S11: Toutes les stories precedentes

## Stories Dependantes

- Aucune (story finale de l'Epic)
