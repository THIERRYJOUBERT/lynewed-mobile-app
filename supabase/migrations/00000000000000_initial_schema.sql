


-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."alertStatus" AS ENUM (
    'active',
    'cancelled',
    'expired'
);


ALTER TYPE "public"."alertStatus" OWNER TO "postgres";


CREATE TYPE "public"."alert_type" AS ENUM (
    'backup_needed',
    'gear_emergency',
    'team_member',
    'emergency_help'
);


ALTER TYPE "public"."alert_type" OWNER TO "postgres";


CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'moderator'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE TYPE "public"."connectionRequestSource" AS ENUM (
    'fromWishlist',
    'fromWedding',
    'fromAlert',
    'fromProfile'
);


ALTER TYPE "public"."connectionRequestSource" OWNER TO "postgres";


CREATE TYPE "public"."connectionRequestStatus" AS ENUM (
    'pending',
    'accepted',
    'declined'
);


ALTER TYPE "public"."connectionRequestStatus" OWNER TO "postgres";


CREATE TYPE "public"."contentModerationStatus" AS ENUM (
    'pendingReview',
    'approved',
    'rejected'
);


ALTER TYPE "public"."contentModerationStatus" OWNER TO "postgres";


CREATE TYPE "public"."conversationStatus" AS ENUM (
    'pending',
    'active',
    'declined',
    'blocked',
    'reportedPending',
    'archived'
);


ALTER TYPE "public"."conversationStatus" OWNER TO "postgres";


CREATE TYPE "public"."messageType" AS ENUM (
    'text',
    'image',
    'audio'
);


ALTER TYPE "public"."messageType" OWNER TO "postgres";


CREATE TYPE "public"."notificationType" AS ENUM (
    'chatMessage',
    'connectionRequest',
    'connectionRequestAccepted',
    'connectionRequestDeclined',
    'wishlistAdd',
    'professionalAlert',
    'professionalAlertReminder24h',
    'videoIncoming',
    'wedPublished',
    'weddingPinMatch',
    'replayPublished',
    'broadcast'
);


ALTER TYPE "public"."notificationType" OWNER TO "postgres";


CREATE TYPE "public"."profession" AS ENUM (
    'PHOTOGRAPHER',
    'FILMMAKER',
    'PLANNER',
    'MAKEUP',
    'HAIRDRESSER',
    'DESIGNER',
    'BRIDALDESIGNER',
    'VENUE',
    'BRIDALSHOP',
    'FLORIST',
    'PHOTOMOVIE',
    'MAKEUPARTIST',
    'EVENTDESIGNER',
    'OTHER',
    'CATERER',
    'JEWELLER',
    'DJ',
    'STATIONER',
    'BRIDALWEARDESIGNER',
    'CONTENTCREATOR',
    'MUSIC',
    'STATIONERY'
);


ALTER TYPE "public"."profession" OWNER TO "postgres";


COMMENT ON TYPE "public"."profession" IS 'Profession types for professionals. DEPRECATED: DJ (use MUSIC), STATIONER (use STATIONERY)';



CREATE TYPE "public"."subscriptionTierType" AS ENUM (
    'inactive',
    'trial',
    'earlyAccess',
    'premiumVisibility',
    'ultimateAccess'
);


ALTER TYPE "public"."subscriptionTierType" OWNER TO "postgres";


CREATE TYPE "public"."userRole" AS ENUM (
    'bride',
    'professional'
);


ALTER TYPE "public"."userRole" OWNER TO "postgres";


CREATE TYPE "public"."videoSessionStatus" AS ENUM (
    'pending',
    'accepted',
    'declined',
    'missed',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."videoSessionStatus" OWNER TO "postgres";


CREATE TYPE "public"."wedding_participant_status" AS ENUM (
    'requested',
    'accepted',
    'declined'
);


ALTER TYPE "public"."wedding_participant_status" OWNER TO "postgres";


CREATE TYPE "public"."wedding_status" AS ENUM (
    'planning',
    'confirmed',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."wedding_status" OWNER TO "postgres";


CREATE TYPE "public"."wedding_visibility" AS ENUM (
    'private',
    'visible_to_pros'
);


ALTER TYPE "public"."wedding_visibility" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_req record;
  v_room_id uuid;
  v_existing_room uuid;
  v_message_id bigint;  -- Fixed: was uuid, should be bigint
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

  -- Insert the initial message from the contact request as the first message
  IF v_req.initial_message IS NOT NULL AND trim(v_req.initial_message) <> '' THEN
    INSERT INTO public.chat_messages (
      room_id,
      profile_id,
      message_type,
      content,
      created_at
    ) VALUES (
      v_room_id,
      v_req.pro_profile_id,  -- Message from the Pro who initiated the request
      'text',
      v_req.initial_message,
      v_req.created_at  -- Use the original request timestamp
    )
    RETURNING id INTO v_message_id;
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
$$;


ALTER FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_get_professional_details"() RETURNS TABLE("profile_id" "uuid", "business_name" "text", "description" "text", "portfolio_images" "text"[], "profession" "public"."profession", "created_at" timestamp with time zone, "budget_min" integer, "budget_max" integer, "instagram_url" "text", "website_url" "text", "slideshow_images" "text"[], "profile_video_url" "text", "currency" "text", "is_live" boolean, "is_pending" boolean, "location_city" "text", "location_country_code" "text", "location_label" "text", "profile" "jsonb", "fixed_locations" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  -- Restrict to admins only
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'ADMIN_ONLY';
  END IF;

  RETURN QUERY
  SELECT
    pd.profile_id,
    pd.business_name,
    pd.description,
    COALESCE(pd.portfolio_images, ARRAY[]::text[]),
    pd.profession,
    pd.created_at,
    pd.budget_min,
    pd.budget_max,
    pd.instagram_url,
    pd.website_url,
    COALESCE(pd.slideshow_images, ARRAY[]::text[]),
    pd.profile_video_url,
    pd.currency,
    pd.is_live,
    pd.is_pending,
    pd.location_city,
    pd.location_country_code,
    pd.location_label,
    jsonb_build_object(
      'full_name', pr.full_name,
      'avatar_url', pr.avatar_url
    ) AS profile,
    (
      SELECT COALESCE(
        jsonb_agg(jsonb_build_object('id', fl.id, 'label', fl.label) ORDER BY fl.created_at DESC),
        '[]'::jsonb
      )
      FROM public.professional_fixed_locations fl
      WHERE fl.professional_profile_id = pd.profile_id
    ) AS fixed_locations
  FROM public.professional_details pd
  LEFT JOIN public.profiles pr ON pr.id = pd.profile_id
  ORDER BY pd.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."admin_get_professional_details"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."alerts_rate_limit_before_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE cnt int;
BEGIN
  SELECT COUNT(*) INTO cnt
  FROM public.professional_alerts
  WHERE author_profile_id = NEW.author_profile_id
    AND status = 'active'
    AND (created_at::date = current_date);
  IF cnt >= 3 THEN
    RAISE EXCEPTION 'ALERTS_RATE_LIMIT_REACHED';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."alerts_rate_limit_before_insert"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auth_uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$ SELECT auth.uid(); $$;


ALTER FUNCTION "public"."auth_uid"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_populate_fixed_location_country_code"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  IF (NEW.location_country_code IS NULL OR NEW.location_country_code = '')
     AND NEW.location_coords IS NOT NULL 
     AND ST_X(NEW.location_coords) != 0 
     AND ST_Y(NEW.location_coords) != 0 THEN
    -- Qualification explicite avec public. pour éviter les problèmes de search_path
    NEW.location_country_code := public.get_country_code_from_coords(NEW.location_coords);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_populate_fixed_location_country_code"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."auto_populate_fixed_location_country_code"() IS 'Trigger pour auto-peupler location_country_code dans professional_fixed_locations. SÉCURISÉ avec search_path fixe.';



CREATE OR REPLACE FUNCTION "public"."auto_populate_location_country_code"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF (NEW.location_country_code IS NULL OR NEW.location_country_code = '')
     AND NEW.location_coords IS NOT NULL 
     AND ST_X(NEW.location_coords) != 0 
     AND ST_Y(NEW.location_coords) != 0 THEN
    NEW.location_country_code := public.get_country_code_from_coords(NEW.location_coords);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_populate_location_country_code"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."auto_populate_location_country_code"() IS 'DEPRECATED (04/12/2025): No longer used. location_country_code is synced from CRM.';



CREATE OR REPLACE FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_rows int := 0;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  UPDATE public.professional_alerts
  SET status = 'cancelled'
  WHERE id = p_alert_id
    AND author_profile_id = v_me
    AND status = 'active';

  GET DIAGNOSTICS v_rows = ROW_COUNT;
  RETURN v_rows > 0;
END;
$$;


ALTER FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_map_security_status"() RETURNS TABLE("check_name" "text", "check_status" "text", "details" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'RLS on weddings'::text,
    CASE WHEN relrowsecurity THEN 'PASS' ELSE 'FAIL' END::text,
    'Row Level Security must be enabled'::text
  FROM pg_class WHERE relname = 'weddings';

  RETURN QUERY
  SELECT 
    'RLS on professional_alerts'::text,
    CASE WHEN relrowsecurity THEN 'PASS' ELSE 'FAIL' END::text,
    'Row Level Security must be enabled'::text
  FROM pg_class WHERE relname = 'professional_alerts';

  RETURN QUERY
  SELECT 
    'RLS on professional_fixed_locations'::text,
    CASE WHEN relrowsecurity THEN 'PASS' ELSE 'FAIL' END::text,
    'Row Level Security must be enabled'::text
  FROM pg_class WHERE relname = 'professional_fixed_locations';

  RETURN QUERY
  SELECT 
    'Expired alerts cleanup'::text,
    CASE WHEN count(*) = 0 THEN 'PASS' ELSE 'WARN' END::text,
    format('%s expired alerts still active', count(*))::text
  FROM public.professional_alerts pa
  WHERE pa.status = 'active' AND pa.expires_at < now() AND pa.is_deleted = false;

  RETURN QUERY
  SELECT 
    'Past weddings visibility'::text,
    CASE WHEN count(*) = 0 THEN 'PASS' ELSE 'INFO' END::text,
    format('%s weddings with past event dates', count(*))::text
  FROM public.weddings w
  WHERE w.event_date < CURRENT_DATE 
    AND (w.event_end_date IS NULL OR w.event_end_date < CURRENT_DATE)
    AND w.is_deleted = false
    AND w.status IN ('planning', 'confirmed');
END;
$$;


ALTER FUNCTION "public"."check_map_security_status"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."notifications_outbox" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "event_type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "attempts" integer DEFAULT 0 NOT NULL,
    "last_error" "text",
    "processed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "event_key" "text" NOT NULL,
    "claimed_at" timestamp with time zone,
    "claimed_by" "text"
);


ALTER TABLE "public"."notifications_outbox" OWNER TO "postgres";


COMMENT ON TABLE "public"."notifications_outbox" IS 'Queue pour notifications push/in-app. Les events sont claim par l''edge function notifications_outbox_drain qui tourne toutes les 30 secondes via cron job.';



CREATE OR REPLACE FUNCTION "public"."claim_outbox_events"("p_batch_size" integer DEFAULT 100, "p_claim_ttl_minutes" integer DEFAULT 5, "p_worker_id" "text" DEFAULT NULL::"text") RETURNS SETOF "public"."notifications_outbox"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$-- VERSION CORRIGÉE par Flowbase Architect

DECLARE
  v_worker text := COALESCE(p_worker_id, 'worker-'||substring(replace(gen_random_uuid()::text,'-',''),1,12));
BEGIN
  RETURN QUERY
  WITH c AS (
    SELECT id
    FROM public.notifications_outbox
    WHERE 
      processed_at IS NULL
      AND attempts < 5 -- <<< LA MODIFICATION EST ICI
      AND (claimed_at IS NULL OR claimed_at < now() - (make_interval(mins => GREATEST(p_claim_ttl_minutes, 1))))
    ORDER BY created_at
    LIMIT COALESCE(p_batch_size, 100)
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.notifications_outbox n
     SET claimed_at = now(),
         claimed_by = v_worker
  FROM c
  WHERE n.id = c.id
  RETURNING n.*;
END;$$;


ALTER FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."claim_single_outbox_event"("p_event_id" "uuid", "p_worker_id" "text") RETURNS SETOF "public"."notifications_outbox"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  RETURN QUERY
  UPDATE public.notifications_outbox
  SET claimed_at = now(),
      claimed_by = p_worker_id
  WHERE id = p_event_id
    AND processed_at IS NULL
  RETURNING *;
END;
$$;


ALTER FUNCTION "public"."claim_single_outbox_event"("p_event_id" "uuid", "p_worker_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_abandoned_video_sessions"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  -- Marquer comme 'missed' les sessions pending ou accepted de plus de 5 minutes
  UPDATE public.video_sessions
  SET status = 'missed'
  WHERE status IN ('pending', 'accepted')
    AND created_at < NOW() - INTERVAL '5 minutes';
    
  -- Log pour debug (optionnel)
  RAISE NOTICE 'Video sessions cleanup executed at %', NOW();
END;
$$;


ALTER FUNCTION "public"."cleanup_abandoned_video_sessions"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."cleanup_abandoned_video_sessions"() IS 'Nettoie les sessions vidéo abandonnées (pending/accepted) de plus de 5 minutes. À appeler via un cron job toutes les 5 minutes.';



CREATE OR REPLACE FUNCTION "public"."cleanup_old_notifications"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  DELETE FROM public.notifications WHERE is_read = true AND created_at < now() - interval '90 days';
END;
$$;


ALTER FUNCTION "public"."cleanup_old_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."conn_req_before_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE pro_tier public."subscriptionTierType" := public.get_tier_of(NEW.pro_profile_id);
BEGIN
  -- Sources (updated to new enum values):
  -- 'fromWishlist' -> pro must ultimateAccess
  IF NEW.source = 'fromWishlist' AND pro_tier <> 'ultimateAccess' THEN
    RAISE EXCEPTION 'ULTIMATE_REQUIRED_FOR_WISHLIST';
  END IF;

  -- 'fromWedding' -> pro must premiumVisibility or ultimateAccess
  IF NEW.source = 'fromWedding' AND pro_tier NOT IN ('premiumVisibility','ultimateAccess') THEN
    RAISE EXCEPTION 'PREMIUM_OR_ULTIMATE_REQUIRED_FOR_PIN';
  END IF;

  -- 'fromProfile','fromAlert' -> pro must premiumVisibility or ultimateAccess
  IF NEW.source IN ('fromProfile','fromAlert') AND pro_tier NOT IN ('premiumVisibility','ultimateAccess') THEN
    RAISE EXCEPTION 'PREMIUM_OR_ULTIMATE_REQUIRED_FOR_CONTACT';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."conn_req_before_insert"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") RETURNS numeric
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE v_rate numeric;
BEGIN
  IF p_amount IS NULL OR p_currency IS NULL OR upper(p_currency) = 'EUR' THEN
    RETURN p_amount;
  END IF;

  -- Tente taux du jour
  SELECT rate INTO v_rate
  FROM public.fx_rates
  WHERE code = upper(p_currency) AND valid_on = current_date;

  IF v_rate IS NULL THEN
    -- Prend le plus récent
    SELECT rate INTO v_rate
    FROM public.fx_rates
    WHERE code = upper(p_currency)
    ORDER BY valid_on DESC
    LIMIT 1;
  END IF;

  IF v_rate IS NULL THEN
    -- Fallback: si pas de taux connu, retourne p_amount (ou NULL)
    RETURN NULL;
  END IF;

  RETURN p_amount / v_rate;
END;
$$;


ALTER FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_alert"("p_alert_type" "text" DEFAULT 'backup_needed'::"text", "p_title" "text" DEFAULT ''::"text", "p_message" "text" DEFAULT ''::"text", "p_event_date" "date" DEFAULT NULL::"date", "p_location_lat" double precision DEFAULT NULL::double precision, "p_location_lng" double precision DEFAULT NULL::double precision, "p_location_label" "text" DEFAULT ''::"text", "p_radius_km" integer DEFAULT 50, "p_profession_needed" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole";
  v_my_country text;
  v_alert_count integer;
  v_new_alert_id uuid;
  v_location_coords extensions.geometry;
  v_expires_at timestamptz;
  v_alert_type_enum public.alert_type;
  v_profession_enum public.profession;
BEGIN
  -- Check authentication
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Get user role
  SELECT role INTO v_role FROM public.profiles WHERE id = v_me;
  IF v_role != 'professional' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only professionals can create alerts');
  END IF;

  -- Get user country for market separation
  SELECT CASE WHEN UPPER(p.country) IN ('INDIA', 'IN') THEN 'IN' ELSE p.country END
  INTO v_my_country
  FROM public.profiles p
  WHERE p.id = v_me;

  -- INDIAN MARKET RESTRICTION
  IF UPPER(v_my_country) = 'IN' AND p_location_lat IS NOT NULL AND p_location_lng IS NOT NULL THEN
    IF p_location_lat < 6 OR p_location_lat > 36 OR p_location_lng < 68 OR p_location_lng > 98 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Indian users can only create alerts in India');
    END IF;
  END IF;

  -- Validate title
  IF p_title IS NULL OR length(trim(p_title)) < 5 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Title must be at least 5 characters');
  END IF;
  IF length(p_title) > 100 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Title must be 100 characters or less');
  END IF;

  -- Validate event date
  IF p_event_date IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Event date is required');
  END IF;
  IF p_event_date < CURRENT_DATE THEN
    RETURN jsonb_build_object('success', false, 'error', 'Event date must be in the future');
  END IF;

  -- Check max 3 active alerts per pro
  SELECT COUNT(*) INTO v_alert_count
  FROM public.professional_alerts
  WHERE author_profile_id = v_me
    AND status = 'active'
    AND expires_at > now()
    AND is_deleted = false;
  
  IF v_alert_count >= 3 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Maximum 3 active alerts allowed');
  END IF;

  -- Validate coordinates
  IF p_location_lat IS NOT NULL AND p_location_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_location_lat, p_location_lng) THEN
      RETURN jsonb_build_object('success', false, 'error', 'Invalid coordinates');
    END IF;
    v_location_coords := extensions.ST_SetSRID(extensions.ST_MakePoint(p_location_lng, p_location_lat), 4326);
  END IF;

  -- Validate radius
  IF p_radius_km NOT IN (10, 20, 30, 50, 100) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Radius must be 10, 20, 30, 50, or 100 km');
  END IF;

  -- Convert alert type string to enum
  BEGIN
    v_alert_type_enum := p_alert_type::public.alert_type;
  EXCEPTION WHEN OTHERS THEN
    v_alert_type_enum := 'backup_needed'::public.alert_type;
  END;

  -- Convert profession string to enum (if provided)
  IF p_profession_needed IS NOT NULL AND p_profession_needed != '' THEN
    BEGIN
      v_profession_enum := p_profession_needed::public.profession;
    EXCEPTION WHEN OTHERS THEN
      v_profession_enum := NULL;
    END;
  END IF;

  -- Calculate expiration (event_date + 1 day at 23:59:59)
  v_expires_at := (p_event_date + interval '1 day')::date + interval '23 hours 59 minutes 59 seconds';

  -- Insert alert into professional_alerts table
  INSERT INTO public.professional_alerts (
    author_profile_id,
    alert_type,
    title,
    message,
    event_date,
    location_coords,
    location_label,
    radius_km,
    profession_needed,
    status,
    expires_at
  ) VALUES (
    v_me,
    v_alert_type_enum,
    trim(p_title),
    trim(COALESCE(p_message, '')),
    p_event_date,
    v_location_coords,
    COALESCE(p_location_label, ''),
    p_radius_km,
    v_profession_enum,
    'active',
    v_expires_at
  ) RETURNING id INTO v_new_alert_id;

  RETURN jsonb_build_object(
    'success', true,
    'id', v_new_alert_id,
    'expires_at', v_expires_at
  );
END;
$$;


ALTER FUNCTION "public"."create_alert"("p_alert_type" "text", "p_title" "text", "p_message" "text", "p_event_date" "date", "p_location_lat" double precision, "p_location_lng" double precision, "p_location_label" "text", "p_radius_km" integer, "p_profession_needed" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_contact_request"("p_target_id" "uuid", "p_source" "text", "p_message" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
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
$$;


ALTER FUNCTION "public"."create_contact_request"("p_target_id" "uuid", "p_source" "text", "p_message" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_next_notifications_partition"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
  -- Calcule les dates pour le mois prochain
  start_date date := date_trunc('month', now() + interval '1 month')::date;
  end_date date := (date_trunc('month', now() + interval '1 month') + interval '1 month')::date;
  -- Construit le nom de la table de partition, ex: 'notifications_2024_08'
  part_name text := 'notifications_' || to_char(start_date, 'YYYY_MM');
BEGIN
  -- 1. Crée la table de partition pour le mois suivant si elle n'existe pas déjà.
  EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF public.notifications FOR VALUES FROM (%L) TO (%L)', part_name, start_date, end_date);

  -- 2. (AMÉLIORATION) Crée l'index qui sert de clé primaire sur la nouvelle partition.
  --    `CONCURRENTLY` évite de bloquer la table (bonne pratique).
  EXECUTE format('CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS %I ON public.%I (id, created_at)', part_name || '_pkey', part_name);

  -- 3. (AMÉLIORATION) Crée l'index de performance pour lire rapidement les notifications non lues.
  EXECUTE format('CREATE INDEX CONCURRENTLY IF NOT EXISTS %I ON public.%I (profile_id, created_at DESC) WHERE (is_read = false)', part_name || '_unread_idx', part_name);

  -- Affiche un message dans les logs de la base de données pour confirmer l'exécution.
  RAISE NOTICE 'Partition % created and indexed successfully.', part_name;
END;
$$;


ALTER FUNCTION "public"."create_next_notifications_partition"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_dur_hours int;
  v_title text;
  v_id uuid;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  -- Valide que la date de fin est dans le futur
  IF p_end_at IS NULL OR p_end_at <= now() THEN
    RAISE EXCEPTION 'END_AT_INVALID' USING HINT = 'The end date must be in the future.';
  END IF;
  
  -- Calcule la durée en heures (arrondi à l'heure supérieure)
  v_dur_hours := CEIL(EXTRACT(EPOCH FROM (p_end_at - now())) / 3600.0);

  -- Récupère le titre depuis le motif (fallback sur 'Alert')
  SELECT COALESCE(am.name_en, 'Alert') INTO v_title
  FROM public.alert_motifs am WHERE am.code = p_motif_code;

  INSERT INTO public.professional_alerts(
    id, author_profile_id, title, message, location_coords, location_label,
    radius_km, duration_hours, status, is_deleted, motif_code
  )
  VALUES (
    gen_random_uuid(),
    v_me,
    COALESCE(v_title, 'Alert'),
    LEFT(COALESCE(p_message,''), 150),
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326),
    COALESCE(p_location_label,''),
    100,                      -- Rayon par défaut de 100 km
    v_dur_hours::smallint,    -- Le trigger `set_professional_alert_expiry` utilisera cette valeur
    'active',
    false,
    p_motif_code
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_user_with_id"("p_id" "uuid", "p_email" "text", "p_encrypted_password" "text", "p_email_confirmed_at" timestamp with time zone, "p_raw_user_meta_data" "jsonb", "p_raw_app_meta_data" "jsonb", "p_created_at" timestamp with time zone) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change_token_current
  ) VALUES (
    p_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    p_email,
    p_encrypted_password,
    p_email_confirmed_at,
    COALESCE(p_raw_user_meta_data, '{}'::jsonb),
    COALESCE(p_raw_app_meta_data, '{}'::jsonb),
    p_created_at,
    now(),
    '',
    '',
    '',
    ''
  );
END;
$$;


ALTER FUNCTION "public"."create_user_with_id"("p_id" "uuid", "p_email" "text", "p_encrypted_password" "text", "p_email_confirmed_at" timestamp with time zone, "p_raw_user_meta_data" "jsonb", "p_raw_app_meta_data" "jsonb", "p_created_at" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
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
$$;


ALTER FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_alert"("p_alert_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_alert record;
BEGIN
  -- Check authentication
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Get alert and verify ownership
  SELECT * INTO v_alert
  FROM public.professional_alerts
  WHERE id = p_alert_id
    AND is_deleted = false;

  IF v_alert IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Alert not found');
  END IF;

  IF v_alert.author_profile_id != v_me THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authorized to delete this alert');
  END IF;

  -- Soft delete
  UPDATE public.professional_alerts
  SET 
    is_deleted = true,
    status = 'cancelled'
  WHERE id = p_alert_id;

  RETURN jsonb_build_object('success', true, 'alertId', p_alert_id);
END;
$$;


ALTER FUNCTION "public"."delete_alert"("p_alert_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_current_device_token"("device_token" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Supprimer le token fourni
  -- On ne vérifie pas profile_id car l'utilisateur peut être déconnecté
  -- La sécurité vient du fait que seul l'appareil ayant le token peut le supprimer
  DELETE FROM device_tokens
  WHERE token = device_token;
END;
$$;


ALTER FUNCTION "public"."delete_current_device_token"("device_token" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."delete_current_device_token"("device_token" "text") IS 'Supprime le token de l''appareil actuel. Peut être appelé même après déconnexion.';



CREATE OR REPLACE FUNCTION "public"."delete_my_device_tokens"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Cette fonction requiert que l'utilisateur soit authentifié
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Supprimer tous les tokens de l'utilisateur actuel
  DELETE FROM device_tokens
  WHERE profile_id = auth.uid();
END;
$$;


ALTER FUNCTION "public"."delete_my_device_tokens"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."delete_my_device_tokens"() IS 'Supprime tous les tokens de l''utilisateur connecté. Doit être appelé AVANT la déconnexion.';



CREATE OR REPLACE FUNCTION "public"."delete_my_wedding"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
BEGIN
  UPDATE public.weddings
  SET is_deleted = true, updated_at = now()
  WHERE bride_profile_id = v_me
    AND is_deleted = false;

  RETURN jsonb_build_object('success', true);
END;
$$;


ALTER FUNCTION "public"."delete_my_wedding"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_deleted int := 0;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  -- Soft-delete pour la cohérence des données (un pro pourrait essayer de contacter un pin supprimé)
  UPDATE public.wedding_pins
  SET is_deleted = true, is_active = false
  WHERE id = p_pin_id AND bride_profile_id = v_me AND is_deleted = false;

  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN v_deleted > 0;
END;
$$;


ALTER FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."expire_alerts"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.professional_alerts SET status='expired'
  WHERE status='active' AND expires_at < now();
END;
$$;


ALTER FUNCTION "public"."expire_alerts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."expire_trials"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.professional_subscriptions
  SET subscription_tier = 'inactive'
  WHERE subscription_tier = 'trial' AND trial_ends_at < now();
END;
$$;


ALTER FUNCTION "public"."expire_trials"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."geocode_city_to_point"("city_name" "text") RETURNS "extensions"."geometry"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog', 'extensions', 'public'
    AS $$
BEGIN
    -- Note: La fonction tiger.geocode n'existe pas dans cette base
    -- Cette fonction retourne un point par défaut (0,0)
    -- Si vous avez besoin de géocodage réel, utilisez une API externe
    RETURN ST_SetSRID(ST_MakePoint(0, 0), 4326);
END;
$$;


ALTER FUNCTION "public"."geocode_city_to_point"("city_name" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."geocode_city_to_point"("city_name" "text") IS 'Fonction de géocodage (actuellement retourne 0,0 car tiger.geocode non disponible). Non utilisée dans l''application. Sécurisé avec search_path fixe.';



CREATE OR REPLACE FUNCTION "public"."get_active_alerts_for_market"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_my_market text := public.get_my_market_region();
  v_alerts jsonb;
BEGIN
  IF v_me IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', a.id,
      'alertType', a.alert_type,
      'title', a.title,
      'message', a.message,
      'eventDate', a.event_date,
      'locationLabel', a.location_label,
      'professionNeeded', a.profession_needed,
      'status', a.status,
      'expiresAt', a.expires_at,
      'createdAt', a.created_at,
      'authorProfileId', a.author_profile_id,
      'authorFullName', pr.full_name,
      'authorAvatarUrl', pr.avatar_url,
      'authorProfession', pd.profession,
      'isOwn', a.author_profile_id = v_me
    )
    ORDER BY a.created_at DESC
  ), '[]'::jsonb)
  INTO v_alerts
  FROM public.professional_alerts a
  JOIN public.profiles pr ON pr.id = a.author_profile_id
  LEFT JOIN public.professional_details pd ON pd.profile_id = a.author_profile_id
  WHERE a.status = 'active'
    AND a.is_deleted = false
    AND a.expires_at > now()
    AND public.is_visible_in_market(pd.location_country_code, v_my_market);

  RETURN v_alerts;
END;
$$;


ALTER FUNCTION "public"."get_active_alerts_for_market"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_alert record;
  v_author record;
  v_is_own boolean;
  v_is_contactable boolean;
BEGIN
  -- Get alert
  SELECT * INTO v_alert
  FROM public.professional_alerts
  WHERE id = p_alert_id
    AND is_deleted = false;

  IF v_alert IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get author details (using full_name instead of first_name/last_name)
  SELECT 
    pr.id,
    pr.avatar_url,
    pr.full_name,
    pd.profession
  INTO v_author
  FROM public.profiles pr
  LEFT JOIN public.professional_details pd ON pd.profile_id = pr.id
  WHERE pr.id = v_alert.author_profile_id;

  v_is_own := v_me IS NOT NULL AND v_alert.author_profile_id = v_me;
  v_is_contactable := v_me IS NOT NULL AND NOT v_is_own;

  RETURN jsonb_build_object(
    'alertId', v_alert.id,
    'alertType', v_alert.alert_type,
    'motifCode', v_alert.motif_code,
    'motifLabel', COALESCE(
      (SELECT name_en FROM public.alert_motifs WHERE code = v_alert.motif_code),
      v_alert.alert_type::text
    ),
    'title', v_alert.title,
    'message', v_alert.message,
    'eventDate', v_alert.event_date,
    'professionNeeded', v_alert.profession_needed,
    'locationLabel', v_alert.location_label,
    'startAt', v_alert.created_at,
    'endAt', v_alert.expires_at,
    'status', v_alert.status,
    'authorProfileId', v_author.id,
    'authorAvatarUrl', v_author.avatar_url,
    'authorFullName', v_author.full_name,
    'authorProfession', v_author.profession,
    'isOwn', v_is_own,
    'isContactable', v_is_contactable
  );
END;
$$;


ALTER FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_bride_interest_items"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$DECLARE 
  v_me uuid := auth.uid(); 
  v_role public."userRole"; 
  out_items jsonb := '[]'::jsonb;
  v_bride_avatar_url text;
BEGIN 
  IF v_me IS NULL THEN 
    RAISE EXCEPTION 'AUTH_REQUIRED'; 
  END IF; 
  
  SELECT role INTO v_role FROM public.profiles WHERE id = v_me; 
  
  IF v_role <> 'bride' THEN 
    RETURN '[]'::jsonb; 
  END IF; 
  
  -- Récupérer l'avatar de la bride
  SELECT avatar_url INTO v_bride_avatar_url
  FROM public.profiles  -- ✅ CORRECTION: profiles au lieu de public_profiles
  WHERE id = v_me;
  
  -- 1) POIs privés (user_pois)
  out_items := out_items || COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'source', 'poiPrivate', 
        'poiId', p.id::text, 
        'weddingPinId', null, 
        'locationLabel', COALESCE(NULLIF(p.label, ''), p.location_label), 
        'center', ST_AsGeoJSON(p.coords)::jsonb, 
        'radiusKm', p.radius_km, 
        'professionsNeeded', CASE 
          WHEN p.professions IS NULL THEN '[]'::jsonb 
          ELSE to_jsonb(ARRAY(SELECT x::text FROM unnest(p.professions) AS x)) 
        END, 
        'eventStartDate', p.event_start_date,
        'budgetMin', p.budget_min, 
        'budgetMax', p.budget_max, 
        'currency', p.currency, 
        'brideProfileId', v_me::text, 
        'isContactable', false, 
        'createdAt', p.created_at,
        'brideAvatarUrl', v_bride_avatar_url
      )
    ) 
    FROM public.user_pois p 
    WHERE p.bride_profile_id = v_me
  ), '[]'::jsonb); 
  
  -- 2) Wedding pins publics
  out_items := out_items || COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'source', 'weddingPin', 
        'poiId', null, 
        'weddingPinId', wp.id::text, 
        'locationLabel', wp.location_label, 
        'center', ST_AsGeoJSON(wp.location_coords)::jsonb, 
        'radiusKm', wp.radius_km, 
        'professionsNeeded', CASE 
          WHEN wp.professions_needed IS NULL THEN '[]'::jsonb 
          ELSE to_jsonb(ARRAY(SELECT x::text FROM unnest(wp.professions_needed) AS x)) 
        END, 
        'eventStartDate', wp.event_start_date,
        'budgetMin', wp.budget_min, 
        'budgetMax', wp.budget_max, 
        'currency', wp.currency, 
        'brideProfileId', wp.bride_profile_id::text, 
        'isContactable', false, 
        'createdAt', wp.created_at,
        'brideAvatarUrl', v_bride_avatar_url
      )
    ) 
    FROM public.wedding_pins wp 
    WHERE wp.bride_profile_id = v_me 
      AND wp.is_deleted = false 
      AND wp.is_active = true
  ), '[]'::jsonb); 
  
  RETURN out_items; 
