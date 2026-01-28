# Story S01: Creer table stripe_accounts

## Description
En tant que developpeur, je veux creer la table `stripe_accounts` pour stocker les comptes Stripe Connect des vendeuses, afin de permettre l'onboarding et le suivi des comptes marchands.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la base de donnees Supabase When j'applique la migration Then la table stripe_accounts existe avec toutes les colonnes definies
- [ ] Given la table stripe_accounts When j'inspecte la structure Then user_id est PRIMARY KEY et reference profiles(id)
- [ ] Given la table stripe_accounts When j'inspecte la structure Then stripe_account_id est UNIQUE et NOT NULL
- [ ] Given la table stripe_accounts When j'inspecte la structure Then account_type a une contrainte CHECK ('express', 'standard', 'custom')
- [ ] Given la table stripe_accounts When j'inspecte les index Then idx_stripe_accounts_stripe_id existe sur stripe_account_id
- [ ] Given RLS active sur stripe_accounts When un utilisateur authentifie fait SELECT Then il voit uniquement son propre compte (user_id = auth.uid())
- [ ] Given RLS active sur stripe_accounts When un utilisateur tente de voir un autre compte Then le resultat est vide
- [ ] Given RLS active sur stripe_accounts When un utilisateur fait INSERT Then il peut creer uniquement son propre compte (user_id = auth.uid())
- [ ] Given RLS active sur stripe_accounts When un utilisateur fait UPDATE Then la requete est refusee (service_role only)

## Fichiers Concernes

### A Creer
- Migration Supabase: `create_stripe_accounts_table`

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL

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

-- RLS
ALTER TABLE stripe_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User sees own stripe account" ON stripe_accounts
FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "User can create own stripe account" ON stripe_accounts
FOR INSERT WITH CHECK (user_id = auth.uid());
```

### Patterns

- RLS: SELECT/INSERT pour users, UPDATE/DELETE via service_role uniquement
- JSONB pour arrays dynamiques (currently_due, past_due)
- Timestamps avec timezone

## Definition of Done

- [ ] Migration appliquee sur Supabase
- [ ] Table creee avec toutes les colonnes
- [ ] Index cree
- [ ] RLS active et policies creees
- [ ] Tests SQL verifies (SELECT own, SELECT other, INSERT own)
- [ ] `flutter analyze --fatal-infos` passe (si code Dart ajoute)

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

- EPIC-06-PREREQUISITES (patterns RLS communs)

## Stories Dependantes

- S04: Edge Function stripe-webhook (utilise cette table)
- S07: Handler account.updated (met a jour cette table)
- S11: Entites Dart (modele StripeAccount)
