-- Migration: 20260129000003_create_invitation_attempts
-- Description: Create rate limiting table for invitation code attempts
-- Created: 2026-01-29
-- Risk Level: LOW - New table, no impact on existing data
-- Applied: Production (hekyovgnovhfhmkpfrna)

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

-- Enable RLS (no public access - service_role only)
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

-- Comments
COMMENT ON TABLE invitation_attempts IS 'Rate limiting for wedding invitation code attempts (D-15)';
COMMENT ON FUNCTION check_invitation_rate_limit IS 'Returns TRUE if IP is rate limited (5 attempts per 15 min)';