END;$$;


ALTER FUNCTION "public"."get_bride_interest_items"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  RETURN CASE p_profession
    WHEN 'PHOTOGRAPHER' THEN '#9C27B0'
    WHEN 'FILMMAKER' THEN '#3F51B5'
    WHEN 'PLANNER' THEN '#009688'
    WHEN 'MAKEUP' THEN '#E91E63'
    WHEN 'HAIRDRESSER' THEN '#FF9800'
    WHEN 'DESIGNER' THEN '#607D8B'
    WHEN 'BRIDALDESIGNER' THEN '#795548'
    WHEN 'VENUE' THEN '#4CAF50'
    WHEN 'BRIDALSHOP' THEN '#00BCD4'
    WHEN 'FLORIST' THEN '#8BC34A'
    ELSE '#000000' -- Noir par défaut
  END;
END;
$$;


ALTER FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_country_code_from_coords"("coords" "extensions"."geometry") RETURNS "text"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'extensions, public'
    AS $$
DECLARE
  lat double precision;
  lon double precision;
BEGIN
  -- Extraire latitude et longitude avec qualification explicite
  lat := extensions.ST_Y(coords);
  lon := extensions.ST_X(coords);
  
  -- Monaco
  IF lat BETWEEN 43.72 AND 43.76 AND lon BETWEEN 7.40 AND 7.44 THEN RETURN 'MC'; END IF;
  IF lat BETWEEN 49.45 AND 50.18 AND lon BETWEEN 5.73 AND 6.53 THEN RETURN 'LU'; END IF;
  IF lat BETWEEN 47.05 AND 47.27 AND lon BETWEEN 9.47 AND 9.63 THEN RETURN 'LI'; END IF;
  IF lat BETWEEN 42.43 AND 42.66 AND lon BETWEEN 1.41 AND 1.79 THEN RETURN 'AD'; END IF;
  IF lat BETWEEN 43.89 AND 43.99 AND lon BETWEEN 12.40 AND 12.52 THEN RETURN 'SM'; END IF;
  IF lat BETWEEN 41.90 AND 41.91 AND lon BETWEEN 12.45 AND 12.46 THEN RETURN 'VA'; END IF;
  IF lat BETWEEN 35.80 AND 36.08 AND lon BETWEEN 14.18 AND 14.58 THEN RETURN 'MT'; END IF;
  
  -- DOM-TOM
  IF lat BETWEEN 15.83 AND 16.51 AND lon BETWEEN -61.81 AND -61.00 THEN RETURN 'GP'; END IF;
  IF lat BETWEEN 14.39 AND 14.88 AND lon BETWEEN -61.23 AND -60.81 THEN RETURN 'MQ'; END IF;
  IF lat BETWEEN 2.11 AND 5.78 AND lon BETWEEN -54.60 AND -51.61 THEN RETURN 'GF'; END IF;
  IF lat BETWEEN -21.39 AND -20.87 AND lon BETWEEN 55.22 AND 55.84 THEN RETURN 'RE'; END IF;
  IF lat BETWEEN -13.00 AND -12.64 AND lon BETWEEN 45.04 AND 45.30 THEN RETURN 'YT'; END IF;
  IF lat BETWEEN -22.70 AND -20.00 AND lon BETWEEN 164.03 AND 167.00 THEN RETURN 'NC'; END IF;
  IF lat BETWEEN -27.93 AND -7.90 AND lon BETWEEN -154.70 AND -134.93 THEN RETURN 'PF'; END IF;
  IF lat BETWEEN 46.75 AND 47.15 AND lon BETWEEN -56.40 AND -56.10 THEN RETURN 'PM'; END IF;
  IF lat BETWEEN -14.40 AND -13.15 AND lon BETWEEN -178.20 AND -176.10 THEN RETURN 'WF'; END IF;
  IF lat BETWEEN 17.88 AND 17.97 AND lon BETWEEN -62.88 AND -62.78 THEN RETURN 'BL'; END IF;
  IF lat BETWEEN 18.04 AND 18.13 AND lon BETWEEN -63.15 AND -63.00 THEN RETURN 'MF'; END IF;
  
  IF lat BETWEEN 45.82 AND 47.81 AND lon BETWEEN 5.96 AND 10.49 THEN RETURN 'CH'; END IF;
  IF lat BETWEEN 49.50 AND 51.51 AND lon BETWEEN 2.54 AND 6.41 THEN RETURN 'BE'; END IF;
  IF lat BETWEEN 50.75 AND 53.55 AND lon BETWEEN 3.36 AND 7.23 THEN RETURN 'NL'; END IF;
  IF lat BETWEEN 36.96 AND 42.15 AND lon BETWEEN -9.50 AND -6.19 THEN RETURN 'PT'; END IF;
  IF lat BETWEEN 36.00 AND 43.79 AND lon BETWEEN -9.30 AND 3.32 THEN RETURN 'ES'; END IF;
  IF lat BETWEEN 41.33 AND 51.09 AND lon BETWEEN -5.14 AND 9.56 THEN RETURN 'FR'; END IF;
  IF lat BETWEEN 49.96 AND 60.86 AND lon BETWEEN -8.18 AND 1.76 THEN RETURN 'GB'; END IF;
  IF lat BETWEEN 51.45 AND 55.43 AND lon BETWEEN -10.48 AND -5.99 THEN RETURN 'IE'; END IF;
  IF lat BETWEEN 63.30 AND 66.57 AND lon BETWEEN -24.54 AND -13.50 THEN RETURN 'IS'; END IF;
  IF lat BETWEEN 47.27 AND 55.06 AND lon BETWEEN 5.87 AND 15.04 THEN RETURN 'DE'; END IF;
  IF lat BETWEEN 46.37 AND 49.02 AND lon BETWEEN 9.53 AND 17.16 THEN RETURN 'AT'; END IF;
  IF lat BETWEEN 49.00 AND 54.84 AND lon BETWEEN 14.12 AND 24.15 THEN RETURN 'PL'; END IF;
  IF lat BETWEEN 48.55 AND 51.06 AND lon BETWEEN 12.09 AND 18.86 THEN RETURN 'CZ'; END IF;
  IF lat BETWEEN 47.73 AND 49.61 AND lon BETWEEN 16.83 AND 22.56 THEN RETURN 'SK'; END IF;
  IF lat BETWEEN 45.74 AND 48.58 AND lon BETWEEN 16.11 AND 22.90 THEN RETURN 'HU'; END IF;
  IF lat BETWEEN 36.65 AND 47.09 AND lon BETWEEN 6.63 AND 18.52 THEN RETURN 'IT'; END IF;
  IF lat BETWEEN 34.80 AND 41.75 AND lon BETWEEN 19.37 AND 28.24 THEN RETURN 'GR'; END IF;
  IF lat BETWEEN 42.39 AND 46.55 AND lon BETWEEN 13.49 AND 19.43 THEN RETURN 'HR'; END IF;
  IF lat BETWEEN 45.42 AND 46.88 AND lon BETWEEN 13.38 AND 16.61 THEN RETURN 'SI'; END IF;
  IF lat BETWEEN 42.56 AND 45.27 AND lon BETWEEN 15.73 AND 19.62 THEN RETURN 'BA'; END IF;
  IF lat BETWEEN 42.23 AND 46.19 AND lon BETWEEN 18.82 AND 23.00 THEN RETURN 'RS'; END IF;
  IF lat BETWEEN 41.85 AND 43.57 AND lon BETWEEN 18.43 AND 20.36 THEN RETURN 'ME'; END IF;
  IF lat BETWEEN 39.65 AND 42.66 AND lon BETWEEN 19.26 AND 21.07 THEN RETURN 'AL'; END IF;
  IF lat BETWEEN 40.86 AND 42.36 AND lon BETWEEN 20.46 AND 23.04 THEN RETURN 'MK'; END IF;
  IF lat BETWEEN 41.24 AND 44.22 AND lon BETWEEN 22.36 AND 28.61 THEN RETURN 'BG'; END IF;
  IF lat BETWEEN 43.62 AND 48.27 AND lon BETWEEN 20.26 AND 29.71 THEN RETURN 'RO'; END IF;
  IF lat BETWEEN 57.98 AND 71.19 AND lon BETWEEN 4.65 AND 31.08 THEN RETURN 'NO'; END IF;
  IF lat BETWEEN 55.34 AND 69.06 AND lon BETWEEN 11.12 AND 24.17 THEN RETURN 'SE'; END IF;
  IF lat BETWEEN 59.81 AND 70.09 AND lon BETWEEN 20.55 AND 31.59 THEN RETURN 'FI'; END IF;
  IF lat BETWEEN 54.56 AND 57.75 AND lon BETWEEN 8.08 AND 15.19 THEN RETURN 'DK'; END IF;
  IF lat BETWEEN 57.52 AND 59.68 AND lon BETWEEN 21.76 AND 28.21 THEN RETURN 'EE'; END IF;
  IF lat BETWEEN 55.68 AND 58.09 AND lon BETWEEN 20.97 AND 28.24 THEN RETURN 'LV'; END IF;
  IF lat BETWEEN 53.90 AND 56.45 AND lon BETWEEN 20.94 AND 26.84 THEN RETURN 'LT'; END IF;
  IF lat BETWEEN 41.19 AND 81.86 AND lon BETWEEN 19.64 AND 180.00 THEN RETURN 'RU'; END IF;
  IF lat BETWEEN 44.39 AND 52.38 AND lon BETWEEN 22.13 AND 40.23 THEN RETURN 'UA'; END IF;
  IF lat BETWEEN 51.26 AND 56.17 AND lon BETWEEN 23.18 AND 32.77 THEN RETURN 'BY'; END IF;
  IF lat BETWEEN 45.47 AND 48.49 AND lon BETWEEN 26.62 AND 30.14 THEN RETURN 'MD'; END IF;
  IF lat BETWEEN 27.66 AND 35.92 AND lon BETWEEN -13.17 AND -0.99 THEN RETURN 'MA'; END IF;
  IF lat BETWEEN 18.96 AND 37.09 AND lon BETWEEN -8.67 AND 11.98 THEN RETURN 'DZ'; END IF;
  IF lat BETWEEN 30.24 AND 37.54 AND lon BETWEEN 7.52 AND 11.60 THEN RETURN 'TN'; END IF;
  IF lat BETWEEN 19.50 AND 33.17 AND lon BETWEEN 9.38 AND 25.15 THEN RETURN 'LY'; END IF;
  IF lat BETWEEN 22.00 AND 31.67 AND lon BETWEEN 24.70 AND 36.89 THEN RETURN 'EG'; END IF;
  IF lat BETWEEN 24.52 AND 49.38 AND lon BETWEEN -125.00 AND -66.95 THEN RETURN 'US'; END IF;
  IF lat BETWEEN 51.21 AND 71.39 AND lon BETWEEN -179.15 AND -129.98 THEN RETURN 'US'; END IF;
  IF lat BETWEEN 18.91 AND 28.40 AND lon BETWEEN -178.33 AND -154.81 THEN RETURN 'US'; END IF;
  IF lat BETWEEN 41.68 AND 83.11 AND lon BETWEEN -141.00 AND -52.62 THEN RETURN 'CA'; END IF;
  IF lat BETWEEN 14.53 AND 32.72 AND lon BETWEEN -118.45 AND -86.71 THEN RETURN 'MX'; END IF;
  IF lat BETWEEN 19.83 AND 23.19 AND lon BETWEEN -84.96 AND -74.13 THEN RETURN 'CU'; END IF;
  IF lat BETWEEN 17.70 AND 18.53 AND lon BETWEEN -78.37 AND -76.18 THEN RETURN 'JM'; END IF;
  IF lat BETWEEN 17.47 AND 19.93 AND lon BETWEEN -72.00 AND -68.32 THEN RETURN 'DO'; END IF;
  IF lat BETWEEN 17.93 AND 18.52 AND lon BETWEEN -67.27 AND -65.59 THEN RETURN 'PR'; END IF;
  IF lat BETWEEN -33.75 AND 5.27 AND lon BETWEEN -73.99 AND -34.79 THEN RETURN 'BR'; END IF;
  IF lat BETWEEN -55.05 AND -21.78 AND lon BETWEEN -73.56 AND -53.64 THEN RETURN 'AR'; END IF;
  IF lat BETWEEN -55.98 AND -17.50 AND lon BETWEEN -109.45 AND -66.42 THEN RETURN 'CL'; END IF;
  IF lat BETWEEN -18.35 AND -0.04 AND lon BETWEEN -81.33 AND -68.65 THEN RETURN 'PE'; END IF;
  IF lat BETWEEN -4.23 AND 12.46 AND lon BETWEEN -79.02 AND -66.87 THEN RETURN 'CO'; END IF;
  IF lat BETWEEN 0.65 AND 12.20 AND lon BETWEEN -73.35 AND -59.80 THEN RETURN 'VE'; END IF;
  IF lat BETWEEN -5.01 AND 1.45 AND lon BETWEEN -92.01 AND -75.19 THEN RETURN 'EC'; END IF;
  IF lat BETWEEN 24.04 AND 45.55 AND lon BETWEEN 122.93 AND 153.99 THEN RETURN 'JP'; END IF;
  IF lat BETWEEN 18.16 AND 53.56 AND lon BETWEEN 73.50 AND 135.09 THEN RETURN 'CN'; END IF;
  IF lat BETWEEN 6.75 AND 35.51 AND lon BETWEEN 68.18 AND 97.40 THEN RETURN 'IN'; END IF;
  IF lat BETWEEN 33.11 AND 38.61 AND lon BETWEEN 124.61 AND 131.87 THEN RETURN 'KR'; END IF;
  IF lat BETWEEN 5.61 AND 20.46 AND lon BETWEEN 97.34 AND 105.64 THEN RETURN 'TH'; END IF;
  IF lat BETWEEN 8.56 AND 23.39 AND lon BETWEEN 102.14 AND 109.47 THEN RETURN 'VN'; END IF;
  IF lat BETWEEN -11.01 AND 6.08 AND lon BETWEEN 94.97 AND 141.02 THEN RETURN 'ID'; END IF;
  IF lat BETWEEN 0.85 AND 7.36 AND lon BETWEEN 99.64 AND 119.27 THEN RETURN 'MY'; END IF;
  IF lat BETWEEN 1.16 AND 1.47 AND lon BETWEEN 103.61 AND 104.04 THEN RETURN 'SG'; END IF;
  IF lat BETWEEN 4.64 AND 21.12 AND lon BETWEEN 116.93 AND 126.60 THEN RETURN 'PH'; END IF;
  IF lat BETWEEN 35.82 AND 42.11 AND lon BETWEEN 25.66 AND 44.83 THEN RETURN 'TR'; END IF;
  IF lat BETWEEN 22.63 AND 26.08 AND lon BETWEEN 51.58 AND 56.38 THEN RETURN 'AE'; END IF;
  IF lat BETWEEN 16.38 AND 32.15 AND lon BETWEEN 34.57 AND 55.67 THEN RETURN 'SA'; END IF;
  IF lat BETWEEN 29.50 AND 33.34 AND lon BETWEEN 34.27 AND 35.88 THEN RETURN 'IL'; END IF;
  IF lat BETWEEN 33.05 AND 34.69 AND lon BETWEEN 35.10 AND 36.62 THEN RETURN 'LB'; END IF;
  IF lat BETWEEN -43.63 AND -10.06 AND lon BETWEEN 113.16 AND 153.64 THEN RETURN 'AU'; END IF;
  IF lat BETWEEN -47.29 AND -34.39 AND lon BETWEEN 166.42 AND 178.58 THEN RETURN 'NZ'; END IF;
  IF lat BETWEEN -34.84 AND -22.13 AND lon BETWEEN 16.46 AND 32.89 THEN RETURN 'ZA'; END IF;
  IF lat BETWEEN -4.68 AND 5.03 AND lon BETWEEN 33.89 AND 41.90 THEN RETURN 'KE'; END IF;
  IF lat BETWEEN 4.27 AND 13.89 AND lon BETWEEN 2.69 AND 14.68 THEN RETURN 'NG'; END IF;
  
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."get_country_code_from_coords"("coords" "extensions"."geometry") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_country_code_from_coords"("coords" "extensions"."geometry") IS 'Détecte le code pays (ISO 3166-1 alpha-2) à partir de coordonnées GPS. SÉCURISÉ avec search_path fixe.';



CREATE OR REPLACE FUNCTION "public"."get_favorited_professionals"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog', 'public', 'extensions', 'auth'
    AS $$
DECLARE
    v_me uuid := auth.uid();
    v_items jsonb;
BEGIN
    IF v_me IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED';
    END IF;

    SELECT jsonb_agg(
        jsonb_build_object(
            -- Champs requis par le DataType ProDetails
            'proProfileId', p.id,
            'fullName', p.full_name,
            'avatarUrl', p.avatar_url,
            'businessName', pd.business_name,
            'profession', pd.profession,
            'budgetMin', pd.budget_min,
            'budgetMax', pd.budget_max,
            'currency', pd.currency,
            'subscriptionTier', ps.subscription_tier,
            'distanceKm', null, -- La distance n'est pas pertinente dans ce contexte
            'locationLabel', pd.location_label,
            'coverImageUrl', pd.portfolio_images[1],
            'isFavorited', true,
            'isLive', pd.is_live,
            'description', pd.description,
            'portfolioImages', to_jsonb(pd.portfolio_images),
            'slideshowImages', to_jsonb(pd.slideshow_images),
            'profileVideoUrl', pd.profile_video_url,
            'hasCoverVideo', COALESCE(pd.has_cover_video, false),
            -- CHANGED (04/12/2025): fixedLocations now ONLY from professional_fixed_locations
            -- Includes id and label for each location
            'fixedLocations', (
                SELECT COALESCE(jsonb_agg(
                    jsonb_build_object(
                        'id', fl.id,
                        'label', fl.label,
                        'lat', ST_Y(fl.location_coords),
                        'lng', ST_X(fl.location_coords)
                    ) ORDER BY fl.created_at
                ), '[]'::jsonb)
                FROM public.professional_fixed_locations fl
                WHERE fl.professional_profile_id = p.id
            ),
            'instagramUrl', pd.instagram_url,
            'websiteUrl', pd.website_url,
            'canBeContactedByBride', (ps.subscription_tier IN ('premiumVisibility','ultimateAccess')),
            'canContactBride', false
        ) ORDER BY w.added_at DESC
    )
    INTO v_items
    FROM public.wishlist_items w
    JOIN public.profiles p ON w.professional_profile_id = p.id
    JOIN public.professional_details pd ON w.professional_profile_id = pd.profile_id
    LEFT JOIN public.professional_subscriptions ps ON w.professional_profile_id = ps.profile_id
    WHERE w.bride_profile_id = v_me;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_favorited_professionals"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_favorited_professionals"() IS 'Récupère les professionnels favoris de l''utilisateur connecté. Sécurisé avec search_path fixe.';



