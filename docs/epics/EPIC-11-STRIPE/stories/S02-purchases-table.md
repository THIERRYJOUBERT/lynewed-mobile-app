# Story S02: Creer table purchases

## Description
En tant que developpeur, je veux creer la table `purchases` pour tracker tous les achats (marketplace, reels, albums, etc.), afin de gerer les transactions et les paiements avec commission.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la base de donnees Supabase When j'applique la migration Then la table purchases existe avec toutes les colonnes
- [ ] Given la table purchases When j'inspecte la structure Then id est UUID PRIMARY KEY avec gen_random_uuid()
- [ ] Given la table purchases When j'inspecte la structure Then user_id reference profiles(id) et est NOT NULL
- [ ] Given la table purchases When j'inspecte la structure Then product_type a CHECK ('marketplace_item', 'reel', 'album', 'print', 'subscription')
- [ ] Given la table purchases When j'inspecte la structure Then amount_cents a CHECK (amount_cents > 0)
- [ ] Given la table purchases When j'inspecte la structure Then status a CHECK avec tous les statuts possibles
- [ ] Given les index When j'inspecte la table Then tous les index de performance sont crees (user_id, seller_id, status, stripe_pi, stripe_cs, product)
- [ ] Given RLS active sur purchases When un buyer fait SELECT Then il voit ses propres achats (user_id = auth.uid())
- [ ] Given RLS active sur purchases When un seller fait SELECT Then il voit les ventes de ses produits (seller_id = auth.uid())
- [ ] Given RLS active sur purchases When un utilisateur fait INSERT/UPDATE Then la requete est refusee (service_role only)
- [ ] Given un achat marketplace avec amount=10000 When la logique de commission est appliquee Then platform_fee=1000 (10%) et seller_amount=9000

## Fichiers Concernes

### A Creer
- Migration Supabase: `create_purchases_table`

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL

```sql
-- Achats (marketplace, reels, albums, prints futurs)
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,

  -- Type de produit
  product_type VARCHAR(50) NOT NULL CHECK (product_type IN ('marketplace_item', 'reel', 'album', 'print', 'subscription')),
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

-- RLS
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyer sees own purchases" ON purchases
FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Seller sees sales" ON purchases
FOR SELECT USING (seller_id = auth.uid());
```

### Calcul Commission (10%)

La commission est calculee dans l'Edge Function lors de la creation d'achat:
```typescript
const platformFeeCents = Math.floor(amountCents * 0.10);
const sellerAmountCents = amountCents - platformFeeCents;
```

### Patterns

- Index partiels (WHERE clause) pour optimiser les lookups Stripe
- Double RLS policy pour buyer et seller
- Pas d'INSERT/UPDATE public (service_role via webhooks)

## Definition of Done

- [ ] Migration appliquee sur Supabase
- [ ] Table creee avec toutes les colonnes et contraintes
- [ ] Tous les index crees
- [ ] RLS active avec policies buyer et seller
- [ ] Tests SQL verifies
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- EPIC-06-PREREQUISITES (patterns RLS)
- S01: stripe_accounts (seller_id peut etre dans stripe_accounts)

## Stories Dependantes

- S04: Edge Function stripe-webhook (cree/met a jour purchases)
- S05: Handlers payment_intent (met a jour purchases)
- S06: Handlers checkout.session (cree purchases)
- S11: Entites Dart (modele Purchase)
