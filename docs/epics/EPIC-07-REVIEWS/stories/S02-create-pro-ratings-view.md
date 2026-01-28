# Story S02: Create pro_ratings view for average calculation

## Description
En tant que developpeur backend, je veux creer une vue SQL `pro_ratings` qui calcule automatiquement la moyenne et le nombre d'avis par professionnel, afin de pouvoir afficher facilement les statistiques de notation.

## Criteres d'Acceptance (Gherkin)
- [ ] Given pro-A has reviews with ratings [5, 4, 4, 5] When selecting from pro_ratings where pro_id = pro-A Then average_rating should be 4.5 And review_count should be 4
- [ ] Given pro-B has one review with rating 3 When selecting from pro_ratings where pro_id = pro-B Then average_rating should be 3.0 And review_count should be 1
- [ ] Given pro-C has no reviews When selecting from pro_ratings where pro_id = pro-C Then no row should be returned
- [ ] Given pro-D has reviews with ratings [5, 5, 4] When selecting from pro_ratings where pro_id = pro-D Then average_rating should be 4.7 (rounded to 1 decimal) And review_count should be 3
- [ ] Given pro-E has average_rating 4.0 from 2 reviews When a new 5-star review is added for pro-E Then average_rating should become 4.3 And review_count should become 3

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100002_create_pro_ratings_view`

### A Modifier
- Aucun

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100002_create_pro_ratings_view
-- Description: Create view for aggregated professional ratings
-- Source: MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

-- Create view for professional ratings aggregation
CREATE OR REPLACE VIEW pro_ratings AS
SELECT
  pro_id,
  ROUND(AVG(rating)::NUMERIC, 1) AS average_rating,
  COUNT(*)::INTEGER AS review_count
FROM reviews
GROUP BY pro_id;

-- Comment for documentation
COMMENT ON VIEW pro_ratings IS 'Aggregated ratings per professional (average + count)';
```

### Rollback SQL
```sql
DROP VIEW IF EXISTS pro_ratings;
```

### Considerations de Performance
- Vue simple (pas materialisee) pour MVP - donnees toujours a jour
- Si besoin de performance future: considerer `MATERIALIZED VIEW` avec refresh periodique
- Index sur reviews.pro_id (cree en S01) optimise les aggregations

## Definition of Done
- [ ] Migration appliquee via Supabase MCP
- [ ] Vue pro_ratings existe
- [ ] Colonne average_rating retourne NUMERIC(2,1)
- [ ] Colonne review_count retourne INTEGER
- [ ] Tests manuels SQL passes avec donnees de test
- [ ] Performance acceptable (<50ms pour requete)

## Estimation
**Points** : 1
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01: Table reviews must exist

## Stories Dependantes
- S05: Repository implementation (queries this view)
- S07: UI display (uses ProRating data)
- S09: Map filter by rating (filters using this view)
