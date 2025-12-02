-- ============================================================================
-- CHAT & CONTACT REFACTORING - PHASE 1
-- ============================================================================
-- Date: 2025-12-02
-- Description: Backend changes for new contact flow
--   1. Drop trigger trg_on_first_msg_pro_bride (auto-create connection_request)
--   2. Rename enum connectionRequestSource values
--   3. Create RPC create_contact_request (explicit request creation)
--   4. Modify RPC accept_connection_request (create room on accept)
--   5. Create RPC decline_connection_request (if not exists)
-- ============================================================================

-- ============================================================================
-- 1. DROP TRIGGER trg_on_first_msg_pro_bride
-- ============================================================================
-- This trigger auto-created connection_requests on first message Pro→Bride
-- New flow: Pro explicitly creates request via sheet BEFORE chat opens

DROP TRIGGER IF EXISTS trg_on_first_msg_pro_bride ON public.chat_messages;
DROP FUNCTION IF EXISTS public.on_first_message_pro_to_bride();

-- ============================================================================
-- 2. RENAME ENUM connectionRequestSource VALUES
-- ============================================================================
-- Old: wishlist, weddingPin, map, alert, proToPro
-- New: fromWishlist, fromWedding, fromAlert, fromProfile
-- Note: PostgreSQL doesn't allow direct rename of enum values
-- We need to: create new type, migrate data, drop old type, rename new type

-- Step 2.1: Create new enum type
CREATE TYPE public."connectionRequestSource_new" AS ENUM (
  'fromWishlist',
  'fromWedding', 
  'fromAlert',
  'fromProfile'
);

-- Step 2.2: Add temporary column with new type
ALTER TABLE public.connection_requests 
ADD COLUMN source_new public."connectionRequestSource_new";

-- Step 2.3: Migrate data from old to new
UPDATE public.connection_requests SET source_new = 
  CASE source::text
    WHEN 'wishlist' THEN 'fromWishlist'::public."connectionRequestSource_new"
    WHEN 'weddingPin' THEN 'fromWedding'::public."connectionRequestSource_new"
    WHEN 'map' THEN 'fromProfile'::public."connectionRequestSource_new"
    WHEN 'alert' THEN 'fromAlert'::public."connectionRequestSource_new"
    WHEN 'proToPro' THEN 'fromProfile'::public."connectionRequestSource_new"
  END;

-- Step 2.4: Drop old column and rename new one
ALTER TABLE public.connection_requests DROP COLUMN source;
ALTER TABLE public.connection_requests RENAME COLUMN source_new TO source;

-- Step 2.5: Set NOT NULL constraint
ALTER TABLE public.connection_requests ALTER COLUMN source SET NOT NULL;

-- Step 2.6: Drop old enum type
DROP TYPE public."connectionRequestSource";

-- Step 2.7: Rename new type to original name
ALTER TYPE public."connectionRequestSource_new" RENAME TO "connectionRequestSource";

-- ============================================================================
-- 3. CREATE RPC create_contact_request
-- ============================================================================
-- Called from ContactRequestSheet when Pro wants to contact Bride
-- Creates connection_request with status 'pending'
-- Does NOT create room (room created on accept)

