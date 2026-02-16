# RAPPORT DE REVIEW - S02 (Round 2)

> **Story** : S02 - Fix invite codes (trigger + backfill)
> **Reviewer** : Claude Senior PostgreSQL Expert
> **Date** : 2026-02-16
> **Round** : 2 (Re-challenge après corrections mineures Round 1)

---

## VERDICT GLOBAL

**Status** : ❌ **BLOQUÉ - PROBLÈMES CRITIQUES IDENTIFIÉS**

**Raison** : La fonction `regenerate_wedding_invite_code` utilisée pour le backfill **N'A PAS de retry logic pour l'unicité**, contrairement à la fonction trigger. Cela peut causer des violations de contrainte UNIQUE lors du backfill.

---

## NOUVEAUX PROBLÈMES IDENTIFIÉS (Round 2)

### 🔴 P-01 : Fonction backfill sans retry logic (CRITIQUE)

**Localisation** : Migration ligne 63-77 + Story Etape 4 ligne 106-112

**Problème** :
La fonction `regenerate_wedding_invite_code(p_wedding_id UUID)` utilisée pour le backfill :
```sql
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();  -- ❌ GÉNÈRE 1 CODE SANS VÉRIFIER UNICITÉ

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
```

**Comparaison avec trigger** (qui A un retry loop) :
```sql
CREATE OR REPLACE FUNCTION generate_secure_invite_code()
RETURNS TRIGGER AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;  -- ✅ RETRY LOGIC
  attempt INTEGER := 0;
BEGIN
  IF NEW.invite_code IS NULL THEN
    LOOP
      new_code := generate_invite_code_value();
      attempt := attempt + 1;

      EXIT WHEN NOT EXISTS (  -- ✅ VÉRIFIE UNICITÉ
        SELECT 1 FROM weddings WHERE invite_code = new_code ...
      );

      IF attempt >= max_attempts THEN
        RAISE EXCEPTION 'Could not generate unique invite code after % attempts', max_attempts;
      END IF;
    END LOOP;
```

**Conséquence** :
- Si `generate_invite_code_value()` retourne un code déjà existant lors du backfill → **ERREUR : duplicate key value violates unique constraint "weddings_invite_code_key"**
- Le backfill DO loop (Etape 4) va crasher à la première collision
- Les mariages suivants ne seront pas traités (backfill partiel)

**Probabilité** :
- Charset: 30 caractères (`ABCDEFGHJKLMNPQRSTUVWXYZ23456789`)
- Espace: 30^8 = 656,100,000 combinaisons
- 7 mariages sans code actuellement en prod
- **Probabilité collision ≈ 0.000001%** MAIS non-nulle → risque INACCEPTABLE en production

**Impact** : BLOQUANT - Le backfill peut échouer en production

---

### 🔴 P-02 : Backfill DO loop sans gestion d'erreur

**Localisation** : Story Etape 4 ligne 106-112

**Code actuel** :
```sql
DO $$ DECLARE w RECORD; BEGIN
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    PERFORM regenerate_wedding_invite_code(w.id);  -- ❌ PAS DE EXCEPTION HANDLER
  END LOOP;
END $$;
```

**Problèmes** :
1. Si `regenerate_wedding_invite_code` échoue (collision) → le DO block entier crashe
2. Aucune transaction explicite → les mariages déjà traités restent avec codes, les autres non
3. Aucun logging des erreurs (impossible de savoir quel mariage a échoué)
4. Pas de ROLLBACK possible (pas de BEGIN/COMMIT englobant)

**Impact** : BLOQUANT - Backfill non-idempotent et non-réparable

---

### 🟡 P-03 : Validation post-backfill incomplète (Round 1 non corrigé)

**Localisation** : Story Etape 5 ligne 115-127

**Code actuel** :
```sql
-- Verify no NULL codes remain
SELECT COUNT(*) AS weddings_without_code FROM weddings WHERE invite_code IS NULL;

-- Verify uniqueness
SELECT invite_code, COUNT(*) AS duplicates FROM weddings
GROUP BY invite_code HAVING COUNT(*) > 1;
```

**Problème** : Ne valide PAS le FORMAT des codes générés.

**Corrections suggérées Round 1 (NON APPLIQUÉES)** :
```sql
-- AC-04 amélioration : Valider FORMAT codes
SELECT id, invite_code
FROM weddings
WHERE invite_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$'
   OR LENGTH(invite_code) != 8;
```

