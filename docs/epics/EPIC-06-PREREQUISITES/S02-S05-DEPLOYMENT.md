# Déploiement Production - Stories S02-S05 (EPIC-06-PREREQUISITES)

> **Date de déploiement:** 2026-01-29  
> **Environnement:** Production (Projet: LYNEWED-V1-APP, ID: hekyovgnovhfhmkpfrna)  
> **Statut:** ✅ Terminé avec succès  
> **Responsable:** Claude

---

## Résumé

Ce document résume le déploiement en production des stories S02, S03, S04 et S05 de l'EPIC-06-PREREQUISITES. Ces migrations établissent les fondations techniques pour le système d'invitation des invités aux mariages.

---

## Contexte

L'EPIC-06-PREREQUISITES prépare l'infrastructure technique nécessaire aux fonctionnalités d'invitation de guests (EPIC-09-INVITATIONS et APP-03). Ces stories créent :
- La structure de données pour les codes d'invitation
- La protection contre le bruteforce
- Le cycle de vie des invitations

---

## Décisions Techniques (D-15)

Les décisions suivantes ont guidé l'implémentation :

| Décision | Valeur | Justification |
|----------|--------|---------------|
| Longueur code invitation | 8 caractères | Sécurité anti-bruteforce : 32⁸ = 1.1 trillion de combinaisons |
| Expiration code | 30 jours | Balance sécurité/UX - régénération possible par la mariée |
| Alphabet | 32 caractères | Exclusion de I, O, 0, 1 pour éviter confusion visuelle |
| Rate limiting | 5 tentatives / 15 min | Protection bruteforce configurable |
| Accès invitation_attempts | service_role uniquement | Edge Functions uniquement, aucun accès direct client |

---

## Changements Effectués

### S02: Ajouter colonnes invitation à weddings

**Migration:** `20260129000002_add_wedding_invite_columns`

| Élément | Description |
|---------|-------------|
| `invite_code` | VARCHAR(8) UNIQUE, NULL autorisé |
| `invite_code_expires_at` | TIMESTAMP, NULL autorisé |
| `idx_weddings_invite_code` | Index partiel WHERE invite_code IS NOT NULL |

**Impact:** Les weddings existants conservent des valeurs NULL. Les nouveaux weddings reçoivent un code automatiquement (via trigger S04).

---

### S03: Créer table invitation_attempts

**Migration:** `20260129000003_create_invitation_attempts`

**Structure de la table:**
```
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
ip_address      VARCHAR(50) NOT NULL
attempted_at    TIMESTAMP DEFAULT NOW() NOT NULL
success         BOOLEAN DEFAULT FALSE NOT NULL
code_attempted  VARCHAR(8)
user_agent      TEXT
created_at      TIMESTAMP DEFAULT NOW() NOT NULL
```

**Indexes créés:**
- `idx_invitation_attempts_ip_time` : Pour requêtes de rate limiting (IP + time window)
- `idx_invitation_attempts_created` : Pour nettoyage des vieux enregistrements

**Fonction créée:**
```sql
check_invitation_rate_limit(
  p_ip_address VARCHAR(50),
  p_max_attempts INTEGER DEFAULT 5,
  p_window_minutes INTEGER DEFAULT 15
) RETURNS BOOLEAN
```

**Sécurité:**
- RLS activée
- Aucune policy publique
- Accès uniquement via `service_role` (Edge Functions)

---

### S04: Créer fonction generate_secure_invite_code

**Migration:** `20260129000004_create_generate_invite_code`

**Fonctions créées:**

| Fonction | Type | Description |
|----------|------|-------------|
| `generate_invite_code_value()` | Générateur | Génère code 8 chars aléatoire (alphabet 32 chars) |
| `generate_secure_invite_code()` | Trigger | Fonction trigger avec retry loop (max 10 tentatives) |
| `regenerate_wedding_invite_code(p_wedding_id UUID)` | Utility | Regénère code pour wedding existant |

**Trigger créé:**
```sql
trg_generate_invite_code
  BEFORE INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION generate_secure_invite_code()
```

**Caractéristiques:**
- Expiration automatique : NOW() + 30 days
- Boucle de retry pour garantir l'unicité
- Gestion des collisions (max 10 tentatives avant erreur)

---

### S05: Ajouter colonnes invitation à wedding_guests

**Migration:** `20260129000005_add_guest_invitation_columns`

**Colonnes ajoutées:**

| Colonne | Type | Description |
|---------|------|-------------|
| `user_id` | UUID (FK profiles.id) | Lien vers le profil quand le guest crée un compte |
| `invited_at` | TIMESTAMP | Date d'envoi de l'invitation |
| `joined_at` | TIMESTAMP | Date de rejoindre le wedding |
| `status` | VARCHAR(20) DEFAULT 'pending' | Statut de l'invitation |

**Contrainte créée:**
```sql
chk_guest_status CHECK (status IN ('pending', 'invited', 'joined', 'declined'))
```

**Indexes créés:**
- `idx_wedding_guests_wedding_status` : Requêtes fréquentes par wedding + status
- `idx_wedding_guests_user_id` : Recherche de guest par user_id (partiel WHERE NOT NULL)

**Cycle de vie des statuts:**
```
pending -> invited -> joined
               \
                -> declined
```

---

## Vérifications Réalisées en Production

