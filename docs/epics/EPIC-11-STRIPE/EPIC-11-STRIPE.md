# EPIC-11: Integration Stripe Complete (APP-05)

> **Version** : 1.0.0
> **Status** : DRAFT
> **Derniere MAJ** : 2026-01-28
> **Estimation** : 1 jour | **Prix** : 300 EUR

**Dependances** : EPIC-06-PREREQUISITES (pour nouvelles tables RLS)
**Source PRD** : `docs/specs/MISSION-01-EVOLUTIONS-2026.md` - Section 8 (APP-05)

---

## Resume

Integration Stripe **complete et securisee** pour :
1. **Marketplace** : Stripe Connect Express pour les vendeuses
2. **Achats** : Payment Intents pour tous les types d'achats (marketplace, magazines futurs, etc.)
3. **Audit complet** : Tous les webhooks geres, tous les events logges

Cette integration est la **fondation** pour toutes les fonctionnalites de monetisation de Lynewed.

---

## MCP Stripe - Configuration Autonome

> ⚠️ **IMPORTANT : COMPTE STRIPE PRODUCTION**

Le MCP Stripe est connecté au **compte officiel Lynewed** (mode test activé). Cela permet de créer/configurer les produits Stripe en toute autonomie.

### ⛔ PRODUITS EXISTANTS - NE PAS MODIFIER

Ces produits sont les **offres d'abonnement pro du CRM** - déjà utilisés en production :

| Produit | ID | Usage |
|---------|-----|-------|
| **EARLY ACCESS** | `prod_TCeouF5WM5cN8Z` | Abonnement pro basique |
| **PREMIUM VISIBILITY** | `prod_TCesp37xX9fPKZ` | Abonnement pro avancé |
| **ULTIMATE ACCESS** | `prod_TCeuXHDpPaS7hB` | Abonnement pro premium |

**RÈGLES STRICTES :**
1. **JAMAIS** modifier/supprimer ces produits existants
2. **JAMAIS** modifier leurs prix associés
3. **TOUJOURS** créer de NOUVEAUX produits pour marketplace, magazines, etc.

### Outils MCP Disponibles

Pour cet Epic, utiliser le MCP Stripe pour :

| Action | Outil MCP | Notes |
|--------|-----------|-------|
| Vérifier structure existante | `list_products`, `list_prices` | Avant toute création |
| Créer produit magazine | `create_product` | Metadata: `source: lynewed-app` |
| Créer prix | `create_price` | Pour nouveaux produits uniquement |
| Créer lien paiement | `create_payment_link` | Pour tests |
| Rechercher docs | `search_stripe_documentation` | Best practices |

### Exemple création produit Magazine

```
Utiliser mcp__stripe__create_product:
- name: "Magazine Photo Mariage"
- description: "Magazine photo personnalisé de votre mariage"

Puis mcp__stripe__create_price:
- product: [ID du produit créé]
- unit_amount: 4900 (49.00 USD)
- currency: "usd"
```

---

## Contexte

### Etat Actuel Production

| Element | Statut | Details |
|---------|--------|---------|
| `stripe_events_log` | Existe (limite) | event_id, event_type, timestamps - pas de payload |
| `professional_subscriptions` | Existe (174 rows) | stripe_customer_id pour abonnements pros |
| `stripe_accounts` | N'EXISTE PAS | Necessaire pour Connect |
| `purchases` | N'EXISTE PAS | Necessaire pour achats marketplace/reels |
| `stripe_events` (complet) | N'EXISTE PAS | Necessaire pour audit complet |

### Problemes Actuels

1. **Pas de Stripe Connect** : Impossible d'avoir des vendeuses marketplace
2. **Pas de gestion des achats** : Aucune table pour tracker les paiements
3. **Audit incomplet** : `stripe_events_log` ne stocke pas le payload
4. **Webhooks partiels** : Seuls quelques events sont geres