CREATE OR REPLACE FUNCTION public.create_contact_request(
  p_target_id uuid,
  p_source text,
  p_message text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_me uuid := auth.uid();
  v_my_role public."userRole";
  v_target_role public."userRole";
  v_my_tier public."subscriptionTierType";
  v_blocked boolean;
  v_existing_request uuid;
  v_existing_room uuid;
  v_request_id uuid;
  v_source_enum public."connectionRequestSource";
BEGIN
  -- Auth check
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'AUTH_REQUIRED');
  END IF;

  -- Target check
  IF p_target_id IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'TARGET_REQUIRED');
  END IF;

  -- Self-contact check
  IF v_me = p_target_id THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'SELF_CONTACT');
  END IF;

  -- Get roles
  SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me;
  SELECT role INTO v_target_role FROM public.profiles WHERE id = p_target_id;

  IF v_my_role IS NULL OR v_target_role IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'MISSING_PROFILE');
  END IF;

  -- This RPC is ONLY for Pro → Bride contact requests
  IF v_my_role <> 'professional' OR v_target_role <> 'bride' THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'INVALID_CONTACT_TYPE');
  END IF;

  -- Check subscription tier (Premium+ required)
  SELECT public.get_tier_of(v_me) INTO v_my_tier;
  IF v_my_tier NOT IN ('premiumVisibility', 'ultimateAccess') THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'INSUFFICIENT_TIER');
  END IF;

  -- Check if blocked
  SELECT EXISTS(
    SELECT 1 FROM public.user_blocks b
    WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = p_target_id)
       OR (b.blocker_profile_id = p_target_id AND b.blocked_profile_id = v_me)
  ) INTO v_blocked;

  IF v_blocked THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'BLOCKED');
  END IF;

  -- Check for existing pending request
  SELECT id INTO v_existing_request
  FROM public.connection_requests
  WHERE pro_profile_id = v_me
    AND bride_profile_id = p_target_id
    AND status = 'pending';

  IF v_existing_request IS NOT NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'REQUEST_ALREADY_PENDING');
  END IF;

  -- Check for existing active room (already connected)
  SELECT r.id INTO v_existing_room
  FROM public.chat_rooms r
  JOIN public.chat_room_participants p1 ON p1.room_id = r.id AND p1.profile_id = v_me
  JOIN public.chat_room_participants p2 ON p2.room_id = r.id AND p2.profile_id = p_target_id
  WHERE r.type = 'private'
    AND p1.conversation_status = 'active'
    AND p2.conversation_status = 'active';

  IF v_existing_room IS NOT NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'ALREADY_CONNECTED', 'roomId', v_existing_room);
  END IF;

  -- Validate and convert source
  v_source_enum := CASE p_source
    WHEN 'fromWishlist' THEN 'fromWishlist'::public."connectionRequestSource"
    WHEN 'fromWedding' THEN 'fromWedding'::public."connectionRequestSource"
    WHEN 'fromAlert' THEN 'fromAlert'::public."connectionRequestSource"
    WHEN 'fromProfile' THEN 'fromProfile'::public."connectionRequestSource"
    ELSE 'fromProfile'::public."connectionRequestSource"
  END;

  -- Validate message (required, max 1000 chars)
  IF p_message IS NULL OR trim(p_message) = '' THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'MESSAGE_REQUIRED');
  END IF;

  -- Create the connection request
  INSERT INTO public.connection_requests (
    pro_profile_id,
    bride_profile_id,
    initiator_id,
    source,
    initial_message,
    status
  ) VALUES (
    v_me,
    p_target_id,
    v_me,
    v_source_enum,
    left(trim(p_message), 1000),
    'pending'
  )
  RETURNING id INTO v_request_id;

  RETURN jsonb_build_object(
    'status', 'ok',
    'requestId', v_request_id
  );
END;
$function$;

-- ============================================================================
-- 4. MODIFY RPC accept_connection_request
-- ============================================================================
-- Now creates the room on accept (room not pre-created anymore)

CREATE OR REPLACE FUNCTION public.accept_connection_request(p_request_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_me uuid := auth.uid();
  v_req record;
  v_room_id uuid;
  v_existing_room uuid;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'AUTH_REQUIRED');
  END IF;

  -- Get and lock the request
  SELECT * INTO v_req
  FROM public.connection_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'REQUEST_NOT_FOUND');
  END IF;

  IF v_req.status <> 'pending' THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'INVALID_STATUS');
  END IF;

  -- Only the bride can accept
  IF v_me <> v_req.bride_profile_id THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'FORBIDDEN');
  END IF;

  -- Check if room already exists (edge case)
  SELECT r.id INTO v_existing_room
  FROM public.chat_rooms r
  JOIN public.chat_room_participants p1 ON p1.room_id = r.id AND p1.profile_id = v_req.pro_profile_id
  JOIN public.chat_room_participants p2 ON p2.room_id = r.id AND p2.profile_id = v_req.bride_profile_id
  WHERE r.type = 'private'
  LIMIT 1;

  IF v_existing_room IS NOT NULL THEN
    -- Room exists, just activate it
    v_room_id := v_existing_room;
    UPDATE public.chat_room_participants
    SET conversation_status = 'active'
    WHERE room_id = v_room_id;
  ELSE
    -- Create new room
    INSERT INTO public.chat_rooms (type)
    VALUES ('private')
    RETURNING id INTO v_room_id;

    -- Add both participants with active status
    INSERT INTO public.chat_room_participants (room_id, profile_id, conversation_status)
    VALUES 
      (v_room_id, v_req.pro_profile_id, 'active'),
      (v_room_id, v_req.bride_profile_id, 'active');
  END IF;

  -- Update the request status
  UPDATE public.connection_requests
  SET status = 'accepted',
      responded_at = now()
  WHERE id = p_request_id;

  RETURN jsonb_build_object(
    'status', 'ok',
    'roomId', v_room_id
  );
