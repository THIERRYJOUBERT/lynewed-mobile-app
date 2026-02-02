-- Migration: Add Wedding Groups Support
-- Description: RPCs and triggers for wedding group management (public + private)
--
-- Room types:
-- 'wedding_team'          -> Auto-created on wedding creation, all joined members
-- 'wedding_group_public'  -> Created by bride, auto-join for new joined members
-- 'wedding_group_private' -> Created by bride, manual invitation only

-- ============================================================================
-- 1. RPC: Create a wedding group
-- ============================================================================
CREATE OR REPLACE FUNCTION create_wedding_group(
  p_wedding_id UUID,
  p_name TEXT,
  p_is_public BOOLEAN DEFAULT false,
  p_member_profile_ids UUID[] DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_bride_id UUID;
  v_member_id UUID;
  v_room_type TEXT;
BEGIN
  -- Verify caller is bride of this wedding
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = p_wedding_id;

  IF v_bride_id IS NULL THEN
    RAISE EXCEPTION 'Wedding not found';
  END IF;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can create groups for this wedding';
  END IF;

  -- Determine room type
  v_room_type := CASE WHEN p_is_public THEN 'wedding_group_public' ELSE 'wedding_group_private' END;

  -- Create the room
  INSERT INTO chat_rooms (type, name, wedding_id, is_active, created_at)
  VALUES (v_room_type, p_name, p_wedding_id, true, NOW())
  RETURNING id INTO v_room_id;

  -- Add bride as first participant
  INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
  VALUES (v_room_id, v_bride_id, 'active', NOW());

  -- For public groups, add all currently joined guests and pros
  IF p_is_public THEN
    -- Add joined guests
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
    SELECT v_room_id, wg.user_id, 'active', NOW()
    FROM wedding_guests wg
    WHERE wg.wedding_id = p_wedding_id
    AND wg.status = 'joined'
    AND wg.user_id IS NOT NULL
    AND wg.user_id != v_bride_id
    ON CONFLICT (room_id, profile_id) DO NOTHING;

    -- Add wedding team professionals
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
    SELECT v_room_id, wp.professional_profile_id, 'active', NOW()
    FROM wedding_participants wp
    WHERE wp.wedding_id = p_wedding_id
    AND wp.status = 'active'
    AND wp.professional_profile_id != v_bride_id
    ON CONFLICT (room_id, profile_id) DO NOTHING;
  ELSE
    -- For private groups, add specified members
    IF p_member_profile_ids IS NOT NULL THEN
      FOREACH v_member_id IN ARRAY p_member_profile_ids
      LOOP
        -- Verify member is part of the wedding (guest or pro)
        IF EXISTS (
          SELECT 1 FROM wedding_guests wg
          WHERE wg.wedding_id = p_wedding_id
          AND wg.user_id = v_member_id
          AND wg.status = 'joined'
        ) OR EXISTS (
          SELECT 1 FROM wedding_participants wp
          WHERE wp.wedding_id = p_wedding_id
          AND wp.professional_profile_id = v_member_id
          AND wp.status = 'active'
        ) THEN
          INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
          VALUES (v_room_id, v_member_id, 'active', NOW())
          ON CONFLICT (room_id, profile_id) DO NOTHING;
        END IF;
      END LOOP;
    END IF;
  END IF;

  RETURN v_room_id;
END;
$$;

-- ============================================================================
-- 2. RPC: Manage wedding group members (for private groups)
-- ============================================================================
CREATE OR REPLACE FUNCTION manage_wedding_group_members(
  p_room_id UUID,
  p_add_profile_ids UUID[] DEFAULT NULL,
  p_remove_profile_ids UUID[] DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
  v_wedding_id UUID;
  v_room_type TEXT;
  v_member_id UUID;
BEGIN
  -- Get room info
  SELECT cr.wedding_id, cr.type INTO v_wedding_id, v_room_type
  FROM chat_rooms cr
  WHERE cr.id = p_room_id;

  IF v_wedding_id IS NULL THEN
    RAISE EXCEPTION 'Room not found or not a wedding group';
  END IF;

  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = v_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can manage group members';
  END IF;

  -- Add members
  IF p_add_profile_ids IS NOT NULL THEN
    FOREACH v_member_id IN ARRAY p_add_profile_ids
    LOOP
      -- Verify member is part of the wedding
      IF EXISTS (
        SELECT 1 FROM wedding_guests wg
        WHERE wg.wedding_id = v_wedding_id
        AND wg.user_id = v_member_id
        AND wg.status = 'joined'
      ) OR EXISTS (
        SELECT 1 FROM wedding_participants wp
        WHERE wp.wedding_id = v_wedding_id
        AND wp.professional_profile_id = v_member_id
        AND wp.status = 'active'
      ) THEN
        INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
        VALUES (p_room_id, v_member_id, 'active', NOW())
        ON CONFLICT (room_id, profile_id) DO UPDATE SET conversation_status = 'active';
      END IF;
    END LOOP;
  END IF;

  -- Remove members (but never remove bride)
  IF p_remove_profile_ids IS NOT NULL THEN
    DELETE FROM chat_room_participants
    WHERE room_id = p_room_id
    AND profile_id = ANY(p_remove_profile_ids)
    AND profile_id != v_bride_id;
  END IF;

  RETURN true;
END;
$$;

-- ============================================================================
-- 3. RPC: Get wedding groups for bride
-- ============================================================================
CREATE OR REPLACE FUNCTION get_wedding_groups(p_wedding_id UUID)
RETURNS TABLE (
  room_id UUID,
  name TEXT,
  is_public BOOLEAN,
  is_default BOOLEAN,
  member_count BIGINT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
BEGIN
  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = p_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can list wedding groups';
  END IF;

  RETURN QUERY
  SELECT
    cr.id AS room_id,
    COALESCE(cr.name, 'Wedding Team') AS name,
    cr.type = 'wedding_group_public' AS is_public,
    cr.type = 'wedding_team' AS is_default,
    COUNT(crp.profile_id) AS member_count,
    cr.created_at
  FROM chat_rooms cr
  LEFT JOIN chat_room_participants crp ON crp.room_id = cr.id AND crp.conversation_status = 'active'
  WHERE cr.wedding_id = p_wedding_id
  AND cr.type IN ('wedding_team', 'wedding_group_public', 'wedding_group_private')
  AND cr.is_active = true
  GROUP BY cr.id, cr.name, cr.type, cr.created_at
  ORDER BY
    CASE cr.type
      WHEN 'wedding_team' THEN 0
      WHEN 'wedding_group_public' THEN 1
      ELSE 2
    END,
    cr.created_at;
END;
$$;

-- ============================================================================
-- 4. RPC: Update wedding group
-- ============================================================================
CREATE OR REPLACE FUNCTION update_wedding_group(
  p_room_id UUID,
  p_name TEXT DEFAULT NULL,
  p_is_public BOOLEAN DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
  v_wedding_id UUID;
  v_current_type TEXT;
  v_new_type TEXT;
BEGIN
  -- Get room info
  SELECT cr.wedding_id, cr.type INTO v_wedding_id, v_current_type
  FROM chat_rooms cr
  WHERE cr.id = p_room_id;

  IF v_wedding_id IS NULL THEN
    RAISE EXCEPTION 'Room not found';
  END IF;

  -- Cannot update wedding_team (default group)
  IF v_current_type = 'wedding_team' THEN
    RAISE EXCEPTION 'Cannot modify default wedding team group';
  END IF;

  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = v_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can update group';
  END IF;

  -- Update name if provided
  IF p_name IS NOT NULL THEN
    UPDATE chat_rooms SET name = p_name WHERE id = p_room_id;
  END IF;

  -- Update visibility if provided
  IF p_is_public IS NOT NULL THEN
    v_new_type := CASE WHEN p_is_public THEN 'wedding_group_public' ELSE 'wedding_group_private' END;

    IF v_new_type != v_current_type THEN
      UPDATE chat_rooms SET type = v_new_type WHERE id = p_room_id;

      -- If changing to public, add all currently joined guests/pros
      IF p_is_public THEN
        INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
        SELECT p_room_id, wg.user_id, 'active', NOW()
        FROM wedding_guests wg
        WHERE wg.wedding_id = v_wedding_id
        AND wg.status = 'joined'
        AND wg.user_id IS NOT NULL
        ON CONFLICT (room_id, profile_id) DO NOTHING;

        INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
        SELECT p_room_id, wp.professional_profile_id, 'active', NOW()
        FROM wedding_participants wp
        WHERE wp.wedding_id = v_wedding_id
        AND wp.status = 'active'
        ON CONFLICT (room_id, profile_id) DO NOTHING;
      END IF;
    END IF;
  END IF;

  RETURN true;
END;
$$;

-- ============================================================================
-- 5. RPC: Delete wedding group
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_wedding_group(p_room_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
  v_wedding_id UUID;
  v_room_type TEXT;
BEGIN
  -- Get room info
  SELECT cr.wedding_id, cr.type INTO v_wedding_id, v_room_type
  FROM chat_rooms cr
  WHERE cr.id = p_room_id;

  IF v_wedding_id IS NULL THEN
    RAISE EXCEPTION 'Room not found';
  END IF;

  -- Cannot delete wedding_team (default group)
  IF v_room_type = 'wedding_team' THEN
    RAISE EXCEPTION 'Cannot delete default wedding team group';
  END IF;

  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = v_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can delete group';
  END IF;

  -- Soft delete: set is_active = false
  UPDATE chat_rooms SET is_active = false WHERE id = p_room_id;

  RETURN true;
END;
$$;

-- ============================================================================
-- 6. RPC: Get group members
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
    SELECT 1 FROM chat_room_participants
    WHERE room_id = p_room_id AND profile_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to view group members';
  END IF;

  RETURN QUERY
  SELECT
    p.id AS profile_id,
    p.full_name,
    p.avatar_url,
    CASE
      WHEN p.id = v_bride_id THEN 'bride'
      WHEN EXISTS (SELECT 1 FROM wedding_participants wp WHERE wp.wedding_id = v_wedding_id AND wp.professional_profile_id = p.id) THEN 'pro'
      ELSE 'guest'
    END AS member_type,
    crp.joined_at
  FROM chat_room_participants crp
  JOIN profiles p ON p.id = crp.profile_id
  WHERE crp.room_id = p_room_id
  AND crp.conversation_status = 'active'
  ORDER BY
    CASE
      WHEN p.id = v_bride_id THEN 0
      WHEN EXISTS (SELECT 1 FROM wedding_participants wp WHERE wp.wedding_id = v_wedding_id AND wp.professional_profile_id = p.id) THEN 1
      ELSE 2
    END,
    p.full_name;
END;
$$;

-- ============================================================================
-- 7. RPC: Get eligible members for private groups
-- ============================================================================
CREATE OR REPLACE FUNCTION get_eligible_group_members(p_wedding_id UUID)
RETURNS TABLE (
  profile_id UUID,
  full_name TEXT,
  avatar_url TEXT,
  member_type TEXT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
BEGIN
  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = p_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can get eligible members';
  END IF;

  RETURN QUERY
  -- Joined guests
  SELECT DISTINCT
    p.id AS profile_id,
    p.full_name,
    p.avatar_url,
    'guest'::TEXT AS member_type
  FROM wedding_guests wg
  JOIN profiles p ON p.id = wg.user_id
  WHERE wg.wedding_id = p_wedding_id
  AND wg.status = 'joined'
  AND wg.user_id IS NOT NULL

  UNION ALL

  -- Active pros
  SELECT DISTINCT
    p.id AS profile_id,
    p.full_name,
    p.avatar_url,
    'pro'::TEXT AS member_type
  FROM wedding_participants wp
  JOIN profiles p ON p.id = wp.professional_profile_id
  WHERE wp.wedding_id = p_wedding_id
  AND wp.status = 'active'

  ORDER BY member_type, full_name;
END;
$$;

-- ============================================================================
-- 8. Trigger: Auto-join public wedding groups when guest joins
-- ============================================================================
CREATE OR REPLACE FUNCTION auto_join_public_wedding_groups()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- When guest status changes to 'joined' and has user_id
  IF NEW.status = 'joined' AND NEW.user_id IS NOT NULL AND
     (OLD.status IS DISTINCT FROM 'joined' OR OLD.user_id IS NULL) THEN

    -- Add to wedding_team
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
    SELECT cr.id, NEW.user_id, 'active', NOW()
    FROM chat_rooms cr
    WHERE cr.wedding_id = NEW.wedding_id
    AND cr.type = 'wedding_team'
    AND cr.is_active = true
    ON CONFLICT (room_id, profile_id) DO NOTHING;

    -- Add to all public wedding groups
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at)
    SELECT cr.id, NEW.user_id, 'active', NOW()
    FROM chat_rooms cr
    WHERE cr.wedding_id = NEW.wedding_id
    AND cr.type = 'wedding_group_public'
    AND cr.is_active = true
    ON CONFLICT (room_id, profile_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger on wedding_guests
DROP TRIGGER IF EXISTS trg_auto_join_public_wedding_groups ON wedding_guests;
CREATE TRIGGER trg_auto_join_public_wedding_groups
  AFTER UPDATE ON wedding_guests
  FOR EACH ROW
  EXECUTE FUNCTION auto_join_public_wedding_groups();

-- ============================================================================
-- 9. RPC: Send bulk invitations
-- ============================================================================
CREATE OR REPLACE FUNCTION send_bulk_invitations(p_wedding_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bride_id UUID;
  v_count INT := 0;
  v_guest_ids UUID[];
BEGIN
  -- Verify caller is bride
  SELECT bride_profile_id INTO v_bride_id
  FROM weddings WHERE id = p_wedding_id;

  IF v_bride_id != auth.uid() THEN
    RAISE EXCEPTION 'Only bride can send bulk invitations';
  END IF;

  -- Get all pending guests with email
  SELECT ARRAY_AGG(id) INTO v_guest_ids
  FROM wedding_guests
  WHERE wedding_id = p_wedding_id
  AND email IS NOT NULL
  AND email != ''
  AND status = 'pending';

  IF v_guest_ids IS NULL OR ARRAY_LENGTH(v_guest_ids, 1) IS NULL THEN
    RETURN jsonb_build_object('queued', 0, 'message', 'No pending guests with email');
  END IF;

  v_count := ARRAY_LENGTH(v_guest_ids, 1);

  -- Update status to 'invited' and set invited_at
  UPDATE wedding_guests
  SET
    status = 'invited',
    invited_at = NOW()
  WHERE id = ANY(v_guest_ids);

  -- Note: Actual email sending should be handled by an Edge Function
  -- triggered by the status change or called separately

  RETURN jsonb_build_object(
    'queued', v_count,
    'guest_ids', v_guest_ids,
    'message', format('%s invitations queued', v_count)
  );
END;
$$;

-- ============================================================================
-- Grant permissions
-- ============================================================================
GRANT EXECUTE ON FUNCTION create_wedding_group TO authenticated;
GRANT EXECUTE ON FUNCTION manage_wedding_group_members TO authenticated;
GRANT EXECUTE ON FUNCTION get_wedding_groups TO authenticated;
GRANT EXECUTE ON FUNCTION update_wedding_group TO authenticated;
GRANT EXECUTE ON FUNCTION delete_wedding_group TO authenticated;
GRANT EXECUTE ON FUNCTION get_wedding_group_members TO authenticated;
GRANT EXECUTE ON FUNCTION get_eligible_group_members TO authenticated;
GRANT EXECUTE ON FUNCTION send_bulk_invitations TO authenticated;
