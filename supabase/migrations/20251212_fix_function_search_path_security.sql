-- Migration: Fix search_path security warnings for all SECURITY DEFINER functions
-- This adds SET search_path = '' to prevent search_path injection attacks
-- Applied: 2025-12-12
-- Fixes 13 security warnings from Supabase linter

-- 1. create_wedding_team_chat
CREATE OR REPLACE FUNCTION public.create_wedding_team_chat()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  new_room_id UUID;
  existing_room UUID;
BEGIN
  IF NEW.onboarding_step IS NULL THEN
    SELECT id INTO existing_room 
    FROM public.chat_rooms 
    WHERE wedding_id = NEW.id AND type = 'wedding_team';
    
    IF existing_room IS NULL THEN
      IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.onboarding_step IS NOT NULL) THEN
        INSERT INTO public.chat_rooms (type, name, wedding_id)
        VALUES ('wedding_team', 'Wedding Team', NEW.id)
        RETURNING id INTO new_room_id;
        
        INSERT INTO public.chat_room_participants (room_id, profile_id, conversation_status)
        VALUES (new_room_id, NEW.bride_profile_id, 'active');
        
        RAISE NOTICE 'Created wedding_team chat % for wedding %', new_room_id, NEW.id;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$function$;

-- 2. get_contacted_pros_for_bride
CREATE OR REPLACE FUNCTION public.get_contacted_pros_for_bride(p_bride_id uuid)
 RETURNS TABLE(profile_id uuid, full_name text, avatar_url text, profession text, business_name text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
  SELECT DISTINCT
    p.id as profile_id,
    p.full_name,
    p.avatar_url,
    pd.profession,
    pd.business_name
  FROM public.chat_room_participants crp
  JOIN public.chat_rooms cr ON cr.id = crp.room_id
  JOIN public.profiles p ON p.id = crp.profile_id
  LEFT JOIN public.professional_details pd ON pd.profile_id = p.id
  WHERE cr.type = 'private'
    AND cr.id IN (
      SELECT room_id 
      FROM public.chat_room_participants 
      WHERE profile_id = p_bride_id
    )
    AND crp.profile_id != p_bride_id
    AND p.role = 'professional';
$function$;

-- 3. get_rooms_with_unread_counts
CREATE OR REPLACE FUNCTION public.get_rooms_with_unread_counts(p_limit integer DEFAULT 50)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  v_me uuid := auth.uid();
  items jsonb;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  WITH me_part AS (
    SELECT p.room_id, p.last_read_at, p.conversation_status, r.type, r.created_at as room_created_at
    FROM public.chat_room_participants p
    JOIN public.chat_rooms r ON r.id = p.room_id
    WHERE p.profile_id = v_me
      AND r.is_active = true
      AND p.conversation_status = 'active'
      AND r.type != 'wedding_team'
  ),
  last_msg AS (
    SELECT m.room_id,
           jsonb_build_object(
             'id', m.id,
             'type', m.message_type::text,
             'content', CASE WHEN m.message_type = 'text' THEN m.content ELSE NULL END,
             'attachment_url', m.attachment_url,
             'created_at', m.created_at
           ) AS msg
    FROM (
      SELECT DISTINCT ON (room_id)
             room_id, id, message_type, content, attachment_url, created_at
      FROM public.chat_messages
      WHERE is_deleted = false
      ORDER BY room_id, created_at DESC
    ) m
  ),
  unread AS (
    SELECT mp.room_id, count(*)::int AS unread_count
    FROM public.chat_messages m
    JOIN me_part mp ON mp.room_id = m.room_id
    WHERE m.is_deleted = false
      AND m.profile_id <> v_me
      AND (mp.last_read_at IS NULL OR m.created_at > mp.last_read_at)
    GROUP BY mp.room_id
  ),
  counterpart AS (
    SELECT mp.room_id,
           jsonb_build_object(
             'profile_id', pr.id,
             'full_name', pr.full_name,
             'avatar_url', pr.avatar_url,
             'role', pr.role::text
           ) AS data
    FROM me_part mp
    JOIN public.chat_room_participants p2 ON p2.room_id = mp.room_id AND p2.profile_id <> v_me
    JOIN public.profiles pr ON pr.id = p2.profile_id
    WHERE mp.type = 'private'
  ),
  pubmeta AS (
    SELECT mp.room_id,
           jsonb_build_object(
             'public_title', pcr.title,
             'public_cover', pcr.cover_image_url,
             'audience_role', pcr.audience_role::text
           ) AS data
    FROM me_part mp
    JOIN public.public_chat_rooms pcr ON pcr.chat_room_id = mp.room_id
    WHERE mp.type = 'public'
      AND pcr.is_active = true
  ),
  rows AS (
    SELECT mp.room_id,
           mp.type AS room_type,
           mp.conversation_status::text AS conversation_status,
           mp.room_created_at,
           COALESCE(u.unread_count, 0) AS unread_count,
           lm.msg AS last_msg,
           CASE WHEN mp.type = 'private' THEN c.data ELSE pm.data END AS meta
    FROM me_part mp
    LEFT JOIN unread u ON u.room_id = mp.room_id
    LEFT JOIN last_msg lm ON lm.room_id = mp.room_id
    LEFT JOIN counterpart c ON c.room_id = mp.room_id
    LEFT JOIN pubmeta pm ON pm.room_id = mp.room_id
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'roomId', r.room_id,
      'roomType', r.room_type,
      'conversationStatus', r.conversation_status,
      'unreadCount', r.unread_count,
      'lastMessageType', COALESCE(r.last_msg->>'type', ''),
      'lastMessageText', CASE
        WHEN (r.last_msg->>'type') = 'text' THEN COALESCE(r.last_msg->>'content', '')
        WHEN (r.last_msg->>'type') = 'image' THEN 'Photo'
        WHEN (r.last_msg->>'type') = 'audio' THEN 'Audio'
        ELSE ''
      END,
      'lastMessageAt', COALESCE(r.last_msg->>'created_at', r.room_created_at::text),
      'otherProfileId', r.meta->>'profile_id',
      'otherFullName', r.meta->>'full_name',
      'otherAvatarUrl', r.meta->>'avatar_url',
      'otherRole', r.meta->>'role',
      'publicTitle', r.meta->>'public_title',
      'publicCoverUrl', r.meta->>'public_cover',
      'audienceRole', r.meta->>'audience_role'
    )
    ORDER BY COALESCE((r.last_msg->>'created_at')::timestamptz, r.room_created_at) DESC
  )
  INTO items
  FROM rows r
  LIMIT GREATEST(COALESCE(p_limit, 50), 1);

  RETURN jsonb_build_object('items', COALESCE(items, '[]'::jsonb));