### Vérifications S02 (weddings)
- ✅ Colonnes `invite_code` et `invite_code_expires_at` existent
- ✅ Contrainte UNIQUE sur `invite_code` fonctionne
- ✅ Index `idx_weddings_invite_code` créé et utilisé
- ✅ Weddings existants non affectés (colonnes NULL)

### Vérifications S03 (invitation_attempts)
- ✅ Table créée avec structure correcte
- ✅ Index `idx_invitation_attempts_ip_time` créé
- ✅ Index `idx_invitation_attempts_created` créé
- ✅ Fonction `check_invitation_rate_limit` fonctionne
- ✅ RLS activée, aucune policy publique

### Vérifications S04 (trigger)
- ✅ Fonction `generate_invite_code_value` fonctionne
- ✅ Fonction `generate_secure_invite_code` fonctionne
- ✅ Trigger `trg_generate_invite_code` actif
- ✅ Fonction `regenerate_wedding_invite_code` fonctionne
- ✅ Test : INSERT génère automatiquement un code unique
- ✅ Test : Expiration = NOW() + 30 jours

### Vérifications S05 (wedding_guests)
- ✅ Colonnes `user_id`, `invited_at`, `joined_at`, `status` existent
- ✅ Contrainte `chk_guest_status` fonctionne
- ✅ Index `idx_wedding_guests_wedding_status` créé
- ✅ Index `idx_wedding_guests_user_id` créé
- ✅ Guests existants ont `status = 'pending'` par défaut

---

## Dépendances entre Stories

```
S02 (colonnes weddings invite)
  |
  +---> S04 (trigger generate_invite_code)

S03 (invitation_attempts) --- INDÉPENDANT

S05 (colonnes wedding_guests) --- INDÉPENDANT (mais lié au flow S01)
```

**Note:** S01 (enum userRole avec 'guest') est un prérequis logique pour la cohérence du flow mais n'est pas une dépendance technique stricte pour ces migrations.

---

## Commandes SQL de Vérification

```sql
-- Vérifier colonnes weddings (S02)
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'weddings' 
AND column_name IN ('invite_code', 'invite_code_expires_at');

-- Vérifier index (S02)
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'weddings' 
AND indexname = 'idx_weddings_invite_code';

-- Vérifier table invitation_attempts (S03)
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'invitation_attempts';

-- Vérifier trigger (S04)
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trg_generate_invite_code';

-- Vérifier fonctions (S04)
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name IN (
  'generate_invite_code_value',
  'generate_secure_invite_code', 
  'regenerate_wedding_invite_code',
  'check_invitation_rate_limit'
);

-- Vérifier colonnes wedding_guests (S05)
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'wedding_guests'
AND column_name IN ('user_id', 'invited_at', 'joined_at', 'status');

-- Vérifier constraint (S05)
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'wedding_guests'
AND constraint_name = 'chk_guest_status';
```

---

## Rollback (si nécessaire)

En cas de problème, l'ordre de rollback inverse est :

```sql
-- S05 rollback
DROP INDEX IF EXISTS idx_wedding_guests_user_id;
DROP INDEX IF EXISTS idx_wedding_guests_wedding_status;
ALTER TABLE wedding_guests DROP CONSTRAINT IF EXISTS chk_guest_status;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS status;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS joined_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS invited_at;
ALTER TABLE wedding_guests DROP COLUMN IF EXISTS user_id;

-- S04 rollback
DROP TRIGGER IF EXISTS trg_generate_invite_code ON weddings;
DROP FUNCTION IF EXISTS regenerate_wedding_invite_code;
DROP FUNCTION IF EXISTS generate_secure_invite_code;
DROP FUNCTION IF EXISTS generate_invite_code_value;

-- S03 rollback
DROP FUNCTION IF EXISTS check_invitation_rate_limit;
DROP INDEX IF EXISTS idx_invitation_attempts_created;
DROP INDEX IF EXISTS idx_invitation_attempts_ip_time;
DROP TABLE IF EXISTS invitation_attempts;

-- S02 rollback
DROP INDEX IF EXISTS idx_weddings_invite_code;
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code_expires_at;
ALTER TABLE weddings DROP COLUMN IF EXISTS invite_code;
```

---

## Notes

- **Aucune donnée existante n'a été modifiée** lors de ces migrations
- Les colonnes ajoutées sont toutes `NULLABLE` avec des valeurs par défaut appropriées
- Les codes d'invitation ne sont générés que pour les **nouveaux** weddings (via trigger)
- Les weddings existants peuvent recevoir un code via `regenerate_wedding_invite_code(wedding_id)`
- Le rate limiting (S03) est prêt à être utilisé par les Edge Functions (APP-03)

---

## Références

- **Epic:** [EPIC-06-PREREQUISITES.md](./EPIC-06-PREREQUISITES.md)
- **Tracking:** [TRACKING.md](./TRACKING.md)
- **Story S02:** [stories/S02-add-wedding-invite-columns.md](./stories/S02-add-wedding-invite-columns.md)
- **Story S03:** [stories/S03-create-invitation-attempts-table.md](./stories/S03-create-invitation-attempts-table.md)
- **Story S04:** [stories/S04-create-generate-invite-code-function.md](./stories/S04-create-generate-invite-code-function.md)
- **Story S05:** [stories/S05-add-wedding-guests-invitation-columns.md](./stories/S05-add-wedding-guests-invitation-columns.md)