### Architecture Cible

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ARCHITECTURE STRIPE LYNEWED                          │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   STRIPE API    │    │  EDGE FUNCTION  │    │   SUPABASE DB   │         │
│  │                 │───▶│ stripe-webhook  │───▶│                 │         │
│  │ - Connect       │    │                 │    │ - stripe_accounts│         │
│  │ - Payments      │    │ - Verify sig    │    │ - purchases      │         │
│  │ - Payouts       │    │ - Log event     │    │ - stripe_events  │         │
│  │ - Disputes      │    │ - Process       │    │                 │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐                                 │
│  │   FLUTTER APP   │    │   DART LAYER    │                                 │
│  │                 │───▶│                 │                                 │
│  │ - Onboarding    │    │ - StripeAccount │                                 │
│  │ - Checkout      │    │ - Purchase      │                                 │
│  │ - Status        │    │ - Repository    │                                 │
│  └─────────────────┘    └─────────────────┘                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Objectifs

### Objectifs Principaux

1. **Stripe Connect Express** : Onboarding simplifie pour vendeuses marketplace
2. **Gestion des achats** : Table `purchases` pour tous types d'achats
3. **Audit complet** : Tous les events logges avec payload complet
4. **Webhooks exhaustifs** : TOUS les webhooks de la liste PRD geres

### Objectifs Secondaires

1. Commission 10% automatique sur ventes marketplace
2. Paiements multi-pays (monde entier)
3. Gestion des disputes avec notification
4. Architecture evolutive pour futurs produits (magazines payants, etc.)

---

## Fonctionnalites Stripe

### Stripe Connect (Marketplace)

Pour les vendeuses de la marketplace :
- **Onboarding Express** : Simplifie, rapide (email, telephone, identite, compte bancaire)
- **Paiements avec commission** : 10% preleve automatiquement
- **Transferts automatiques** : Versements aux vendeuses

### Payment Intents (Achats)

Pour toutes les acheteuses et futurs achats :
- Checkout Session pour parcours d'achat
- Payment Intent pour paiements directs
- Support multi-devises (stockage USD)

---

## Webhooks Stripe a Gerer (EXHAUSTIF)

### Paiements (payment_intent.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `payment_intent.created` | Log event, creer purchase en 'pending' | HAUTE |
| `payment_intent.processing` | Mettre a jour purchase en 'processing' | MOYENNE |
| `payment_intent.succeeded` | Marquer purchase 'succeeded', notifier | HAUTE |
| `payment_intent.payment_failed` | Marquer 'failed', notifier user, log error | HAUTE |
| `payment_intent.canceled` | Marquer 'canceled' | MOYENNE |
| `payment_intent.amount_capturable_updated` | Log event | BASSE |
| `payment_intent.requires_action` | Notifier user action requise | HAUTE |

### Checkout (checkout.session.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `checkout.session.completed` | Finaliser achat, creer purchase si absent | HAUTE |
| `checkout.session.expired` | Log expiration, cleanup | MOYENNE |
| `checkout.session.async_payment_succeeded` | Finaliser achat async | HAUTE |
| `checkout.session.async_payment_failed` | Marquer echec, notifier | HAUTE |

### Connect (account.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `account.updated` | MAJ onboarding_complete, charges_enabled, payouts_enabled | HAUTE |
| `account.application.deauthorized` | Desactiver compte, notifier | HAUTE |
| `account.external_account.created` | Log event | BASSE |
| `account.external_account.updated` | Log event | BASSE |
| `account.external_account.deleted` | Log event | BASSE |

### Transferts (transfer.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `transfer.created` | Log, mettre a jour purchase.stripe_transfer_id | MOYENNE |
| `transfer.updated` | Log event | BASSE |
| `transfer.reversed` | Marquer reversal, notifier seller | HAUTE |

### Disputes (charge.dispute.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `charge.dispute.created` | Notifier admin + seller, marquer purchase 'disputed' | CRITIQUE |
| `charge.dispute.updated` | Log update, notifier | MOYENNE |
| `charge.dispute.closed` | MAJ statut final, notifier resolution | HAUTE |
| `charge.dispute.funds_reinstated` | Log, notifier seller bonne nouvelle | MOYENNE |
| `charge.dispute.funds_withdrawn` | Log, notifier seller | HAUTE |