END;
$function$;

-- 4. manage_pro_in_wedding_team_chat
CREATE OR REPLACE FUNCTION public.manage_pro_in_wedding_team_chat()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  team_room_id UUID;
BEGIN
  SELECT id INTO team_room_id
  FROM public.chat_rooms
  WHERE wedding_id = NEW.wedding_id AND type = 'wedding_team';
  
  IF team_room_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status != 'active') THEN
    INSERT INTO public.chat_room_participants (room_id, profile_id, conversation_status)
    VALUES (team_room_id, NEW.professional_profile_id, 'active')
    ON CONFLICT (room_id, profile_id) DO UPDATE SET conversation_status = 'active';
    
    RAISE NOTICE 'Added pro % to wedding_team chat %', NEW.professional_profile_id, team_room_id;
  END IF;
  
  IF NEW.status IN ('left', 'excluded') AND OLD.status = 'active' THEN
    UPDATE public.chat_room_participants
    SET conversation_status = 'archived'
    WHERE room_id = team_room_id AND profile_id = NEW.professional_profile_id;
    
    RAISE NOTICE 'Archived pro % from wedding_team chat %', NEW.professional_profile_id, team_room_id;
  END IF;
  
  RETURN NEW;
END;
$function$;

-- 5. notify_crm_replays_change
CREATE OR REPLACE FUNCTION public.notify_crm_replays_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  payload JSONB;
  crm_url TEXT := 'https://pjcorrkwafjskmzmimon.supabase.co/functions/v1/sync-replays-from-app';
BEGIN
  payload := jsonb_build_object(
    'action', TG_OP,
    'replay', CASE 
      WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD)
      ELSE to_jsonb(NEW)
    END
  );

  PERFORM net.http_post(
    url := crm_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );

  RAISE NOTICE '[replays_sync] Sent % notification to CRM for replay %', TG_OP, COALESCE(NEW.id, OLD.id);

  RETURN COALESCE(NEW, OLD);
END;
$function$;

-- 6. notify_crm_wed_articles_change
CREATE OR REPLACE FUNCTION public.notify_crm_wed_articles_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  payload JSONB;
  pro_info JSONB;
  crm_url TEXT := 'https://pjcorrkwafjskmzmimon.supabase.co/functions/v1/sync-wed-articles-from-app';
BEGIN
  IF TG_OP = 'DELETE' THEN
    pro_info := '{}'::JSONB;
  ELSE
    SELECT jsonb_build_object(
      'email', NULL,
      'name', pd.business_name,
      'profession', pd.profession
    ) INTO pro_info
    FROM public.profiles p
    LEFT JOIN public.professional_details pd ON pd.profile_id = p.id
    WHERE p.id = NEW.linked_pro_profile_id;
  END IF;

  payload := jsonb_build_object(
    'action', TG_OP,
    'article', CASE 
      WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD)
      ELSE to_jsonb(NEW)
    END,
    'pro_info', COALESCE(pro_info, '{}'::JSONB)
  );

  PERFORM net.http_post(
    url := crm_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );

  RAISE NOTICE '[wed_articles_sync] Sent % notification to CRM for article %', TG_OP, COALESCE(NEW.id, OLD.id);

  RETURN COALESCE(NEW, OLD);
