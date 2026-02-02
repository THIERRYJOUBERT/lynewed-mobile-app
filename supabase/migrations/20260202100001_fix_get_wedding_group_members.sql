-- Migration: Fix ambiguous column reference in get_wedding_group_members
-- Description: Rename output column to avoid conflict with plpgsql variable
-- Problem: "profile_id" was ambiguous - could refer to output column or table column
-- Solution: Use table-qualified names throughout

-- ============================================================================
-- Fix RPC: Get group members (ambiguous column fix)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_wedding_group_members(p_room_id UUID)
RETURNS TABLE (
  profile_id UUID,
  full_name TEXT,
  avatar_url TEXT,
  member_type TEXT,
  joined_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
  v_wedding_id UUID;
BEGIN
  -- Get room info
  SELECT cr.wedding_id INTO v_wedding_id
  FROM chat_rooms cr
  WHERE cr.id = p_room_id;

  IF v_wedding_id IS NULL THEN
    RAISE EXCEPTION 'Room not found';
  END IF;

  -- Verify caller is bride or participant
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = v_wedding_id;

  IF v_bride_id != auth.uid() AND NOT EXISTS (
    SELECT 1 FROM chat_room_participants crp_check
    WHERE crp_check.room_id = p_room_id AND crp_check.profile_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to view group members';
  END IF;

  RETURN QUERY
  SELECT
    prof.id AS profile_id,
    prof.full_name,
    prof.avatar_url,
    CASE
      WHEN prof.id = v_bride_id THEN 'bride'
      WHEN EXISTS (SELECT 1 FROM wedding_participants wp WHERE wp.wedding_id = v_wedding_id AND wp.professional_profile_id = prof.id) THEN 'pro'
      ELSE 'guest'
    END AS member_type,
    crp.joined_at
  FROM chat_room_participants crp
  JOIN profiles prof ON prof.id = crp.profile_id
  WHERE crp.room_id = p_room_id
  AND crp.conversation_status = 'active'
  ORDER BY
    CASE
      WHEN prof.id = v_bride_id THEN 0
      WHEN EXISTS (SELECT 1 FROM wedding_participants wp WHERE wp.wedding_id = v_wedding_id AND wp.professional_profile_id = prof.id) THEN 1
      ELSE 2
    END,
    prof.full_name;
END;
$$;