CREATE OR REPLACE FUNCTION "public"."get_featured_replay"() RETURNS TABLE("id" "uuid", "title" "text", "description" "text", "youtube_url" "text", "thumbnail_url" "text", "published_at" timestamp with time zone, "is_featured" boolean, "is_published" boolean, "created_at" timestamp with time zone, "target_region" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_my_market text := public.get_my_market_region();  -- 'IN' or 'GLOBAL'
BEGIN
  -- First, try to get the most recent featured replay for this market
  RETURN QUERY
  SELECT 
    r.id,
    r.title,
    r.description,
    r.youtube_url,
    r.thumbnail_url,
    r.published_at,
    r.is_featured,
    r.is_published,
    r.created_at,
    r.target_region
  FROM public.replays r
  WHERE r.is_published = true
    AND r.is_featured = true
    -- Filter by market region
    AND (
      r.target_region = 'all'
      OR (v_my_market = 'IN' AND r.target_region = 'IN')
      OR (v_my_market = 'GLOBAL' AND r.target_region = 'ROW')
    )
  ORDER BY r.created_at DESC
  LIMIT 1;
  
  -- If no featured replay found, get the most recent published replay
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT 
      r.id,
      r.title,
      r.description,
      r.youtube_url,
      r.thumbnail_url,
      r.published_at,
      r.is_featured,
      r.is_published,
      r.created_at,
      r.target_region
    FROM public.replays r
    WHERE r.is_published = true
      -- Filter by market region
      AND (
        r.target_region = 'all'
        OR (v_my_market = 'IN' AND r.target_region = 'IN')
        OR (v_my_market = 'GLOBAL' AND r.target_region = 'ROW')
      )
    ORDER BY r.created_at DESC
    LIMIT 1;
  END IF;
END;
$$;


ALTER FUNCTION "public"."get_featured_replay"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text" DEFAULT NULL::"text", "p_page_size" integer DEFAULT 24) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
  v_viewer uuid := auth.uid();
  v_center geometry;
  v_radius_km float;
  v_prof_filter text[];
  v_currency text;
  v_budget_min_ui numeric;
  v_budget_max_ui numeric;
  v_budget_min_eur numeric;
  v_budget_max_eur numeric;
  v_country_code text;

  cs jsonb;
  c_tier int;
  c_dist numeric;
  c_wl int;
  c_pid uuid;

  v_page_size int := LEAST(GREATEST(COALESCE(p_page_size,24), 1), 30);
  items jsonb := '[]'::jsonb;
  next_cursor text := NULL;

BEGIN
  -- center/radius
  IF p_filters ? 'center' AND jsonb_typeof(p_filters->'center') = 'object' THEN
    v_center := ST_SetSRID(
      ST_MakePoint(
        (p_filters->'center'->>'longitude')::float,
        (p_filters->'center'->>'latitude')::float
      ), 4326
    );
  END IF;
  v_radius_km := NULLIF(p_filters->>'radiusKm','')::float;

  -- country filter
  v_country_code := NULLIF(p_filters->>'countryCode','');

  -- professions
  SELECT ARRAY(SELECT jsonb_array_elements_text(p_filters->'professions')) INTO v_prof_filter;

  -- budgets → EUR
  v_currency := NULLIF(p_filters->>'currency','');
  v_budget_min_ui := NULLIF(p_filters->>'budgetMin','')::numeric;
  v_budget_max_ui := NULLIF(p_filters->>'budgetMax','')::numeric;
  IF v_budget_min_ui IS NOT NULL AND v_currency IS NOT NULL THEN
    v_budget_min_eur := public.convert_to_eur(v_budget_min_ui, v_currency);
  END IF;
  IF v_budget_max_ui IS NOT NULL AND v_currency IS NOT NULL THEN
    v_budget_max_eur := public.convert_to_eur(v_budget_max_ui, v_currency);
  END IF;

  -- Cursor parsing
  IF p_cursor IS NOT NULL THEN
    cs := convert_from(decode(p_cursor, 'base64'), 'utf8')::jsonb;
    c_tier := (cs->>'tierScore')::int;
    c_dist := (cs->>'distanceForOrder')::numeric;
    c_wl   := (cs->>'wishlistCount')::int;
    c_pid  := (cs->>'profileId')::uuid;
  END IF;

  WITH base AS (
    SELECT
      pd.profile_id,
      pd.profession,
      pd.budget_min, pd.budget_max, pd.currency,
      pd.budget_min_eur, pd.budget_max_eur,
      pd.wishlist_count,
      pd.is_live,
      pr.full_name, pr.avatar_url,
      pd.business_name,
      pd.location_label,
      pd.portfolio_images,
      ps.subscription_tier,
      -- CHANGED (04/12/2025): Distance to CLOSEST fixed_location instead of pd.location_coords
      COALESCE(
        CASE WHEN v_center IS NOT NULL THEN
          (SELECT MIN(ST_Distance(pfl.location_coords::geography, v_center::geography))
           FROM public.professional_fixed_locations pfl
           WHERE pfl.professional_profile_id = pd.profile_id)
        END, NULL
      ) AS distance_meters,
      public.tier_score(ps.subscription_tier) AS tier_score
    FROM public.professional_details pd
    JOIN public.profiles pr ON pr.id = pd.profile_id
    JOIN public.professional_subscriptions ps ON ps.profile_id = pd.profile_id
    WHERE pd.is_live = true
      AND ps.subscription_tier IN ('premiumVisibility','ultimateAccess')
      AND (COALESCE(array_length(v_prof_filter,1),0) = 0 OR pd.profession::text = ANY(v_prof_filter))
      AND (
        (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
        OR (
          pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
          AND (v_budget_min_eur IS NULL OR pd.budget_max_eur >= v_budget_min_eur)
          AND (v_budget_max_eur IS NULL OR pd.budget_min_eur <= v_budget_max_eur)
        )
      )
      -- CHANGED (04/12/2025): Geographic filter now uses professional_fixed_locations
      AND (
        -- Country filter: check main location_country_code OR any fixed location
        (
          v_country_code IS NOT NULL 
          AND (
            pd.location_country_code = v_country_code
            OR EXISTS (
              SELECT 1 
              FROM public.professional_fixed_locations pfl
              WHERE pfl.professional_profile_id = pd.profile_id
                AND pfl.location_country_code = v_country_code
            )
          )
        )
        OR
        -- Radius filter: check if ANY fixed_location is within radius
        (
          v_country_code IS NULL
          AND (
            v_center IS NULL OR v_radius_km IS NULL
            OR EXISTS (
              SELECT 1
              FROM public.professional_fixed_locations pfl
              WHERE pfl.professional_profile_id = pd.profile_id
                AND ST_DWithin(pfl.location_coords::geography, v_center::geography, v_radius_km*1000)
            )
          )
        )
      )
  ),
  ranked AS (
    SELECT
      b.*,
      COALESCE(b.distance_meters, 1e15) AS distance_for_order,
      EXISTS(
        SELECT 1 FROM public.wishlist_items w
        WHERE w.bride_profile_id = v_viewer
          AND w.professional_profile_id = b.profile_id
      ) AS is_favorited
    FROM base b
  ),
  sought AS (
    SELECT * FROM ranked r
    WHERE
      p_cursor IS NULL OR (
        (r.tier_score, r.distance_for_order, r.wishlist_count, r.profile_id) <
        (c_tier, c_dist, c_wl, c_pid)
      )
    ORDER BY r.tier_score DESC, r.distance_for_order ASC, r.wishlist_count DESC, r.profile_id ASC
    LIMIT v_page_size + 1
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'proProfileId', s.profile_id,
      'fullName', s.full_name,
      'avatarUrl', s.avatar_url,
      'businessName', s.business_name,
      'profession', s.profession::text,
      'budgetMin', s.budget_min,
      'budgetMax', s.budget_max,
      'currency', s.currency,
      'subscriptionTier', s.subscription_tier::text,
      'distanceKm', CASE WHEN s.distance_meters IS NOT NULL THEN round((s.distance_meters/1000.0)::numeric, 2) ELSE NULL END,
      'locationLabel', s.location_label,
      'coverImageUrl', COALESCE(NULLIF(s.portfolio_images[1], ''), NULL),
      'isFavorited', s.is_favorited,
      'isLive', s.is_live
    )
  ) INTO items
  FROM (SELECT * FROM sought) s
  WHERE TRUE;

  -- next_cursor
  IF items IS NOT NULL AND jsonb_array_length(items) = v_page_size + 1 THEN
    WITH lst AS (
      SELECT (items->>(v_page_size))::jsonb AS j
    ), lastrow AS (
      SELECT
        (j->>'proProfileId')::uuid AS pid
      FROM lst
    ), full_row_data AS (
      SELECT r.*
      FROM ranked r
      JOIN lastrow lr ON lr.pid = r.profile_id
    )
    SELECT encode(convert_to(
      jsonb_build_object(
        'tierScore', f.tier_score,
        'distanceForOrder', f.distance_for_order,
        'wishlistCount', f.wishlist_count,
        'profileId', f.profile_id
      )::text, 'utf8'), 'base64')
    INTO next_cursor
    FROM full_row_data f;

    items := items - (v_page_size)::int;
  END IF;

  RETURN jsonb_build_object(
    'items', COALESCE(items, '[]'::jsonb),
    'nextCursor', next_cursor
  );
END;
$$;


ALTER FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT CASE public.get_tier_of(p_profile_id)
    WHEN 'trial' THEN 1
    WHEN 'earlyAccess' THEN 1
    WHEN 'premiumVisibility' THEN 3
    WHEN 'ultimateAccess' THEN 5
    ELSE 0
  END;
$$;


ALTER FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_formatted_notifications"("p_limit" integer DEFAULT 100) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
    v_me uuid := auth.uid();
    v_my_locale text;
    v_items jsonb;
BEGIN
    IF v_me IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED';
    END IF;

    -- Récupère la langue de l'utilisateur avec un fallback sur 'en'
    SELECT COALESCE(default_locale, 'en') INTO v_my_locale FROM public.user_preferences WHERE profile_id = v_me;

    -- Récupère les notifications de l'utilisateur et les données du profil de l'expéditeur
    WITH notifs AS (
        SELECT
            n.id as notification_id,
            n.type,
            n.payload,
            n.is_read,
            n.created_at,
            (n.payload->>'sender_profile_id')::uuid as sender_id
        FROM public.notifications n
        WHERE n.profile_id = v_me
        ORDER BY n.created_at DESC
        LIMIT p_limit
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'notificationId', n.notification_id,
            'notificationType', n.type,
            'title',
                CASE n.type
                    WHEN 'chatMessage' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouveau message' ELSE 'New message' END
                    WHEN 'connectionRequest' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouvelle demande de contact' ELSE 'New connection request' END
                    WHEN 'connectionRequestAccepted' THEN CASE v_my_locale WHEN 'fr' THEN 'Demande acceptée' ELSE 'Request accepted' END
                    WHEN 'connectionRequestDeclined' THEN CASE v_my_locale WHEN 'fr' THEN 'Demande refusée' ELSE 'Request declined' END
                    WHEN 'wishlistAdd' THEN CASE v_my_locale WHEN 'fr' THEN 'Ajout à une wishlist' ELSE 'Added to a wishlist' END
                    WHEN 'professionalAlertReminder24h' THEN CASE v_my_locale WHEN 'fr' THEN 'Alerte bientôt expirée' ELSE 'Alert expiring soon' END
                    WHEN 'videoIncoming' THEN CASE v_my_locale WHEN 'fr' THEN 'Appel Vidéo Entrant' ELSE 'Incoming Video Call' END
                    WHEN 'wedPublished' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouveau Wedding of the Week' ELSE 'New Wedding of the Week' END
                    WHEN 'replayPublished' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouveau Replay disponible' ELSE 'New Replay available' END
                    ELSE 'Notification'
                END,
            'message',
                CASE n.type
                    WHEN 'chatMessage' THEN (COALESCE(p.full_name, 'Someone') || CASE v_my_locale WHEN 'fr' THEN ' vous a envoyé un message.' ELSE ' sent you a message.' END)
                    WHEN 'connectionRequest' THEN (COALESCE(p.full_name, 'Someone') || CASE v_my_locale WHEN 'fr' THEN ' souhaite vous contacter.' ELSE ' wants to connect with you.' END)
                    WHEN 'connectionRequestAccepted' THEN (COALESCE(p.full_name, 'Someone') || CASE v_my_locale WHEN 'fr' THEN ' a accepté votre demande.' ELSE ' accepted your request.' END)
                    WHEN 'connectionRequestDeclined' THEN (COALESCE(p.full_name, 'Someone') || CASE v_my_locale WHEN 'fr' THEN ' a refusé votre demande.' ELSE ' declined your request.' END)
                    WHEN 'wishlistAdd' THEN CASE v_my_locale WHEN 'fr' THEN 'Appuyez pour voir les détails' ELSE 'Tap to view details' END
                    WHEN 'professionalAlertReminder24h' THEN CASE v_my_locale WHEN 'fr' THEN 'Votre alerte expire dans moins de 24h.' ELSE 'Your alert expires in less than 24h.' END
                    WHEN 'videoIncoming' THEN (COALESCE(p.full_name, 'Someone') || CASE v_my_locale WHEN 'fr' THEN ' vous appelle en vidéo...' ELSE ' is calling you...' END)
                    WHEN 'wedPublished' THEN CASE v_my_locale WHEN 'fr' THEN 'Découvrez le mariage de la semaine!' ELSE 'Check out the wedding of the week!' END
                    WHEN 'replayPublished' THEN CASE v_my_locale WHEN 'fr' THEN 'Un nouveau replay est disponible.' ELSE 'A new replay is available.' END
                    ELSE CASE v_my_locale WHEN 'fr' THEN 'Vous avez une nouvelle notification.' ELSE 'You have a new notification.' END
                END,
            'createdAt', n.created_at,
            'isRead', n.is_read,
            'referenceId',
                CASE
                    WHEN n.payload ? 'room_id' THEN n.payload->>'room_id'
                    WHEN n.payload ? 'request_id' THEN n.payload->>'request_id'
                    WHEN n.payload ? 'alert_id' THEN n.payload->>'alert_id'
                    WHEN n.payload ? 'video_session_id' THEN n.payload->>'video_session_id'
                    WHEN n.payload ? 'bride_profile_id' THEN n.payload->>'bride_profile_id'
                    WHEN n.payload ? 'sender_profile_id' THEN n.payload->>'sender_profile_id'
                    ELSE n.notification_id::text
                END,
            'senderAvatarUrl', p.avatar_url
        )
        ORDER BY n.created_at DESC  -- IMPORTANT: Préserver l'ordre dans l'agrégation
    )
    INTO v_items
    FROM notifs n
    LEFT JOIN public.profiles p ON n.sender_id = p.id;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_formatted_notifications"("p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_latest_wed_article"("p_lang" "text" DEFAULT 'en'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
    v_article_data jsonb;
    v_lang TEXT := lower(p_lang);
    v_my_market text := public.get_my_market_region();
BEGIN
    -- Validate language
    IF v_lang NOT IN ('fr', 'en', 'es', 'it', 'de') THEN
        v_lang := 'en';
    END IF;

    SELECT
        jsonb_build_object(
            'id', wa.id,
            'title', COALESCE(wa.title->>v_lang, 'Wedding of the Week'),
            'coverImages', to_jsonb(wa.cover_images),
            'contentBlocks', (
                SELECT COALESCE(jsonb_agg(
                    CASE
                        WHEN (block->>'type') = 'paragraph' THEN
                            jsonb_build_object(
                                'type', 'paragraph',
                                'text', COALESCE(block->'content'->>v_lang, ''),
                                'imageUrls', '[]'::jsonb
                            )
                        WHEN (block->>'type') = 'video' THEN
                            -- Video blocks have 'url' (singular), wrap it in an array for imageUrls
                            jsonb_build_object(
                                'type', 'video',
                                'text', null,
                                'imageUrls', jsonb_build_array(COALESCE(block->>'url', ''))
                            )
                        ELSE 
                            -- Gallery and single_image blocks have 'urls' (plural)
                            jsonb_build_object(
                                'type', block->>'type',
                                'text', null,
                                'imageUrls', COALESCE(block->'urls', '[]'::jsonb),
                                'layout', block->>'layout',
                                'columns', (block->>'columns')::int
                            )
                    END
                ), '[]'::jsonb)
                FROM jsonb_array_elements(wa.content_blocks) AS block
            ),
            'professional', jsonb_build_object(
                'profileId', p.id,
                'fullName', p.full_name,
                'avatarUrl', p.avatar_url,
                'businessName', pd.business_name,
                'profession', pd.profession::text,
                'locationLabel', pd.location_label,
                'coverImageUrl', pd.portfolio_images[1],
                'instagramUrl', pd.instagram_url,
                'websiteUrl', pd.website_url,
                'socials', jsonb_build_object(
                    'instagramUrl', pd.instagram_url,
                    'websiteUrl', pd.website_url
                )
            )
        )
    INTO v_article_data
    FROM public.wed_articles wa
    JOIN public.profiles p ON p.id = wa.linked_pro_profile_id
    LEFT JOIN public.professional_details pd ON pd.profile_id = wa.linked_pro_profile_id
    WHERE wa.is_published = true
      AND (
        wa.target_region = 'all'
        OR (v_my_market = 'IN' AND wa.target_region = 'IN')
        OR (v_my_market = 'GLOBAL' AND wa.target_region = 'ROW')
      )
    ORDER BY COALESCE(wa.published_at, wa.created_at) DESC
    LIMIT 1;

    RETURN COALESCE(v_article_data, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_latest_wed_article"("p_lang" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_alerts"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
BEGIN
  IF v_me IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  RETURN COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'id', a.id,
        'alertType', a.alert_type,
        'title', a.title,
        'message', a.message,
        'eventDate', a.event_date,
        'locationLabel', a.location_label,
        'professionNeeded', a.profession_needed,
        'status', a.status,
        'expiresAt', a.expires_at,
        'createdAt', a.created_at,
        'isActive', a.status = 'active' AND a.expires_at > now()
      )
      ORDER BY a.created_at DESC
    )
    FROM public.professional_alerts a
    WHERE a.author_profile_id = v_me
      AND a.is_deleted = false
  ), '[]'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_my_alerts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_market_region"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_country_code text;
BEGIN
  IF v_me IS NULL THEN
    RETURN 'GLOBAL';
  END IF;
  
  -- First check professional_details (for pros)
  SELECT pd.location_country_code INTO v_country_code
  FROM public.professional_details pd
  WHERE pd.profile_id = v_me;
  
  -- If not a pro or no country set, check profiles.country
  IF v_country_code IS NULL THEN
    SELECT 
      CASE 
        WHEN UPPER(p.country) IN ('INDIA', 'IN') THEN 'IN'
        ELSE NULL
      END INTO v_country_code
    FROM public.profiles p
    WHERE p.id = v_me;
  END IF;
  
  -- Return 'IN' for Indian users, 'GLOBAL' for others
  RETURN COALESCE(
    CASE WHEN UPPER(v_country_code) = 'IN' THEN 'IN' ELSE 'GLOBAL' END,
    'GLOBAL'
  );
END;
$$;


ALTER FUNCTION "public"."get_my_market_region"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_my_market_region"() IS 'Returns market region for current user: IN for India, GLOBAL for rest of world';



CREATE OR REPLACE FUNCTION "public"."get_my_role"() RETURNS "public"."userRole"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;


ALTER FUNCTION "public"."get_my_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_tier"() RETURNS "public"."subscriptionTierType"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT COALESCE(
    (SELECT subscription_tier
     FROM public.professional_subscriptions
     WHERE profile_id = auth.uid()),
     'inactive'::public."subscriptionTierType");
$$;


ALTER FUNCTION "public"."get_my_tier"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_wedding"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'id', w.id,
    'weddingName', w.wedding_name,
    'eventDate', w.event_date,
    'eventEndDate', w.event_end_date,
    'venueLabel', w.venue_label,
    'venueLat', extensions.ST_Y(w.venue_coords),
    'venueLng', extensions.ST_X(w.venue_coords),
    'searchRadiusKm', w.search_radius_km,
    'locationCountryCode', w.location_country_code,
    'budgetMin', w.budget_min,
    'budgetMax', w.budget_max,
    'currency', w.currency,
    'professionsNeeded', w.professions_needed,
    'visibility', w.visibility,
    'status', w.status,
    'createdAt', w.created_at,
    'updatedAt', w.updated_at
  ) INTO v_result
  FROM public.weddings w
  WHERE w.bride_profile_id = v_me
    AND w.is_deleted = false;

  IF v_result IS NULL THEN
    RETURN jsonb_build_object('exists', false);
  END IF;

  RETURN v_result || jsonb_build_object('exists', true);
END;
$$;


ALTER FUNCTION "public"."get_my_wedding"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_pending_contact_requests"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_me uuid := auth.uid();
  v_my_role text;
begin
  if v_me is null then
    return jsonb_build_object('items', jsonb_build_array());
  end if;

  -- Get current user's role
  select role into v_my_role from public.profiles where id = v_me;

  return jsonb_build_object(
    'items', (
      select coalesce(jsonb_agg(row_to_json(x)), '[]'::jsonb)
      from (
        select
          cr.id as "requestId",
          cr.initiator_id as "initiatorId",
          case when v_me = cr.pro_profile_id then cr.bride_profile_id else cr.pro_profile_id end as "otherProfileId",
          pr.full_name as "otherFullName",
          pr.avatar_url as "otherAvatarUrl",
          pr.role as "otherRole",
          cr.source as "source",
          cr.initial_message as "initialMessage",
          cr.created_at as "createdAt",
          -- Get the associated room ID
          (
            select r.id
            from public.chat_rooms r
            join public.chat_room_participants p1 on p1.room_id = r.id and p1.profile_id = cr.pro_profile_id
            join public.chat_room_participants p2 on p2.room_id = r.id and p2.profile_id = cr.bride_profile_id
            where r.type = 'private'
            limit 1
          ) as "roomId"
        from public.connection_requests cr
        join public.profiles pr on pr.id = (
          case when v_me = cr.pro_profile_id then cr.bride_profile_id else cr.pro_profile_id end
        )
        where cr.status = 'pending'
          and (
            -- BRIDE: sees requests where she is bride AND initiator is the PRO
            (v_my_role = 'bride' and cr.bride_profile_id = v_me and cr.initiator_id = cr.pro_profile_id)
            or
            -- PRO: sees requests where he is pro AND initiator is HIM (waiting for bride response)
            (v_my_role = 'professional' and cr.pro_profile_id = v_me and cr.initiator_id = v_me)
          )
        order by cr.created_at desc
      ) x
    )
  );
end;
$$;


ALTER FUNCTION "public"."get_pending_contact_requests"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_pending_contact_requests"() IS 'Returns pending contact requests for current user based on role:
- Bride: sees "new" requests from pros wanting to contact her
- Pro: sees "waiting" requests he sent to brides, awaiting their response';



CREATE OR REPLACE FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb" DEFAULT '{}'::"jsonb", "p_cursor" "text" DEFAULT NULL::"text", "p_page_size" integer DEFAULT 30, "p_seed" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_viewer_id   uuid := auth.uid();
  v_my_market   text := public.get_my_market_region();
  v_filters     jsonb;
  v_center      extensions.geometry;
  v_radius_km   float;
  v_prof_filter text[];
  v_budget_min  numeric;
  v_budget_max  numeric;
  v_country_code text;
  cs            jsonb;
  c_sort_key    text;
  c_pid         uuid;
  c_idx         int;
  v_seed        text := COALESCE(p_seed, md5(random()::text));
  v_page_size2  int  := LEAST(GREATEST(COALESCE(p_page_size, 30), 1), 60);
  items         jsonb;
  next_cursor   text;
BEGIN
  BEGIN
    v_filters := COALESCE(p_filters, '{}'::jsonb);
  EXCEPTION WHEN OTHERS THEN
    v_filters := '{}'::jsonb;
  END;

  IF v_filters ? 'center' AND jsonb_typeof(v_filters->'center') = 'object' THEN
    v_center := extensions.ST_SetSRID(extensions.ST_MakePoint((v_filters->'center'->>'longitude')::float, (v_filters->'center'->>'latitude')::float), 4326);
  END IF;

  v_radius_km := NULLIF(v_filters->>'radiusKm','')::float;
  IF v_radius_km IS NOT NULL THEN
    v_radius_km := GREATEST(5, LEAST(v_radius_km, 1000));
  END IF;

  v_country_code := NULLIF(v_filters->>'countryCode','');

  IF v_filters ? 'professions' AND jsonb_typeof(v_filters->'professions') = 'array' THEN
    SELECT ARRAY(SELECT jsonb_array_elements_text(v_filters->'professions')) INTO v_prof_filter;
  END IF;

  v_budget_min := NULLIF(v_filters->>'budgetMin','')::numeric;
  v_budget_max := NULLIF(v_filters->>'budgetMax','')::numeric;

  IF p_cursor IS NOT NULL THEN
    BEGIN
      cs := convert_from(decode(p_cursor, 'base64'), 'utf8')::jsonb;
      c_sort_key := cs->>'sortKey';
      c_pid      := (cs->>'proProfileId')::uuid;
      c_idx      := (cs->>'imageIndex')::int;
    EXCEPTION WHEN OTHERS THEN
      cs := NULL;
    END;
  END IF;

  WITH base_items AS (
    SELECT
      ps.profile_id,
      pr.full_name,
      pr.avatar_url,
      pr.ambassador,
      pd.profession,
      pd.location_label,
      CASE 
        WHEN pd.portfolio_images_v2 IS NOT NULL 
             AND jsonb_array_length(pd.portfolio_images_v2) > 0 
        THEN (u_v2.img->>'crop_3x4')
        ELSE u_legacy.image_url
      END AS image_url,
      CASE 
        WHEN pd.portfolio_images_v2 IS NOT NULL 
             AND jsonb_array_length(pd.portfolio_images_v2) > 0 
        THEN (u_v2.img->>'crop_9x16')
        ELSE u_legacy.image_url
      END AS fullscreen_url,
      CASE 
        WHEN pd.portfolio_images_v2 IS NOT NULL 
             AND jsonb_array_length(pd.portfolio_images_v2) > 0 
        THEN (u_v2.img->>'id')
        ELSE NULL
      END AS image_id,
      CASE 
        WHEN pd.portfolio_images_v2 IS NOT NULL 
             AND jsonb_array_length(pd.portfolio_images_v2) > 0 
        THEN u_v2.image_index
        ELSE u_legacy.image_index
      END AS image_index,
      md5(
        CASE 
          WHEN pd.portfolio_images_v2 IS NOT NULL 
               AND jsonb_array_length(pd.portfolio_images_v2) > 0 
          THEN (u_v2.img->>'crop_3x4')
          ELSE u_legacy.image_url
        END || '|' || v_seed
      ) AS sort_key
    FROM
      public.professional_subscriptions ps
    JOIN
      public.professional_details pd ON ps.profile_id = pd.profile_id
    JOIN
      public.profiles pr ON ps.profile_id = pr.id
    LEFT JOIN LATERAL (
      SELECT img, (row_number() OVER ())::int AS image_index
      FROM jsonb_array_elements(pd.portfolio_images_v2) AS img
      WHERE pd.portfolio_images_v2 IS NOT NULL 
            AND jsonb_array_length(pd.portfolio_images_v2) > 0
    ) u_v2 ON pd.portfolio_images_v2 IS NOT NULL AND jsonb_array_length(pd.portfolio_images_v2) > 0
    LEFT JOIN LATERAL (
      SELECT image_url, image_index::int
      FROM unnest(pd.portfolio_images) WITH ORDINALITY AS t(image_url, image_index)
      WHERE (pd.portfolio_images_v2 IS NULL OR jsonb_array_length(pd.portfolio_images_v2) = 0)
            AND array_length(pd.portfolio_images, 1) > 0
    ) u_legacy ON (pd.portfolio_images_v2 IS NULL OR jsonb_array_length(pd.portfolio_images_v2) = 0)
    WHERE
      ps.subscription_tier IN ('premiumVisibility', 'ultimateAccess')
      AND pd.is_live = true
      AND (
        (pd.portfolio_images_v2 IS NOT NULL AND jsonb_array_length(pd.portfolio_images_v2) > 0)
        OR (array_length(pd.portfolio_images, 1) > 0)
      )
      AND (
        (pd.portfolio_images_v2 IS NOT NULL AND jsonb_array_length(pd.portfolio_images_v2) > 0 AND u_v2.img IS NOT NULL)
        OR ((pd.portfolio_images_v2 IS NULL OR jsonb_array_length(pd.portfolio_images_v2) = 0) AND u_legacy.image_url IS NOT NULL AND u_legacy.image_url <> '')
      )
      AND (pd.feed_enabled = true OR pr.ambassador = true)
      AND public.is_visible_in_market(pd.location_country_code, v_my_market)
      AND (
        v_prof_filter IS NULL
        OR COALESCE(array_length(v_prof_filter, 1), 0) = 0
        OR (
          UPPER(pd.profession::text) = ANY(v_prof_filter)
          AND (
            (v_my_market = 'IN' AND UPPER(pd.profession::text) NOT IN ('JEWELLER', 'STATIONER', 'CONTENTCREATOR'))
            OR
            (v_my_market = 'GLOBAL' AND UPPER(pd.profession::text) NOT IN ('CATERER', 'DJ', 'BRIDALWEARDESIGNER'))
          )
        )
      )
      AND (
        (v_my_market = 'IN' AND UPPER(pd.profession::text) NOT IN ('JEWELLER', 'STATIONER', 'CONTENTCREATOR'))
        OR
        (v_my_market = 'GLOBAL' AND UPPER(pd.profession::text) NOT IN ('CATERER', 'DJ', 'BRIDALWEARDESIGNER'))
      )
      AND (
        (
          v_country_code IS NOT NULL 
          AND (
            pd.location_country_code = v_country_code
            OR EXISTS (
              SELECT 1 
              FROM public.professional_fixed_locations pfl
              WHERE pfl.professional_profile_id = pd.profile_id
                AND pfl.location_country_code = v_country_code
            )
          )
        )
        OR
        (
          v_country_code IS NULL
          AND (
            v_center IS NULL OR
            EXISTS (
              SELECT 1
              FROM public.professional_fixed_locations pfl
              WHERE pfl.professional_profile_id = pd.profile_id
                AND extensions.ST_DWithin(pfl.location_coords::extensions.geography, v_center::extensions.geography, COALESCE(v_radius_km, 100) * 1000)
            )
          )
        )
      )
      AND (
        (v_budget_min IS NULL AND v_budget_max IS NULL)
        OR (
          pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
          AND (v_budget_min IS NULL OR pd.budget_max_eur >= v_budget_min)
          AND (v_budget_max IS NULL OR pd.budget_min_eur <= v_budget_max)
        )
      )
  ),
  paginated_items AS (
    SELECT *
    FROM base_items
    WHERE image_url IS NOT NULL AND image_url <> ''
      AND (p_cursor IS NULL OR (sort_key, profile_id, image_index) > (c_sort_key, c_pid, c_idx))
    ORDER BY ambassador DESC, sort_key ASC, profile_id ASC, image_index ASC
    LIMIT v_page_size2 + 1
  )
  SELECT
    (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'imageUrl',         p.image_url,
          'fullscreenUrl',    p.fullscreen_url,
          'imageId',          p.image_id,
          'imageIndex',       p.image_index,
          'proProfileId',     p.profile_id,
          'proFullName',      p.full_name,
          'proAvatarUrl',     p.avatar_url,
          'proProfession',    p.profession,
          'proLocationLabel', p.location_label,
          'isAmbassador',     p.ambassador,
          'isFavorited', EXISTS(
            SELECT 1 FROM public.wishlist_items w
            WHERE w.bride_profile_id = v_viewer_id AND w.professional_profile_id = p.profile_id
          )
        )
      ), '[]'::jsonb)
      FROM (SELECT * FROM paginated_items LIMIT v_page_size2) p
    ) AS items,
    (
      SELECT encode(convert_to(jsonb_build_object('sortKey', p.sort_key, 'proProfileId', p.profile_id, 'imageIndex', p.image_index)::text, 'utf8'), 'base64')
      FROM paginated_items p
      ORDER BY ambassador DESC, sort_key ASC, profile_id ASC, image_index ASC
      OFFSET v_page_size2
      LIMIT 1
    ) AS next_cursor
  INTO items, next_cursor;

  RETURN jsonb_build_object(
    'items',      COALESCE(items, '[]'::jsonb),
    'nextCursor', next_cursor,
    'newSeed',    v_seed
  );
END;
$$;


ALTER FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_my_role public."userRole";
  v_my_tier public."subscriptionTierType" := public.get_my_tier();
  v_blocked boolean := false;
  v_profile_video_url text;

  v_full_name text; v_avatar_url text;
  v_business_name text; v_profession public.profession;
  v_budget_min int; v_budget_max int; v_currency text;
  v_subscription_tier public."subscriptionTierType";
  v_location_label text; v_description text; v_is_live boolean;
  v_portfolio text[];
  v_slideshow text[];
  v_portfolio_v2 jsonb;
  v_slideshow_v2 jsonb;
  v_cover text;
  v_is_fav boolean := false;
  v_instagram_url text;
  v_website_url text;
  v_has_cover_video boolean;
  v_upcoming_travels jsonb;

  v_all_locations jsonb := '[]'::jsonb;

  can_contact_by_bride boolean := false;
  can_contact_bride boolean := false;
BEGIN
  IF v_me IS NOT NULL THEN
      SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me;
  END IF;

  SELECT pr.full_name, pr.avatar_url,
         pd.business_name, pd.profession,
         pd.budget_min, pd.budget_max, pd.currency,
         pd.location_label, pd.description, pd.is_live,
         pd.portfolio_images,
         pd.slideshow_images,
         pd.portfolio_images_v2,
         pd.slideshow_images_v2,
         pd.instagram_url,
         pd.website_url,
         pd.profile_video_url,
         pd.has_cover_video,
         pd.upcoming_travels,
         ps.subscription_tier
  INTO v_full_name, v_avatar_url,
       v_business_name, v_profession,
       v_budget_min, v_budget_max, v_currency,
       v_location_label, v_description, v_is_live,
       v_portfolio,
       v_slideshow,
       v_portfolio_v2,
       v_slideshow_v2,
       v_instagram_url,
       v_website_url,
       v_profile_video_url,
       v_has_cover_video,
       v_upcoming_travels,
       v_subscription_tier
  FROM public.professional_details pd
  JOIN public.profiles pr ON pr.id = pd.profile_id
  LEFT JOIN public.professional_subscriptions ps ON ps.profile_id = pd.profile_id
  WHERE pd.profile_id = p_pro_profile_id;
  
  IF NOT FOUND THEN
      RAISE EXCEPTION 'PROFESSIONAL_NOT_FOUND';
  END IF;

  IF v_portfolio IS NOT NULL AND array_length(v_portfolio,1) >= 1 THEN
    v_cover := v_portfolio[1];
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', fl.id,
      'label', fl.label,
      'type', 'Point',
      'coordinates', jsonb_build_array(
        extensions.ST_X(fl.location_coords),
        extensions.ST_Y(fl.location_coords)
      )
    ) ORDER BY fl.created_at
  ), '[]'::jsonb)
  INTO v_all_locations
  FROM public.professional_fixed_locations fl
  WHERE fl.professional_profile_id = p_pro_profile_id;

  IF v_me IS NOT NULL AND v_my_role = 'bride' THEN
    SELECT EXISTS(
      SELECT 1 FROM public.wishlist_items
      WHERE bride_profile_id = v_me
        AND professional_profile_id = p_pro_profile_id
    ) INTO v_is_fav;
  END IF;

  IF v_me IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM public.user_blocks b
      WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = p_pro_profile_id)
         OR (b.blocker_profile_id = p_pro_profile_id AND b.blocked_profile_id = v_me)
    ) INTO v_blocked;
  END IF;

  can_contact_by_bride :=
    (v_subscription_tier IN ('premiumVisibility','ultimateAccess'))
    AND NOT v_blocked;

  can_contact_bride :=
    (v_my_role = 'professional')
    AND (v_my_tier IN ('premiumVisibility','ultimateAccess'))
    AND NOT v_blocked;

  RETURN jsonb_build_object(
    'proProfileId', p_pro_profile_id,
    'fullName', v_full_name,
    'avatarUrl', v_avatar_url,
    'businessName', v_business_name,
    'profession', v_profession::text,
    'budgetMin', v_budget_min,
    'budgetMax', v_budget_max,
    'currency', v_currency,
    'subscriptionTier', COALESCE(v_subscription_tier::text,'inactive'),
    'locationLabel', v_location_label,
    'coverImageUrl', v_cover,
    'isFavorited', v_is_fav,
    'isLive', v_is_live,
    'description', v_description,
    -- Legacy arrays (for backward compatibility)
    'portfolioImages', COALESCE(to_jsonb(v_portfolio), '[]'::jsonb),
    'slideshowImages', COALESCE(to_jsonb(v_slideshow), '[]'::jsonb),
    -- V2 arrays with all crops
    'portfolioImagesV2', COALESCE(v_portfolio_v2, '[]'::jsonb),
    'slideshowImagesV2', COALESCE(v_slideshow_v2, '[]'::jsonb),
    'fixedLocations', v_all_locations,
    'profileVideoUrl', v_profile_video_url,
    'hasCoverVideo', COALESCE(v_has_cover_video, false),
    'canBeContactedByBride', can_contact_by_bride,
    'canContactBride', can_contact_bride,
    'upcomingTravels', COALESCE(v_upcoming_travels, '[]'::jsonb),
    'socials', jsonb_build_object(
      'instagramUrl', v_instagram_url,
      'websiteUrl', v_website_url
    )
  );