### Refunds (charge.refund*)

| Event | Action | Priorite |
|-------|--------|----------|
| `charge.refunded` | Marquer purchase 'refunded', notifier buyer | HAUTE |
| `charge.refund.updated` | Log update | BASSE |

### Payouts (payout.*)

| Event | Action | Priorite |
|-------|--------|----------|
| `payout.created` | Log event | BASSE |
| `payout.updated` | Log event | BASSE |
| `payout.paid` | Notifier seller "Virement recu" | HAUTE |
| `payout.failed` | Notifier seller + admin, investiguer | CRITIQUE |
| `payout.canceled` | Log event, notifier | MOYENNE |

---

## Schema Base de Donnees

### Table: stripe_accounts (NOUVELLE)

```sql
-- Comptes Stripe Connect des vendeuses
CREATE TABLE stripe_accounts (
  user_id UUID REFERENCES profiles(id) PRIMARY KEY,
  stripe_account_id VARCHAR(255) NOT NULL UNIQUE,
  account_type VARCHAR(20) DEFAULT 'express' CHECK (account_type IN ('express', 'standard', 'custom')),

  -- Statut onboarding
  onboarding_complete BOOLEAN DEFAULT FALSE,
  charges_enabled BOOLEAN DEFAULT FALSE,
  payouts_enabled BOOLEAN DEFAULT FALSE,
  details_submitted BOOLEAN DEFAULT FALSE,

  -- Restrictions
  currently_due JSONB DEFAULT '[]'::jsonb,
  past_due JSONB DEFAULT '[]'::jsonb,
  disabled_reason TEXT,

  -- Metadata
  country VARCHAR(2),
  default_currency VARCHAR(3),

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche par stripe_account_id
CREATE INDEX idx_stripe_accounts_stripe_id ON stripe_accounts(stripe_account_id);
```

### Table: purchases (NOUVELLE)

```sql
-- Achats (marketplace, magazines, albums, prints futurs)
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,

  -- Type de produit
  product_type VARCHAR(50) NOT NULL CHECK (product_type IN ('marketplace_item', 'magazine', 'album', 'print', 'subscription')),
  product_id UUID,

  -- Seller (pour marketplace)
  seller_id UUID REFERENCES profiles(id),

  -- Montants (en centimes)
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  currency VARCHAR(3) DEFAULT 'USD',
  platform_fee_cents INTEGER DEFAULT 0,
  seller_amount_cents INTEGER,
  shipping_cents INTEGER DEFAULT 0,

  -- Stripe IDs
  stripe_payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),

  -- Statut
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN (
    'pending', 'processing', 'requires_action', 'succeeded',
    'failed', 'canceled', 'refunded', 'partially_refunded', 'disputed'
  )),

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,
  error_message TEXT,
  error_code VARCHAR(100),

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  paid_at TIMESTAMP WITH TIME ZONE,
  refunded_at TIMESTAMP WITH TIME ZONE,
  disputed_at TIMESTAMP WITH TIME ZONE
);

-- Index pour recherches frequentes
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_purchases_seller_id ON purchases(seller_id) WHERE seller_id IS NOT NULL;
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_purchases_stripe_pi ON purchases(stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;
CREATE INDEX idx_purchases_stripe_cs ON purchases(stripe_checkout_session_id) WHERE stripe_checkout_session_id IS NOT NULL;
CREATE INDEX idx_purchases_product ON purchases(product_type, product_id);
```

### Table: stripe_events (NOUVELLE - Audit Complet)