**Impact** : MAJEUR - Si la fonction génère des codes invalides (bug), on ne le détecte pas

---

### 🟡 P-04 : Incohérence dépendances (Round 1 partiellement corrigé)

**Localisation** : Story header ligne 9-10

**Problème** :
```markdown
> **Dependances** : Aucune
> **Stories dependantes** : S05 (Edge Function send-wedding-invitation)
```

**Contradiction** :
- S05 DÉPEND de S02 (a besoin de `invite_code` non-null)
- Donc S02 n'a PAS de dépendances mais S05 en a UNE (S02)

**Correction Round 1 suggérée (NON APPLIQUÉE)** :
```markdown
> **Dependances** : Aucune (peut être fait en premier)
> **Stories dependantes** : S05 (send-wedding-invitation nécessite invite_code)
```

**Impact** : MINEUR - Documentation imprécise mais pas bloquant

---

### 🟢 P-05 : AC-02 ne vérifie pas le trigger (Round 1 non corrigé)

**Localisation** : Story AC-02 ligne 30-34

**Code actuel** :
```gherkin
### AC-02 : Fonctions SQL presentes en production

- [ ] Given the Supabase production database
  When I query `SELECT proname FROM pg_proc WHERE proname IN (...)`
  Then all 3 functions are returned
```

**Problème** : AC-02 s'appelle "Fonctions SQL" mais NE VÉRIFIE PAS le trigger.

**Solution** :
- Soit renommer AC-02 en "Fonctions et trigger présents"
- Soit fusionner AC-01 et AC-02 (trigger + fonctions en 1 AC)

**Impact** : MINEUR - Cosmétique (le trigger est vérifié dans AC-01)

---

## ANALYSE SQL DÉTAILLÉE

### Migration 20260129000004 - Cohérence

**Fonctions créées** :
1. ✅ `generate_invite_code_value()` - Génère code 8 chars (charset correct)
2. ✅ `generate_secure_invite_code()` - Trigger BEFORE INSERT avec retry loop
3. ❌ `regenerate_wedding_invite_code()` - **PROBLÈME CRITIQUE : pas de retry**

**Trigger** :
- ✅ Créé avec `BEFORE INSERT` sur `weddings`
- ✅ Actif en production (`tgenabled = 'O'`)
- ✅ Ligne 56-60 : `DROP IF EXISTS` puis `CREATE TRIGGER`

**Schéma DB** :
- ✅ Colonne `weddings.invite_code` : `VARCHAR`, `NULLABLE`, `UNIQUE`
- ✅ Colonne `weddings.invite_code_expires_at` : `TIMESTAMP`, `NULLABLE`
- ✅ Contrainte UNIQUE existe (confirmé par query pg_catalog)

**État production** :
- 9 mariages totaux
- 2 mariages avec code
- **7 mariages sans code** (à backfiller)

---

## CORRECTIONS OBLIGATOIRES

### 🔴 CORRECTION C-01 : Réécrire regenerate_wedding_invite_code avec retry

**Fichier** : `supabase/migrations/20260129000004_create_generate_invite_code.sql`

**Code actuel (ligne 63-77)** :
```sql
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();
  UPDATE weddings SET invite_code = new_code, ... WHERE id = p_wedding_id;
  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Code corrigé** :
```sql
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;
  attempt INTEGER := 0;
BEGIN
  -- Retry loop pour garantir unicité
  LOOP
    new_code := generate_invite_code_value();
    attempt := attempt + 1;

    -- Vérifier que le code n'existe pas déjà (sauf pour ce mariage)
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM weddings
      WHERE invite_code = new_code
      AND id != p_wedding_id
    );

    IF attempt >= max_attempts THEN
      RAISE EXCEPTION 'Could not generate unique invite code for wedding % after % attempts',
        p_wedding_id, max_attempts;
    END IF;
  END LOOP;

  -- Mettre à jour avec code unique garanti
  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Pourquoi SECURITY DEFINER** :
