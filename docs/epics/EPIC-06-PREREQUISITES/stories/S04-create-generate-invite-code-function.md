# Story S04: Create generate_secure_invite_code Function and Trigger

## Description
En tant que **systeme**, je veux **creer une fonction et un trigger pour generer automatiquement des codes d'invitation securises**, afin de **garantir que chaque mariage ait un code unique de 8 caracteres avec expiration de 30 jours**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given generate_invite_code_value() is called When the function executes Then it should return a code of exactly 8 characters And the code should contain only uppercase letters (A-Z sans I,O) and numbers (2-9) And the code should be cryptographically random
- [ ] Given a user creates a new wedding When the wedding is inserted into the database Then invite_code should be automatically populated And invite_code_expires_at should be set to NOW() + 30 days
- [ ] Given 100 weddings in the database When each has a generated invite_code Then all codes should be unique And no collision should occur
- [ ] Given an existing wedding with invite_code = NULL When regenerate_wedding_invite_code(wedding_id) is called Then the wedding should have a valid invite_code And invite_code_expires_at should be set to NOW() + 30 days
- [ ] Given a wedding with an existing invite_code When regenerate_wedding_invite_code is called Then a new unique code should be generated And the old code should become invalid

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000004_create_generate_invite_code.sql`

### A Modifier
- Aucun fichier Dart (fonctions server-side)

## Notes Techniques

**Migration SQL:**
```sql
-- Function to generate a single secure code value
CREATE OR REPLACE FUNCTION generate_invite_code_value()
RETURNS VARCHAR(8) AS $$
DECLARE
  -- Excluded I, O, 0, 1 for readability
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code VARCHAR(8) := '';
  i INTEGER;
BEGIN
  FOR i IN 1..8 LOOP
    code := code || SUBSTR(chars, 1 + FLOOR(RANDOM() * LENGTH(chars))::INTEGER, 1);
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for automatic code generation
CREATE OR REPLACE FUNCTION generate_secure_invite_code()
RETURNS TRIGGER AS $$
DECLARE
  new_code VARCHAR(8);
  max_attempts INTEGER := 10;
  attempt INTEGER := 0;
BEGIN
  IF NEW.invite_code IS NULL THEN
    LOOP
      new_code := generate_invite_code_value();
      attempt := attempt + 1;

      EXIT WHEN NOT EXISTS (
        SELECT 1 FROM weddings
        WHERE invite_code = new_code
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
      );

      IF attempt >= max_attempts THEN
        RAISE EXCEPTION 'Could not generate unique invite code after % attempts', max_attempts;
      END IF;
    END LOOP;

    NEW.invite_code := new_code;
    NEW.invite_code_expires_at := NOW() + INTERVAL '30 days';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trg_generate_invite_code ON weddings;
CREATE TRIGGER trg_generate_invite_code
  BEFORE INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION generate_secure_invite_code();

-- Function to regenerate code for existing wedding
CREATE OR REPLACE FUNCTION regenerate_wedding_invite_code(p_wedding_id UUID)
RETURNS VARCHAR(8) AS $$
DECLARE
  new_code VARCHAR(8);
BEGIN
  new_code := generate_invite_code_value();

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Rollback SQL:**
```sql
DROP TRIGGER IF EXISTS trg_generate_invite_code ON weddings;
DROP FUNCTION IF EXISTS regenerate_wedding_invite_code;
DROP FUNCTION IF EXISTS generate_secure_invite_code;
DROP FUNCTION IF EXISTS generate_invite_code_value;
```

**Choix techniques:**
- Alphabet de 32 caracteres (sans I, O, 0, 1 pour eviter confusion)
- 32^8 = 1.1 trillion de combinaisons possibles
- Loop de retry (max 10) pour garantir unicite
- Expiration automatique 30 jours

## Definition of Done

- [ ] Fonction generate_invite_code_value creee et fonctionne
- [ ] Fonction generate_secure_invite_code (trigger) creee
- [ ] Trigger trg_generate_invite_code actif sur weddings
- [ ] Test: INSERT wedding genere automatiquement invite_code
- [ ] Test: invite_code_expires_at = NOW() + 30 days
- [ ] Test: Codes generes sont uniques (test sur 100 inserts)
- [ ] Fonction regenerate_wedding_invite_code fonctionne
- [ ] `flutter analyze --fatal-infos` passe (aucun changement Dart)

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible (trigger bien delimite)

## Dependances

- S02: Add invitation columns to weddings (colonnes invite_code doivent exister)

## Stories Dependantes

- Aucune directement (sera utilisee par APP-03)
