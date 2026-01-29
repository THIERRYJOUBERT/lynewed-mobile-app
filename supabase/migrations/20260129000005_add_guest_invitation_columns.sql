-- Migration: 20260129000005_add_guest_invitation_columns
-- Description: Add invitation tracking columns to wedding_guests table
-- Created: 2026-01-29
-- Risk Level: LOW - Only adds nullable columns
-- Dependencies: 20260129000001_add_guest_role
-- Applied: Production (hekyovgnovhfhmkpfrna)

-- Add user_id column (links to profiles when guest creates account)
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES profiles(id);

-- Add invitation tracking columns
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS invited_at TIMESTAMP;

ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP;

-- Add status column with constraint
ALTER TABLE wedding_guests
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending';

-- Add check constraint for valid status values
ALTER TABLE wedding_guests
  ADD CONSTRAINT chk_guest_status
  CHECK (status IN ('pending', 'invited', 'joined', 'declined'));

-- Create index for common queries (guests by wedding and status)
CREATE INDEX IF NOT EXISTS idx_wedding_guests_wedding_status
  ON wedding_guests(wedding_id, status);

-- Create index for finding guest by user_id
CREATE INDEX IF NOT EXISTS idx_wedding_guests_user_id
  ON wedding_guests(user_id)
  WHERE user_id IS NOT NULL;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'wedding_guests' AND column_name = 'status'
  ) THEN
    RAISE EXCEPTION 'Migration failed: status column not created';
  END IF;
END $$;

-- Comments
COMMENT ON COLUMN wedding_guests.status IS 'Guest invitation status: pending, invited, joined, declined';
COMMENT ON COLUMN wedding_guests.user_id IS 'Links to profiles when guest creates an account';
COMMENT ON COLUMN wedding_guests.invited_at IS 'Timestamp when invitation was sent';
COMMENT ON COLUMN wedding_guests.joined_at IS 'Timestamp when guest joined via invitation code';