END;
$function$;

-- 7. notify_pro_added_to_wedding
CREATE OR REPLACE FUNCTION public.notify_pro_added_to_wedding()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status != 'active') THEN
    SELECT p.full_name, w.wedding_name INTO bride_name, wedding_name
    FROM public.weddings w
    JOIN public.profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;

    INSERT INTO public.notifications (
      recipient_profile_id,
      type,
      title,
      body,
      data
    ) VALUES (
      NEW.professional_profile_id,
      'wedding_team_invite',
      'Invitation à une équipe mariage',
      COALESCE(bride_name, 'Une mariée') || ' vous a ajouté à son équipe pour ' || COALESCE(wedding_name, 'son mariage'),
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'bride_name', bride_name,
        'wedding_name', wedding_name
      )
    );
  END IF;
  RETURN NEW;
END;
$function$;

-- 8. notify_pro_excluded_from_wedding
CREATE OR REPLACE FUNCTION public.notify_pro_excluded_from_wedding()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'excluded' AND OLD.status = 'active' THEN
    SELECT p.full_name, w.wedding_name INTO bride_name, wedding_name
    FROM public.weddings w
    JOIN public.profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;

    INSERT INTO public.notifications (
      recipient_profile_id,
      type,
      title,
      body,
      data
    ) VALUES (
      NEW.professional_profile_id,
      'wedding_team_removed',
      'Retrait d''une équipe mariage',
      'Vous avez été retiré de l''équipe de ' || COALESCE(bride_name, 'une mariée') || ' pour ' || COALESCE(wedding_name, 'son mariage'),
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'reason', NEW.excluded_reason
      )
    );
  END IF;
  RETURN NEW;
END;
$function$;

-- 9. notify_wedding_cancelled
CREATE OR REPLACE FUNCTION public.notify_wedding_cancelled()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  participant RECORD;
  bride_name TEXT;
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    SELECT display_name INTO bride_name
    FROM public.profiles WHERE id = NEW.bride_profile_id;
    
    FOR participant IN 
      SELECT professional_profile_id FROM public.wedding_participants 
      WHERE wedding_id = NEW.id AND status = 'active'
    LOOP
      PERFORM public.queue_wedding_notification(
        'wedding_cancelled',
        jsonb_build_object(
          'wedding_id', NEW.id,
          'recipient_id', participant.professional_profile_id,
          'bride_name', bride_name,
          'wedding_name', NEW.wedding_name
        )
      );
    END LOOP;
  END IF;
  RETURN NEW;
END;
$function$;

-- 10. notify_wedding_pro_added
CREATE OR REPLACE FUNCTION public.notify_wedding_pro_added()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status != 'active') THEN
    SELECT p.full_name, w.wedding_name INTO bride_name, wedding_name
    FROM public.weddings w
    JOIN public.profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;
    
    PERFORM public.queue_wedding_notification(
      'wedding_pro_added',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', NEW.professional_profile_id,
        'bride_name', bride_name,
        'wedding_name', wedding_name
      )
    );
  END IF;
  RETURN NEW;
END;
$function$;

-- 11. notify_wedding_pro_excluded
CREATE OR REPLACE FUNCTION public.notify_wedding_pro_excluded()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'excluded' AND OLD.status = 'active' THEN
    SELECT p.full_name, w.wedding_name INTO bride_name, wedding_name
    FROM public.weddings w
    JOIN public.profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;
    
    PERFORM public.queue_wedding_notification(
      'wedding_pro_excluded',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', NEW.professional_profile_id,
        'bride_name', bride_name,
        'wedding_name', wedding_name,
        'reason', NEW.excluded_reason
      )
    );
  END IF;
  RETURN NEW;
END;
$function$;

-- 12. notify_wedding_pro_left
CREATE OR REPLACE FUNCTION public.notify_wedding_pro_left()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  bride_id UUID;
  pro_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'left' AND OLD.status = 'active' THEN
    SELECT w.bride_profile_id, w.wedding_name INTO bride_id, wedding_name
    FROM public.weddings w WHERE w.id = NEW.wedding_id;
    
    SELECT full_name INTO pro_name
    FROM public.profiles WHERE id = NEW.professional_profile_id;
    
    PERFORM public.queue_wedding_notification(
      'wedding_pro_left',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', bride_id,
        'pro_name', pro_name,
        'wedding_name', wedding_name,
        'reason', NEW.left_reason
      )
    );
  END IF;
  RETURN NEW;
END;
$function$;

-- 13. queue_wedding_notification
CREATE OR REPLACE FUNCTION public.queue_wedding_notification(p_event_type text, p_payload jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
BEGIN
  INSERT INTO public.notifications_outbox (event_type, payload, event_key)
  VALUES (
    p_event_type,
    p_payload,
    p_event_type || '_' || COALESCE((p_payload->>'wedding_id')::TEXT, 'unknown') || '_' || extract(epoch from now())::TEXT
  );
END;
$function$;