END;
$$;


ALTER FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") IS 'Accessible par tous les utilisateurs (anon, authenticated) pour permettre la consultation des profils professionnels depuis Wedding of the Week';



CREATE OR REPLACE FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
    v_profile_data jsonb;
BEGIN
    SELECT
        jsonb_build_object(
            'profileId', pd.profile_id,
            'businessName', pd.business_name,
            'profession', pd.profession::text,
            'description', pd.description,
            'portfolioImages', to_jsonb(pd.portfolio_images),
            'slideshowImages', to_jsonb(pd.slideshow_images),
            'profileVideoUrl', pd.profile_video_url,
            'budgetMin', pd.budget_min,
            'budgetMax', pd.budget_max,
            'currency', pd.currency,
            'instagramUrl', pd.instagram_url,
            'websiteUrl', pd.website_url,
            'locationLabel', pd.location_label,
            'locationCity', pd.location_city,
            'locationCountryCode', pd.location_country_code,
            'isLive', pd.is_live,
            'wishlistCount', pd.wishlist_count,
            'profile', jsonb_build_object(
                'fullName', p.full_name,
                'avatarUrl', p.avatar_url,
                'country', p.country
            ),
            'subscription', jsonb_build_object(
                'tier', COALESCE(ps.subscription_tier::text, 'inactive')
            ),
            'fixedLocations', (
                SELECT COALESCE(jsonb_agg(
                    jsonb_build_object(
                        'label', fl.label,
                        'lat', ST_Y(fl.location_coords),
                        'lng', ST_X(fl.location_coords)
                    )
                ), '[]'::jsonb)
                FROM public.professional_fixed_locations fl
                WHERE fl.professional_profile_id = pd.profile_id
            )
        )
    INTO v_profile_data
    FROM public.professional_details pd
    JOIN public.profiles p ON p.id = pd.profile_id
    LEFT JOIN public.professional_subscriptions ps ON ps.profile_id = pd.profile_id
    WHERE pd.profile_id = p_profile_id
      AND pd.is_live = true;

    RETURN COALESCE(v_profile_data, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_chat_rooms_for_brides"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE 
  items jsonb;
  v_my_market text := public.get_my_market_region();
BEGIN
  WITH base AS (
    SELECT 
      pcr.chat_room_id AS room_id,
      pcr.title,
      pcr.cover_image_url,
      (
        SELECT count(DISTINCT m.profile_id)
        FROM public.chat_messages m
        WHERE m.room_id = pcr.chat_room_id
          AND m.is_deleted = false
      ) AS active_users_count
    FROM public.public_chat_rooms pcr
    WHERE pcr.is_active = true
      AND pcr.audience_role = 'bride'
      AND pcr.market_region = v_my_market
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'roomId', b.room_id,
      'title', b.title,
      'coverImageUrl', b.cover_image_url,
      'activeUsersCount', COALESCE(b.active_users_count, 0)
    )
    ORDER BY b.title ASC
  )
  INTO items
  FROM base b;

  RETURN jsonb_build_object('items', COALESCE(items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_public_chat_rooms_for_brides"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
BEGIN
  RETURN (
    SELECT jsonb_build_object(
      'id', p.id,
      'role', p.role,
      'full_name', p.full_name,
      'avatar_url', p.avatar_url
    )
    FROM public.profiles p
    WHERE p.id = p_profile_id
  );
END;
$$;


ALTER FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_replays_bundle"() RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_my_market text := public.get_my_market_region();  -- 'IN' or 'GLOBAL'
  v_result jsonb;
BEGIN
  SELECT COALESCE(jsonb_agg(replay_data ORDER BY is_featured DESC, created_at DESC), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', r.id,
      'title', r.title,
      'description', r.description,
      'youtubeUrl', r.youtube_url,
      'thumbnailUrl', r.thumbnail_url,
      'publishedAt', r.published_at,
      'isFeatured', r.is_featured,
      'createdAt', r.created_at,
      'guests', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'guestId', rg.id,
          'fullName', rg.full_name,
          'profession', rg.profession,
          'avatarUrl', rg.avatar_url
        ))
        FROM public.replay_guest_assignments rga
        JOIN public.replay_guests rg ON rg.id = rga.guest_id
        WHERE rga.replay_id = r.id
      ), '[]'::jsonb)
    ) as replay_data,
    r.is_featured,
    r.created_at
    FROM public.replays r
    WHERE r.is_published = true
      -- Filter by market region
      AND (
        r.target_region = 'all'
        OR (v_my_market = 'IN' AND r.target_region = 'IN')
        OR (v_my_market = 'GLOBAL' AND r.target_region = 'ROW')
      )
  ) sub;

  RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_replays_bundle"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_report_motifs"("p_locale" "text" DEFAULT 'fr'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
declare
  items jsonb := '[]'::jsonb;
begin
  select jsonb_agg(
    jsonb_build_object(
      'code', code,
      'label', case when p_locale = 'fr' then name_fr else name_en end
    )
  )
  into items
  from public.report_motifs
  where is_active = true
  order by sort_order asc;

  return jsonb_build_object('motifs', coalesce(items, '[]'::jsonb));
end;
$$;


ALTER FUNCTION "public"."get_report_motifs"("p_locale" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_room_header"("p_room_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$ declare v_me uuid := auth.uid(); v_type text; v_json jsonb; begin if v_me is null then raise exception 'AUTH_REQUIRED'; end if; select type into v_type from public.chat_rooms where id = p_room_id; if not found then raise exception 'ROOM_NOT_FOUND'; end if; if v_type = 'private' then if not is_room_participant(p_room_id, v_me) then raise exception 'NOT_A_PARTICIPANT'; end if; select jsonb_build_object('roomType','private', 'otherProfileId', pr.id, 'otherFullName', pr.full_name, 'otherAvatarUrl', pr.avatar_url, 'otherRole', pr.role::text) into v_json from public.chat_room_participants p1 join public.chat_room_participants p2 on p1.room_id = p2.room_id and p1.profile_id <> p2.profile_id join public.profiles pr on pr.id = case when p1.profile_id = v_me then p2.profile_id else p1.profile_id end where p1.room_id = p_room_id and (p1.profile_id = v_me or p2.profile_id = v_me) limit 1; else select jsonb_build_object('roomType','public', 'publicTitle', pcr.title, 'publicCoverUrl', pcr.cover_image_url, 'audienceRole', pcr.audience_role::text) into v_json from public.public_chat_rooms pcr where pcr.chat_room_id = p_room_id and pcr.is_active = true; end if; return v_json; end; $$;


ALTER FUNCTION "public"."get_room_header"("p_room_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer DEFAULT 50) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
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
      AND p.conversation_status = 'active'  -- Only show active conversations
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
  -- REMOVED: where r.last_msg is not null or r.room_type = 'public'
  -- Now includes private rooms without messages (newly created after accept)
  LIMIT GREATEST(COALESCE(p_limit, 50), 1);

  RETURN jsonb_build_object('items', COALESCE(items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") RETURNS "public"."subscriptionTierType"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT COALESCE(
    (SELECT subscription_tier
     FROM public.professional_subscriptions
     WHERE profile_id = p_profile_id),
     'inactive'::public."subscriptionTierType");
$$;


ALTER FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_unread_notifications_count"() RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
  SELECT count(*)::integer
  FROM public.notifications
  WHERE profile_id = auth.uid() AND is_read = false;
$$;


ALTER FUNCTION "public"."get_unread_notifications_count"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_unread_notifications_count"() IS 'Compte le nombre de notifications non lues pour l''utilisateur connecté. Utilisée pour afficher le badge dans l''app Flutter.';



CREATE OR REPLACE FUNCTION "public"."get_user_email"("user_id" "uuid") RETURNS TABLE("email" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT au.email::text
  FROM auth.users au
  WHERE au.id = user_id;
END;
$$;


ALTER FUNCTION "public"."get_user_email"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_email_by_profile_id"("p_profile_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_email TEXT;
BEGIN
  SELECT email INTO v_email
  FROM auth.users
  WHERE id = p_profile_id;
  
  RETURN v_email;
END;
$$;


ALTER FUNCTION "public"."get_user_email_by_profile_id"("p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_wedding_details"("p_wedding_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole" := public.get_my_role();
  v_is_pro boolean := (v_role = 'professional');
  v_my_tier public."subscriptionTierType" := public.get_my_tier();
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'id', w.id,
    'brideProfileId', w.bride_profile_id,
    'weddingName', w.wedding_name,
    'eventDate', w.event_date,
    'eventEndDate', w.event_end_date,
    'venueLabel', w.venue_label,
    'searchRadiusKm', w.search_radius_km,
    'budgetMin', w.budget_min,
    'budgetMax', w.budget_max,
    'currency', w.currency,
    'professionsNeeded', w.professions_needed,
    'visibility', w.visibility,
    'status', w.status,
    'isOwn', w.bride_profile_id = v_me,
    'brideInfo', jsonb_build_object(
      'fullName', pr.full_name,
      'avatarUrl', pr.avatar_url
    ),
    'createdAt', w.created_at
  ) INTO v_result
  FROM public.weddings w
  JOIN public.profiles pr ON pr.id = w.bride_profile_id
  WHERE w.id = p_wedding_id
    AND w.is_deleted = false
    AND (
      w.bride_profile_id = v_me
      OR
      (
        v_is_pro
        AND w.visibility = 'visible_to_pros'
        AND v_my_tier IN ('premiumVisibility', 'ultimateAccess')
      )
    );

  IF v_result IS NULL THEN
    RETURN jsonb_build_object('error', 'Wedding not found or access denied');
  END IF;

  RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_wedding_details"("p_wedding_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$DECLARE 
  v_me uuid := auth.uid(); 
  v_my_role public."userRole"; 
  v_my_tier public."subscriptionTierType"; 
  v_blocked boolean := false; 
  v_pin record; 
  v_is_contactable boolean := false;
  v_bride_avatar_url text;
BEGIN 
  IF v_me IS NOT NULL THEN 
    SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me; 
    v_my_tier := public.get_my_tier(); 
  END IF; 
  
  SELECT 
    id, 
    bride_profile_id, 
    location_coords, 
    radius_km, 
    professions_needed, 
    event_start_date, 
    event_end_date, 
    is_active, 
    is_deleted, 
    location_label, 
    budget_min, 
    budget_max, 
    currency 
  INTO v_pin 
  FROM public.wedding_pins 
  WHERE id = p_pin_id; 
  
  IF NOT FOUND OR v_pin.is_deleted THEN 
    RAISE EXCEPTION 'WEDDING_PIN_NOT_FOUND'; 
  END IF; 
  
  IF v_me IS NOT NULL THEN 
    SELECT EXISTS(
      SELECT 1 
      FROM public.user_blocks b 
      WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = v_pin.bride_profile_id) 
         OR (b.blocker_profile_id = v_pin.bride_profile_id AND b.blocked_profile_id = v_me)
    ) INTO v_blocked; 
  END IF; 
  
  v_is_contactable := (v_my_role = 'professional') 
                   AND (v_my_tier IN ('premiumVisibility','ultimateAccess')) 
                   AND NOT v_blocked; 
  
  SELECT avatar_url INTO v_bride_avatar_url
  FROM public.profiles
  WHERE id = v_pin.bride_profile_id;
  
  RETURN jsonb_build_object(
    'weddingPinId', v_pin.id, 
    'brideProfileId', v_pin.bride_profile_id, 
    'locationLabel', v_pin.location_label, 
    'center', ST_AsGeoJSON(v_pin.location_coords)::jsonb, 
    'radiusKm', v_pin.radius_km, 
    'professionsNeeded', (SELECT jsonb_agg(x) FROM unnest(v_pin.professions_needed) x), 
    'eventStartDate', v_pin.event_start_date,
    'eventEndDate', v_pin.event_end_date,
    'budgetMin', v_pin.budget_min, 
    'budgetMax', v_pin.budget_max, 
    'currency', v_pin.currency, 
    'isContactable', v_is_contactable,
    'brideAvatarUrl', v_bride_avatar_url
  ); 
END;$$;


ALTER FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_wishlisted_by_brides"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
    v_me uuid := auth.uid();
    v_items jsonb;
BEGIN
    IF v_me IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED';
    END IF;

    SELECT jsonb_agg(
        jsonb_build_object(
            'brideProfileId', p.id,
            'fullName', p.full_name,
            'avatarUrl', p.avatar_url,
            'addedAt', w.added_at,
            'contactStatus', COALESCE(cr.status::text, 'none')
        ) ORDER BY w.added_at DESC
    )
    INTO v_items
    FROM public.wishlist_items w
    JOIN public.profiles p ON w.bride_profile_id = p.id
    LEFT JOIN public.connection_requests cr 
        ON cr.pro_profile_id = v_me 
        AND cr.bride_profile_id = w.bride_profile_id
        AND cr.initiator_id = v_me
    WHERE w.professional_profile_id = v_me;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_wishlisted_by_brides"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_message_report"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.chat_messages SET is_deleted = true WHERE id = NEW.reported_message_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_message_report"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;


ALTER FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[] DEFAULT NULL::"text"[], "p_budget_min" integer DEFAULT NULL::integer, "p_budget_max" integer DEFAULT NULL::integer, "p_currency" "text" DEFAULT NULL::"text", "p_event_start_date" "date" DEFAULT NULL::"date", "p_event_end_date" "date" DEFAULT NULL::"date", "p_location_label" "text" DEFAULT ''::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_id uuid;
  v_me uuid := auth.uid();
  v_professions public.profession[];
  v_budget_max_clean integer;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  -- [Suggestion #7] Validation du rayon
  IF p_radius_km NOT IN (5, 10, 20, 50, 100) THEN
    RAISE EXCEPTION 'INVALID_RADIUS' USING HINT = 'Radius must be one of: 5, 10, 20, 50, 100.';
  END IF;
  
  -- Normalisation budget max (100k+ => NULL)
  IF p_budget_max IS NOT NULL AND p_budget_max >= 100000 THEN
    v_budget_max_clean := NULL;
  ELSE
    v_budget_max_clean := p_budget_max;
  END IF;

  -- Cast des professions
  IF p_professions IS NOT NULL THEN
    v_professions := ARRAY(SELECT unnest(p_professions)::public.profession);
  END IF;

  INSERT INTO public.wedding_pins(
    id, bride_profile_id, location_coords, radius_km, professions_needed,
    budget_min, budget_max, currency, event_start_date, event_end_date,
    is_active, is_deleted, location_label
  ) VALUES (
    gen_random_uuid(),
    v_me,
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326),
    p_radius_km,
    v_professions,
    p_budget_min,
    v_budget_max_clean,
    CASE WHEN p_currency IS NULL THEN NULL ELSE UPPER(p_currency) END,
    p_event_start_date,
    p_event_end_date,
    true,
    false,
    COALESCE(p_location_label, '')
  )
  RETURNING id INTO v_id;

  -- Triggers wedding_pins_set_budget_eur & history se déclenchent automatiquement.

  RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_blocks
    WHERE (blocker_profile_id = a AND blocked_profile_id = b)
       OR (blocker_profile_id = b AND blocked_profile_id = a)
  );
$$;


ALTER FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_public_room"("p_room_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
    select exists (select 1 from public.chat_rooms r where r.id = p_room_id and r.type = 'public' and r.is_active = true);
$$;


ALTER FUNCTION "public"."is_public_room"("p_room_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
    select exists (select 1 from public.chat_room_participants p where p.room_id = p_room_id and p.profile_id = p_profile_id);
$$;


ALTER FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_visible_in_market"("owner_country" "text", "viewer_region" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- If owner has no country set, visible to GLOBAL only (legacy non-Indian data)
  IF owner_country IS NULL THEN
    RETURN viewer_region = 'GLOBAL';
  END IF;
  
  -- Indian owners only visible to Indian viewers
  IF UPPER(owner_country) = 'IN' THEN
    RETURN viewer_region = 'IN';
  END IF;
  
  -- Non-Indian owners visible to GLOBAL viewers only
  RETURN viewer_region = 'GLOBAL';
END;
$$;


ALTER FUNCTION "public"."is_visible_in_market"("owner_country" "text", "viewer_region" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole";
  v_room_type text;
  v_audience public."userRole";
  v_is_active boolean;
  v_market_region text;
  v_my_market text := public.get_my_market_region();
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  SELECT role INTO v_role FROM public.profiles WHERE id = v_me;
  IF v_role <> 'bride' THEN
    RAISE EXCEPTION 'ONLY_BRIDES_CAN_JOIN_PUBLIC_SALONS';
  END IF;

  SELECT r.type, pcr.audience_role, pcr.is_active, pcr.market_region
  INTO v_room_type, v_audience, v_is_active, v_market_region
  FROM public.chat_rooms r
  JOIN public.public_chat_rooms pcr ON pcr.chat_room_id = r.id
  WHERE r.id = p_room_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PUBLIC_ROOM_NOT_FOUND';
  END IF;

  IF v_room_type <> 'public' THEN
    RAISE EXCEPTION 'ROOM_NOT_PUBLIC';
  END IF;

  IF v_audience <> 'bride' THEN
    RAISE EXCEPTION 'AUDIENCE_NOT_BRIDE';
  END IF;

  IF NOT v_is_active THEN
    RAISE EXCEPTION 'ROOM_INACTIVE';
  END IF;

  -- Check market region
  IF v_market_region <> v_my_market THEN
    RAISE EXCEPTION 'MARKET_MISMATCH';
  END IF;

  INSERT INTO public.chat_room_participants(room_id, profile_id, conversation_status)
  VALUES (p_room_id, v_me, 'active')
  ON CONFLICT (room_id, profile_id) DO NOTHING;

  RETURN p_room_id;
END;
$$;


ALTER FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_all_notifications_as_read"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
  UPDATE public.notifications
  SET is_read = true
  WHERE profile_id = auth.uid() AND is_read = false;
$$;


ALTER FUNCTION "public"."mark_all_notifications_as_read"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
  UPDATE public.notifications
  SET is_read = true
  WHERE id = p_notification_id AND profile_id = auth.uid();
$$;


ALTER FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_video_sessions_missed"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.video_sessions SET status='missed'
  WHERE status='pending' AND created_at < now() - interval '1 minute';
END;
$$;


ALTER FUNCTION "public"."mark_video_sessions_missed"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_crm_is_live_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  user_email text;
BEGIN
  -- Only proceed if is_live actually changed
  IF OLD.is_live IS NOT DISTINCT FROM NEW.is_live THEN
    RETURN NEW;
  END IF;

  -- Get the user's email from auth.users
  SELECT email INTO user_email
  FROM auth.users
  WHERE id = NEW.profile_id;

  IF user_email IS NULL THEN
    RAISE WARNING '[notify_crm_is_live_change] No email found for profile_id: %', NEW.profile_id;
    RETURN NEW;
  END IF;

  RAISE NOTICE '[notify_crm_is_live_change] is_live changed from % to % for email: %', OLD.is_live, NEW.is_live, user_email;

  -- Send HTTP POST to CRM Edge Function
  PERFORM net.http_post(
    url := 'https://pjcorrkwafjskmzmimon.supabase.co/functions/v1/sync-is-live-from-app',
    body := jsonb_build_object(
      'email', user_email,
      'is_live', NEW.is_live,
      'profile_id', NEW.profile_id::text,
      'changed_at', now()
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqY29ycmt3YWZqc2ttem1pbW9uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzgyODksImV4cCI6MjA3OTU1NDI4OX0._cufIk_wmDY2HzgiQY3doAOrt4XFTWElEH1QlbuPnsw',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqY29ycmt3YWZqc2ttem1pbW9uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzgyODksImV4cCI6MjA3OTU1NDI4OX0._cufIk_wmDY2HzgiQY3doAOrt4XFTWElEH1QlbuPnsw'
    )
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_crm_is_live_change"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."notify_crm_is_live_change"() IS 'Syncs is_live status from APP professional_details to CRM profiles.is_live_app. Created 06/12/2025.';



CREATE OR REPLACE FUNCTION "public"."notify_crm_replays_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  payload JSONB;
  crm_url TEXT := 'https://pjcorrkwafjskmzmimon.supabase.co/functions/v1/sync-replays-from-app';
BEGIN
  -- Build payload
  payload := jsonb_build_object(
    'action', TG_OP,
    'replay', CASE 
      WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD)
      ELSE to_jsonb(NEW)
    END
  );

  -- Send to CRM via HTTP (no auth needed, Edge Function is public)
  PERFORM net.http_post(
    url := crm_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );

  RAISE NOTICE '[replays_sync] Sent % notification to CRM for replay %', TG_OP, COALESCE(NEW.id, OLD.id);

  RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION "public"."notify_crm_replays_change"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."notify_crm_replays_change"() IS 'Syncs replays changes to CRM database via Edge Function';



CREATE OR REPLACE FUNCTION "public"."notify_crm_wed_articles_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  payload JSONB;
  pro_info JSONB;
  crm_url TEXT := 'https://pjcorrkwafjskmzmimon.supabase.co/functions/v1/sync-wed-articles-from-app';
BEGIN
  -- Get pro info for the article
  IF TG_OP = 'DELETE' THEN
    pro_info := '{}'::JSONB;
  ELSE
    SELECT jsonb_build_object(
      'email', NULL,
      'name', pd.business_name,
      'profession', pd.profession
    ) INTO pro_info
    FROM profiles p
    LEFT JOIN professional_details pd ON pd.profile_id = p.id
    WHERE p.id = NEW.linked_pro_profile_id;
  END IF;

  -- Build payload
  payload := jsonb_build_object(
    'action', TG_OP,
    'article', CASE 
      WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD)
      ELSE to_jsonb(NEW)
    END,
    'pro_info', COALESCE(pro_info, '{}'::JSONB)
  );

  -- Send to CRM via HTTP (no auth needed, Edge Function is public)
  PERFORM net.http_post(
    url := crm_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );

  RAISE NOTICE '[wed_articles_sync] Sent % notification to CRM for article %', TG_OP, COALESCE(NEW.id, OLD.id);

  RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION "public"."notify_crm_wed_articles_change"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."notify_crm_wed_articles_change"() IS 'Syncs wed_articles changes to CRM database via Edge Function';



CREATE OR REPLACE FUNCTION "public"."on_auth_user_created"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  -- Insert into profiles
  INSERT INTO public.profiles(id, role, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role','bride')::public."userRole",
    NEW.raw_user_meta_data->>'full_name'
  );

  -- Insert notification settings
  INSERT INTO public.notification_settings(profile_id, notification_type, in_app_enabled, push_enabled)
  SELECT NEW.id, nt::public."notificationType", true, true
  FROM unnest(ARRAY[
    'chatMessage','connectionRequest','connectionRequestAccepted','connectionRequestDeclined',
    'wishlistAdd','professionalAlert','professionalAlertReminder24h',
    'videoIncoming','wedPublished','weddingPinMatch'
  ]) AS nt;

  -- Insert user preferences with default currency
  INSERT INTO public.user_preferences(profile_id, distance_unit, default_radius_km, default_locale, map_toggles, currency)
  VALUES (NEW.id, 'km', 20, NULL, '{}'::jsonb, 'EUR')
  ON CONFLICT (profile_id) DO UPDATE SET currency = EXCLUDED.currency;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_auth_user_created"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_blocked boolean;
  v_init_role public."userRole";
  v_targ_role public."userRole";
  v_init_tier public."subscriptionTierType";
  v_room_id uuid;
  v_req_id uuid;
  v_is_room_empty boolean := false;
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
    'firstMessageTextOnly', false,
    'limitToSingleInitialMessage', false,
    'viewerIsReviewer', v_viewer_is_reviewer,
    'conversationStatus', coalesce(v_conv_status_me, 'active')
  );
END;
$$;


ALTER FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_chat_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
  v_room_type text;
  v_is_initial_request_message boolean := false;
BEGIN
  SELECT type INTO v_room_type
  FROM public.chat_rooms
  WHERE id = NEW.room_id;

  -- N'enqueuer que pour les rooms privés (pas de push sur salons publics)
  IF v_room_type <> 'private' THEN
    RETURN NEW;
  END IF;

  -- Vérifier si c'est un message initial d'une demande de contact
  -- Ces messages ont un created_at dans le passé (copié de la demande originale)
  -- Un message normal a created_at très proche de now() (< 5 secondes)
  IF NEW.created_at < (now() - interval '5 seconds') THEN
    -- C'est probablement un message initial de demande de contact, ignorer
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications_outbox(event_type, payload, event_key)
  VALUES (
    'chatMessageCreated',
    jsonb_build_object(
      'message_id', NEW.id,
      'room_id', NEW.room_id,
      'sender_profile_id', NEW.profile_id
    ),
    'chat:' || NEW.id::text
  )
  ON CONFLICT (event_key) DO NOTHING;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."outbox_on_chat_message"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_connection_request"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.notifications_outbox(event_type, payload)
    VALUES ('connectionRequestCreated', jsonb_build_object('request_id', NEW.id));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.status <> OLD.status THEN
      IF NEW.status = 'accepted' THEN
        INSERT INTO public.notifications_outbox(event_type, payload)
        VALUES ('connectionRequestAccepted', jsonb_build_object('request_id', NEW.id));
      ELSIF NEW.status = 'declined' THEN
        INSERT INTO public.notifications_outbox(event_type, payload)
        VALUES ('connectionRequestDeclined', jsonb_build_object('request_id', NEW.id));
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."outbox_on_connection_request"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_connection_request_aiu"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_actor uuid := auth.uid();
  v_event_type text;
  v_event_key text;
  v_recipient uuid;
  v_sender uuid;
  v_room_id uuid;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_event_type := 'connectionRequestCreated';

    -- Déterminer sender/recipient
    IF v_actor IS NULL THEN
      v_sender := NEW.pro_profile_id;
      v_recipient := NEW.bride_profile_id;
    ELSE
      IF v_actor = NEW.pro_profile_id THEN
        v_sender := NEW.pro_profile_id;
        v_recipient := NEW.bride_profile_id;
      ELSE
        v_sender := NEW.bride_profile_id;
        v_recipient := NEW.pro_profile_id;
      END IF;
    END IF;

    -- Tenter de retrouver la room privée existante entre pro et bride
    SELECT r.id
      INTO v_room_id
      FROM public.chat_rooms r
      JOIN public.chat_room_participants p1 ON p1.room_id = r.id AND p1.profile_id = NEW.pro_profile_id
      JOIN public.chat_room_participants p2 ON p2.room_id = r.id AND p2.profile_id = NEW.bride_profile_id
     WHERE r.type = 'private'
     LIMIT 1;

    v_event_key := 'connreq:' || NEW.id::text || ':created';

    INSERT INTO public.notifications_outbox(event_type, payload, event_key)
    VALUES (
      v_event_type,
      jsonb_build_object(
        'request_id', NEW.id,
        'status', NEW.status,
        'pro_profile_id', NEW.pro_profile_id,
        'bride_profile_id', NEW.bride_profile_id,
        'source', NEW.source,
        'sender_profile_id', v_sender,
        'recipient_profile_id', v_recipient,
        'room_id', v_room_id
      ),
      v_event_key
    )
    ON CONFLICT (event_key) DO NOTHING;

    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
      -- SEULEMENT notifier pour 'accepted', PAS pour 'declined'
      IF NEW.status = 'accepted' THEN
        v_event_type := 'connectionRequestAccepted';
      ELSE
        -- 'declined' et autres statuts ne sont plus notifiés
        RETURN NEW;
      END IF;

      IF v_actor IS NULL THEN
        v_sender := NEW.bride_profile_id;
        v_recipient := NEW.pro_profile_id;
      ELSE
        IF v_actor = NEW.pro_profile_id THEN
          v_sender := NEW.pro_profile_id;
          v_recipient := NEW.bride_profile_id;
        ELSE
          v_sender := NEW.bride_profile_id;
          v_recipient := NEW.pro_profile_id;
        END IF;
      END IF;

      -- Recherche de room privée pour Accepted
      SELECT r.id
        INTO v_room_id
        FROM public.chat_rooms r
        JOIN public.chat_room_participants p1 ON p1.room_id = r.id AND p1.profile_id = NEW.pro_profile_id
        JOIN public.chat_room_participants p2 ON p2.room_id = r.id AND p2.profile_id = NEW.bride_profile_id
       WHERE r.type = 'private'
       LIMIT 1;

      v_event_key := 'connreq:' || NEW.id::text || ':' || NEW.status::text;

      INSERT INTO public.notifications_outbox(event_type, payload, event_key)
      VALUES (
        v_event_type,
        jsonb_build_object(
          'request_id', NEW.id,
          'status', NEW.status,
          'pro_profile_id', NEW.pro_profile_id,
          'bride_profile_id', NEW.bride_profile_id,
          'source', NEW.source,
          'sender_profile_id', v_sender,
          'recipient_profile_id', v_recipient,
          'room_id', v_room_id
        ),
        v_event_key
      )
      ON CONFLICT (event_key) DO NOTHING;
    END IF;

    RETURN NEW;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."outbox_on_connection_request_aiu"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_video_session_created"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
  sender_name text;
  sender_avatar text;
BEGIN
  -- Récupérer les informations du sender depuis la table profiles
  SELECT full_name, avatar_url
  INTO sender_name, sender_avatar
  FROM public.profiles
  WHERE id = NEW.initiator_id;

  -- Insère un événement "videoIncoming" dans la table outbox avec les infos complètes
  INSERT INTO public.notifications_outbox(event_type, payload, event_key)
  VALUES (
    'videoIncoming',
    jsonb_build_object(
      'video_session_id', NEW.id,
      'agora_channel_name', NEW.agora_channel_name,
      'sender_profile_id', NEW.initiator_id,
      'sender_full_name', COALESCE(sender_name, 'Unknown'),
      'sender_avatar_url', sender_avatar,
      'recipient_profile_id', NEW.receiver_id
    ),
    'video-incoming-' || NEW.id::text -- Clé unique pour éviter les doublons
  )
  ON CONFLICT (event_key) DO NOTHING;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."outbox_on_video_session_created"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_wishlist_add"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  pro_tier public."subscriptionTierType";
BEGIN
  SELECT subscription_tier INTO pro_tier
  FROM public.professional_subscriptions
  WHERE profile_id = NEW.professional_profile_id;

  IF pro_tier = 'ultimateAccess' THEN
    INSERT INTO public.notifications_outbox(event_type, payload, event_key)
    VALUES (
      'wishlistAdded',
      jsonb_build_object(
        'bride_profile_id', NEW.bride_profile_id,
        'professional_profile_id', NEW.professional_profile_id,
        'added_at', NEW.added_at,
        'sender_profile_id', NEW.bride_profile_id,
        'recipient_profile_id', NEW.professional_profile_id
      ),
      'wishlist:' || NEW.bride_profile_id::text || ':' || NEW.professional_profile_id::text
    )
    ON CONFLICT (event_key) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."outbox_on_wishlist_add"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prof_details_set_budget_eur"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  IF NEW.currency IS NULL THEN
    NEW.budget_min_eur := NULL;
    NEW.budget_max_eur := NULL;
  ELSE
    NEW.budget_min_eur := public.convert_to_eur(NEW.budget_min::numeric, NEW.currency);
    NEW.budget_max_eur := public.convert_to_eur(NEW.budget_max::numeric, NEW.currency);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."prof_details_set_budget_eur"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."recompute_all_budgets_eur"() RETURNS TABLE("updated_pros" integer, "updated_pins" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  -- Recompute pros
  UPDATE public.professional_details pd
  SET budget_min_eur = CASE WHEN pd.budget_min IS NULL OR pd.currency IS NULL
                            THEN NULL
                            ELSE public.convert_to_eur(pd.budget_min::numeric, pd.currency)
                       END,
      budget_max_eur = CASE WHEN pd.budget_max IS NULL OR pd.currency IS NULL
                            THEN NULL
                            ELSE public.convert_to_eur(pd.budget_max::numeric, pd.currency)
                       END
  WHERE TRUE;
  GET DIAGNOSTICS updated_pros = ROW_COUNT;

  -- Recompute wedding pins
  UPDATE public.wedding_pins wp
  SET budget_min_eur = CASE WHEN wp.budget_min IS NULL OR wp.currency IS NULL
                            THEN NULL
                            ELSE public.convert_to_eur(wp.budget_min::numeric, wp.currency)
                       END,
      budget_max_eur = CASE WHEN wp.budget_max IS NULL OR wp.currency IS NULL
                            THEN NULL
                            ELSE public.convert_to_eur(wp.budget_max::numeric, wp.currency)
                       END
  WHERE TRUE;
  GET DIAGNOSTICS updated_pins = ROW_COUNT;

  RETURN;
END;
$$;


ALTER FUNCTION "public"."recompute_all_budgets_eur"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) RETURNS TABLE("id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  UPDATE public.professional_alerts a
     SET reminder_sent = true
   WHERE a.status = 'active'
     AND a.is_deleted = false
     AND a.reminder_sent = false
     AND a.expires_at >= p_from
     AND a.expires_at <= p_to
  RETURNING a.id;
$$;


ALTER FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) IS 'Capture atomique des alertes à rappeler dans la fenêtre [p_from; p_to] et flag reminder_sent=true. Phase 2.3';



CREATE OR REPLACE FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_bbox extensions.geometry;

  v_me uuid := auth.uid();
  v_role public."userRole" := public.get_my_role();
  v_is_pro boolean := (v_role = 'professional');
  v_my_tier public."subscriptionTierType" := public.get_my_tier();
  v_my_profession public.profession;
  
  -- Market region for filtering
  v_my_market text := public.get_my_market_region();

  v_prof_filter text[];
  v_currency text;
  v_budget_min_eur numeric;
  v_budget_max_eur numeric;

  -- REMOVED: t_show_pros (no longer needed)
  t_show_fixed boolean := COALESCE((p_filters->>'showFixedLocations')::boolean, true);
  t_show_alerts boolean := COALESCE((p_filters->>'showProAlerts')::boolean, true);
  t_show_weddings boolean := COALESCE((p_filters->>'showWeddings')::boolean, true);

  v_limit_each int;

  out_markers jsonb := '[]'::jsonb;
  out_overlays jsonb := '[]'::jsonb;

  t0 timestamptz := clock_timestamp();
  ms_fixed int; ms_alerts int; ms_weddings int;
BEGIN
  v_bbox := extensions.ST_MakeEnvelope(
    (p_bbox_coords->>'min_lng')::float,
    (p_bbox_coords->>'min_lat')::float,
    (p_bbox_coords->>'max_lng')::float,
    (p_bbox_coords->>'max_lat')::float,
    4326
  );

  v_limit_each := CASE
    WHEN p_zoom <= 5 THEN 2000
    WHEN p_zoom BETWEEN 6 AND 8 THEN 800
    WHEN p_zoom BETWEEN 9 AND 11 THEN 300
    WHEN p_zoom BETWEEN 12 AND 14 THEN 100
    ELSE 50
  END;

  SELECT ARRAY(SELECT jsonb_array_elements_text(p_filters->'professions')) INTO v_prof_filter;

  v_currency := NULLIF(p_filters->>'currency','');
  v_budget_min_eur := public.convert_to_eur(NULLIF(p_filters->>'budgetMin','')::numeric, v_currency);
  v_budget_max_eur := public.convert_to_eur(NULLIF(p_filters->>'budgetMax','')::numeric, v_currency);

  IF v_is_pro AND v_me IS NOT NULL THEN
    SELECT pd.profession INTO v_my_profession
    FROM public.professional_details pd
    WHERE pd.profile_id = v_me;
  END IF;

  -- SECTION 1 "Pros live" REMOVED (04/12/2025)
  -- Pros are now displayed ONLY via fixed_locations below
  -- This eliminates the duplicate marker issue and uses professional_fixed_locations as single source of truth

  -- 2) Fixed locations - NOW THE ONLY SOURCE FOR PRO MARKERS
  IF t_show_fixed THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', fl.id,
          'type', 'fixedLocation',
          'position', extensions.ST_AsGeoJSON(fl.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url,
            'borderColorHex', public.get_color_for_profession(pd.profession),
            'profileId', pd.profile_id,
            'locationLabel', fl.label
          )
        ) AS marker_data
        FROM public.professional_fixed_locations fl
        JOIN public.professional_details pd ON pd.profile_id = fl.professional_profile_id
        JOIN public.profiles pr ON pr.id = fl.professional_profile_id
        WHERE pd.is_live = true
          AND extensions.ST_Intersects(fl.location_coords, v_bbox)
          AND public.is_visible_in_market(pd.location_country_code, v_my_market)
          AND (COALESCE(array_length(v_prof_filter,1),0) = 0 OR pd.profession::text = ANY(v_prof_filter))
          AND (
            (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
            OR (pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
              AND (v_budget_min_eur IS NULL OR pd.budget_max_eur >= v_budget_min_eur)
              AND (v_budget_max_eur IS NULL OR pd.budget_min_eur <= v_budget_max_eur))
          )
        ORDER BY fl.created_at DESC
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_fixed := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int;

  -- 3) Alerts
  IF v_is_pro AND t_show_alerts THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', a.id,
          'type', 'professionalAlert',
          'position', extensions.ST_AsGeoJSON(a.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'isOwn', a.author_profile_id = v_me,
            'avatarUrl', pr.avatar_url,
            'alertType', a.alert_type,
            'eventDate', a.event_date
          )
        ) AS marker_data
        FROM public.professional_alerts a
        JOIN public.profiles pr ON pr.id = a.author_profile_id
        JOIN public.professional_details author_pd ON author_pd.profile_id = a.author_profile_id
        WHERE a.status = 'active'
          AND a.is_deleted = false
          AND a.expires_at > now()
          AND extensions.ST_Intersects(a.location_coords, v_bbox)
          AND public.is_visible_in_market(author_pd.location_country_code, v_my_market)
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_alerts := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - ms_fixed;

  -- 4) Weddings
  IF t_show_weddings THEN
    WITH visible_weddings AS (
      SELECT
        w.id,
        w.bride_profile_id,
        w.venue_coords,
        w.professions_needed,
        w.budget_min_eur,
        w.budget_max_eur,
        pr.avatar_url as bride_avatar_url,
        w.created_at
      FROM public.weddings w
      JOIN public.profiles pr ON pr.id = w.bride_profile_id
      WHERE w.is_deleted = false
        AND w.status IN ('planning', 'confirmed')
        AND (w.event_date >= CURRENT_DATE OR w.event_end_date >= CURRENT_DATE)
        AND w.venue_coords IS NOT NULL
        AND extensions.ST_Intersects(w.venue_coords, v_bbox)
        AND public.is_visible_in_market(
          CASE WHEN UPPER(pr.country) IN ('INDIA', 'IN') THEN 'IN' ELSE pr.country END,
          v_my_market
        )
        AND (
          (NOT v_is_pro AND v_me IS NOT NULL AND w.bride_profile_id = v_me)
          OR
          (
            v_is_pro
            AND w.visibility = 'visible_to_pros'
            AND v_my_tier IN ('premiumVisibility','ultimateAccess')
            AND (
              (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
              OR (w.budget_min_eur IS NOT NULL AND w.budget_max_eur IS NOT NULL
                AND (v_budget_min_eur IS NULL OR w.budget_max_eur >= v_budget_min_eur)
                AND (v_budget_max_eur IS NULL OR w.budget_min_eur <= v_budget_max_eur))
            )
            AND (
              COALESCE(array_length(v_prof_filter,1),0) = 0
              OR (v_my_profession IS NOT NULL AND w.professions_needed @> ARRAY[v_my_profession])
              OR (exists (select 1 from unnest(w.professions_needed) p where p::text = ANY(v_prof_filter)))
            )
          )
        )
      ORDER BY w.created_at DESC
      LIMIT v_limit_each
    )
    SELECT
      out_markers || COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'id', vw.id,
            'type', 'wedding',
            'position', extensions.ST_AsGeoJSON(vw.venue_coords)::jsonb,
            'styleInfo', jsonb_build_object(
              'isOwn', vw.bride_profile_id = v_me,
              'avatarUrl', vw.bride_avatar_url
            )
          )
        ) FILTER (WHERE vw.id IS NOT NULL),
        '[]'::jsonb
      )
    INTO out_markers
    FROM visible_weddings vw;
  END IF;
  ms_weddings := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_fixed + ms_alerts);

  RETURN jsonb_build_object(
    'markers', out_markers,
    'overlays', out_overlays,
    'market', v_my_market,
    'debugStats', format(
      'ms: total=%s | fixed=%s, alerts=%s, weddings=%s | market=%s',
      EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int, ms_fixed, ms_alerts, ms_weddings, v_my_market
    )
  );