```sql
-- Events Stripe (audit complet avec payload)
CREATE TABLE stripe_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id VARCHAR(255) UNIQUE NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  api_version VARCHAR(20),

  -- Payload complet
  payload JSONB NOT NULL,

  -- Processing status
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP WITH TIME ZONE,
  processing_attempts INTEGER DEFAULT 0,

  -- Error tracking
  error_message TEXT,
  error_code VARCHAR(100),

  -- Metadata
  livemode BOOLEAN DEFAULT TRUE,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  stripe_created_at TIMESTAMP WITH TIME ZONE
);

-- Index pour requetes frequentes
CREATE INDEX idx_stripe_events_type ON stripe_events(event_type);
CREATE INDEX idx_stripe_events_unprocessed ON stripe_events(created_at) WHERE processed = FALSE;
CREATE INDEX idx_stripe_events_stripe_id ON stripe_events(stripe_event_id);
CREATE INDEX idx_stripe_events_livemode ON stripe_events(livemode);
```

---

## RLS Policies (PRD Section D.6)

### stripe_accounts

```sql
-- Activer RLS
ALTER TABLE stripe_accounts ENABLE ROW LEVEL SECURITY;

-- Chaque utilisateur voit son propre compte Stripe
CREATE POLICY "User sees own stripe account" ON stripe_accounts
FOR SELECT USING (user_id = auth.uid());

-- L'utilisateur peut creer son propre compte
CREATE POLICY "User can create own stripe account" ON stripe_accounts
FOR INSERT WITH CHECK (user_id = auth.uid());

-- Seul service_role peut update (via webhooks)
-- Pas de policy UPDATE pour les users normaux
```

### purchases

```sql
-- Activer RLS
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Buyer voit ses propres achats
CREATE POLICY "Buyer sees own purchases" ON purchases
FOR SELECT USING (user_id = auth.uid());

-- Seller voit les achats de ses produits
CREATE POLICY "Seller sees sales" ON purchases
FOR SELECT USING (seller_id = auth.uid());

-- Insert via service_role uniquement (checkout webhook)
-- Pas de policy INSERT/UPDATE pour users normaux
```

### stripe_events

```sql
-- Activer RLS
ALTER TABLE stripe_events ENABLE ROW LEVEL SECURITY;

-- AUCUNE policy publique - acces service_role uniquement
-- Les events sont sensibles et ne doivent pas etre exposes aux users
```

---

## Edge Function: stripe-webhook

### Architecture

```typescript
// supabase/functions/stripe-webhook/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@14";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-12-18.acacia",
});

const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

Deno.serve(async (req: Request) => {
  // 1. Verify signature
  const signature = req.headers.get("stripe-signature")!;
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature", { status: 400 });
  }

  // 2. Create Supabase client with service_role
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 3. Log event for audit (idempotent - UPSERT)
  const { error: logError } = await supabase
    .from("stripe_events")
    .upsert({
      stripe_event_id: event.id,
      event_type: event.type,
      api_version: event.api_version,
      payload: event.data.object,
      livemode: event.livemode,
      stripe_created_at: new Date(event.created * 1000).toISOString(),
    }, { onConflict: "stripe_event_id" });

  if (logError) {
    console.error("Failed to log event:", logError);
  }

  // 4. Check if already processed (idempotency)
  const { data: existing } = await supabase
    .from("stripe_events")
    .select("processed")
    .eq("stripe_event_id", event.id)
    .single();

  if (existing?.processed) {
    return new Response("Already processed", { status: 200 });
  }

  // 5. Process by event type
  try {
    await processEvent(supabase, event);

    // 6. Mark as processed
    await supabase
      .from("stripe_events")
      .update({
        processed: true,
        processed_at: new Date().toISOString()
      })
      .eq("stripe_event_id", event.id);

  } catch (err) {
    console.error("Processing error:", err);

    // Get current attempt count
    const { data: eventData } = await supabase
      .from("stripe_events")
      .select("processing_attempts")
      .eq("stripe_event_id", event.id)
      .single();

    const attempts = (eventData?.processing_attempts || 0) + 1;
    const MAX_ATTEMPTS = 5;

    await supabase
      .from("stripe_events")
      .update({
        error_message: err.message,
        processing_attempts: attempts,
        // Mark as permanently failed after max attempts
        status: attempts >= MAX_ATTEMPTS ? 'failed' : 'pending'
      })
      .eq("stripe_event_id", event.id);

    // Alert if max attempts reached (dead letter scenario)
    if (attempts >= MAX_ATTEMPTS) {
      console.error(`ALERT: Webhook ${event.id} failed after ${MAX_ATTEMPTS} attempts. Manual intervention required.`);
      // Could also send to notifications_outbox for admin alert
      await supabase.from("notifications_outbox").insert({
        event_type: "webhook_dead_letter",
        payload: {
          event_id: event.id,
          event_type: event.type,
          error: err.message,
          attempts: attempts
        },
        recipient_id: null // Admin notification
      });
      // Return 200 to stop Stripe retries (we've logged it for manual review)
      return new Response("Max retries reached, logged for manual review", { status: 200 });
    }

    // Return 500 to trigger Stripe retry (up to max attempts)
    return new Response("Processing error", { status: 500 });
  }

  return new Response("OK", { status: 200 });
});
```

