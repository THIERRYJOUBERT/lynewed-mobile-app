# Story S03: Create marketplace_offers table

## Description
En tant que developpeur backend, je veux creer la table marketplace_offers dans Supabase, afin de gerer les offres d'achat avec expiration automatique apres 48h.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_offers is applied Then table marketplace_offers should exist with all required columns
- [ ] Given an offer created 48 hours ago with status 'pending' When checking offer status Then offer should be considered expired And the expire_marketplace_offers() function should update status to 'expired'
- [ ] Given a buyer with offers on multiple listings When the buyer queries marketplace_offers Then only their own offers should be returned (RLS)
- [ ] Given a seller with listings receiving offers When the seller queries marketplace_offers Then offers on their listings should be returned And offers on other listings should not be visible (RLS)
- [ ] Given a pending offer When buyer tries to withdraw Then status should change to 'withdrawn' only if it was 'pending'
- [ ] Given a pending offer When seller accepts Then status should change to 'accepted' And responded_at should be set

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128100003_create_marketplace_offers.sql` - Migration principale
- `supabase/migrations/20260128100003_create_marketplace_offers_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL
```sql
CREATE TABLE marketplace_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,

  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  message TEXT,

  status VARCHAR(20) DEFAULT 'pending' NOT NULL
    CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'withdrawn')),

  expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '48 hours') NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  responded_at TIMESTAMP
);
```

### Function expire_marketplace_offers()
```sql
CREATE OR REPLACE FUNCTION expire_marketplace_offers()
RETURNS INTEGER AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  UPDATE marketplace_offers
  SET status = 'expired'
  WHERE status = 'pending' AND expires_at < NOW();
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  RETURN expired_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### RLS Policies (5 policies)
1. Buyer sees own offers
2. Seller sees listing offers
3. Buyer creates offers (can't offer on own listing)
4. Buyer withdraws offers
5. Seller responds to offers

### Cron job requis
- Appeler `expire_marketplace_offers()` toutes les heures via pg_cron ou Edge Function scheduled

## Definition of Done
- [ ] Migration appliquee avec succes
- [ ] Function expire_marketplace_offers() fonctionne
- [ ] 5 RLS policies actives
- [ ] Cron job configure
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (marketplace_listings table)

## Stories Dependantes
- S04 (marketplace_transactions - offer_id reference)
- S19 (systeme d'offres frontend)
