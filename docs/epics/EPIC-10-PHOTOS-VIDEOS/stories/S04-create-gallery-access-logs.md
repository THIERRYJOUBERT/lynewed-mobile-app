# Story S04: Creer table gallery_access_logs

## Description
En tant que **administrateur systeme**, je veux **enregistrer tous les acces a la galerie (vue, telechargement, partage)**, afin de **avoir une tracabilite complete pour la conformite et l'audit de securite**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema When the migration create_gallery_access_logs is applied Then table gallery_access_logs should exist with columns: id, wedding_id, accessed_by, access_type, media_id, ip_address, user_agent, created_at
- [ ] Given a user views media in a wedding gallery When the access is logged Then a row should be inserted with access_type = 'view' And accessed_by should contain the user's profile_id
- [ ] Given a user downloads media When the access is logged Then a row should be inserted with access_type = 'download'
- [ ] Given a user downloads multiple files as zip When the access is logged Then a row should be inserted with access_type = 'download_zip'
- [ ] Given a guest toggles shared_with_bride to TRUE When the action is logged Then a row should be inserted with access_type = 'share_enabled'
- [ ] Given a guest toggles shared_with_bride to FALSE When the action is logged Then a row should be inserted with access_type = 'share_disabled'
- [ ] Given a user authenticated with anon key When they try to SELECT from gallery_access_logs Then they should receive 0 rows (RLS blocks access)

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260128100004_create_gallery_access_logs`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100004_create_gallery_access_logs
-- Description: Create audit log table for gallery access traceability

CREATE TABLE IF NOT EXISTS gallery_access_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id),
  accessed_by UUID REFERENCES profiles(id),
  access_type VARCHAR(50) NOT NULL,
  media_id UUID, -- Optional: specific media accessed
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Constraint for valid access types
  CONSTRAINT chk_access_type CHECK (
    access_type IN ('view', 'download', 'download_zip', 'share_enabled', 'share_disabled')
  )
);

-- Index for queries by wedding
CREATE INDEX IF NOT EXISTS idx_gallery_logs_wedding
  ON gallery_access_logs(wedding_id, created_at DESC);

-- Index for queries by user
CREATE INDEX IF NOT EXISTS idx_gallery_logs_user
  ON gallery_access_logs(accessed_by, created_at DESC);

-- Index for cleanup of old logs
CREATE INDEX IF NOT EXISTS idx_gallery_logs_created
  ON gallery_access_logs(created_at);

-- Enable RLS
ALTER TABLE gallery_access_logs ENABLE ROW LEVEL SECURITY;

-- No public policies - only service_role can access
-- Logs are written by Edge Functions using service_role

-- Comments
COMMENT ON TABLE gallery_access_logs IS 'Audit log for gallery access (view, download, share toggle)';
COMMENT ON COLUMN gallery_access_logs.access_type IS 'Type of access: view, download, download_zip, share_enabled, share_disabled';
COMMENT ON COLUMN gallery_access_logs.media_id IS 'Optional: UUID of specific media accessed (for single view/download)';
```

### Rollback SQL
```sql
DROP INDEX IF EXISTS idx_gallery_logs_created;
DROP INDEX IF EXISTS idx_gallery_logs_user;
DROP INDEX IF EXISTS idx_gallery_logs_wedding;
DROP TABLE IF EXISTS gallery_access_logs;
```

### Types d'acces supportes
| Type | Description |
|------|-------------|
| `view` | Visualisation d'un media |
| `download` | Telechargement d'un seul fichier |
| `download_zip` | Telechargement de plusieurs fichiers (zip) |
| `share_enabled` | Guest active le partage avec bride |
| `share_disabled` | Guest desactive le partage avec bride |

### Securite
- **RLS stricte**: Aucune policy publique
- **service_role uniquement**: Seules les Edge Functions peuvent ecrire/lire
- **Pas d'acces client**: Les logs sont invisibles pour les utilisateurs finaux

### Usage depuis Edge Function
```typescript
// Exemple: Logger un acces depuis une Edge Function
const { error } = await supabase
  .from('gallery_access_logs')
  .insert({
    wedding_id: weddingId,
    accessed_by: userId,
    access_type: 'download',
    media_id: mediaId,
    ip_address: request.headers.get('x-forwarded-for'),
    user_agent: request.headers.get('user-agent')
  });
```

## Definition of Done
- [ ] Table gallery_access_logs creee
- [ ] Contrainte CHECK sur access_type active
- [ ] RLS activee (aucune policy publique)
- [ ] Index crees pour queries performantes
- [ ] Test: user normal ne peut pas SELECT
- [ ] Test: service_role peut INSERT/SELECT
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune (independante des autres stories)

## Stories Dependantes
- S07 (Toggle shared_with_bride - log share_enabled/share_disabled)
- S09 (Telechargement - log download/download_zip)