### Handlers par Type d'Event

```typescript
async function processEvent(supabase: any, event: Stripe.Event) {
  const obj = event.data.object as any;

  switch (event.type) {
    // === PAYMENT INTENTS ===
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

    // === CHECKOUT SESSIONS ===
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

    // === CONNECT ACCOUNTS ===
    case "account.updated":
      await handleAccountUpdated(supabase, obj);
      break;
    case "account.application.deauthorized":
      await handleAccountDeauthorized(supabase, obj);
      break;

    // === TRANSFERS ===
    case "transfer.created":
      await handleTransferCreated(supabase, obj);
      break;
    case "transfer.reversed":
      await handleTransferReversed(supabase, obj);
      break;

    // === DISPUTES ===
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

    // === REFUNDS ===
    case "charge.refunded":
      await handleChargeRefunded(supabase, obj);
      break;

    // === PAYOUTS ===
    case "payout.paid":
      await handlePayoutPaid(supabase, obj);
      break;
    case "payout.failed":
      await handlePayoutFailed(supabase, obj);
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
}
```

---

## Criteres d'Acceptation Globaux

- [ ] Stripe Connect onboarding Express fonctionnel
- [ ] Tous les webhooks listes ci-dessus geres
- [ ] Tous les events logges dans `stripe_events` avec payload complet
- [ ] Idempotency : meme event traite une seule fois
- [ ] Signature verification obligatoire
- [ ] Gestion erreurs avec messages user-friendly
- [ ] Gestion disputes avec notification admin + seller
- [ ] Paiements monde entier (multi-country)
- [ ] Commission 10% calculee correctement
- [ ] Tests mode test + production
- [ ] RLS policies conformes au PRD Section D.6

---

## Stories

### Phase 1 : Infrastructure Database (S01-S03)

| Story | Titre | Points | Priorite |
|-------|-------|--------|----------|
| S01 | Creer table `stripe_accounts` | 2 | CRITIQUE |
| S02 | Creer table `purchases` | 3 | CRITIQUE |
| S03 | Creer table `stripe_events` (audit complet) | 2 | CRITIQUE |

### Phase 2 : Edge Function Core (S04-S06)

| Story | Titre | Points | Priorite |
|-------|-------|--------|----------|
| S04 | Creer Edge Function `stripe-webhook` avec signature verification | 3 | CRITIQUE |
| S05 | Implementer handlers `payment_intent.*` | 3 | HAUTE |
| S06 | Implementer handlers `checkout.session.*` | 3 | HAUTE |

### Phase 3 : Connect & Marketplace (S07-S09)

| Story | Titre | Points | Priorite |
|-------|-------|--------|----------|
| S07 | Implementer handler `account.updated` (Connect status) | 2 | HAUTE |
| S08 | Implementer handlers `charge.dispute.*` | 3 | HAUTE |
| S09 | Implementer handlers `payout.*` | 2 | MOYENNE |

### Phase 4 : Dart Layer (S10-S11)

