# Story S06: Create fedex_events table

## Description
En tant que developpeur backend, je veux creer la table fedex_events dans Supabase, afin de logger tous les evenements de tracking FedEx avec audit complet.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_transactions table exists When the migration create_fedex_events is applied Then table fedex_events should exist with columns for tracking_number, event_type, event_description, location, event_timestamp, raw_payload
- [ ] Given a transaction with tracking When FedEx reports picked_up, in_transit, out_for_delivery, delivered Then each event should be logged with full details And raw webhook payload should be preserved as JSONB
- [ ] Given FedEx events for a transaction When the buyer queries Then they should see events When the seller queries Then they should see events When other user queries Then access should be denied (RLS)
- [ ] Given an event with location details Then location_city and location_country should be extracted from the payload

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128100006_create_fedex_events.sql` - Migration principale
- `supabase/migrations/20260128100006_create_fedex_events_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL
```sql
CREATE TABLE fedex_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES marketplace_transactions(id),
  tracking_number VARCHAR(255),

  -- Event details
  event_type VARCHAR(100) NOT NULL,
  event_description TEXT,
  event_code VARCHAR(50),
  location TEXT,
  location_city VARCHAR(255),
  location_country VARCHAR(100),

  -- FedEx timestamp
  event_timestamp TIMESTAMP,

  -- Raw payload for debugging
  raw_payload JSONB,

  -- When we processed this
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);
```

### Indexes
```sql
CREATE INDEX idx_fedex_events_transaction ON fedex_events(transaction_id, event_timestamp DESC);
CREATE INDEX idx_fedex_events_tracking ON fedex_events(tracking_number, event_timestamp DESC);
CREATE INDEX idx_fedex_events_type ON fedex_events(event_type);
```

### RLS Policies
- Transaction parties view events (via JOIN on marketplace_transactions)
- Inserts via service_role (Edge Functions)

### Event types attendus
- label_created
- picked_up
- in_transit
- out_for_delivery
- delivered
- exception
- returned

## Definition of Done
- [ ] Migration appliquee avec succes
- [ ] Indexes crees
- [ ] RLS policy active
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S04 (marketplace_transactions table)

## Stories Dependantes
- S13 (FedEx Track API)
- S22 (tracking colis frontend)