END;
$$;


ALTER FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) IS 'RPC pour recherche map avec filtres. v2.1: Ajout locationLabel pour fixed locations.';



CREATE OR REPLACE FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
p_paris  geometry := ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326);
p_london geometry := ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326);
p_nyc    geometry := ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326);
p_rome   geometry := ST_SetSRID(ST_MakePoint(12.4964, 41.9028), 4326);
p_tokyo  geometry := ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326);
BEGIN
DELETE FROM public.professional_alerts WHERE author_profile_id = p_pro;
DELETE FROM public.professional_fixed_locations WHERE professional_profile_id = p_pro;
DELETE FROM public.user_pois WHERE bride_profile_id = p_bride;
DELETE FROM public.wedding_pins WHERE bride_profile_id = p_bride;

INSERT INTO public.professional_subscriptions(profile_id, subscription_tier)
VALUES (p_pro, 'ultimateAccess')
ON CONFLICT (profile_id) DO UPDATE SET subscription_tier = EXCLUDED.subscription_tier;

INSERT INTO public.professional_details(profile_id, business_name, profession, is_live, location_coords, location_label) 
VALUES (p_pro, 'Test Pro', 'PHOTOGRAPHER', true, p_paris, 'Paris, France')
ON CONFLICT (profile_id) DO UPDATE SET is_live = true, location_coords = EXCLUDED.location_coords;

INSERT INTO public.professional_fixed_locations(professional_profile_id, location_coords, label)
VALUES (p_pro, ST_SetSRID(ST_MakePoint(2.3333, 48.8600), 4326), 'Marais Studio'), (p_pro, ST_SetSRID(ST_MakePoint(-0.1410, 51.5010), 4326), 'London Spot');

INSERT INTO public.pro_recent_locations(profile_id, coords_approx, is_opt_in, last_seen_at)
VALUES (p_pro, ST_SetSRID(ST_MakePoint(2.3698, 48.8594), 4326), true, now())
ON CONFLICT (profile_id) DO UPDATE SET is_opt_in = true, coords_approx = EXCLUDED.coords_approx;

INSERT INTO public.professional_alerts(author_profile_id, title, message, location_coords, radius_km, duration_hours, status)
VALUES (p_pro, 'Looking for MUA', 'Urgent event downtown', ST_SetSRID(ST_MakePoint(2.3200, 48.8567), 4326), 5, 48, 'active');

INSERT INTO public.wedding_pins(bride_profile_id, location_coords, radius_km, professions_needed, is_active, location_label) 
VALUES (p_bride, p_paris, 20, ARRAY['PHOTOGRAPHER','PLANNER']::public.profession[], true, 'Paris Wedding Area'), (p_bride, p_london, 10, ARRAY['MAKEUP']::public.profession[], true, 'London Central');

INSERT INTO public.user_pois(bride_profile_id, label, coords, location_label) 
VALUES (p_bride, 'Dress Shop', ST_SetSRID(ST_MakePoint(2.2945,48.8584), 4326), 'Near Eiffel'), (p_bride, 'Cathedral', ST_SetSRID(ST_MakePoint(-0.0761,51.5081), 4326), 'City landmark');
END;
$$;


ALTER FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_alert_reminders"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.professional_alerts
  SET reminder_sent = true
  WHERE status='active' AND reminder_sent=false
    AND now() >= (created_at + interval '24 hours')
    AND expires_at > now();
END;
$$;


ALTER FUNCTION "public"."send_alert_reminders"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."set_current_timestamp_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_professional_alert_expiry"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  NEW.expires_at := COALESCE(NEW.created_at, now()) + (NEW.duration_hours * interval '1 hour');
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_professional_alert_expiry"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_professional_on_validation"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF NEW.is_live = true AND (OLD.is_live IS DISTINCT FROM NEW.is_live) THEN
    PERFORM
      net.http_post(
        url := 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/sync-professional-to-app',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5Nzg1MzQsImV4cCI6MjA3OTU1NDUzNH0.MNxUZAyL_7tSGp-w7MZ6rYx6UiZIMSPOnwC0XhsOHgI'
        ),
        body := jsonb_build_object('profile_id', NEW.profile_id)
      );
    RAISE NOTICE 'Sync triggered for profile %', NEW.profile_id;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_professional_on_validation"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_profile_to_professional_details"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  -- Ne synchroniser que si le rôle est 'professional'
  IF NEW.role = 'professional' THEN
    -- Upsert dans professional_details
    INSERT INTO public.professional_details (
      profile_id,
      business_name,
      description,
      portfolio_images,
      slideshow_images,
      profile_video_url,
      budget_min,
      budget_max,
      currency,
      instagram_url,
      website_url,
      location_label,
      profession,
      is_live,
      is_pending,
      updated_at
    ) VALUES (
      NEW.id,
      COALESCE(NEW.studio_name, NEW.full_name),
      NEW.bio,
      COALESCE(NEW.portfolio_photos, ARRAY[]::text[]),
      COALESCE(NEW.slideshow_photos, ARRAY[]::text[]),
      NEW.profile_video_url,
      NEW.budget_min,
      NEW.budget_max,
      'EUR', -- devise par défaut
      NEW.instagram_handle,
      NEW.website_url,
      NEW.locations::text, -- convertir jsonb en text
      COALESCE(NEW.specialty, 'OTHER'),
      false, -- is_live par défaut
      false, -- is_pending par défaut
      now()
    )
    ON CONFLICT (profile_id) 
    DO UPDATE SET
      business_name = COALESCE(EXCLUDED.business_name, professional_details.business_name),
      description = COALESCE(EXCLUDED.description, professional_details.description),
      portfolio_images = COALESCE(EXCLUDED.portfolio_images, professional_details.portfolio_images),
      slideshow_images = COALESCE(EXCLUDED.slideshow_images, professional_details.slideshow_images),
      profile_video_url = EXCLUDED.profile_video_url,
      budget_min = EXCLUDED.budget_min,
      budget_max = EXCLUDED.budget_max,
      instagram_url = COALESCE(EXCLUDED.instagram_url, professional_details.instagram_url),
      website_url = COALESCE(EXCLUDED.website_url, professional_details.website_url),
      location_label = COALESCE(EXCLUDED.location_label, professional_details.location_label),
      profession = COALESCE(EXCLUDED.profession, professional_details.profession),
      updated_at = now();
    
    -- Synchroniser les emplacements fixes (ultimateLocations)
    IF NEW.ultimate_locations IS NOT NULL THEN
      -- Supprimer les anciens emplacements
      DELETE FROM public.professional_fixed_locations 
      WHERE professional_profile_id = NEW.id;
      
      -- Insérer les nouveaux emplacements
      INSERT INTO public.professional_fixed_locations (professional_profile_id, label)
      SELECT NEW.id, loc->>'label'
      FROM jsonb_array_elements(NEW.ultimate_locations) AS loc
      WHERE loc->>'label' IS NOT NULL;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_profile_to_professional_details"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") RETURNS integer
    LANGUAGE "sql" IMMUTABLE
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
SELECT CASE t
  WHEN 'ultimateAccess' THEN 2
  WHEN 'premiumVisibility' THEN 1
  ELSE 0
END
$$;


ALTER FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_my_role public."userRole";
  v_deleted int := 0;
  v_exists boolean;
BEGIN
  IF v_me IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED';
  END IF;

  SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me;
  IF v_my_role <> 'bride' THEN
    RAISE EXCEPTION 'ONLY_BRIDE_CAN_WISHLIST';
  END IF;

  DELETE FROM public.wishlist_items
  WHERE bride_profile_id = v_me
    AND professional_profile_id = p_pro_profile_id;
  GET DIAGNOSTICS v_deleted = ROW_COUNT;

  IF v_deleted > 0 THEN
    RETURN jsonb_build_object('isFavorited', false);
  END IF;

  BEGIN
    INSERT INTO public.wishlist_items(bride_profile_id, professional_profile_id)
    VALUES (v_me, p_pro_profile_id)
    ON CONFLICT (bride_profile_id, professional_profile_id) DO NOTHING;
  EXCEPTION WHEN unique_violation THEN
    -- ignore
    NULL;
  END;

  SELECT EXISTS(
    SELECT 1 FROM public.wishlist_items
    WHERE bride_profile_id = v_me
      AND professional_profile_id = p_pro_profile_id
  ) INTO v_exists;

  RETURN jsonb_build_object('isFavorited', v_exists);
END;
$$;


ALTER FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_process_outbox_realtime"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'net'
    AS $$
DECLARE
  v_url text := 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/notifications_outbox_drain';
  v_token text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Mzk3ODUzNCwiZXhwIjoyMDc5NTU0NTM0fQ.NCqoShehd2V8xZyMJcMq8bxVqKWIx5S4c0BMkujp6PU';
BEGIN
  -- Appeler l'Edge Function immédiatement avec l'event_id
  -- pg_net timeout de 5s mais on s'en fiche - l'Edge Function continue en background
  PERFORM net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_token
    ),
    body := jsonb_build_object('event_id', NEW.id::text)
  );
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_process_outbox_realtime"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_alert"("p_alert_id" "uuid", "p_title" "text" DEFAULT NULL::"text", "p_message" "text" DEFAULT NULL::"text", "p_event_date" "date" DEFAULT NULL::"date", "p_location_lat" double precision DEFAULT NULL::double precision, "p_location_lng" double precision DEFAULT NULL::double precision, "p_location_label" "text" DEFAULT NULL::"text", "p_status" "public"."alertStatus" DEFAULT NULL::"public"."alertStatus") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_alert record;
  v_new_expires_at timestamptz;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  SELECT * INTO v_alert
  FROM public.professional_alerts
  WHERE id = p_alert_id AND is_deleted = false;

  IF v_alert IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Alert not found');
  END IF;

  IF v_alert.author_profile_id != v_me THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authorized to update this alert');
  END IF;

  IF p_title IS NOT NULL THEN
    IF length(p_title) < 3 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Title must be at least 3 characters');
    END IF;
    IF length(p_title) > 100 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Title must be 100 characters or less');
    END IF;
  END IF;

  IF p_message IS NOT NULL THEN
    IF length(p_message) < 3 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Message must be at least 3 characters');
    END IF;
    IF length(p_message) > 2000 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Message must be 2000 characters or less');
    END IF;
  END IF;

  IF p_location_lat IS NOT NULL OR p_location_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_location_lat, p_location_lng) THEN
      RETURN jsonb_build_object('success', false, 'error', 'Invalid coordinates');
    END IF;
    IF p_location_lat IS NULL OR p_location_lng IS NULL THEN
      RETURN jsonb_build_object('success', false, 'error', 'Both latitude and longitude must be provided');
    END IF;
  END IF;

  IF p_event_date IS NOT NULL THEN
    IF p_event_date < CURRENT_DATE THEN
      RETURN jsonb_build_object('success', false, 'error', 'Event date must be in the future');
    END IF;
    v_new_expires_at := (p_event_date + interval '1 day' + interval '23 hours 59 minutes 59 seconds')::timestamptz;
  END IF;

  UPDATE public.professional_alerts
  SET
    title = COALESCE(p_title, title),
    message = COALESCE(p_message, message),
    event_date = COALESCE(p_event_date, event_date),
    location_coords = CASE 
      WHEN p_location_lat IS NOT NULL AND p_location_lng IS NOT NULL 
      THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_location_lng, p_location_lat), 4326)
      ELSE location_coords
    END,
    location_label = COALESCE(p_location_label, location_label),
    expires_at = COALESCE(v_new_expires_at, expires_at),
    status = COALESCE(p_status, status),
    updated_at = now()
  WHERE id = p_alert_id;

  RETURN jsonb_build_object('success', true, 'alertId', p_alert_id);
END;
$$;


ALTER FUNCTION "public"."update_alert"("p_alert_id" "uuid", "p_title" "text", "p_message" "text", "p_event_date" "date", "p_location_lat" double precision, "p_location_lng" double precision, "p_location_label" "text", "p_status" "public"."alertStatus") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_updated_at_column"() IS 'Trigger function pour mettre à jour updated_at. Sécurisé avec search_path fixe.';



CREATE OR REPLACE FUNCTION "public"."update_weddings_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;


ALTER FUNCTION "public"."update_weddings_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_wishlist_count"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.professional_details
    SET wishlist_count = wishlist_count + 1
    WHERE profile_id = NEW.professional_profile_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.professional_details
    SET wishlist_count = GREATEST(wishlist_count - 1, 0)
    WHERE profile_id = OLD.professional_profile_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_wishlist_count"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_wedding"("p_wedding_name" "text" DEFAULT NULL::"text", "p_event_date" "date" DEFAULT NULL::"date", "p_event_end_date" "date" DEFAULT NULL::"date", "p_venue_label" "text" DEFAULT NULL::"text", "p_venue_lat" double precision DEFAULT NULL::double precision, "p_venue_lng" double precision DEFAULT NULL::double precision, "p_search_radius_km" integer DEFAULT 50, "p_budget_min" integer DEFAULT NULL::integer, "p_budget_max" integer DEFAULT NULL::integer, "p_currency" "text" DEFAULT 'EUR'::"text", "p_professions_needed" "text"[] DEFAULT NULL::"text"[], "p_visibility" "text" DEFAULT 'private'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole";
  v_my_country text;
  v_existing_id uuid;
  v_existing_deleted_id uuid;
  v_new_id uuid;
  v_professions public.profession[] := '{}';
  v_visibility public.wedding_visibility;
  v_budget_min_eur integer;
  v_budget_max_eur integer;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('error', 'Not authenticated');
  END IF;

  SELECT role INTO v_role FROM public.profiles WHERE id = v_me;
  IF v_role != 'bride' THEN
    RETURN jsonb_build_object('error', 'Only brides can manage weddings');
  END IF;

  -- Get bride's country from profiles
  SELECT CASE WHEN UPPER(p.country) IN ('INDIA', 'IN') THEN 'IN' ELSE p.country END 
  INTO v_my_country
  FROM public.profiles p
  WHERE p.id = v_me;

  -- INDIAN MARKET RESTRICTION: Indian brides can only create weddings in India
  IF UPPER(v_my_country) = 'IN' AND p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL THEN
    -- India bounding box: lat 6-36, lng 68-98
    IF p_venue_lat < 6 OR p_venue_lat > 36 OR p_venue_lng < 68 OR p_venue_lng > 98 THEN
      RETURN jsonb_build_object('error', 'Indian users can only create weddings in India');
    END IF;
  END IF;

  IF p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_venue_lat, p_venue_lng) THEN
      RETURN jsonb_build_object('error', 'Invalid venue coordinates');
    END IF;
  END IF;

  IF p_event_end_date IS NOT NULL AND p_event_date IS NOT NULL AND p_event_end_date < p_event_date THEN
    RETURN jsonb_build_object('error', 'End date must be after start date');
  END IF;

  IF p_budget_min IS NOT NULL AND p_budget_max IS NOT NULL AND p_budget_max < p_budget_min THEN
    RETURN jsonb_build_object('error', 'Maximum budget must be greater than minimum');
  END IF;

  v_visibility := CASE 
    WHEN p_visibility = 'visible_to_pros' THEN 'visible_to_pros'::public.wedding_visibility
    ELSE 'private'::public.wedding_visibility
  END;

  IF p_professions_needed IS NOT NULL AND array_length(p_professions_needed, 1) > 0 THEN
    SELECT array_agg(val::public.profession) INTO v_professions
    FROM unnest(p_professions_needed) AS val;
  END IF;

  v_budget_min_eur := public.convert_to_eur(p_budget_min::numeric, p_currency)::integer;
  v_budget_max_eur := public.convert_to_eur(p_budget_max::numeric, p_currency)::integer;

  -- Check for ACTIVE wedding first
  SELECT id INTO v_existing_id FROM public.weddings
  WHERE bride_profile_id = v_me AND is_deleted = false;

  -- Check for SOFT-DELETED wedding (to reactivate)
  SELECT id INTO v_existing_deleted_id FROM public.weddings
  WHERE bride_profile_id = v_me AND is_deleted = true;

  IF v_existing_id IS NOT NULL THEN
    -- UPDATE existing active wedding
    UPDATE public.weddings SET
      wedding_name = COALESCE(p_wedding_name, wedding_name),
      event_date = COALESCE(p_event_date, event_date),
      event_end_date = p_event_end_date,
      venue_label = COALESCE(p_venue_label, venue_label),
      venue_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE venue_coords
      END,
      search_radius_km = COALESCE(p_search_radius_km, search_radius_km),
      budget_min = p_budget_min, budget_max = p_budget_max,
      budget_min_eur = v_budget_min_eur, budget_max_eur = v_budget_max_eur,
      currency = COALESCE(p_currency, currency),
      professions_needed = COALESCE(v_professions, professions_needed),
      visibility = v_visibility, updated_at = now()
    WHERE id = v_existing_id;
    RETURN jsonb_build_object('success', true, 'id', v_existing_id, 'action', 'updated');

  ELSIF v_existing_deleted_id IS NOT NULL THEN
    -- REACTIVATE soft-deleted wedding with new data
    UPDATE public.weddings SET
      is_deleted = false,
      wedding_name = p_wedding_name,
      event_date = p_event_date,
      event_end_date = p_event_end_date,
      venue_label = p_venue_label,
      venue_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL
      END,
      search_radius_km = p_search_radius_km,
      budget_min = p_budget_min, budget_max = p_budget_max,
      budget_min_eur = v_budget_min_eur, budget_max_eur = v_budget_max_eur,
      currency = p_currency,
      professions_needed = v_professions,
      visibility = v_visibility,
      status = 'planning',
      updated_at = now()
    WHERE id = v_existing_deleted_id;
    RETURN jsonb_build_object('success', true, 'id', v_existing_deleted_id, 'action', 'reactivated');

  ELSE
    -- CREATE new wedding (no existing record at all)
    INSERT INTO public.weddings (
      bride_profile_id, wedding_name, event_date, event_end_date, venue_label,
      venue_coords, search_radius_km, budget_min, budget_max, budget_min_eur, budget_max_eur,
      currency, professions_needed, visibility, status
    ) VALUES (
      v_me, p_wedding_name, p_event_date, p_event_end_date, p_venue_label,
      CASE WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL END,
      p_search_radius_km, p_budget_min, p_budget_max, v_budget_min_eur, v_budget_max_eur,
      p_currency, v_professions, v_visibility, 'planning'
    ) RETURNING id INTO v_new_id;
    RETURN jsonb_build_object('success', true, 'id', v_new_id, 'action', 'created');
  END IF;
