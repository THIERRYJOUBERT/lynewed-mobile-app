# Story S03: Creer table stripe_events (audit complet)

## Description
En tant que developpeur, je veux creer la table `stripe_events` pour logger tous les webhooks Stripe avec payload complet, afin d'assurer l'audit, l'idempotency et le debugging.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la base de donnees Supabase When j'applique la migration Then la table stripe_events existe avec toutes les colonnes
- [ ] Given la table stripe_events When j'inspecte la structure Then id est UUID PRIMARY KEY avec gen_random_uuid()
- [ ] Given la table stripe_events When j'inspecte la structure Then stripe_event_id est VARCHAR(255) UNIQUE NOT NULL
- [ ] Given la table stripe_events When j'inspecte la structure Then payload est de type JSONB NOT NULL
- [ ] Given la table stripe_events When j'inspecte la structure Then processed est BOOLEAN DEFAULT FALSE
- [ ] Given les index When j'inspecte la table Then idx_stripe_events_type existe sur event_type
- [ ] Given les index When j'inspecte la table Then idx_stripe_events_unprocessed existe (partial index WHERE processed = FALSE)
- [ ] Given les index When j'inspecte la table Then idx_stripe_events_stripe_id existe sur stripe_event_id
- [ ] Given un event avec stripe_event_id="evt_123" When le meme event est insere via UPSERT Then il n'y a qu'une seule ligne (pas d'erreur duplicate)
- [ ] Given RLS active sur stripe_events When un utilisateur authentifie fait SELECT Then le resultat est vide (aucun acces public)
- [ ] Given RLS active sur stripe_events When service_role fait SELECT Then tous les events sont visibles

## Fichiers Concernes

### A Creer
- Migration Supabase: `create_stripe_events_table`

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL

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

-- RLS - AUCUN acces public
ALTER TABLE stripe_events ENABLE ROW LEVEL SECURITY;
-- Pas de policy = service_role uniquement
```

### Idempotency Pattern

L'UPSERT sur stripe_event_id garantit qu'un event n'est jamais duplique:
```typescript
await supabase
  .from("stripe_events")
  .upsert({
    stripe_event_id: event.id,
    // ...
  }, { onConflict: "stripe_event_id" });
```

### Securite

- **AUCUNE policy publique** : Les events sont sensibles (contiennent des donnees de paiement)
- Acces uniquement via service_role (Edge Functions)
- Utile pour debugging et audit post-incident

### Patterns

- Index partiel pour les events non traites (optimise les retries)
- processing_attempts pour dead letter handling
- livemode pour distinguer test/prod

## Definition of Done

- [ ] Migration appliquee sur Supabase
- [ ] Table creee avec toutes les colonnes
- [ ] Tous les index crees (dont index partiel)
- [ ] RLS active SANS policy publique
- [ ] Test UPSERT idempotency verifie
- [ ] Test acces refuse pour users normaux
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

- EPIC-06-PREREQUISITES (patterns)

## Stories Dependantes

- S04: Edge Function stripe-webhook (log tous les events dans cette table)
- S05-S10: Tous les handlers (utilisent cette table pour idempotency)
