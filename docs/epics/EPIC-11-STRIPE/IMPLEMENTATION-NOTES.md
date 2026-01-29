# EPIC-11 Stripe - Notes d'Implementation

**Date**: 2026-01-29
**Mode**: Autonomous
**Agent**: Claude Opus 4.5
**Durée**: ~1h

---

## Résumé Exécutif

Implementation complete de l'integration Stripe pour Lynewed:
- 3 tables Supabase (via MCP)
- 1 Edge Function (31 handlers webhook)
- 6 fichiers Dart (entities + repository)
- 76 tests unitaires

---

## Phase 1: Infrastructure Database

### S01 - Table stripe_accounts

**Migration appliquée via MCP Supabase:**

```sql
CREATE TABLE stripe_accounts (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  stripe_account_id VARCHAR(255) UNIQUE NOT NULL,
  account_type VARCHAR(50) DEFAULT 'express',
  onboarding_complete BOOLEAN DEFAULT FALSE,
  charges_enabled BOOLEAN DEFAULT FALSE,
  payouts_enabled BOOLEAN DEFAULT FALSE,
  details_submitted BOOLEAN DEFAULT FALSE,
  currently_due JSONB DEFAULT '[]',
  past_due JSONB DEFAULT '[]',
  disabled_reason TEXT,
  country VARCHAR(2),
  default_currency VARCHAR(3),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_stripe_accounts_stripe_id ON stripe_accounts(stripe_account_id);

-- RLS
ALTER TABLE stripe_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User sees own stripe account" ON stripe_accounts FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "User can create own stripe account" ON stripe_accounts FOR INSERT WITH CHECK (user_id = auth.uid());
```

### S02 - Table purchases

**Migration appliquée via MCP Supabase:**

```sql
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  product_type VARCHAR(50) NOT NULL CHECK (product_type IN ('marketplace_item', 'magazine', 'album', 'print', 'subscription')),
  product_id UUID,
  seller_id UUID REFERENCES profiles(id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  currency VARCHAR(3) DEFAULT 'USD',
  platform_fee_cents INTEGER DEFAULT 0,
  seller_amount_cents INTEGER,
  shipping_cents INTEGER DEFAULT 0,
  stripe_payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN (
    'pending', 'processing', 'requires_action', 'succeeded',
    'failed', 'canceled', 'refunded', 'partially_refunded', 'disputed'
  )),
  metadata JSONB DEFAULT '{}',
  error_message TEXT,
  error_code VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  paid_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  disputed_at TIMESTAMPTZ
);

-- 7 Index de performance
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_purchases_seller_id ON purchases(seller_id) WHERE seller_id IS NOT NULL;
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_purchases_stripe_pi ON purchases(stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;
CREATE INDEX idx_purchases_stripe_cs ON purchases(stripe_checkout_session_id) WHERE stripe_checkout_session_id IS NOT NULL;
CREATE INDEX idx_purchases_product ON purchases(product_type, product_id);

-- RLS
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Buyer sees own purchases" ON purchases FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Seller sees sales" ON purchases FOR SELECT USING (seller_id = auth.uid());
```

### S03 - Table stripe_events

**Migration appliquée via MCP Supabase:**

```sql
CREATE TABLE stripe_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id VARCHAR(255) UNIQUE NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  livemode BOOLEAN DEFAULT FALSE,
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMPTZ,
  processing_attempts INTEGER DEFAULT 0,
  error_message TEXT,
  error_code VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4 Index
CREATE INDEX idx_stripe_events_stripe_id ON stripe_events(stripe_event_id);
CREATE INDEX idx_stripe_events_type ON stripe_events(event_type);
CREATE INDEX idx_stripe_events_livemode ON stripe_events(livemode);
CREATE INDEX idx_stripe_events_unprocessed ON stripe_events(processed) WHERE processed = FALSE;

-- RLS (service_role only)
ALTER TABLE stripe_events ENABLE ROW LEVEL SECURITY;
```

---

## Phase 2: Edge Function stripe-webhook

### Structure Déployée (v5)

```
supabase/functions/stripe-webhook/
├── index.ts          # Entry point + signature verification
├── deno.json         # Stripe SDK import
└── handlers/
    ├── payment-intent.ts    # 7 handlers
    ├── checkout-session.ts  # 4 handlers
    ├── account.ts           # 5 handlers
    ├── dispute.ts           # 5 handlers
    ├── payout.ts            # 5 handlers
    ├── transfer.ts          # 3 handlers
    └── refund.ts            # 2 handlers
```

### Flow Principal (index.ts)