END;
$$;


ALTER FUNCTION "public"."upsert_wedding"("p_wedding_name" "text", "p_event_date" "date", "p_event_end_date" "date", "p_venue_label" "text", "p_venue_lat" double precision, "p_venue_lng" double precision, "p_search_radius_km" integer, "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_professions_needed" "text"[], "p_visibility" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_wedding"("p_wedding_name" "text" DEFAULT NULL::"text", "p_event_date" "date" DEFAULT NULL::"date", "p_event_end_date" "date" DEFAULT NULL::"date", "p_venue_label" "text" DEFAULT NULL::"text", "p_venue_lat" double precision DEFAULT NULL::double precision, "p_venue_lng" double precision DEFAULT NULL::double precision, "p_search_radius_km" integer DEFAULT NULL::integer, "p_budget_min" integer DEFAULT NULL::integer, "p_budget_max" integer DEFAULT NULL::integer, "p_currency" "text" DEFAULT 'EUR'::"text", "p_professions_needed" "text"[] DEFAULT NULL::"text"[], "p_visibility" "text" DEFAULT 'private'::"text", "p_location_country_code" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole";
  v_my_country text;
  v_existing_id uuid;
  v_existing_deleted_id uuid;
  v_new_id uuid;
  v_professions public.profession[] := '{}';
  v_visibility public.wedding_visibility;
  v_budget_min_eur integer;
  v_budget_max_eur integer;
BEGIN
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('error', 'Not authenticated');
  END IF;

  SELECT role INTO v_role FROM public.profiles WHERE id = v_me;
  IF v_role != 'bride' THEN
    RETURN jsonb_build_object('error', 'Only brides can manage weddings');
  END IF;

  -- Get bride's country from profiles
  SELECT CASE WHEN UPPER(p.country) IN ('INDIA', 'IN') THEN 'IN' ELSE p.country END 
  INTO v_my_country
  FROM public.profiles p
  WHERE p.id = v_me;

  -- INDIAN MARKET RESTRICTION: Indian brides can only create weddings in India
  IF UPPER(v_my_country) = 'IN' AND p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL THEN
    -- India bounding box: lat 6-36, lng 68-98
    IF p_venue_lat < 6 OR p_venue_lat > 36 OR p_venue_lng < 68 OR p_venue_lng > 98 THEN
      RETURN jsonb_build_object('error', 'Indian users can only create weddings in India');
    END IF;
  END IF;

  IF p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_venue_lat, p_venue_lng) THEN
      RETURN jsonb_build_object('error', 'Invalid venue coordinates');
    END IF;
  END IF;

  IF p_event_end_date IS NOT NULL AND p_event_date IS NOT NULL AND p_event_end_date < p_event_date THEN
    RETURN jsonb_build_object('error', 'End date must be after start date');
  END IF;

  IF p_budget_min IS NOT NULL AND p_budget_max IS NOT NULL AND p_budget_max < p_budget_min THEN
    RETURN jsonb_build_object('error', 'Maximum budget must be greater than minimum');
  END IF;

  v_visibility := CASE 
    WHEN p_visibility = 'visible_to_pros' THEN 'visible_to_pros'::public.wedding_visibility
    ELSE 'private'::public.wedding_visibility
  END;

  IF p_professions_needed IS NOT NULL AND array_length(p_professions_needed, 1) > 0 THEN
    SELECT array_agg(val::public.profession) INTO v_professions
    FROM unnest(p_professions_needed) AS val;
  END IF;

  v_budget_min_eur := public.convert_to_eur(p_budget_min::numeric, p_currency)::integer;
  v_budget_max_eur := public.convert_to_eur(p_budget_max::numeric, p_currency)::integer;

  -- Check for ACTIVE wedding first
  SELECT id INTO v_existing_id FROM public.weddings
  WHERE bride_profile_id = v_me AND is_deleted = false;

  -- Check for SOFT-DELETED wedding (to reactivate)
  SELECT id INTO v_existing_deleted_id FROM public.weddings
  WHERE bride_profile_id = v_me AND is_deleted = true;

  IF v_existing_id IS NOT NULL THEN
    -- UPDATE existing active wedding
    UPDATE public.weddings SET
      wedding_name = COALESCE(p_wedding_name, wedding_name),
      event_date = COALESCE(p_event_date, event_date),
      event_end_date = p_event_end_date,
      venue_label = COALESCE(p_venue_label, venue_label),
      venue_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE venue_coords
      END,
      search_area_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE search_area_coords
      END,
      search_radius_km = p_search_radius_km,
      location_country_code = COALESCE(p_location_country_code, location_country_code),
      budget_min = p_budget_min, budget_max = p_budget_max,
      budget_min_eur = v_budget_min_eur, budget_max_eur = v_budget_max_eur,
      currency = COALESCE(p_currency, currency),
      professions_needed = COALESCE(v_professions, professions_needed),
      visibility = v_visibility, updated_at = now()
    WHERE id = v_existing_id;
    RETURN jsonb_build_object('success', true, 'id', v_existing_id, 'action', 'updated');

  ELSIF v_existing_deleted_id IS NOT NULL THEN
    -- REACTIVATE soft-deleted wedding with new data
    UPDATE public.weddings SET
      is_deleted = false,
      wedding_name = p_wedding_name,
      event_date = p_event_date,
      event_end_date = p_event_end_date,
      venue_label = p_venue_label,
      venue_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL
      END,
      search_area_coords = CASE 
        WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL
      END,
      search_radius_km = p_search_radius_km,
      location_country_code = p_location_country_code,
      budget_min = p_budget_min, budget_max = p_budget_max,
      budget_min_eur = v_budget_min_eur, budget_max_eur = v_budget_max_eur,
      currency = p_currency,
      professions_needed = v_professions,
      visibility = v_visibility,
      status = 'planning',
      updated_at = now()
    WHERE id = v_existing_deleted_id;
    RETURN jsonb_build_object('success', true, 'id', v_existing_deleted_id, 'action', 'reactivated');

  ELSE
    -- CREATE new wedding (no existing record at all)
    INSERT INTO public.weddings (
      bride_profile_id, wedding_name, event_date, event_end_date, venue_label,
      venue_coords, search_area_coords, search_radius_km, location_country_code,
      budget_min, budget_max, budget_min_eur, budget_max_eur,
      currency, professions_needed, visibility, status
    ) VALUES (
      v_me, p_wedding_name, p_event_date, p_event_end_date, p_venue_label,
      CASE WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL END,
      CASE WHEN p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL 
        THEN extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326)
        ELSE NULL END,
      p_search_radius_km, p_location_country_code,
      p_budget_min, p_budget_max, v_budget_min_eur, v_budget_max_eur,
      p_currency, v_professions, v_visibility, 'planning'
    ) RETURNING id INTO v_new_id;
    RETURN jsonb_build_object('success', true, 'id', v_new_id, 'action', 'created');
  END IF;
END;
$$;


ALTER FUNCTION "public"."upsert_wedding"("p_wedding_name" "text", "p_event_date" "date", "p_event_end_date" "date", "p_venue_label" "text", "p_venue_lat" double precision, "p_venue_lng" double precision, "p_search_radius_km" integer, "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_professions_needed" "text"[], "p_visibility" "text", "p_location_country_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_coordinates"("p_lat" double precision, "p_lng" double precision) RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN p_lat IS NULL OR p_lng IS NULL OR (
    p_lat >= -90 AND p_lat <= 90 AND
    p_lng >= -180 AND p_lng <= 180
  );
END;
$$;


ALTER FUNCTION "public"."validate_coordinates"("p_lat" double precision, "p_lng" double precision) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_coordinates"("p_lat" double precision, "p_lng" double precision) IS 'Validates that coordinates are within valid geographic bounds. Returns true if NULL or valid.';



CREATE OR REPLACE FUNCTION "public"."wedding_pins_history_logger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.wedding_pins_history(wedding_pin_id, action, old_values, new_values, changed_by)
    VALUES (NEW.id, 'insert', NULL, to_jsonb(NEW), auth.uid());
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO public.wedding_pins_history(wedding_pin_id, action, old_values, new_values, changed_by)
    VALUES (NEW.id, 'update', to_jsonb(OLD), to_jsonb(NEW), auth.uid());
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO public.wedding_pins_history(wedding_pin_id, action, old_values, new_values, changed_by)
    VALUES (OLD.id, 'delete', to_jsonb(OLD), NULL, auth.uid());
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."wedding_pins_history_logger"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."wedding_pins_set_budget_eur"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
BEGIN
  IF NEW.currency IS NULL THEN
    NEW.budget_min_eur := NULL;
    NEW.budget_max_eur := NULL;
  ELSE
    NEW.budget_min_eur := public.convert_to_eur(NEW.budget_min::numeric, NEW.currency);
    NEW.budget_max_eur := public.convert_to_eur(NEW.budget_max::numeric, NEW.currency);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."wedding_pins_set_budget_eur"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."alert_motifs" (
    "code" "text" NOT NULL,
    "name_fr" "text" NOT NULL,
    "name_en" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."alert_motifs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bride_details" (
    "profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."bride_details" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."broadcast_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "link" "text",
    "target_roles" "text"[] DEFAULT '{}'::"text"[],
    "target_region" "text" DEFAULT 'all'::"text",
    "target_profile_ids" "uuid"[] DEFAULT '{}'::"uuid"[],
    "recipients_count" integer DEFAULT 0,
    "sent_at" timestamp with time zone DEFAULT "now"(),
    "sent_by" "uuid",
    "status" "text" DEFAULT 'pending'::"text",
    "notification_type" "text" DEFAULT 'broadcast'::"text",
    CONSTRAINT "broadcast_history_body_check" CHECK (("char_length"("body") <= 120)),
    CONSTRAINT "broadcast_history_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'sent'::"text", 'failed'::"text"]))),
    CONSTRAINT "broadcast_history_target_region_check" CHECK (("target_region" = ANY (ARRAY['all'::"text", 'IN'::"text", 'ROW'::"text"]))),
    CONSTRAINT "broadcast_history_title_check" CHECK (("char_length"("title") <= 50))
);


ALTER TABLE "public"."broadcast_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."broadcast_history" IS 'Historique des notifications push broadcast envoyées depuis l''Admin Panel. Utilisé pour le suivi et l''audit des communications.';



COMMENT ON COLUMN "public"."broadcast_history"."notification_type" IS 'Type de notification: wedPublished, replayPublished, ou broadcast (générique)';



CREATE TABLE IF NOT EXISTS "public"."chat_messages" (
    "id" bigint NOT NULL,
    "room_id" "uuid" NOT NULL,
    "profile_id" "uuid",
    "content" "text",
    "message_type" "public"."messageType" NOT NULL,
    "attachment_url" "text",
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chat_msg_content_chk" CHECK (((("message_type" = 'text'::"public"."messageType") AND ("content" IS NOT NULL) AND ("attachment_url" IS NULL)) OR (("message_type" = ANY (ARRAY['image'::"public"."messageType", 'audio'::"public"."messageType"])) AND ("content" IS NULL) AND ("attachment_url" IS NOT NULL))))
);

ALTER TABLE ONLY "public"."chat_messages" REPLICA IDENTITY FULL;


ALTER TABLE "public"."chat_messages" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."chat_messages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."chat_messages_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."chat_messages_id_seq" OWNED BY "public"."chat_messages"."id";



CREATE TABLE IF NOT EXISTS "public"."chat_room_participants" (
    "room_id" "uuid" NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "conversation_status" "public"."conversationStatus" DEFAULT 'active'::"public"."conversationStatus" NOT NULL,
    "joined_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_read_at" timestamp with time zone
);

ALTER TABLE ONLY "public"."chat_room_participants" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_room_participants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_rooms" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text" NOT NULL,
    "name" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chat_rooms_type_check" CHECK (("type" = ANY (ARRAY['private'::"text", 'public'::"text"])))
);


ALTER TABLE "public"."chat_rooms" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."connection_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pro_profile_id" "uuid" NOT NULL,
    "bride_profile_id" "uuid" NOT NULL,
    "source_id" "uuid",
    "initial_message" "text",
    "status" "public"."connectionRequestStatus" DEFAULT 'pending'::"public"."connectionRequestStatus" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "responded_at" timestamp with time zone,
    "initiator_id" "uuid" NOT NULL,
    "source" "public"."connectionRequestSource" NOT NULL,
    CONSTRAINT "connection_requests_initial_message_check" CHECK (("char_length"("initial_message") <= 1000)),
    CONSTRAINT "connection_requests_initiator_check" CHECK ((("initiator_id" = "pro_profile_id") OR ("initiator_id" = "bride_profile_id")))
);


ALTER TABLE "public"."connection_requests" OWNER TO "postgres";


COMMENT ON TABLE "public"."connection_requests" IS 'Contact requests between Pro and Bride. Realtime enabled for instant notifications.';



CREATE TABLE IF NOT EXISTS "public"."content" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text" DEFAULT 'wed_of_the_week'::"text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "image_url" "text",
    "linked_pro_profile_id" "uuid",
    "translations" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_published" boolean DEFAULT false NOT NULL,
    "published_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."content" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."countries" (
    "iso2" character(2) NOT NULL,
    "name_fr" "text" NOT NULL,
    "name_en" "text" NOT NULL,
    "phone_code" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."countries" OWNER TO "postgres";


COMMENT ON TABLE "public"."countries" IS 'Table de référence pour les pays (ISO 3166-1 alpha-2).';



COMMENT ON COLUMN "public"."countries"."iso2" IS 'Code ISO 3166-1 alpha-2 du pays (ex: FR, US). Clé primaire.';



COMMENT ON COLUMN "public"."countries"."name_fr" IS 'Nom français officiel du pays.';



COMMENT ON COLUMN "public"."countries"."name_en" IS 'Nom anglais officiel du pays.';



COMMENT ON COLUMN "public"."countries"."phone_code" IS 'Indicatif téléphonique international (ex: +33).';



CREATE TABLE IF NOT EXISTS "public"."deleted_users_log" (
    "user_id" "uuid" NOT NULL,
    "deleted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email_hash" "text",
    "reason" "text" DEFAULT 'user_request'::"text"
);


ALTER TABLE "public"."deleted_users_log" OWNER TO "postgres";


COMMENT ON TABLE "public"."deleted_users_log" IS 'Journalise les suppressions de comptes pour des raisons d''audit et de sécurité, tout en respectant l''anonymat.';



COMMENT ON COLUMN "public"."deleted_users_log"."email_hash" IS 'Hash SHA-256 de l''email de l''utilisateur pour vérification sans stockage de données personnelles.';



CREATE TABLE IF NOT EXISTS "public"."device_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "platform" "text" NOT NULL,
    "last_seen_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "device_tokens_platform_check" CHECK (("platform" = ANY (ARRAY['ios'::"text", 'android'::"text", 'web'::"text"])))
);


ALTER TABLE "public"."device_tokens" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."fx_rates" (
    "code" "text" NOT NULL,
    "base" "text" DEFAULT 'EUR'::"text" NOT NULL,
    "rate" numeric NOT NULL,
    "valid_on" "date" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "fx_rates_rate_check" CHECK (("rate" > (0)::numeric))
);


ALTER TABLE "public"."fx_rates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notification_settings" (
    "profile_id" "uuid" NOT NULL,
    "notification_type" "public"."notificationType" NOT NULL,
    "in_app_enabled" boolean DEFAULT true NOT NULL,
    "push_enabled" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."notification_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "type" "public"."notificationType" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
)
PARTITION BY RANGE ("created_at");


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications_2025_09" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "type" "public"."notificationType" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notifications_2025_09" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications_2025_10" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "type" "public"."notificationType" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notifications_2025_10" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications_2025_11" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "type" "public"."notificationType" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notifications_2025_11" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications_2025_12" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "type" "public"."notificationType" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notifications_2025_12" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professional_alerts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "author_profile_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "radius_km" smallint NOT NULL,
    "duration_hours" smallint DEFAULT 168,
    "status" "public"."alertStatus" DEFAULT 'active'::"public"."alertStatus" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "reminder_sent" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "location_label" "text" DEFAULT ''::"text" NOT NULL,
    "motif_code" "text",
    "location_coords" "extensions"."geometry"(Point,4326),
    "alert_type" "public"."alert_type",
    "event_date" "date",
    "profession_needed" "public"."profession",
    "location_country_code" "text",
    CONSTRAINT "professional_alerts_message_check" CHECK ((("char_length"("message") >= 3) AND ("char_length"("message") <= 2000))),
    CONSTRAINT "professional_alerts_radius_km_check" CHECK ((("radius_km" >= 1) AND ("radius_km" <= 100))),
    CONSTRAINT "professional_alerts_title_check" CHECK ((("char_length"("title") >= 3) AND ("char_length"("title") <= 120)))
);


ALTER TABLE "public"."professional_alerts" OWNER TO "postgres";


COMMENT ON COLUMN "public"."professional_alerts"."alert_type" IS 'Type d''alerte structuré: backup_needed, gear_emergency, team_member, emergency_help';



COMMENT ON COLUMN "public"."professional_alerts"."event_date" IS 'Date de l''événement pour lequel l''aide est demandée';



COMMENT ON COLUMN "public"."professional_alerts"."profession_needed" IS 'Profession recherchée (optionnel)';



CREATE TABLE IF NOT EXISTS "public"."professional_details" (
    "profile_id" "uuid" NOT NULL,
    "business_name" "text" NOT NULL,
    "description" "text",
    "portfolio_images" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "profession" "public"."profession" NOT NULL,
    "is_live" boolean DEFAULT false NOT NULL,
    "wishlist_count" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "location_city" "text",
    "location_country_code" "text",
    "location_label" "text",
    "budget_min" integer,
    "budget_max" integer,
    "currency" "text",
    "instagram_url" "text",
    "website_url" "text",
    "budget_min_eur" numeric,
    "budget_max_eur" numeric,
    "slideshow_images" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "profile_video_url" "text",
    "is_pending" boolean DEFAULT false NOT NULL,
    "feed_enabled" boolean DEFAULT false,
    "has_cover_video" boolean DEFAULT false,
    "slideshow_images_v2" "jsonb" DEFAULT '[]'::"jsonb",
    "portfolio_images_v2" "jsonb" DEFAULT '[]'::"jsonb",
    "upcoming_travels" "jsonb" DEFAULT '[]'::"jsonb"
);

ALTER TABLE ONLY "public"."professional_details" REPLICA IDENTITY FULL;


ALTER TABLE "public"."professional_details" OWNER TO "postgres";


COMMENT ON TABLE "public"."professional_details" IS 'Professional profile details. NOTE (04/12/2025): location_coords column removed - all coordinates now in professional_fixed_locations table.';



COMMENT ON COLUMN "public"."professional_details"."has_cover_video" IS 'If true, display profile_video_url as header. If false, display thumbnail_photos slider.';



COMMENT ON COLUMN "public"."professional_details"."slideshow_images_v2" IS 'Header photos with multi-format crops: [{id, crop_1x1, crop_3x4, crop_9x16}]';



COMMENT ON COLUMN "public"."professional_details"."portfolio_images_v2" IS 'Portfolio photos with multi-format crops: [{id, crop_1x1, crop_3x4, crop_9x16}]';



COMMENT ON COLUMN "public"."professional_details"."upcoming_travels" IS 'Array of upcoming travel destinations with dates. Synced from CRM profiles.upcoming_travels';



CREATE TABLE IF NOT EXISTS "public"."professional_fixed_locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "professional_profile_id" "uuid" NOT NULL,
    "label" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "location_coords" "extensions"."geometry"(Point,4326),
    "location_country_code" "text"
);


ALTER TABLE "public"."professional_fixed_locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professional_profile_changes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "change_type" "text" NOT NULL,
    "changed_fields" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "previous_values" "jsonb",
    "new_values" "jsonb",
    "requires_validation" boolean DEFAULT false,
    "validation_status" "text" DEFAULT 'pending'::"text",
    "was_live_before" boolean,
    "is_live_after" boolean,
    "reviewed_at" timestamp with time zone,
    "reviewed_by" "uuid",
    "review_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "sync_source" "text" DEFAULT 'crm'::"text",
    CONSTRAINT "professional_profile_changes_change_type_check" CHECK (("change_type" = ANY (ARRAY['first_submission'::"text", 'major_update'::"text", 'minor_update'::"text", 'technical_update'::"text"]))),
    CONSTRAINT "professional_profile_changes_validation_status_check" CHECK (("validation_status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."professional_profile_changes" OWNER TO "postgres";


COMMENT ON TABLE "public"."professional_profile_changes" IS 'Historique des changements de fiches professionnelles pour validation Admin';



CREATE TABLE IF NOT EXISTS "public"."professional_subscriptions" (
    "profile_id" "uuid" NOT NULL,
    "subscription_tier" "public"."subscriptionTierType" DEFAULT 'inactive'::"public"."subscriptionTierType" NOT NULL,
    "trial_ends_at" timestamp with time zone,
    "stripe_customer_id" "text",
    "stripe_subscription_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."professional_subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "role" "public"."userRole" DEFAULT 'bride'::"public"."userRole" NOT NULL,
    "full_name" "text",
    "avatar_url" "text",
    "country" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ambassador" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."profiles"."ambassador" IS 'Indique si le professionnel est un ambassadeur LYNEWED (synchro depuis CRM)';



CREATE TABLE IF NOT EXISTS "public"."public_chat_rooms" (
    "chat_room_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "cover_image_url" "text",
    "audience_role" "public"."userRole" DEFAULT 'bride'::"public"."userRole" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "market_region" "text" DEFAULT 'GLOBAL'::"text" NOT NULL
);


ALTER TABLE "public"."public_chat_rooms" OWNER TO "postgres";


COMMENT ON COLUMN "public"."public_chat_rooms"."market_region" IS 'Market region: IN for India, GLOBAL for rest of world';



CREATE OR REPLACE VIEW "public"."public_professionals" WITH ("security_invoker"='true') AS
 SELECT "pd"."profile_id" AS "profileId",
    "pr"."full_name" AS "fullName",
    "pr"."avatar_url" AS "avatarUrl",
    "pd"."business_name" AS "businessName",
    "pd"."description",
    "pd"."location_label" AS "locationLabel",
    ("pd"."profession")::"text" AS "profession",
    "pd"."budget_min" AS "budgetMin",
    "pd"."budget_max" AS "budgetMax",
    "pd"."currency",
    "pd"."budget_min_eur" AS "budgetMinEur",
    "pd"."budget_max_eur" AS "budgetMaxEur",
    "pd"."is_live" AS "isLive",
    ("ps"."subscription_tier")::"text" AS "subscriptionTier",
        CASE
            WHEN ("array_length"("pd"."portfolio_images", 1) >= 1) THEN "pd"."portfolio_images"[1]
            ELSE NULL::"text"
        END AS "coverImageUrl",
    "pd"."wishlist_count" AS "wishlistCount"
   FROM (("public"."professional_details" "pd"
     JOIN "public"."profiles" "pr" ON (("pr"."id" = "pd"."profile_id")))
     LEFT JOIN "public"."professional_subscriptions" "ps" ON (("ps"."profile_id" = "pd"."profile_id")))
  WHERE ("pd"."is_live" = true);


ALTER VIEW "public"."public_professionals" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."public_profiles" WITH ("security_invoker"='true') AS
 SELECT "id",
    "role",
    "full_name",
    "avatar_url",
    "country",
    "created_at"
   FROM "public"."profiles";


ALTER VIEW "public"."public_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."replay_guest_assignments" (
    "replay_id" "uuid" NOT NULL,
    "guest_id" "uuid" NOT NULL
);


ALTER TABLE "public"."replay_guest_assignments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."replay_guests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "full_name" "text" NOT NULL,
    "profession" "text",
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "replay_guests_avatar_url_check" CHECK (("avatar_url" ~* '^https?://.+'::"text"))
);


ALTER TABLE "public"."replay_guests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."replays" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "youtube_url" "text" NOT NULL,
    "thumbnail_url" "text" NOT NULL,
    "published_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_featured" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_published" boolean DEFAULT true NOT NULL,
    "target_region" "text" DEFAULT 'all'::"text",
    CONSTRAINT "replays_target_region_check" CHECK (("target_region" = ANY (ARRAY['all'::"text", 'IN'::"text", 'ROW'::"text"]))),
    CONSTRAINT "replays_thumbnail_url_check" CHECK (("thumbnail_url" ~* '^https?://.+'::"text")),
    CONSTRAINT "replays_youtube_url_check" CHECK (("youtube_url" ~* '^https?://(www\.)?(youtube\.com|youtu\.be)/.+'::"text"))
);


ALTER TABLE "public"."replays" OWNER TO "postgres";


COMMENT ON COLUMN "public"."replays"."is_featured" IS 'Si true, ce replay apparaîtra en haut de la page Replay.';



COMMENT ON COLUMN "public"."replays"."is_published" IS 'Si true, ce replay est visible dans l''application. Si false, il est masqué.';



COMMENT ON COLUMN "public"."replays"."target_region" IS 'Target market region: all, IN (India), ROW (Rest of World/GLOBAL)';



CREATE TABLE IF NOT EXISTS "public"."report_motifs" (
    "code" "text" NOT NULL,
    "name_fr" "text" NOT NULL,
    "name_en" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."report_motifs" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."report_motifs_v" WITH ("security_invoker"='true') AS
 SELECT "code",
    "name_fr",
    "name_en",
    "is_active",
    "sort_order"
   FROM "public"."report_motifs";


ALTER VIEW "public"."report_motifs_v" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_profile_id" "uuid" NOT NULL,
    "reported_message_id" bigint NOT NULL,
    "reason" "text",
    "status" "public"."contentModerationStatus" DEFAULT 'pendingReview'::"public"."contentModerationStatus" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stripe_events_log" (
    "event_id" "text" NOT NULL,
    "event_type" "text" NOT NULL,
    "received_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "processed_at" timestamp with time zone,
    "result_status" "text"
);


ALTER TABLE "public"."stripe_events_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."support_tickets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "subject" "text" NOT NULL,
    "message" "text" NOT NULL,
    "admin_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "resolved_at" timestamp with time zone,
    "ticket_type" "text" DEFAULT 'support'::"text" NOT NULL,
    "reported_profile_id" "uuid",
    "report_reason" "text",
    CONSTRAINT "support_tickets_report_reason_check" CHECK ((("report_reason" IS NULL) OR ("report_reason" = ANY (ARRAY['spam'::"text", 'harassment'::"text", 'inappropriate_content'::"text", 'other'::"text"])))),
    CONSTRAINT "support_tickets_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'resolved'::"text", 'rejected'::"text"]))),
    CONSTRAINT "support_tickets_ticket_type_check" CHECK (("ticket_type" = ANY (ARRAY['support'::"text", 'user_report'::"text", 'message_report'::"text"])))
);


ALTER TABLE "public"."support_tickets" OWNER TO "postgres";


COMMENT ON COLUMN "public"."support_tickets"."ticket_type" IS 'Type of ticket: support (general), user_report (profile report), message_report (chat message report)';



COMMENT ON COLUMN "public"."support_tickets"."reported_profile_id" IS 'Profile ID of the reported user (for user_report type)';



COMMENT ON COLUMN "public"."support_tickets"."report_reason" IS 'Structured reason for reports: spam, harassment, inappropriate_content, other';



CREATE TABLE IF NOT EXISTS "public"."sync_control" (
    "sync_type" "text" NOT NULL,
    "last_sync_timestamp" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sync_control" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sync_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "event_type" "text" NOT NULL,
    "email" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "response" "jsonb",
    "error_message" "text",
    "http_status" integer,
    "duration_ms" integer,
    "user_id" "uuid",
    "ip_address" "text"
);


