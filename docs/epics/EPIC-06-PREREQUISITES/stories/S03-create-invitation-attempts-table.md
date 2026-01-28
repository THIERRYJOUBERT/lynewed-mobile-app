# Story S03: Create invitation_attempts Table for Rate Limiting

## Description
En tant que **systeme**, je veux **creer une table invitation_attempts pour tracer les tentatives d'utilisation de codes d'invitation**, afin de **prevenir les attaques par brute force sur les codes d'invitation (Decision D-15)**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema When the migration create_invitation_attempts is applied Then table invitation_attempts should exist And it should have columns: id, ip_address, attempted_at, success, code_attempted, user_agent, created_at
- [ ] Given the invitation_attempts table exists When querying attempts by IP in the last 15 minutes Then the query should use index idx_invitation_attempts_ip_time And the query should be performant (< 10ms for 10K rows)
- [ ] Given a user authenticated with anon key When they try to SELECT from invitation_attempts Then they should receive 0 rows (RLS blocks access)
- [ ] Given 5 failed attempts from IP 192.168.1.1 in the last 15 minutes When check_invitation_rate_limit is called for that IP Then the function should return TRUE (rate limited)
- [ ] Given 3 failed attempts from IP 192.168.1.1 in the last 15 minutes When check_invitation_rate_limit is called for that IP Then the function should return FALSE (not rate limited)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000003_create_invitation_attempts.sql`

### A Modifier
- Aucun fichier Dart (table utilisee uniquement via Edge Functions)

## Notes Techniques

**Migration SQL:**
```sql
CREATE TABLE IF NOT EXISTS invitation_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_address VARCHAR(50) NOT NULL,
  attempted_at TIMESTAMP DEFAULT NOW() NOT NULL,
  success BOOLEAN DEFAULT FALSE NOT NULL,
  code_attempted VARCHAR(8),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Index for rate limiting queries (IP + time window)
CREATE INDEX IF NOT EXISTS idx_invitation_attempts_ip_time
  ON invitation_attempts(ip_address, attempted_at DESC);

-- Index for cleanup of old records
CREATE INDEX IF NOT EXISTS idx_invitation_attempts_created
  ON invitation_attempts(created_at);

-- Enable RLS (no public access)
ALTER TABLE invitation_attempts ENABLE ROW LEVEL SECURITY;

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_invitation_rate_limit(
  p_ip_address VARCHAR(50),
  p_max_attempts INTEGER DEFAULT 5,
  p_window_minutes INTEGER DEFAULT 15
)
RETURNS BOOLEAN AS $$
DECLARE
  attempt_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO attempt_count
  FROM invitation_attempts
  WHERE ip_address = p_ip_address
    AND attempted_at > NOW() - (p_window_minutes || ' minutes')::INTERVAL
    AND success = FALSE;

  RETURN attempt_count >= p_max_attempts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Rollback SQL:**
```sql
DROP FUNCTION IF EXISTS check_invitation_rate_limit;
DROP INDEX IF EXISTS idx_invitation_attempts_created;
DROP INDEX IF EXISTS idx_invitation_attempts_ip_time;
DROP TABLE IF EXISTS invitation_attempts;
```

**Securite:**
- Table accessible uniquement via service_role (Edge Functions)
- Pas de policy publique = aucun utilisateur ne peut lire/ecrire directement
- Rate limit configurable: 5 tentatives / 15 minutes par defaut

## Definition of Done

- [ ] Table invitation_attempts creee avec succes
- [ ] Index idx_invitation_attempts_ip_time cree
- [ ] Index idx_invitation_attempts_created cree
- [ ] RLS activee (aucune policy publique)
- [ ] Fonction check_invitation_rate_limit fonctionne correctement
- [ ] Test rate limit: 5 echecs en 15min = TRUE
- [ ] Test rate limit: 3 echecs en 15min = FALSE
- [ ] `flutter analyze --fatal-infos` passe (aucun changement Dart)

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible (nouvelle table sans impact sur existant)

## Dependances

- Aucune (story independante)

## Stories Dependantes

- Aucune directement (sera utilisee par APP-03 Edge Functions)