```typescript
import Stripe from "npm:stripe@14";
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  // 1. Vérification signature Stripe
  const signature = req.headers.get("stripe-signature");
  const body = await req.text();
  const stripe = new Stripe(STRIPE_SECRET_KEY);
  const event = stripe.webhooks.constructEvent(body, signature, WEBHOOK_SECRET);

  // 2. Idempotency check via stripe_events
  const { data: existing } = await supabase
    .from("stripe_events")
    .select("id")
    .eq("stripe_event_id", event.id)
    .single();

  if (existing) return new Response(JSON.stringify({ received: true, duplicate: true }));

  // 3. Store event
  await supabase.from("stripe_events").insert({
    stripe_event_id: event.id,
    event_type: event.type,
    livemode: event.livemode,
    payload: event.data.object,
  });

  // 4. Process event
  await processEvent(supabase, event);

  // 5. Mark processed
  await supabase.from("stripe_events")
    .update({ processed: true, processed_at: new Date().toISOString() })
    .eq("stripe_event_id", event.id);

  return new Response(JSON.stringify({ received: true }));
});
```

### Handlers Implémentés (31 events)

| Catégorie | Events |
|-----------|--------|
| payment_intent.* | created, processing, succeeded, payment_failed, canceled, amount_capturable_updated, requires_action |
| checkout.session.* | completed, expired, async_payment_succeeded, async_payment_failed |
| account.* | updated, application.deauthorized, external_account.created/updated/deleted |
| charge.dispute.* | created, updated, closed, funds_reinstated, funds_withdrawn |
| payout.* | created, updated, paid, failed, canceled |
| transfer.* | created, updated, reversed |
| charge.refund* | refunded, refund.updated |

### Commission Marketplace (10%)

```typescript
// Dans payment-intent.ts
const platformFeeCents = seller_id ? Math.floor(amountCents * 0.10) : 0;
const sellerAmountCents = seller_id ? amountCents - platformFeeCents : null;
```

---

## Phase 3: Couche Dart

### Fichiers Créés

| Fichier | Lignes | Description |
|---------|--------|-------------|
| `lib/features/payments/domain/entities/purchase_status.dart` | 95 | Enum 9 statuts + extensions |
| `lib/features/payments/domain/entities/product_type.dart` | 70 | Enum 5 types + extensions |
| `lib/features/payments/domain/entities/stripe_account.dart` | 180 | Entity avec fromJson, copyWith, == |
| `lib/features/payments/domain/entities/purchase.dart` | 270 | Entity avec fromJson, copyWith, == |
| `lib/features/payments/domain/repositories/stripe_repository.dart` | 25 | Interface repository |
| `lib/features/payments/data/repositories/supabase_stripe_repository.dart` | 55 | Implementation Supabase |

### Tests Créés

| Fichier | Tests | Coverage |
|---------|-------|----------|
| `test/features/payments/domain/entities/purchase_status_test.dart` | 18 | fromString, toJson, extensions |
| `test/features/payments/domain/entities/product_type_test.dart` | 16 | fromString, toJson, extensions |
| `test/features/payments/domain/entities/stripe_account_test.dart` | 15 | fromJson, copyWith, computed props |
| `test/features/payments/domain/entities/purchase_test.dart` | 20 | fromJson, copyWith, computed props |
| `test/features/payments/data/repositories/supabase_stripe_repository_test.dart` | 7 | Parsing, commission calc |

**Total: 76 tests**

---

## Décisions Techniques

### Pourquoi `@immutable` au lieu de `Equatable`

Le projet existant utilise `@immutable` de Flutter plutôt que le package `equatable`. Pour rester cohérent avec les patterns existants (ex: `UserProfile`), les entités Stripe suivent le même pattern avec:
- `@immutable` annotation
- Override manuel de `==` et `hashCode`
- `copyWith` pour immutabilité

### Pourquoi verify_jwt: false

L'Edge Function `stripe-webhook` a `verify_jwt: false` car:
- Stripe utilise sa propre signature HMAC-SHA256
- Le header `stripe-signature` est vérifié via `stripe.webhooks.constructEvent()`
- Pas de JWT Supabase dans les requêtes webhook

### Pourquoi Idempotency via table

Au lieu de Redis ou autre cache:
- Persiste dans la DB (auditabilité)
- Permet retry manuel si échec
- Table `stripe_events` sert aussi de log

---

## Configuration Requise (Post-Implementation)

```bash
# Secrets Supabase (Dashboard > Edge Functions > Secrets)
STRIPE_SECRET_KEY=sk_test_... ou sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Webhook Stripe (Dashboard > Developers > Webhooks)
URL: https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-webhook
Events: 31 events listés ci-dessus
```

---

## Métriques Finales

| Métrique | Valeur |
|----------|--------|
| Tables créées | 3 |
| Index créés | 16 |
| RLS policies | 6 |
| Edge Function version | v5 |
| Handlers webhook | 31 |
| Fichiers Dart | 6 |
| Tests unitaires | 76 |
| flutter analyze | 0 warnings |
| Durée totale | ~1h (mode autonomous) |