| Story | Titre | Points | Priorite |
|-------|-------|--------|----------|
| S10 | Implementer handlers transfers + refunds | 2 | MOYENNE |
| S11 | Creer entites Dart et repository Stripe | 3 | HAUTE |

---

## Detail des Stories

### S01: Creer table `stripe_accounts`

**Description** : Creer la table pour stocker les comptes Stripe Connect des vendeuses.

**Criteres d'Acceptation** :
```gherkin
Feature: Table stripe_accounts

Scenario: Creation de la table
  Given la base de donnees Supabase
  When j'applique la migration
  Then la table stripe_accounts existe
  And la colonne user_id est PRIMARY KEY
  And la colonne stripe_account_id est UNIQUE et NOT NULL

Scenario: RLS Policy - User sees own account
  Given un utilisateur authentifie avec id "user-123"
  And un compte stripe avec user_id "user-123"
  When l'utilisateur fait SELECT sur stripe_accounts
  Then il voit uniquement son propre compte

Scenario: RLS Policy - Cannot see others
  Given un utilisateur authentifie avec id "user-123"
  And un compte stripe avec user_id "user-456"
  When l'utilisateur fait SELECT sur stripe_accounts
  Then le resultat est vide
```

**Migration SQL** : Voir schema ci-dessus

---

### S02: Creer table `purchases`

**Description** : Creer la table pour tracker tous les achats (marketplace, magazines, etc.).

**Criteres d'Acceptation** :
```gherkin
Feature: Table purchases

Scenario: Creation de la table
  Given la base de donnees Supabase
  When j'applique la migration
  Then la table purchases existe
  And les index de performance sont crees
  And les contraintes CHECK sont actives

Scenario: Calcul commission marketplace
  Given un achat marketplace avec amount_cents = 10000
  When la commission est calculee
  Then platform_fee_cents = 1000 (10%)
  And seller_amount_cents = 9000

Scenario: RLS Policy - Buyer sees purchases
  Given un utilisateur authentifie avec id "buyer-123"
  And un achat avec user_id "buyer-123"
  When l'utilisateur fait SELECT sur purchases
  Then il voit son achat

Scenario: RLS Policy - Seller sees sales
  Given un utilisateur authentifie avec id "seller-456"
  And un achat avec seller_id "seller-456"
  When l'utilisateur fait SELECT sur purchases
  Then il voit la vente
```

---

### S03: Creer table `stripe_events`

**Description** : Creer la table d'audit complet pour tous les events Stripe.

**Criteres d'Acceptation** :
```gherkin
Feature: Table stripe_events

Scenario: Creation de la table
  Given la base de donnees Supabase
  When j'applique la migration
  Then la table stripe_events existe
  And stripe_event_id est UNIQUE
  And la colonne payload est de type JSONB

Scenario: Idempotency via UPSERT
  Given un event avec stripe_event_id "evt_123"
  When le meme event est recu deux fois
  Then il n'y a qu'une seule ligne dans stripe_events
  And pas d'erreur duplicate key

Scenario: RLS Policy - No public access
  Given un utilisateur authentifie
  When il tente SELECT sur stripe_events
  Then il recoit 0 resultats (RLS bloque)
```

---

### S04: Creer Edge Function `stripe-webhook`

**Description** : Creer l'Edge Function principale qui recoit tous les webhooks Stripe.

**Criteres d'Acceptation** :
```gherkin
Feature: Edge Function stripe-webhook

Scenario: Signature verification valide
  Given une requete webhook avec signature valide
  When la fonction est appelee
  Then le traitement continue
  And l'event est logge dans stripe_events

Scenario: Signature verification invalide
  Given une requete webhook avec signature invalide
  When la fonction est appelee
  Then elle retourne HTTP 400
  And aucun event n'est logge

Scenario: Idempotency
  Given un event deja traite (processed = true)
  When le meme event est recu a nouveau
  Then la fonction retourne HTTP 200
  And le traitement n'est pas re-execute

Scenario: Error handling avec retry
  Given une erreur lors du traitement
  When la fonction echoue
  Then elle retourne HTTP 500
  And processing_attempts est incremente
  And Stripe re-essaiera
```

