-- Migration: 20260128000002_add_wedding_invite_columns
-- Description: Add invitation code columns to weddings table
-- Created: 2026-01-29
-- Author: Epic-06-PREREQUISITES
-- Dependencies: 20260128000001_add_guest_role

-- Add invite_code column (8 characters for security - Decision D-15)
-- Unique constraint ensures no duplicate codes
ALTER TABLE weddings
  ADD COLUMN IF NOT EXISTS invite_code VARCHAR(8) UNIQUE;

-- Add expiration column
ALTER TABLE weddings
  ADD COLUMN IF NOT EXISTS invite_code_expires_at TIMESTAMP;

-- Create index for faster lookup by invite_code
-- Partial index (WHERE NOT NULL) for performance - only indexes rows with codes
CREATE INDEX IF NOT EXISTS idx_weddings_invite_code
  ON weddings(invite_code)
  WHERE invite_code IS NOT NULL;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'weddings' AND column_name = 'invite_code'
  ) THEN
    RAISE EXCEPTION 'Migration failed: invite_code column not created';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'weddings' AND column_name = 'invite_code_expires_at'
  ) THEN
    RAISE EXCEPTION 'Migration failed: invite_code_expires_at column not created';
  END IF;
END $$;

-- Comments for documentation
COMMENT ON COLUMN weddings.invite_code IS 'Unique 8-character invitation code for guest access (D-15)';
COMMENT ON COLUMN weddings.invite_code_expires_at IS 'Expiration timestamp for invitation code (30 days default)';
