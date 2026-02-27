-- Migration: 20260129000004_create_generate_invite_code
-- Description: Create secure invite code generation function and trigger
-- Created: 2026-01-29
-- Risk Level: MEDIUM - Creates trigger on weddings table
-- Dependencies: 20260129000002_add_wedding_invite_columns
-- Applied: Production (hekyovgnovhfhmkpfrna)

-- Function to generate a single secure code value
CREATE OR REPLACE FUNCTION generate_invite_code_value()
RETURNS VARCHAR(8) AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excluded I, O, 0, 1 for readability
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

-- Create trigger on weddings table
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
  max_attempts INTEGER := 10;
  attempt INTEGER := 0;
BEGIN
  LOOP
    new_code := generate_invite_code_value();
    attempt := attempt + 1;

    -- Check uniqueness before update
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM weddings
      WHERE invite_code = new_code
      AND id != p_wedding_id
    );

    IF attempt >= max_attempts THEN
      RAISE EXCEPTION 'Could not generate unique invite code for wedding % after % attempts', p_wedding_id, max_attempts;
    END IF;
  END LOOP;

  UPDATE weddings
  SET invite_code = new_code,
      invite_code_expires_at = NOW() + INTERVAL '30 days'
  WHERE id = p_wedding_id;

  RETURN new_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON FUNCTION generate_invite_code_value IS 'Generates 8-char alphanumeric code (excludes confusing chars I,O,0,1)';
COMMENT ON FUNCTION generate_secure_invite_code IS 'Trigger function for automatic invite code generation';
COMMENT ON FUNCTION regenerate_wedding_invite_code IS 'Regenerates invite code for existing wedding (30 day expiration)';