---

### S05: Implementer handlers `payment_intent.*`

**Description** : Gerer tous les events payment_intent.

**Criteres d'Acceptation** :
```gherkin
Feature: Payment Intent Handlers

Scenario: payment_intent.succeeded
  Given un event payment_intent.succeeded
  And une purchase en status 'pending'
  When l'event est traite
  Then la purchase passe en 'succeeded'
  And paid_at est mis a jour
  And une notification est envoyee au buyer

Scenario: payment_intent.payment_failed
  Given un event payment_intent.payment_failed
  And une purchase en status 'pending'
  When l'event est traite
  Then la purchase passe en 'failed'
  And error_message contient le message Stripe
  And une notification est envoyee au buyer

Scenario: payment_intent.requires_action
  Given un event payment_intent.requires_action
  When l'event est traite
  Then la purchase passe en 'requires_action'
  And une notification est envoyee avec instructions
```

---

### S06: Implementer handlers `checkout.session.*`

**Description** : Gerer tous les events checkout.session.

**Criteres d'Acceptation** :
```gherkin
Feature: Checkout Session Handlers

Scenario: checkout.session.completed - nouvelle purchase
  Given un event checkout.session.completed
  And aucune purchase existante pour ce checkout
  When l'event est traite
  Then une nouvelle purchase est creee
  And status = 'succeeded'
  And les montants sont extraits du checkout

Scenario: checkout.session.expired
  Given un event checkout.session.expired
  When l'event est traite
  Then l'event est logge
  And aucune purchase n'est creee
```

---

### S07: Implementer handler `account.updated`

**Description** : Gerer les mises a jour de compte Stripe Connect.

**Criteres d'Acceptation** :
```gherkin
Feature: Account Updated Handler

Scenario: Onboarding complete
  Given un event account.updated
  And charges_enabled = true dans l'event
  And payouts_enabled = true dans l'event
  When l'event est traite
  Then stripe_accounts.charges_enabled = true
  And stripe_accounts.payouts_enabled = true
  And stripe_accounts.onboarding_complete = true

Scenario: Nouveau requirements
  Given un event account.updated
  And currently_due contient des elements
  When l'event est traite
  Then stripe_accounts.currently_due est mis a jour
  And une notification est envoyee a la vendeuse

Scenario: Account deauthorized
  Given un event account.application.deauthorized
  When l'event est traite
  Then stripe_accounts.charges_enabled = false
  And stripe_accounts.disabled_reason = 'deauthorized'
  And une notification est envoyee
```

---

### S08: Implementer handlers `charge.dispute.*`

**Description** : Gerer les litiges (disputes) Stripe.

**Criteres d'Acceptation** :
```gherkin
Feature: Dispute Handlers

Scenario: charge.dispute.created
  Given un event charge.dispute.created
  And une purchase associee au charge
  When l'event est traite
  Then purchase.status = 'disputed'
  And purchase.disputed_at est mis a jour
  And une notification CRITIQUE est envoyee au seller
  And une notification est envoyee a l'admin

Scenario: charge.dispute.closed - won
  Given un event charge.dispute.closed
  And status = 'won'
  When l'event est traite
  Then purchase.status revient a 'succeeded'
  And une notification positive est envoyee au seller

Scenario: charge.dispute.closed - lost
  Given un event charge.dispute.closed
  And status = 'lost'
  When l'event est traite
  Then purchase.status = 'refunded'
  And une notification est envoyee
```

---

### S09: Implementer handlers `payout.*`

**Description** : Gerer les versements aux vendeuses.

**Criteres d'Acceptation** :
```gherkin
Feature: Payout Handlers

Scenario: payout.paid
  Given un event payout.paid
  And le payout est associe a un stripe_account
  When l'event est traite
  Then l'event est logge
  And une notification "Virement recu" est envoyee a la vendeuse

Scenario: payout.failed
  Given un event payout.failed
  When l'event est traite
  Then l'event est logge
  And une notification CRITIQUE est envoyee a la vendeuse
  And une notification est envoyee a l'admin pour investigation
```