ALTER TABLE "public"."sync_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sync_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pro_id" "uuid",
    "operation" "text",
    "status" "text" DEFAULT 'success'::"text",
    "error" "text",
    "synced_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sync_log" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."sync_stats" WITH ("security_invoker"='true') AS
 SELECT "date"("created_at") AS "sync_date",
    "event_type",
    "count"(*) AS "count",
    "count"(DISTINCT "email") AS "unique_emails",
    "avg"("duration_ms") AS "avg_duration_ms"
   FROM "public"."sync_events"
  GROUP BY ("date"("created_at")), "event_type"
  ORDER BY ("date"("created_at")) DESC, "event_type";


ALTER VIEW "public"."sync_stats" OWNER TO "postgres";


COMMENT ON VIEW "public"."sync_stats" IS 'Statistics view for sync events - accessible only to admins via sync_events RLS';



CREATE TABLE IF NOT EXISTS "public"."user_blocks" (
    "blocker_profile_id" "uuid" NOT NULL,
    "blocked_profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_blocks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_legal_acceptances" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "tos_version" "text",
    "privacy_version" "text",
    "accepted_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_legal_acceptances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_preferences" (
    "profile_id" "uuid" NOT NULL,
    "distance_unit" "text" DEFAULT 'km'::"text" NOT NULL,
    "default_radius_km" smallint DEFAULT 20 NOT NULL,
    "default_country_code" "text",
    "default_city" "text",
    "default_locale" "text",
    "map_toggles" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "currency" "text" DEFAULT 'EUR'::"text" NOT NULL,
    "default_timezone" "text",
    "last_filters" "jsonb",
    "last_feed_filters" "jsonb",
    CONSTRAINT "user_preferences_default_radius_km_check" CHECK ((("default_radius_km" >= 1) AND ("default_radius_km" <= 100))),
    CONSTRAINT "user_preferences_distance_unit_check" CHECK (("distance_unit" = ANY (ARRAY['km'::"text", 'miles'::"text"])))
);


ALTER TABLE "public"."user_preferences" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_preferences"."last_feed_filters" IS 'Derniers filtres utilisés sur le feed d''inspiration (type Pinterest).';



CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "public"."app_role" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."video_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "initiator_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "status" "public"."videoSessionStatus" DEFAULT 'pending'::"public"."videoSessionStatus" NOT NULL,
    "agora_channel_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "accepted_at" timestamp with time zone,
    "completed_at" timestamp with time zone
);

ALTER TABLE ONLY "public"."video_sessions" REPLICA IDENTITY FULL;


ALTER TABLE "public"."video_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wed_articles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "jsonb" NOT NULL,
    "linked_pro_profile_id" "uuid" NOT NULL,
    "cover_images" "text"[] NOT NULL,
    "content_blocks" "jsonb",
    "is_published" boolean DEFAULT false NOT NULL,
    "published_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "target_region" "text" DEFAULT 'all'::"text" NOT NULL,
    CONSTRAINT "wed_articles_target_region_check" CHECK (("target_region" = ANY (ARRAY['all'::"text", 'IN'::"text", 'ROW'::"text"])))
);


ALTER TABLE "public"."wed_articles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."wed_articles"."target_region" IS 'Région cible: all (toutes), IN (Inde), ROW (Rest of World)';



CREATE TABLE IF NOT EXISTS "public"."wedding_participants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "wedding_id" "uuid" NOT NULL,
    "professional_profile_id" "uuid" NOT NULL,
    "profession" "public"."profession",
    "status" "public"."wedding_participant_status" DEFAULT 'requested'::"public"."wedding_participant_status",
    "requested_at" timestamp with time zone DEFAULT "now"(),
    "accepted_at" timestamp with time zone
);


ALTER TABLE "public"."wedding_participants" OWNER TO "postgres";


COMMENT ON TABLE "public"."wedding_participants" IS 'Pros confirmés pour un mariage. Préparation pour albums partagés futurs.';



CREATE TABLE IF NOT EXISTS "public"."weddings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bride_profile_id" "uuid" NOT NULL,
    "wedding_name" "text",
    "event_date" "date" NOT NULL,
    "event_end_date" "date",
    "venue_coords" "extensions"."geometry"(Point,4326),
    "venue_label" "text",
    "search_area_coords" "extensions"."geometry"(Point,4326),
    "search_radius_km" smallint DEFAULT 50,
    "budget_min" integer,
    "budget_max" integer,
    "budget_min_eur" numeric,
    "budget_max_eur" numeric,
    "currency" "text" DEFAULT 'EUR'::"text",
    "professions_needed" "public"."profession"[],
    "visibility" "public"."wedding_visibility" DEFAULT 'private'::"public"."wedding_visibility",
    "status" "public"."wedding_status" DEFAULT 'planning'::"public"."wedding_status",
    "market_region" "text" DEFAULT 'europe'::"text",
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "location_country_code" "text",
    CONSTRAINT "weddings_search_radius_km_check" CHECK ((("search_radius_km" IS NULL) OR ("search_radius_km" = ANY (ARRAY[5, 10, 20, 50, 100, 200, 300, 500]))))
);


ALTER TABLE "public"."weddings" OWNER TO "postgres";


COMMENT ON TABLE "public"."weddings" IS 'Hub central pour chaque bride. 1 mariage actif par bride. Remplace wedding_pins.';



CREATE TABLE IF NOT EXISTS "public"."wishlist_items" (
    "bride_profile_id" "uuid" NOT NULL,
    "professional_profile_id" "uuid" NOT NULL,
    "added_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."wishlist_items" OWNER TO "postgres";


ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_09" FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');



ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_10" FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');



ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_11" FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');



ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_12" FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');



ALTER TABLE ONLY "public"."chat_messages" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."chat_messages_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."alert_motifs"
    ADD CONSTRAINT "alert_motifs_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."bride_details"
    ADD CONSTRAINT "bride_details_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."broadcast_history"
    ADD CONSTRAINT "broadcast_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_room_participants"
    ADD CONSTRAINT "chat_room_participants_pkey" PRIMARY KEY ("room_id", "profile_id");



ALTER TABLE ONLY "public"."chat_rooms"
    ADD CONSTRAINT "chat_rooms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."connection_requests"
    ADD CONSTRAINT "connection_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."content"
    ADD CONSTRAINT "content_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_pkey" PRIMARY KEY ("iso2");



ALTER TABLE ONLY "public"."deleted_users_log"
    ADD CONSTRAINT "deleted_users_log_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."device_tokens"
    ADD CONSTRAINT "device_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."device_tokens"
    ADD CONSTRAINT "device_tokens_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."fx_rates"
    ADD CONSTRAINT "fx_rates_pkey" PRIMARY KEY ("code", "valid_on");



ALTER TABLE ONLY "public"."notification_settings"
    ADD CONSTRAINT "notification_settings_pkey" PRIMARY KEY ("profile_id", "notification_type");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id", "created_at");



ALTER TABLE ONLY "public"."notifications_2025_09"
    ADD CONSTRAINT "notifications_2025_09_pkey" PRIMARY KEY ("id", "created_at");



ALTER TABLE ONLY "public"."notifications_2025_10"
    ADD CONSTRAINT "notifications_2025_10_pkey" PRIMARY KEY ("id", "created_at");



ALTER TABLE ONLY "public"."notifications_2025_11"
    ADD CONSTRAINT "notifications_2025_11_pkey" PRIMARY KEY ("id", "created_at");



ALTER TABLE ONLY "public"."notifications_2025_12"
    ADD CONSTRAINT "notifications_2025_12_pkey" PRIMARY KEY ("id", "created_at");



ALTER TABLE ONLY "public"."notifications_outbox"
    ADD CONSTRAINT "notifications_outbox_event_key_key" UNIQUE ("event_key");



ALTER TABLE ONLY "public"."notifications_outbox"
    ADD CONSTRAINT "notifications_outbox_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_details"
    ADD CONSTRAINT "professional_details_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."professional_fixed_locations"
    ADD CONSTRAINT "professional_fixed_locations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_profile_changes"
    ADD CONSTRAINT "professional_profile_changes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_subscriptions"
    ADD CONSTRAINT "professional_subscriptions_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."public_chat_rooms"
    ADD CONSTRAINT "public_chat_rooms_pkey" PRIMARY KEY ("chat_room_id");



ALTER TABLE ONLY "public"."replay_guest_assignments"
    ADD CONSTRAINT "replay_guest_assignments_pkey" PRIMARY KEY ("replay_id", "guest_id");



ALTER TABLE ONLY "public"."replay_guests"
    ADD CONSTRAINT "replay_guests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."replays"
    ADD CONSTRAINT "replays_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."report_motifs"
    ADD CONSTRAINT "report_motifs_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stripe_events_log"
    ADD CONSTRAINT "stripe_events_log_pkey" PRIMARY KEY ("event_id");



ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sync_control"
    ADD CONSTRAINT "sync_control_pkey" PRIMARY KEY ("sync_type");



ALTER TABLE ONLY "public"."sync_events"
    ADD CONSTRAINT "sync_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sync_log"
    ADD CONSTRAINT "sync_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_fixed_locations"
    ADD CONSTRAINT "unique_pro_location_label" UNIQUE ("professional_profile_id", "label");



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_pkey" PRIMARY KEY ("blocker_profile_id", "blocked_profile_id");



ALTER TABLE ONLY "public"."user_legal_acceptances"
    ADD CONSTRAINT "user_legal_acceptances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");



ALTER TABLE ONLY "public"."video_sessions"
    ADD CONSTRAINT "video_sessions_agora_channel_name_key" UNIQUE ("agora_channel_name");



ALTER TABLE ONLY "public"."video_sessions"
    ADD CONSTRAINT "video_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wed_articles"
    ADD CONSTRAINT "wed_articles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wedding_participants"
    ADD CONSTRAINT "wedding_participants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wedding_participants"
    ADD CONSTRAINT "wedding_participants_wedding_id_professional_profile_id_key" UNIQUE ("wedding_id", "professional_profile_id");



ALTER TABLE ONLY "public"."weddings"
    ADD CONSTRAINT "weddings_bride_profile_id_key" UNIQUE ("bride_profile_id");



ALTER TABLE ONLY "public"."weddings"
    ADD CONSTRAINT "weddings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_pkey" PRIMARY KEY ("bride_profile_id", "professional_profile_id");



CREATE INDEX "idx_alerts_active_not_deleted" ON "public"."professional_alerts" USING "btree" ("created_at") WHERE (("status" = 'active'::"public"."alertStatus") AND ("is_deleted" = false));



CREATE INDEX "idx_alerts_expires_active" ON "public"."professional_alerts" USING "btree" ("expires_at") WHERE ("status" = 'active'::"public"."alertStatus");



CREATE INDEX "idx_broadcast_history_sent_at" ON "public"."broadcast_history" USING "btree" ("sent_at" DESC);



CREATE INDEX "idx_broadcast_history_status" ON "public"."broadcast_history" USING "btree" ("status");



CREATE INDEX "idx_chat_messages_created_brin" ON "public"."chat_messages" USING "brin" ("created_at");



CREATE INDEX "idx_chat_messages_room_created_desc" ON "public"."chat_messages" USING "btree" ("room_id", "created_at" DESC);



CREATE INDEX "idx_chat_msgs_room_time" ON "public"."chat_messages" USING "btree" ("room_id", "created_at" DESC) WHERE ("is_deleted" = false);



CREATE INDEX "idx_chat_participants_by_profile" ON "public"."chat_room_participants" USING "btree" ("profile_id", "room_id");



CREATE INDEX "idx_chat_participants_profile" ON "public"."chat_room_participants" USING "btree" ("profile_id");



CREATE INDEX "idx_chat_rooms_private" ON "public"."chat_rooms" USING "btree" ("id") WHERE ("type" = 'private'::"text");



CREATE INDEX "idx_connreq_by_bride_status" ON "public"."connection_requests" USING "btree" ("bride_profile_id", "status");



CREATE INDEX "idx_connreq_by_pro_status" ON "public"."connection_requests" USING "btree" ("pro_profile_id", "status");



CREATE INDEX "idx_crp_profile_room" ON "public"."chat_room_participants" USING "btree" ("profile_id", "room_id");



CREATE INDEX "idx_msgs_room_created_notdel" ON "public"."chat_messages" USING "btree" ("room_id", "created_at" DESC) WHERE ("is_deleted" = false);



CREATE INDEX "idx_notifications_outbox_type_created" ON "public"."notifications_outbox" USING "btree" ("event_type", "created_at");



CREATE INDEX "idx_notifications_outbox_unprocessed" ON "public"."notifications_outbox" USING "btree" ("created_at") WHERE ("processed_at" IS NULL);



CREATE INDEX "idx_notifications_profile_unread" ON ONLY "public"."notifications" USING "btree" ("profile_id", "is_read", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "idx_notifications_unread" ON ONLY "public"."notifications" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "idx_outbox_unprocessed" ON "public"."notifications_outbox" USING "btree" ("processed_at", "created_at");



CREATE INDEX "idx_pcr_active_created" ON "public"."public_chat_rooms" USING "btree" ("is_active", "created_at" DESC);



CREATE INDEX "idx_pd_profession_live_partial" ON "public"."professional_details" USING "btree" ("profession") WHERE ("is_live" = true);



CREATE INDEX "idx_pd_wishlist_count" ON "public"."professional_details" USING "btree" ("wishlist_count");



CREATE INDEX "idx_pro_details_live" ON "public"."professional_details" USING "btree" ("is_live");



CREATE INDEX "idx_prof_alerts_active_partial" ON "public"."professional_alerts" USING "btree" ("expires_at") WHERE ("status" = 'active'::"public"."alertStatus");



CREATE INDEX "idx_prof_alerts_status_expires" ON "public"."professional_alerts" USING "btree" ("status", "expires_at");



CREATE INDEX "idx_prof_details_live_profession" ON "public"."professional_details" USING "btree" ("is_live", "profession");



CREATE INDEX "idx_prof_details_wishlist_count" ON "public"."professional_details" USING "btree" ("wishlist_count" DESC);



CREATE INDEX "idx_professional_alerts_active" ON "public"."professional_alerts" USING "btree" ("status", "is_deleted", "created_at" DESC);



CREATE INDEX "idx_professional_alerts_alert_type" ON "public"."professional_alerts" USING "btree" ("alert_type") WHERE (("status" = 'active'::"public"."alertStatus") AND ("is_deleted" = false));



CREATE INDEX "idx_professional_alerts_country" ON "public"."professional_alerts" USING "btree" ("location_country_code");



CREATE INDEX "idx_professional_alerts_event_date" ON "public"."professional_alerts" USING "btree" ("event_date") WHERE (("status" = 'active'::"public"."alertStatus") AND ("is_deleted" = false));



CREATE INDEX "idx_professional_details_country" ON "public"."professional_details" USING "btree" ("location_country_code");



CREATE INDEX "idx_professional_details_validation_status" ON "public"."professional_details" USING "btree" ("is_live", "is_pending");



CREATE INDEX "idx_professional_fixed_locations_country" ON "public"."professional_fixed_locations" USING "btree" ("location_country_code");



CREATE INDEX "idx_profile_changes_change_type" ON "public"."professional_profile_changes" USING "btree" ("change_type");



CREATE INDEX "idx_profile_changes_created_at" ON "public"."professional_profile_changes" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_profile_changes_profile_id" ON "public"."professional_profile_changes" USING "btree" ("profile_id");



CREATE INDEX "idx_profile_changes_requires_validation" ON "public"."professional_profile_changes" USING "btree" ("requires_validation") WHERE (("requires_validation" = true) AND ("validation_status" = 'pending'::"text"));



CREATE INDEX "idx_ps_visible_tier" ON "public"."professional_subscriptions" USING "btree" ("profile_id") WHERE ("subscription_tier" = ANY (ARRAY['premiumVisibility'::"public"."subscriptionTierType", 'ultimateAccess'::"public"."subscriptionTierType"]));



CREATE INDEX "idx_replays_is_published" ON "public"."replays" USING "btree" ("is_published");



CREATE INDEX "idx_rooms_type_active" ON "public"."chat_rooms" USING "btree" ("type", "is_active");



CREATE INDEX "idx_subscriptions_tier" ON "public"."professional_subscriptions" USING "btree" ("subscription_tier");



CREATE INDEX "idx_support_tickets_created_at" ON "public"."support_tickets" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_support_tickets_reported_profile" ON "public"."support_tickets" USING "btree" ("reported_profile_id") WHERE ("reported_profile_id" IS NOT NULL);



CREATE INDEX "idx_support_tickets_status" ON "public"."support_tickets" USING "btree" ("status");



CREATE INDEX "idx_support_tickets_type" ON "public"."support_tickets" USING "btree" ("ticket_type");



CREATE INDEX "idx_sync_events_created_at" ON "public"."sync_events" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_sync_events_email" ON "public"."sync_events" USING "btree" ("email");



CREATE INDEX "idx_sync_events_event_type" ON "public"."sync_events" USING "btree" ("event_type");



CREATE INDEX "idx_sync_events_user_id" ON "public"."sync_events" USING "btree" ("user_id");



CREATE UNIQUE INDEX "idx_unique_stripe_customer_id_not_null" ON "public"."professional_subscriptions" USING "btree" ("stripe_customer_id") WHERE ("stripe_customer_id" IS NOT NULL);



CREATE UNIQUE INDEX "idx_unique_stripe_subscription_id_not_null" ON "public"."professional_subscriptions" USING "btree" ("stripe_subscription_id") WHERE ("stripe_subscription_id" IS NOT NULL);



CREATE INDEX "idx_video_sessions_status_time" ON "public"."video_sessions" USING "btree" ("status", "created_at");



CREATE INDEX "idx_wedding_participants_pro" ON "public"."wedding_participants" USING "btree" ("professional_profile_id");



CREATE INDEX "idx_wedding_participants_wedding" ON "public"."wedding_participants" USING "btree" ("wedding_id");



CREATE INDEX "idx_weddings_country" ON "public"."weddings" USING "btree" ("location_country_code");



CREATE INDEX "idx_weddings_market_region" ON "public"."weddings" USING "btree" ("market_region");



CREATE INDEX "idx_weddings_search_area" ON "public"."weddings" USING "gist" ("search_area_coords");



CREATE INDEX "idx_weddings_status" ON "public"."weddings" USING "btree" ("status") WHERE ("status" = ANY (ARRAY['planning'::"public"."wedding_status", 'confirmed'::"public"."wedding_status"]));



CREATE INDEX "idx_weddings_venue_coords" ON "public"."weddings" USING "gist" ("venue_coords");



CREATE INDEX "idx_weddings_visibility" ON "public"."weddings" USING "btree" ("visibility") WHERE (("visibility" = 'visible_to_pros'::"public"."wedding_visibility") AND ("is_deleted" = false));



CREATE INDEX "idx_wishlist_pro" ON "public"."wishlist_items" USING "btree" ("professional_profile_id");



CREATE INDEX "notifications_2025_09_profile_id_created_at_idx" ON "public"."notifications_2025_09" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_09_profile_id_is_read_created_at_idx" ON "public"."notifications_2025_09" USING "btree" ("profile_id", "is_read", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_10_profile_id_created_at_idx" ON "public"."notifications_2025_10" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_10_profile_id_is_read_created_at_idx" ON "public"."notifications_2025_10" USING "btree" ("profile_id", "is_read", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_11_profile_id_created_at_idx" ON "public"."notifications_2025_11" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_11_profile_id_is_read_created_at_idx" ON "public"."notifications_2025_11" USING "btree" ("profile_id", "is_read", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_12_profile_id_created_at_idx" ON "public"."notifications_2025_12" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_12_profile_id_is_read_created_at_idx" ON "public"."notifications_2025_12" USING "btree" ("profile_id", "is_read", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "professional_alerts_location_coords_idx" ON "public"."professional_alerts" USING "gist" ("location_coords");



CREATE INDEX "professional_fixed_locations_location_coords_idx" ON "public"."professional_fixed_locations" USING "gist" ("location_coords");



CREATE UNIQUE INDEX "uq_pending_conn_request" ON "public"."connection_requests" USING "btree" ("pro_profile_id", "bride_profile_id") WHERE ("status" = 'pending'::"public"."connectionRequestStatus");



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_09_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_09_profile_id_created_at_idx";



ALTER INDEX "public"."idx_notifications_profile_unread" ATTACH PARTITION "public"."notifications_2025_09_profile_id_is_read_created_at_idx";



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_10_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_10_profile_id_created_at_idx";



ALTER INDEX "public"."idx_notifications_profile_unread" ATTACH PARTITION "public"."notifications_2025_10_profile_id_is_read_created_at_idx";



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_11_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_11_profile_id_created_at_idx";



ALTER INDEX "public"."idx_notifications_profile_unread" ATTACH PARTITION "public"."notifications_2025_11_profile_id_is_read_created_at_idx";



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_12_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_12_profile_id_created_at_idx";



ALTER INDEX "public"."idx_notifications_profile_unread" ATTACH PARTITION "public"."notifications_2025_12_profile_id_is_read_created_at_idx";



CREATE OR REPLACE TRIGGER "handle_wed_articles_updated_at" BEFORE UPDATE ON "public"."wed_articles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "on_is_live_change_notify_crm" AFTER UPDATE OF "is_live" ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."notify_crm_is_live_change"();



COMMENT ON TRIGGER "on_is_live_change_notify_crm" ON "public"."professional_details" IS 'Triggers sync of is_live to CRM when changed. Created 06/12/2025.';



CREATE OR REPLACE TRIGGER "on_replays_change_notify_crm" AFTER INSERT OR DELETE OR UPDATE ON "public"."replays" FOR EACH ROW EXECUTE FUNCTION "public"."notify_crm_replays_change"();



CREATE OR REPLACE TRIGGER "on_wed_articles_change_notify_crm" AFTER INSERT OR DELETE OR UPDATE ON "public"."wed_articles" FOR EACH ROW EXECUTE FUNCTION "public"."notify_crm_wed_articles_change"();



CREATE OR REPLACE TRIGGER "trg_alerts_rate_limit_bi" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."alerts_rate_limit_before_insert"();



CREATE OR REPLACE TRIGGER "trg_conn_req_before_insert" BEFORE INSERT ON "public"."connection_requests" FOR EACH ROW EXECUTE FUNCTION "public"."conn_req_before_insert"();



CREATE OR REPLACE TRIGGER "trg_handle_message_report" AFTER INSERT ON "public"."reports" FOR EACH ROW EXECUTE FUNCTION "public"."handle_message_report"();



CREATE OR REPLACE TRIGGER "trg_outbox_chat_msg" AFTER INSERT ON "public"."chat_messages" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_chat_message"();



CREATE OR REPLACE TRIGGER "trg_outbox_on_connection_request_aiu" AFTER INSERT OR UPDATE OF "status" ON "public"."connection_requests" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_connection_request_aiu"();



CREATE OR REPLACE TRIGGER "trg_outbox_on_video_session" AFTER INSERT ON "public"."video_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_video_session_created"();



CREATE OR REPLACE TRIGGER "trg_outbox_realtime_process" AFTER INSERT ON "public"."notifications_outbox" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_process_outbox_realtime"();



CREATE OR REPLACE TRIGGER "trg_prof_details_budget_eur_biub" BEFORE INSERT OR UPDATE OF "budget_min", "budget_max", "currency" ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."prof_details_set_budget_eur"();



CREATE OR REPLACE TRIGGER "trg_prof_details_set_updated_at" BEFORE UPDATE ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_profiles_set_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_set_alert_expiry" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."set_professional_alert_expiry"();



CREATE OR REPLACE TRIGGER "trg_set_alert_expiry_bi" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."set_professional_alert_expiry"();



CREATE OR REPLACE TRIGGER "trg_user_prefs_set_updated_at" BEFORE UPDATE ON "public"."user_preferences" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_wishlist_count" AFTER INSERT OR DELETE ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_wishlist_count"();



CREATE OR REPLACE TRIGGER "trg_wishlist_count_aiud" AFTER INSERT OR DELETE ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_wishlist_count"();



CREATE OR REPLACE TRIGGER "trg_wishlist_items_after_insert_enqueue_notification" AFTER INSERT ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_wishlist_add"();



CREATE OR REPLACE TRIGGER "trigger_auto_populate_fixed_location_country_code" BEFORE INSERT OR UPDATE OF "location_coords", "location_country_code" ON "public"."professional_fixed_locations" FOR EACH ROW EXECUTE FUNCTION "public"."auto_populate_fixed_location_country_code"();



CREATE OR REPLACE TRIGGER "trigger_sync_professional_on_validation" AFTER UPDATE ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."sync_professional_on_validation"();



CREATE OR REPLACE TRIGGER "trigger_weddings_updated_at" BEFORE UPDATE ON "public"."weddings" FOR EACH ROW EXECUTE FUNCTION "public"."update_weddings_updated_at"();



CREATE OR REPLACE TRIGGER "update_support_tickets_updated_at" BEFORE UPDATE ON "public"."support_tickets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."bride_details"
    ADD CONSTRAINT "bride_details_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."broadcast_history"
    ADD CONSTRAINT "broadcast_history_sent_by_fkey" FOREIGN KEY ("sent_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_room_participants"
    ADD CONSTRAINT "chat_room_participants_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_room_participants"
    ADD CONSTRAINT "chat_room_participants_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connection_requests"
    ADD CONSTRAINT "connection_requests_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connection_requests"
    ADD CONSTRAINT "connection_requests_initiator_id_fkey" FOREIGN KEY ("initiator_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."connection_requests"
    ADD CONSTRAINT "connection_requests_pro_profile_id_fkey" FOREIGN KEY ("pro_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content"
    ADD CONSTRAINT "content_linked_pro_profile_id_fkey" FOREIGN KEY ("linked_pro_profile_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."device_tokens"
    ADD CONSTRAINT "device_tokens_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notification_settings"
    ADD CONSTRAINT "notification_settings_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE "public"."notifications"
    ADD CONSTRAINT "notifications_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_author_profile_id_fkey" FOREIGN KEY ("author_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_motif_code_fkey" FOREIGN KEY ("motif_code") REFERENCES "public"."alert_motifs"("code");



ALTER TABLE ONLY "public"."professional_details"
    ADD CONSTRAINT "professional_details_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_fixed_locations"
    ADD CONSTRAINT "professional_fixed_locations_professional_profile_id_fkey" FOREIGN KEY ("professional_profile_id") REFERENCES "public"."professional_details"("profile_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_profile_changes"
    ADD CONSTRAINT "professional_profile_changes_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_subscriptions"
    ADD CONSTRAINT "professional_subscriptions_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."public_chat_rooms"
    ADD CONSTRAINT "public_chat_rooms_chat_room_id_fkey" FOREIGN KEY ("chat_room_id") REFERENCES "public"."chat_rooms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."replay_guest_assignments"
    ADD CONSTRAINT "replay_guest_assignments_guest_id_fkey" FOREIGN KEY ("guest_id") REFERENCES "public"."replay_guests"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."replay_guest_assignments"
    ADD CONSTRAINT "replay_guest_assignments_replay_id_fkey" FOREIGN KEY ("replay_id") REFERENCES "public"."replays"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reported_message_id_fkey" FOREIGN KEY ("reported_message_id") REFERENCES "public"."chat_messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_reporter_profile_id_fkey" FOREIGN KEY ("reporter_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."support_tickets"
    ADD CONSTRAINT "support_tickets_reported_profile_id_fkey" FOREIGN KEY ("reported_profile_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."sync_events"
    ADD CONSTRAINT "sync_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocked_profile_id_fkey" FOREIGN KEY ("blocked_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocker_profile_id_fkey" FOREIGN KEY ("blocker_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_legal_acceptances"
    ADD CONSTRAINT "user_legal_acceptances_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."video_sessions"
    ADD CONSTRAINT "video_sessions_initiator_id_fkey" FOREIGN KEY ("initiator_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."video_sessions"
    ADD CONSTRAINT "video_sessions_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wed_articles"
    ADD CONSTRAINT "wed_articles_linked_pro_profile_id_fkey" FOREIGN KEY ("linked_pro_profile_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."wedding_participants"
    ADD CONSTRAINT "wedding_participants_professional_profile_id_fkey" FOREIGN KEY ("professional_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wedding_participants"
    ADD CONSTRAINT "wedding_participants_wedding_id_fkey" FOREIGN KEY ("wedding_id") REFERENCES "public"."weddings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."weddings"
    ADD CONSTRAINT "weddings_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_professional_profile_id_fkey" FOREIGN KEY ("professional_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Admin full access on broadcast_history" ON "public"."broadcast_history" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can delete wed_articles" ON "public"."wed_articles" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can insert wed_articles" ON "public"."wed_articles" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can manage guest assignments" ON "public"."replay_guest_assignments" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role")) WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can manage replay guests" ON "public"."replay_guests" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role")) WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can manage replays" ON "public"."replays" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role")) WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can read deleted users log" ON "public"."deleted_users_log" FOR SELECT TO "authenticated" USING ((("auth"."jwt"() ->> 'user_role'::"text") = 'admin'::"text"));



CREATE POLICY "Admins can update tickets" ON "public"."support_tickets" FOR UPDATE TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role")) WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update wed_articles" ON "public"."wed_articles" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can view all roles" ON "public"."user_roles" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all sync events" ON "public"."sync_events" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all tickets" ON "public"."support_tickets" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all wed_articles" ON "public"."wed_articles" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins have full access to professional details" ON "public"."professional_details" TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role")) WITH CHECK ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "All authenticated users can view details" ON "public"."professional_details" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."countries" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to read their own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "profile_id"));



CREATE POLICY "Allow authenticated users to update their own notifications" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Allow author to manage their alerts" ON "public"."professional_alerts" TO "authenticated" USING (("author_profile_id" = "auth"."uid"())) WITH CHECK (("author_profile_id" = "auth"."uid"()));



CREATE POLICY "Allow owner to manage their fixed locations" ON "public"."professional_fixed_locations" TO "authenticated" USING (("professional_profile_id" = "auth"."uid"())) WITH CHECK (("professional_profile_id" = "auth"."uid"()));



CREATE POLICY "Allow owner to update their profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "Allow professionals to view alerts" ON "public"."professional_alerts" FOR SELECT TO "authenticated" USING (("public"."get_my_role"() = 'professional'::"public"."userRole"));



CREATE POLICY "Allow public read access to published articles" ON "public"."wed_articles" FOR SELECT USING (("is_published" = true));



CREATE POLICY "Allow public read-only access" ON "public"."replays" FOR SELECT USING (true);



CREATE POLICY "Allow public read-only access on assignments" ON "public"."replay_guest_assignments" FOR SELECT USING (true);



CREATE POLICY "Allow public read-only access on guests" ON "public"."replay_guests" FOR SELECT USING (true);



CREATE POLICY "Allow service_role to insert notifications" ON "public"."notifications" FOR INSERT TO "service_role" WITH CHECK (true);



CREATE POLICY "Allow service_role to read all notifications" ON "public"."notifications" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "Allow write access to service role only" ON "public"."wed_articles" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Authenticated users can read active report motifs" ON "public"."report_motifs" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Authenticated users can view bride details" ON "public"."bride_details" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can view fixed locations" ON "public"."professional_fixed_locations" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Bride can delete wedding participants" ON "public"."wedding_participants" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."weddings" "w"
  WHERE (("w"."id" = "wedding_participants"."wedding_id") AND ("w"."bride_profile_id" = "auth"."uid"())))));



CREATE POLICY "Bride can insert wedding participants" ON "public"."wedding_participants" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."weddings" "w"
  WHERE (("w"."id" = "wedding_participants"."wedding_id") AND ("w"."bride_profile_id" = "auth"."uid"()) AND ("w"."is_deleted" = false)))));