- Permet à l'owner d'appeler la fonction même sans perms UPDATE sur `weddings`
- Nécessaire si appelé depuis RLS context (bride ne peut pas UPDATE d'autres mariages)

**Action** :
1. Re-appliquer la migration avec fonction corrigée
2. OU créer migration additive `20260216000001_fix_regenerate_invite_code.sql`

---

### 🔴 CORRECTION C-02 : Backfill avec exception handling

**Fichier** : Story S02, Etape 4

**Code actuel (ligne 106-112)** :
```sql
DO $$ DECLARE w RECORD; BEGIN
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    PERFORM regenerate_wedding_invite_code(w.id);
  END LOOP;
END $$;
```

**Code corrigé** :
```sql
DO $$
DECLARE
  w RECORD;
  success_count INTEGER := 0;
  error_count INTEGER := 0;
BEGIN
  -- Transaction explicite pour tout-ou-rien
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    BEGIN
      PERFORM regenerate_wedding_invite_code(w.id);
      success_count := success_count + 1;
      RAISE NOTICE 'Wedding % : code generated successfully', w.id;
    EXCEPTION WHEN OTHERS THEN
      error_count := error_count + 1;
      RAISE WARNING 'Wedding % : FAILED - %', w.id, SQLERRM;
      -- Continue loop (pas de RAISE pour ne pas crasher tout le backfill)
    END;
  END LOOP;

  -- Rapport final
  RAISE NOTICE 'Backfill completed: % success, % errors', success_count, error_count;

  -- Fail si au moins 1 erreur
  IF error_count > 0 THEN
    RAISE EXCEPTION 'Backfill incomplete: % weddings failed', error_count;
  END IF;
END $$;
```

**Avantages** :
- ✅ Continue même si 1 mariage échoue
- ✅ Logging explicite (NOTICE + WARNING)
- ✅ Fail global si au moins 1 erreur (force investigation)
- ✅ Rapport compteurs final

**Alternative (tout-ou-rien strict)** :
```sql
BEGIN; -- Transaction explicite
  DO $$ DECLARE w RECORD; BEGIN
    FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
      PERFORM regenerate_wedding_invite_code(w.id);
    END LOOP;
  END $$;
COMMIT; -- Rollback auto si erreur
```

**Recommandation** : Utiliser version avec exception handling (plus robuste)

---

### 🟡 CORRECTION C-03 : Ajouter validation format codes

**Fichier** : Story S02, Etape 5

**Ajout après ligne 127** :
```sql
-- Verify code format (8 chars, correct charset)
SELECT id, invite_code, LENGTH(invite_code) as code_length
FROM weddings
WHERE invite_code IS NOT NULL
  AND (
    invite_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$'
    OR LENGTH(invite_code) != 8
  );
-- Expected: 0 rows (all codes valid)

-- Verify expiration dates are set and future
SELECT id, invite_code, invite_code_expires_at,
       invite_code_expires_at - NOW() as days_remaining
FROM weddings
WHERE invite_code IS NOT NULL
  AND (invite_code_expires_at IS NULL OR invite_code_expires_at < NOW());
-- Expected: 0 rows (all codes have valid expiration)
```

---

## RISQUES RÉÉVALUÉS

| Risque | Impact Round 1 | Impact Round 2 | Mitigation |
|--------|----------------|----------------|------------|
| Collision codes backfill | Très faible | **MOYEN** (fonction sans retry) | C-01 (retry loop) |
| Backfill partiel | Faible | **MOYEN** (crash à 1ère erreur) | C-02 (exception handling) |
| Trigger inactif | Faible | Faible (trigger actif confirmé) | Diagnostic Etape 1 |
| Codes format invalide | Non évalué | **FAIBLE** (mais non détecté) | C-03 (validation format) |

---

## MÉTRIQUES PROBLÈMES

### Par Sévérité

| Sévérité | Nombre | Problèmes |
|----------|--------|-----------|
| 🔴 BLOQUANT | 2 | P-01 (retry), P-02 (error handling) |
| 🟡 MAJEUR | 2 | P-03 (validation format), P-04 (dépendances doc) |
| 🟢 MINEUR | 1 | P-05 (AC-02 naming) |

### Par Catégorie

| Catégorie | Nombre | Problèmes |
|-----------|--------|-----------|
| SQL Logic | 2 | P-01, P-02 |
| Validation | 1 | P-03 |
| Documentation | 2 | P-04, P-05 |

---

## ESTIMATION RÉÉVALUÉE

**Estimation initiale** : 2 SP (1h)
**Estimation Round 1** : 2 SP (1h) - "Acceptable avec corrections mineures"
**Estimation Round 2** : **3 SP (2h)** - Corrections SQL critiques requises

**Détail** :
- Réécrire fonction `regenerate_wedding_invite_code` : +30 min
- Réécrire script backfill avec exception handling : +20 min
- Re-appliquer migration en prod : +10 min
- Validation étendue (format + expiration) : +10 min
- Buffer sécurité : +20 min
- **Total** : 2h (3 SP)

---

## VERDICT INVEST

| Critère | Round 1 | Round 2 |
|---------|---------|---------|
| **Independent** | ✅ Pas de dépendance | ✅ Toujours vrai |
| **Negotiable** | ⚠️ Méthode flexible | ❌ Retry loop NON-NÉGOCIABLE |
| **Valuable** | ✅ Débloque S05 | ✅ Toujours vrai |
| **Estimable** | ✅ 2 SP | ⚠️ 3 SP (sous-évalué) |
| **Small** | ✅ Max 1h | ⚠️ 2h avec corrections |
| **Testable** | ✅ Validation SQL | ✅ + validation format |

**Verdict INVEST** : ⚠️ **PARTIELLEMENT CONFORME** (Estimable et Small sous-évalués)

---

## DEFINITION OF DONE - MISE À JOUR

**DoD originale** (ligne 211-218) :
```markdown
- [ ] Les 3 fonctions SQL existent en production
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")
```

**DoD CORRIGÉE** :
```markdown
- [ ] Les 3 fonctions SQL existent en production
- [ ] Fonction `regenerate_wedding_invite_code` A un retry loop (max 10 tentatives)
- [ ] Le trigger `trg_generate_invite_code` est actif (tgenabled = 'O')
- [ ] Backfill exécuté avec success_count = 7, error_count = 0
- [ ] 0 mariages avec `invite_code IS NULL`
- [ ] 0 doublons de codes (`GROUP BY HAVING COUNT > 1` = 0 rows)
- [ ] 0 codes format invalide (regex + LENGTH validation)
- [ ] 0 codes avec expiration NULL ou passée
- [ ] Test insert + rollback confirme la generation automatique
- [ ] L'UI My Wedding affiche le code (pas "Generating...")
```

**Ajouts** :
- Vérification retry loop dans fonction backfill
- Compteurs backfill explicites
- Validation format codes
- Validation expiration dates

---

## CONCLUSION

### Pourquoi Round 1 a raté

Le Round 1 a classé S02 comme **"ACCEPTABLE avec corrections mineures"** car il s'est concentré sur :
- La documentation (dépendances, AC-02 naming)
- La validation post-backfill (format codes)

**Mais il a RATÉ le problème critique** : L'analyse du CODE SQL de la fonction `regenerate_wedding_invite_code` qui n'a PAS de retry logic.

### Nouveaux problèmes Round 2

Round 2 a fait une **analyse exhaustive du code SQL** :
1. ✅ Lecture migration complète (83 lignes)
2. ✅ Comparaison trigger vs fonction backfill
3. ✅ Vérification schéma DB production
4. ✅ Analyse probabilité collision (30^8 combinaisons)
5. ✅ Inspection code Flutter UI (confirme comportement attendu)

**Résultat** : 2 problèmes BLOQUANTS identifiés (P-01, P-02) qui rendent la story NON-IMPLÉMENTABLE en l'état.

### Leçon apprise

**Ne JAMAIS approuver une story data sans :**
1. Lire le code SQL ligne par ligne
2. Comparer les fonctions similaires (trigger vs backfill)
3. Vérifier la gestion d'erreur (exception handling)
4. Valider l'idempotence (rollback, retry)

> "Le diable est dans les détails" - ici, dans la fonction `regenerate_wedding_invite_code` ligne 63-77.

---

## RECOMMANDATION FINALE

**❌ STORY NON VALIDÉE - CORRECTIONS CRITIQUES REQUISES**

**Actions avant validation** :
1. ✅ Appliquer C-01 (retry loop fonction backfill)
2. ✅ Appliquer C-02 (exception handling script backfill)
3. ✅ Appliquer C-03 (validation format codes)
4. ✅ Mettre à jour DoD avec nouveaux critères
5. ✅ Re-challenger après corrections

**Temps estimé corrections** : 1h (modification migration + script backfill + validation)

**Verdict INVEST après corrections** : ✅ STORY VALIDÉE (3 SP, Small, Testable)

---

**Rapport généré par** : Review Adversariale APEX Round 2
**Méthodologie** : Analyse SQL exhaustive, 0 complaisance, focus code
**Date** : 2026-02-16