END;
$function$;

-- ============================================================================
-- 5. CREATE/UPDATE RPC decline_connection_request
-- ============================================================================

CREATE OR REPLACE FUNCTION public.decline_connection_request(p_request_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_me uuid := auth.uid();
  v_req record;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'AUTH_REQUIRED');
  END IF;

  -- Get and lock the request
  SELECT * INTO v_req
  FROM public.connection_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'REQUEST_NOT_FOUND');
  END IF;

  IF v_req.status <> 'pending' THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'INVALID_STATUS');
  END IF;

  -- Only the bride can decline
  IF v_me <> v_req.bride_profile_id THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'FORBIDDEN');
  END IF;

  -- Update the request status
  UPDATE public.connection_requests
  SET status = 'declined',
      responded_at = now()
  WHERE id = p_request_id;

  RETURN jsonb_build_object('status', 'ok');
END;
$function$;

-- ============================================================================
-- 6. UPDATE open_or_prepare_contact_context
-- ============================================================================
-- Simplified: Pro→Bride no longer creates room, returns 'requiresRequest'
-- Bride→Pro and Pro→Pro still create room directly

CREATE OR REPLACE FUNCTION public.open_or_prepare_contact_context(p_target uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
DECLARE
  v_me uuid := auth.uid();
  v_blocked boolean;
  v_init_role public."userRole";
  v_targ_role public."userRole";
  v_init_tier public."subscriptionTierType";
  v_room_id uuid;
  v_req_id uuid;
  v_is_room_empty boolean := false;
  v_first_text_only boolean := false;
  v_limit_single boolean := false;
  v_other_full_name text;
  v_other_avatar_url text;
  v_other_role public."userRole";
  v_conv_status_me public."conversationStatus";
  v_status text;
  v_viewer_is_reviewer boolean := false;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'AUTH_REQUIRED');
  END IF;
  IF p_target IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'TARGET_REQUIRED');
  END IF;
  IF v_me = p_target THEN
    RETURN jsonb_build_object('status', 'notAllowed', 'reason', 'SELF_CONTACT');
  END IF;

  SELECT role INTO v_init_role FROM public.profiles WHERE id = v_me;
  SELECT role INTO v_targ_role FROM public.profiles WHERE id = p_target;

  IF v_init_role IS NULL OR v_targ_role IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'reason', 'MISSING_PROFILE');
  END IF;

  -- Check for blocks
  SELECT EXISTS(
    SELECT 1 FROM public.user_blocks b
    WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = p_target)
       OR (b.blocker_profile_id = p_target AND b.blocked_profile_id = v_me)
  ) INTO v_blocked;

  IF v_blocked THEN
    RETURN jsonb_build_object('status', 'blocked', 'otherProfileId', p_target);
  END IF;

  -- Check for existing private room
  SELECT r.id INTO v_room_id
  FROM public.chat_rooms r
  JOIN public.chat_room_participants p1 ON p1.room_id = r.id AND p1.profile_id = v_me
  JOIN public.chat_room_participants p2 ON p2.room_id = r.id AND p2.profile_id = p_target
  WHERE r.type = 'private'
  LIMIT 1;

  -- If no room exists, handle based on roles
  IF v_room_id IS NULL THEN
    -- PRO → BRIDE: Requires explicit contact request (new flow)
    IF v_init_role = 'professional' AND v_targ_role = 'bride' THEN
      SELECT public.get_tier_of(v_me) INTO v_init_tier;
      IF v_init_tier NOT IN ('premiumVisibility', 'ultimateAccess') THEN
        RETURN jsonb_build_object('status', 'notAllowed', 'reason', 'INSUFFICIENT_TIER');
      END IF;
      
      -- Check for existing pending request
      SELECT id INTO v_req_id
      FROM public.connection_requests
      WHERE pro_profile_id = v_me
        AND bride_profile_id = p_target
        AND status = 'pending';
      
      IF v_req_id IS NOT NULL THEN
        v_status := 'requestPending';
      ELSE
        -- Return special status indicating sheet should be shown
        v_status := 'requiresRequest';
      END IF;
      
    -- BRIDE → PRO: Direct room creation
    ELSIF v_init_role = 'bride' AND v_targ_role = 'professional' THEN
      INSERT INTO public.chat_rooms(type) VALUES ('private') RETURNING id INTO v_room_id;
      INSERT INTO public.chat_room_participants(room_id, profile_id, conversation_status)
      VALUES (v_room_id, v_me, 'active'), (v_room_id, p_target, 'active');
      v_first_text_only := true;
      v_status := 'roomReady';
      
    -- PRO → PRO: Direct room creation (earlyAccess+)
    ELSIF v_init_role = 'professional' AND v_targ_role = 'professional' THEN
      SELECT public.get_tier_of(v_me) INTO v_init_tier;
      IF v_init_tier NOT IN ('earlyAccess', 'premiumVisibility', 'ultimateAccess') THEN
        RETURN jsonb_build_object('status', 'notAllowed', 'reason', 'INSUFFICIENT_TIER');
      END IF;
      INSERT INTO public.chat_rooms(type) VALUES ('private') RETURNING id INTO v_room_id;
      INSERT INTO public.chat_room_participants(room_id, profile_id, conversation_status)
      VALUES (v_room_id, v_me, 'active'), (v_room_id, p_target, 'active');
      v_status := 'roomReady';
      
    ELSE
      RETURN jsonb_build_object('status', 'notAllowed', 'reason', 'UNSUPPORTED_CONTACT');
    END IF;
  ELSE
    v_status := 'roomReady';
  END IF;

  -- Check if room is empty (if we have a room)
  IF v_room_id IS NOT NULL THEN
    SELECT count(*) = 0
    FROM public.chat_messages
    WHERE room_id = v_room_id AND is_deleted = false
    INTO v_is_room_empty;
  END IF;

  -- Check for pending request (for existing rooms or Pro→Bride)
  IF v_req_id IS NULL AND v_room_id IS NOT NULL THEN
    SELECT cr.id INTO v_req_id
    FROM public.connection_requests cr
    WHERE cr.status = 'pending'
      AND ((cr.pro_profile_id = v_me AND cr.bride_profile_id = p_target)
        OR (cr.pro_profile_id = p_target AND cr.bride_profile_id = v_me))
    LIMIT 1;

    IF v_req_id IS NOT NULL THEN
      v_status := 'requestPending';
      v_viewer_is_reviewer := (v_init_role = 'bride');
    END IF;
  END IF;

  -- Get other profile info
  SELECT full_name, avatar_url, role
  INTO v_other_full_name, v_other_avatar_url, v_other_role
  FROM public.profiles
  WHERE id = p_target;

  -- Get conversation status for current user
  IF v_room_id IS NOT NULL THEN
    SELECT p1.conversation_status INTO v_conv_status_me
    FROM public.chat_room_participants p1
    WHERE p1.room_id = v_room_id AND p1.profile_id = v_me
    LIMIT 1;
  END IF;

  RETURN jsonb_build_object(
    'status', v_status,
    'roomId', v_room_id,
    'requestId', v_req_id,
    'otherProfileId', p_target,
    'otherFullName', coalesce(v_other_full_name, ''),
    'otherAvatarUrl', coalesce(v_other_avatar_url, ''),
    'otherRole', v_other_role,
    'isPublic', false,
    'isRoomEmpty', coalesce(v_is_room_empty, true),
    'firstMessageTextOnly', v_first_text_only,
    'limitToSingleInitialMessage', v_limit_single,
    'viewerIsReviewer', v_viewer_is_reviewer,
    'conversationStatus', coalesce(v_conv_status_me, 'active')
  );
END;
$function$;

-- ============================================================================
-- 7. GRANT PERMISSIONS
-- ============================================================================

GRANT EXECUTE ON FUNCTION public.create_contact_request(uuid, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_connection_request(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.decline_connection_request(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.open_or_prepare_contact_context(uuid) TO authenticated;

-- ============================================================================
-- DONE
-- ============================================================================
