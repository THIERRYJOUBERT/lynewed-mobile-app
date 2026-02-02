-- Migration: Add Guest Conversations RPC
-- Description: RPC for guests to get their wedding group conversations with proper metadata
--
-- This RPC returns wedding groups (wedding_team, wedding_group_public, wedding_group_private)
-- with proper display name and metadata for the guest messages page.

-- ============================================================================
-- RPC: Get guest conversations (wedding groups only)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_guest_conversations()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_me UUID := auth.uid();
  v_items JSONB;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  WITH my_rooms AS (
    -- Get all wedding group rooms where I'm a participant
    SELECT
      p.room_id,
      p.last_read_at,
      p.conversation_status,
      r.type,
      r.name AS room_name,
      r.wedding_id,
      r.created_at AS room_created_at
    FROM public.chat_room_participants p
    JOIN public.chat_rooms r ON r.id = p.room_id
    WHERE p.profile_id = v_me
      AND r.is_active = true
      AND p.conversation_status = 'active'
      AND r.type IN ('wedding_team', 'wedding_group_public', 'wedding_group_private')
  ),
  last_msg AS (
    -- Get last message for each room
    SELECT
      m.room_id,
      m.id AS msg_id,
      m.message_type,
      m.content,
      m.created_at AS msg_created_at
    FROM (
      SELECT DISTINCT ON (room_id)
        room_id, id, message_type, content, created_at
      FROM public.chat_messages
      WHERE is_deleted = false
      ORDER BY room_id, created_at DESC
    ) m
  ),
  unread AS (
    -- Count unread messages per room
    SELECT mr.room_id, COUNT(*)::INT AS unread_count
    FROM public.chat_messages m
    JOIN my_rooms mr ON mr.room_id = m.room_id
    WHERE m.is_deleted = false
      AND m.profile_id <> v_me
      AND (mr.last_read_at IS NULL OR m.created_at > mr.last_read_at)
    GROUP BY mr.room_id
  ),
  wedding_info AS (
    -- Get wedding info for context
    SELECT
      mr.room_id,
      w.wedding_name,  -- Column is wedding_name, not name
      w.cover_image_url AS cover_url
    FROM my_rooms mr
    JOIN public.weddings w ON w.id = mr.wedding_id
  ),
  member_count AS (
    -- Count active members per room
    SELECT room_id, COUNT(*)::INT AS count
    FROM public.chat_room_participants
    WHERE conversation_status = 'active'
    GROUP BY room_id
  )
  SELECT JSONB_AGG(
    JSONB_BUILD_OBJECT(
      'roomId', mr.room_id,
      'roomType', mr.type,
      'conversationStatus', mr.conversation_status::TEXT,
      'unreadCount', COALESCE(u.unread_count, 0),
      'lastMessageType', COALESCE(lm.message_type::TEXT, ''),
      'lastMessageText', CASE
        WHEN lm.message_type = 'text' THEN COALESCE(lm.content, '')
        WHEN lm.message_type = 'image' THEN 'Photo'
        WHEN lm.message_type = 'audio' THEN 'Audio'
        ELSE ''
      END,
      'lastMessageAt', COALESCE(lm.msg_created_at::TEXT, mr.room_created_at::TEXT),
      -- For wedding groups, use room name as the display title
      'publicTitle', COALESCE(mr.room_name,
        CASE mr.type
          WHEN 'wedding_team' THEN 'Wedding Team'
          ELSE 'Group'
        END
      ),
      'publicCoverUrl', wi.cover_url,
      'memberCount', COALESCE(mc.count, 0),
      -- No individual "other" profile for group chats
      'otherProfileId', NULL,
      'otherFullName', NULL,
      'otherAvatarUrl', NULL,
      'otherRole', NULL
    )
    ORDER BY COALESCE(lm.msg_created_at, mr.room_created_at) DESC
  )
  INTO v_items
  FROM my_rooms mr
  LEFT JOIN last_msg lm ON lm.room_id = mr.room_id
  LEFT JOIN unread u ON u.room_id = mr.room_id
  LEFT JOIN wedding_info wi ON wi.room_id = mr.room_id
  LEFT JOIN member_count mc ON mc.room_id = mr.room_id;

  RETURN JSONB_BUILD_OBJECT('items', COALESCE(v_items, '[]'::JSONB));
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_guest_conversations() TO authenticated;