---

### S10: Implementer handlers transfers + refunds

**Description** : Gerer les transferts et remboursements.

**Criteres d'Acceptation** :
```gherkin
Feature: Transfer and Refund Handlers

Scenario: transfer.created
  Given un event transfer.created
  And une purchase associee
  When l'event est traite
  Then purchase.stripe_transfer_id est mis a jour

Scenario: transfer.reversed
  Given un event transfer.reversed
  When l'event est traite
  Then l'event est logge
  And une notification est envoyee au seller

Scenario: charge.refunded
  Given un event charge.refunded
  And une purchase associee
  When l'event est traite
  Then purchase.status = 'refunded'
  And purchase.refunded_at est mis a jour
  And une notification est envoyee au buyer
```

---

### S11: Creer entites Dart et repository Stripe

**Description** : Creer la couche Dart pour interagir avec les tables Stripe.

**Criteres d'Acceptation** :
```gherkin
Feature: Dart Stripe Layer

Scenario: StripeAccount entity
  Given la classe StripeAccount
  Then elle a les champs: userId, stripeAccountId, chargesEnabled, payoutsEnabled, onboardingComplete
  And elle a une methode fromJson factory
  And elle a une methode copyWith

Scenario: Purchase entity
  Given la classe Purchase
  Then elle a les champs: id, userId, productType, amountCents, status, etc.
  And elle a une methode fromJson factory
  And elle a une enum PurchaseStatus

Scenario: StripeRepository
  Given le StripeRepository
  Then il a une methode getStripeAccount(userId)
  Then il a une methode getPurchases(userId)
  Then il a une methode getPurchase(id)
  Then il a une methode getSales(sellerId)
```

**Fichiers a creer** :
- `lib/features/payments/domain/entities/stripe_account.dart`
- `lib/features/payments/domain/entities/purchase.dart`
- `lib/features/payments/domain/entities/purchase_status.dart`
- `lib/features/payments/domain/repositories/stripe_repository.dart`
- `lib/features/payments/data/repositories/supabase_stripe_repository.dart`
- `lib/features/payments/data/datasources/stripe_datasource.dart`

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Webhook rate limits Stripe | Perte d'events | Idempotency + retry logic |
| Signature verification fail | Securite | Tests exhaustifs |
| Disputes mal gerees | Pertes financieres | Notifications admin + process clair |
| Commission mal calculee | Mecontentement sellers | Tests unitaires + validation |

---

## Securite

### Verification Signature Obligatoire

**TOUJOURS** verifier la signature webhook avant traitement :
```typescript
try {
  event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
} catch (err) {
  return new Response("Invalid signature", { status: 400 });
}
```

### Service Role pour Updates

Les tables `stripe_events` et updates sensibles de `purchases` utilisent `service_role` :
- Pas de policy UPDATE pour les utilisateurs normaux
- Edge Function utilise SUPABASE_SERVICE_ROLE_KEY

### Logs d'Audit

**TOUS** les events sont logges dans `stripe_events` avec :
- Payload complet
- Timestamp
- Status de traitement
- Erreurs eventuelles

---

## Tests

### Tests Unitaires Dart
- StripeAccount.fromJson()
- Purchase.fromJson()
- PurchaseStatus enum
- Commission calculation

### Tests Integration
- Webhook signature verification
- Idempotency (meme event 2x)
- Chaque type d'event

### Tests End-to-End (Mode Test Stripe)
- Checkout complet
- Onboarding Connect
- Dispute flow

---

## Checklist Finale

- [ ] Tables creees avec migrations
- [ ] RLS policies actives
- [ ] Edge Function deployee
- [ ] Webhook endpoint configure dans Stripe Dashboard
- [ ] Tous les handlers implementes
- [ ] Entites Dart creees
- [ ] Tests passes
- [ ] 0 warnings flutter analyze
- [ ] Documentation a jour