CREATE POLICY "Bride can manage own wedding" ON "public"."weddings" USING (("bride_profile_id" = "auth"."uid"())) WITH CHECK (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "Bride can see own wedding participants" ON "public"."wedding_participants" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."weddings" "w"
  WHERE (("w"."id" = "wedding_participants"."wedding_id") AND ("w"."bride_profile_id" = "auth"."uid"())))));



CREATE POLICY "Bride owners can manage their own details" ON "public"."bride_details" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Disallow app-side inserts" ON "public"."deleted_users_log" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Owner can update their own subscription record" ON "public"."professional_subscriptions" FOR UPDATE TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Owners can manage their own details" ON "public"."professional_details" TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Participants can view video sessions" ON "public"."video_sessions" FOR SELECT TO "authenticated" USING ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "Pro can see own participation" ON "public"."wedding_participants" FOR SELECT USING (("professional_profile_id" = "auth"."uid"()));



CREATE POLICY "Pro can update own participation" ON "public"."wedding_participants" FOR UPDATE USING (("professional_profile_id" = "auth"."uid"())) WITH CHECK (("professional_profile_id" = "auth"."uid"()));



CREATE POLICY "Pros Premium+ can see visible weddings" ON "public"."weddings" FOR SELECT USING ((("visibility" = 'visible_to_pros'::"public"."wedding_visibility") AND ("is_deleted" = false) AND ("status" = ANY (ARRAY['planning'::"public"."wedding_status", 'confirmed'::"public"."wedding_status"])) AND (("event_date" >= CURRENT_DATE) OR ("event_end_date" >= CURRENT_DATE)) AND (EXISTS ( SELECT 1
   FROM "public"."professional_details" "pd"
  WHERE (("pd"."profile_id" = "auth"."uid"()) AND ("pd"."is_live" = true)))) AND ("public"."get_my_tier"() = ANY (ARRAY['premiumVisibility'::"public"."subscriptionTierType", 'ultimateAccess'::"public"."subscriptionTierType"]))));



CREATE POLICY "Public can view professional_details linked to published wed_ar" ON "public"."professional_details" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."wed_articles" "wa"
  WHERE (("wa"."linked_pro_profile_id" = "professional_details"."profile_id") AND ("wa"."is_published" = true)))));



CREATE POLICY "Public can view profiles linked to published wed_articles" ON "public"."profiles" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."wed_articles" "wa"
  WHERE (("wa"."linked_pro_profile_id" = "profiles"."id") AND ("wa"."is_published" = true)))));



CREATE POLICY "Public profiles are viewable by authenticated users" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Service role can manage notifications in 2025_10" ON "public"."notifications_2025_10" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage notifications in 2025_11" ON "public"."notifications_2025_11" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage notifications in 2025_12" ON "public"."notifications_2025_12" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage roles" ON "public"."user_roles" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Service role can manage sync events" ON "public"."sync_events" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can write report motifs" ON "public"."report_motifs" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role full access participants" ON "public"."wedding_participants" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Service role full access weddings" ON "public"."weddings" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Service role only for sync_control" ON "public"."sync_control" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role only for sync_log" ON "public"."sync_log" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Subscription status is viewable by authenticated users" ON "public"."professional_subscriptions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can create their own tickets" ON "public"."support_tickets" FOR INSERT WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Users can read their own notifications in 2025_10" ON "public"."notifications_2025_10" FOR SELECT USING (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can read their own notifications in 2025_11" ON "public"."notifications_2025_11" FOR SELECT USING (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can read their own notifications in 2025_12" ON "public"."notifications_2025_12" FOR SELECT USING (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can update their own notifications in 2025_10" ON "public"."notifications_2025_10" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can update their own notifications in 2025_11" ON "public"."notifications_2025_11" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can update their own notifications in 2025_12" ON "public"."notifications_2025_12" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can view blocks they're involved in" ON "public"."user_blocks" FOR SELECT TO "authenticated" USING ((("blocker_profile_id" = "auth"."uid"()) OR ("blocked_profile_id" = "auth"."uid"())));



CREATE POLICY "Users can view their own notification settings" ON "public"."notification_settings" FOR SELECT TO "authenticated" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "Users can view their own preferences" ON "public"."user_preferences" FOR SELECT TO "authenticated" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "Users can view their own tickets" ON "public"."support_tickets" FOR SELECT USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "admin_read_all_device_tokens" ON "public"."device_tokens" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



ALTER TABLE "public"."alert_motifs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "alert_motifs_read_authenticated" ON "public"."alert_motifs" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "authenticated_can_select" ON "public"."professional_profile_changes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_can_update" ON "public"."professional_profile_changes" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



ALTER TABLE "public"."bride_details" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."broadcast_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_messages" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_messages_delete_self" ON "public"."chat_messages" FOR DELETE TO "authenticated" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "chat_messages_insert" ON "public"."chat_messages" FOR INSERT TO "authenticated" WITH CHECK ((("profile_id" = "auth"."uid"()) AND (("public"."is_public_room"("room_id") AND ("public"."get_my_role"() = 'bride'::"public"."userRole")) OR ("public"."is_room_participant"("room_id", "auth"."uid"()) AND (NOT "public"."is_blocked_between"("auth"."uid"(), ( SELECT "p"."profile_id"
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = "chat_messages"."room_id") AND ("p"."profile_id" <> "auth"."uid"()))
 LIMIT 1)))))));



CREATE POLICY "chat_messages_select" ON "public"."chat_messages" FOR SELECT TO "authenticated" USING ((("public"."is_public_room"("room_id") AND ("public"."get_my_role"() = 'bride'::"public"."userRole")) OR ("public"."is_room_participant"("room_id", "auth"."uid"()) AND (NOT "public"."is_blocked_between"("auth"."uid"(), "profile_id")))));



CREATE POLICY "chat_messages_update_self" ON "public"."chat_messages" FOR UPDATE TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "chat_participants_insert" ON "public"."chat_room_participants" FOR INSERT TO "authenticated" WITH CHECK ((("profile_id" = "auth"."uid"()) OR ("auth"."role"() = 'service_role'::"text")));



CREATE POLICY "chat_participants_select" ON "public"."chat_room_participants" FOR SELECT USING ((("profile_id" = "auth"."uid"()) OR "public"."is_public_room"("room_id")));



CREATE POLICY "chat_participants_update" ON "public"."chat_room_participants" FOR UPDATE USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."chat_room_participants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_rooms" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_rooms_select" ON "public"."chat_rooms" FOR SELECT USING ((("type" = 'public'::"text") OR "public"."is_room_participant"("id", "auth"."uid"())));



CREATE POLICY "conn_req_bride_update" ON "public"."connection_requests" FOR UPDATE USING (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "conn_req_parties_read" ON "public"."connection_requests" FOR SELECT USING ((("pro_profile_id" = "auth"."uid"()) OR ("bride_profile_id" = "auth"."uid"())));



CREATE POLICY "conn_req_select_self" ON "public"."connection_requests" FOR SELECT USING ((("pro_profile_id" = "auth"."uid"()) OR ("bride_profile_id" = "auth"."uid"())));



CREATE POLICY "conn_req_update_parties" ON "public"."connection_requests" FOR UPDATE USING ((("pro_profile_id" = "auth"."uid"()) OR ("bride_profile_id" = "auth"."uid"())));



CREATE POLICY "conn_req_write_pro_or_bride_self" ON "public"."connection_requests" FOR INSERT WITH CHECK ((("pro_profile_id" = "auth"."uid"()) OR ("bride_profile_id" = "auth"."uid"())));



ALTER TABLE "public"."connection_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "content_read_all" ON "public"."content" FOR SELECT USING (true);



CREATE POLICY "content_select_all" ON "public"."content" FOR SELECT USING (true);



ALTER TABLE "public"."countries" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."deleted_users_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."device_tokens" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "device_tokens_owner_rw" ON "public"."device_tokens" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."fx_rates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "fx_rates_read_all" ON "public"."fx_rates" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "legal_owner_insert" ON "public"."user_legal_acceptances" FOR INSERT WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "legal_owner_select" ON "public"."user_legal_acceptances" FOR SELECT USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "notif_settings_owner" ON "public"."notification_settings" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "notif_settings_owner_rw" ON "public"."notification_settings" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."notification_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications_2025_09" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications_2025_10" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications_2025_11" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications_2025_12" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications_outbox" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notifications_read_auth" ON "public"."notifications_2025_09" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "outbox_service_role_all" ON "public"."notifications_outbox" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "pcr_read_auth" ON "public"."public_chat_rooms" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "pcr_write_service" ON "public"."public_chat_rooms" TO "authenticated" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



ALTER TABLE "public"."professional_alerts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_details" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_fixed_locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_profile_changes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_subscriptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_insert_self_only" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));



ALTER TABLE "public"."public_chat_rooms" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replay_guest_assignments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replay_guests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replays" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."report_motifs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "reports_owner" ON "public"."reports" USING (("reporter_profile_id" = "auth"."uid"()));



CREATE POLICY "reports_owner_rw" ON "public"."reports" USING (("reporter_profile_id" = "auth"."uid"())) WITH CHECK (("reporter_profile_id" = "auth"."uid"()));



CREATE POLICY "service_role_all_notifications_outbox" ON "public"."notifications_outbox" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "service_role_can_insert_profiles" ON "public"."profiles" FOR INSERT TO "service_role" WITH CHECK (true);



CREATE POLICY "service_role_can_manage_locations" ON "public"."professional_fixed_locations" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "service_role_can_upsert_details" ON "public"."professional_details" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "service_role_can_upsert_subscriptions" ON "public"."professional_subscriptions" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "service_role_full_access" ON "public"."professional_profile_changes" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "service_role_read_device_tokens" ON "public"."device_tokens" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_read_notification_settings" ON "public"."notification_settings" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_read_profiles" ON "public"."profiles" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_read_user_preferences" ON "public"."user_preferences" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_chat_messages" ON "public"."chat_messages" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_chat_room_participants" ON "public"."chat_room_participants" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_chat_rooms" ON "public"."chat_rooms" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_device_tokens" ON "public"."device_tokens" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_notification_settings" ON "public"."notification_settings" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_profiles" ON "public"."profiles" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_select_user_preferences" ON "public"."user_preferences" FOR SELECT TO "service_role" USING (true);



CREATE POLICY "service_role_update_profiles" ON "public"."profiles" FOR UPDATE TO "service_role" USING (true) WITH CHECK (true);



ALTER TABLE "public"."stripe_events_log" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "stripe_events_read_sr" ON "public"."stripe_events_log" FOR SELECT USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "stripe_events_write_sr" ON "public"."stripe_events_log" USING (("auth"."role"() = 'service_role'::"text"));



ALTER TABLE "public"."support_tickets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sync_control" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sync_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sync_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_blocks" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_blocks_owner" ON "public"."user_blocks" USING (("blocker_profile_id" = "auth"."uid"()));



CREATE POLICY "user_blocks_owner_rw" ON "public"."user_blocks" USING (("blocker_profile_id" = "auth"."uid"())) WITH CHECK (("blocker_profile_id" = "auth"."uid"()));



ALTER TABLE "public"."user_legal_acceptances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_preferences" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_prefs_owner_all" ON "public"."user_preferences" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "user_prefs_owner_rw" ON "public"."user_preferences" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."video_sessions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "video_sessions_participants" ON "public"."video_sessions" USING ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "video_sessions_participants_rw" ON "public"."video_sessions" USING ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



ALTER TABLE "public"."wed_articles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wedding_participants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."weddings" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "wishlist_bride_all" ON "public"."wishlist_items" USING (("bride_profile_id" = "auth"."uid"()));



ALTER TABLE "public"."wishlist_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "wishlist_items_owner_rw" ON "public"."wishlist_items" USING (("bride_profile_id" = "auth"."uid"())) WITH CHECK (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "wishlist_pro_ultimate_read" ON "public"."wishlist_items" FOR SELECT USING ((("professional_profile_id" = "auth"."uid"()) AND ("public"."get_my_tier"() = 'ultimateAccess'::"public"."subscriptionTierType")));



REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "authenticator";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") TO "service_role";
GRANT ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."admin_get_professional_details"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."admin_get_professional_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."alerts_rate_limit_before_insert"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."alerts_rate_limit_before_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auth_uid"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."auth_uid"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_populate_fixed_location_country_code"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."auto_populate_fixed_location_country_code"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_populate_location_country_code"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."auto_populate_location_country_code"() TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_map_security_status"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."check_map_security_status"() TO "authenticated";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications_outbox" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications_outbox" TO "anon";
GRANT ALL ON TABLE "public"."notifications_outbox" TO "authenticator";
GRANT ALL ON TABLE "public"."notifications_outbox" TO "service_role";



GRANT ALL ON FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."claim_single_outbox_event"("p_event_id" "uuid", "p_worker_id" "text") TO "authenticator";



GRANT ALL ON FUNCTION "public"."cleanup_abandoned_video_sessions"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."cleanup_abandoned_video_sessions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_old_notifications"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."cleanup_old_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."conn_req_before_insert"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."conn_req_before_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_alert"("p_alert_type" "text", "p_title" "text", "p_message" "text", "p_event_date" "date", "p_location_lat" double precision, "p_location_lng" double precision, "p_location_label" "text", "p_radius_km" integer, "p_profession_needed" "text") TO "authenticator";



GRANT ALL ON FUNCTION "public"."create_contact_request"("p_target_id" "uuid", "p_source" "text", "p_message" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."create_contact_request"("p_target_id" "uuid", "p_source" "text", "p_message" "text") TO "authenticated";



GRANT ALL ON FUNCTION "public"."create_next_notifications_partition"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."create_next_notifications_partition"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_with_id"("p_id" "uuid", "p_email" "text", "p_encrypted_password" "text", "p_email_confirmed_at" timestamp with time zone, "p_raw_user_meta_data" "jsonb", "p_raw_app_meta_data" "jsonb", "p_created_at" timestamp with time zone) TO "authenticator";



GRANT ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") TO "service_role";
GRANT ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."delete_alert"("p_alert_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."delete_alert"("p_alert_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."delete_current_device_token"("device_token" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."delete_current_device_token"("device_token" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_my_device_tokens"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."delete_my_device_tokens"() TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_my_wedding"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."delete_my_wedding"() TO "authenticated";



GRANT ALL ON FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_alerts"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."expire_alerts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_trials"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."expire_trials"() TO "service_role";



GRANT ALL ON FUNCTION "public"."geocode_city_to_point"("city_name" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."geocode_city_to_point"("city_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_active_alerts_for_market"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_bride_interest_items"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_bride_interest_items"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_country_code_from_coords"("coords" "extensions"."geometry") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_country_code_from_coords"("coords" "extensions"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_favorited_professionals"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_favorited_professionals"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_featured_replay"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_formatted_notifications"("p_limit" integer) TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_formatted_notifications"("p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_latest_wed_article"("p_lang" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_latest_wed_article"("p_lang" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_alerts"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_my_alerts"() TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_my_market_region"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_my_market_region"() TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_my_role"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_my_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_tier"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_my_tier"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_wedding"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_my_wedding"() TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_pending_contact_requests"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_pending_contact_requests"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_public_chat_rooms_for_brides"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_public_chat_rooms_for_brides"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_replays_bundle"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."get_report_motifs"("p_locale" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_report_motifs"("p_locale" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_room_header"("p_room_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_room_header"("p_room_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_unread_notifications_count"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_unread_notifications_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_email"("user_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_user_email"("user_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_user_email_by_profile_id"("p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_user_email_by_profile_id"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_wedding_details"("p_wedding_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_wedding_details"("p_wedding_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_wishlisted_by_brides"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."get_wishlisted_by_brides"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_message_report"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."handle_message_report"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "authenticator";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "authenticator";
GRANT ALL ON FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_public_room"("p_room_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."is_public_room"("p_room_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_visible_in_market"("owner_country" "text", "viewer_region" "text") TO "authenticator";



GRANT ALL ON FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_video_sessions_missed"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."mark_video_sessions_missed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_crm_is_live_change"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."notify_crm_replays_change"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."notify_crm_wed_articles_change"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."on_auth_user_created"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."on_auth_user_created"() TO "service_role";



GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "service_role";
GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."outbox_on_chat_message"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."outbox_on_chat_message"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_connection_request"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_connection_request_aiu"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request_aiu"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_video_session_created"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."outbox_on_video_session_created"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_wishlist_add"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."outbox_on_wishlist_add"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prof_details_set_budget_eur"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."prof_details_set_budget_eur"() TO "service_role";



GRANT ALL ON FUNCTION "public"."recompute_all_budgets_eur"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."recompute_all_budgets_eur"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) TO "authenticator";
GRANT ALL ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) TO "authenticator";



GRANT ALL ON FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_alert_reminders"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."send_alert_reminders"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_professional_alert_expiry"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."set_professional_alert_expiry"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_professional_on_validation"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."sync_profile_to_professional_details"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."sync_profile_to_professional_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") TO "authenticator";
GRANT ALL ON FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") TO "service_role";



GRANT ALL ON FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") TO "authenticator";
GRANT ALL ON FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_process_outbox_realtime"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."update_alert"("p_alert_id" "uuid", "p_title" "text", "p_message" "text", "p_event_date" "date", "p_location_lat" double precision, "p_location_lng" double precision, "p_location_label" "text", "p_status" "public"."alertStatus") TO "authenticator";
GRANT ALL ON FUNCTION "public"."update_alert"("p_alert_id" "uuid", "p_title" "text", "p_message" "text", "p_event_date" "date", "p_location_lat" double precision, "p_location_lng" double precision, "p_location_label" "text", "p_status" "public"."alertStatus") TO "authenticated";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_weddings_updated_at"() TO "authenticator";



GRANT ALL ON FUNCTION "public"."update_wishlist_count"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."update_wishlist_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_wedding"("p_wedding_name" "text", "p_event_date" "date", "p_event_end_date" "date", "p_venue_label" "text", "p_venue_lat" double precision, "p_venue_lng" double precision, "p_search_radius_km" integer, "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_professions_needed" "text"[], "p_visibility" "text") TO "authenticator";



GRANT ALL ON FUNCTION "public"."upsert_wedding"("p_wedding_name" "text", "p_event_date" "date", "p_event_end_date" "date", "p_venue_label" "text", "p_venue_lat" double precision, "p_venue_lng" double precision, "p_search_radius_km" integer, "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_professions_needed" "text"[], "p_visibility" "text", "p_location_country_code" "text") TO "authenticator";



GRANT ALL ON FUNCTION "public"."validate_coordinates"("p_lat" double precision, "p_lng" double precision) TO "authenticator";
GRANT ALL ON FUNCTION "public"."validate_coordinates"("p_lat" double precision, "p_lng" double precision) TO "authenticated";



GRANT ALL ON FUNCTION "public"."wedding_pins_history_logger"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."wedding_pins_history_logger"() TO "service_role";



GRANT ALL ON FUNCTION "public"."wedding_pins_set_budget_eur"() TO "authenticator";
GRANT ALL ON FUNCTION "public"."wedding_pins_set_budget_eur"() TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."alert_motifs" TO "authenticated";
GRANT SELECT ON TABLE "public"."alert_motifs" TO "anon";
GRANT ALL ON TABLE "public"."alert_motifs" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."bride_details" TO "authenticated";
GRANT SELECT ON TABLE "public"."bride_details" TO "anon";
GRANT ALL ON TABLE "public"."bride_details" TO "authenticator";



GRANT SELECT ON TABLE "public"."broadcast_history" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."broadcast_history" TO "authenticated";
GRANT ALL ON TABLE "public"."broadcast_history" TO "authenticator";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."broadcast_history" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."chat_messages" TO "authenticated";
GRANT SELECT ON TABLE "public"."chat_messages" TO "anon";
GRANT ALL ON TABLE "public"."chat_messages" TO "authenticator";
GRANT SELECT ON TABLE "public"."chat_messages" TO "service_role";



GRANT USAGE ON SEQUENCE "public"."chat_messages_id_seq" TO "authenticated";
GRANT USAGE ON SEQUENCE "public"."chat_messages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."chat_messages_id_seq" TO "authenticator";
GRANT SELECT,USAGE ON SEQUENCE "public"."chat_messages_id_seq" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."chat_room_participants" TO "authenticated";
GRANT SELECT ON TABLE "public"."chat_room_participants" TO "anon";
GRANT ALL ON TABLE "public"."chat_room_participants" TO "authenticator";
GRANT SELECT ON TABLE "public"."chat_room_participants" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."chat_rooms" TO "authenticated";
GRANT SELECT ON TABLE "public"."chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."chat_rooms" TO "authenticator";
GRANT SELECT ON TABLE "public"."chat_rooms" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."connection_requests" TO "authenticated";
GRANT SELECT ON TABLE "public"."connection_requests" TO "anon";
GRANT ALL ON TABLE "public"."connection_requests" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."content" TO "authenticated";
GRANT SELECT ON TABLE "public"."content" TO "anon";
GRANT ALL ON TABLE "public"."content" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."countries" TO "authenticated";
GRANT SELECT ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."deleted_users_log" TO "authenticated";
GRANT SELECT ON TABLE "public"."deleted_users_log" TO "anon";
GRANT ALL ON TABLE "public"."deleted_users_log" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."device_tokens" TO "authenticated";
GRANT SELECT ON TABLE "public"."device_tokens" TO "anon";
GRANT ALL ON TABLE "public"."device_tokens" TO "authenticator";
GRANT SELECT ON TABLE "public"."device_tokens" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."fx_rates" TO "authenticated";
GRANT SELECT ON TABLE "public"."fx_rates" TO "anon";
GRANT ALL ON TABLE "public"."fx_rates" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notification_settings" TO "authenticated";
GRANT SELECT ON TABLE "public"."notification_settings" TO "anon";
GRANT ALL ON TABLE "public"."notification_settings" TO "authenticator";
GRANT SELECT ON TABLE "public"."notification_settings" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticator";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications_2025_09" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications_2025_09" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_09" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications_2025_10" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications_2025_10" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_10" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications_2025_11" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications_2025_11" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_11" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."notifications_2025_12" TO "authenticated";
GRANT SELECT ON TABLE "public"."notifications_2025_12" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_12" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_alerts" TO "authenticated";
GRANT SELECT ON TABLE "public"."professional_alerts" TO "anon";
GRANT ALL ON TABLE "public"."professional_alerts" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_details" TO "authenticated";
GRANT SELECT ON TABLE "public"."professional_details" TO "anon";
GRANT ALL ON TABLE "public"."professional_details" TO "authenticator";
GRANT ALL ON TABLE "public"."professional_details" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_fixed_locations" TO "authenticated";
GRANT SELECT ON TABLE "public"."professional_fixed_locations" TO "anon";
GRANT ALL ON TABLE "public"."professional_fixed_locations" TO "authenticator";
GRANT ALL ON TABLE "public"."professional_fixed_locations" TO "service_role";



GRANT SELECT ON TABLE "public"."professional_profile_changes" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_profile_changes" TO "authenticated";
GRANT ALL ON TABLE "public"."professional_profile_changes" TO "authenticator";
GRANT ALL ON TABLE "public"."professional_profile_changes" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_subscriptions" TO "authenticated";
GRANT SELECT ON TABLE "public"."professional_subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."professional_subscriptions" TO "authenticator";
GRANT ALL ON TABLE "public"."professional_subscriptions" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."profiles" TO "authenticated";
GRANT SELECT ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticator";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."public_chat_rooms" TO "authenticated";
GRANT SELECT ON TABLE "public"."public_chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."public_chat_rooms" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."public_professionals" TO "authenticated";
GRANT SELECT ON TABLE "public"."public_professionals" TO "anon";
GRANT ALL ON TABLE "public"."public_professionals" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."public_profiles" TO "authenticated";
GRANT SELECT ON TABLE "public"."public_profiles" TO "anon";
GRANT ALL ON TABLE "public"."public_profiles" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."replay_guest_assignments" TO "authenticated";
GRANT SELECT ON TABLE "public"."replay_guest_assignments" TO "anon";
GRANT ALL ON TABLE "public"."replay_guest_assignments" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."replay_guests" TO "authenticated";
GRANT SELECT ON TABLE "public"."replay_guests" TO "anon";
GRANT ALL ON TABLE "public"."replay_guests" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."replays" TO "authenticated";
GRANT SELECT ON TABLE "public"."replays" TO "anon";
GRANT ALL ON TABLE "public"."replays" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."report_motifs" TO "authenticated";
GRANT SELECT ON TABLE "public"."report_motifs" TO "anon";
GRANT ALL ON TABLE "public"."report_motifs" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."report_motifs_v" TO "authenticated";
GRANT SELECT ON TABLE "public"."report_motifs_v" TO "anon";
GRANT ALL ON TABLE "public"."report_motifs_v" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."reports" TO "authenticated";
GRANT SELECT ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."stripe_events_log" TO "authenticated";
GRANT SELECT ON TABLE "public"."stripe_events_log" TO "anon";
GRANT ALL ON TABLE "public"."stripe_events_log" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."support_tickets" TO "authenticated";
GRANT SELECT ON TABLE "public"."support_tickets" TO "anon";
GRANT ALL ON TABLE "public"."support_tickets" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."sync_control" TO "authenticated";
GRANT SELECT ON TABLE "public"."sync_control" TO "anon";
GRANT ALL ON TABLE "public"."sync_control" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."sync_events" TO "authenticated";
GRANT SELECT ON TABLE "public"."sync_events" TO "anon";
GRANT ALL ON TABLE "public"."sync_events" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."sync_log" TO "authenticated";
GRANT SELECT ON TABLE "public"."sync_log" TO "anon";
GRANT ALL ON TABLE "public"."sync_log" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."sync_stats" TO "authenticated";
GRANT SELECT ON TABLE "public"."sync_stats" TO "anon";
GRANT ALL ON TABLE "public"."sync_stats" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_blocks" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_blocks" TO "anon";
GRANT ALL ON TABLE "public"."user_blocks" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_legal_acceptances" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_legal_acceptances" TO "anon";
GRANT ALL ON TABLE "public"."user_legal_acceptances" TO "authenticator";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_preferences" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_preferences" TO "anon";
GRANT ALL ON TABLE "public"."user_preferences" TO "authenticator";
GRANT SELECT ON TABLE "public"."user_preferences" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_roles" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticator";
GRANT SELECT ON TABLE "public"."user_roles" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."video_sessions" TO "authenticated";
GRANT SELECT ON TABLE "public"."video_sessions" TO "anon";
GRANT ALL ON TABLE "public"."video_sessions" TO "authenticator";



GRANT ALL ON TABLE "public"."wed_articles" TO "authenticated";
GRANT SELECT ON TABLE "public"."wed_articles" TO "anon";
GRANT ALL ON TABLE "public"."wed_articles" TO "authenticator";
GRANT ALL ON TABLE "public"."wed_articles" TO "service_role";



GRANT SELECT ON TABLE "public"."wedding_participants" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."wedding_participants" TO "authenticated";
GRANT ALL ON TABLE "public"."wedding_participants" TO "authenticator";
GRANT ALL ON TABLE "public"."wedding_participants" TO "service_role";



GRANT SELECT ON TABLE "public"."weddings" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."weddings" TO "authenticated";
GRANT ALL ON TABLE "public"."weddings" TO "authenticator";
GRANT ALL ON TABLE "public"."weddings" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."wishlist_items" TO "authenticated";
GRANT SELECT ON TABLE "public"."wishlist_items" TO "anon";
GRANT ALL ON TABLE "public"."wishlist_items" TO "authenticator";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticator";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticator";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT SELECT ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticator";




