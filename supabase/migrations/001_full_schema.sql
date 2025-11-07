


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


CREATE SCHEMA IF NOT EXISTS "auth";


ALTER SCHEMA "auth" OWNER TO "supabase_admin";


CREATE SCHEMA IF NOT EXISTS "graphql";


ALTER SCHEMA "graphql" OWNER TO "supabase_admin";


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE SCHEMA IF NOT EXISTS "storage";


ALTER SCHEMA "storage" OWNER TO "supabase_admin";


CREATE TYPE "auth"."aal_level" AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE "auth"."aal_level" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."code_challenge_method" AS ENUM (
    's256',
    'plain'
);


ALTER TYPE "auth"."code_challenge_method" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."factor_status" AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE "auth"."factor_status" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."factor_type" AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE "auth"."factor_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."oauth_authorization_status" AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE "auth"."oauth_authorization_status" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."oauth_client_type" AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE "auth"."oauth_client_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."oauth_registration_type" AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE "auth"."oauth_registration_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."oauth_response_type" AS ENUM (
    'code'
);


ALTER TYPE "auth"."oauth_response_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."one_time_token_type" AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE "auth"."one_time_token_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "public"."alertStatus" AS ENUM (
    'active',
    'cancelled',
    'expired'
);


ALTER TYPE "public"."alertStatus" OWNER TO "postgres";


CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'moderator'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE TYPE "public"."connectionRequestSource" AS ENUM (
    'wishlist',
    'weddingPin',
    'map',
    'alert',
    'proToPro'
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
    'weddingPinMatch'
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
    'PHOTO/MOVIE',
    'MAKEUPARTIST',
    'EVENTDESIGNER',
    'OTHER'
);


ALTER TYPE "public"."profession" OWNER TO "postgres";


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


CREATE TYPE "storage"."buckettype" AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE "storage"."buckettype" OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION "auth"."email"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."email"() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';



CREATE OR REPLACE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION "auth"."jwt"() OWNER TO "supabase_auth_admin";


CREATE OR REPLACE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION "auth"."role"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';



CREATE OR REPLACE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION "auth"."uid"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."uid"() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';



CREATE OR REPLACE FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_me uuid := auth.uid();
  v_req record;
  v_room_id uuid;
begin
  if v_me is null then
    return jsonb_build_object('status','error','reason','AUTH_REQUIRED');
  end if;

  select * into v_req
  from public.connection_requests
  where id = p_request_id
  for update;

  if not found then
    return jsonb_build_object('status','error','reason','REQUEST_NOT_FOUND');
  end if;

  if v_req.status <> 'pending' then
    return jsonb_build_object('status','error','reason','INVALID_STATUS');
  end if;

  if v_me <> v_req.bride_profile_id then
    return jsonb_build_object('status','error','reason','FORBIDDEN');
  end if;

  -- Mettre à jour la demande de contact
  update public.connection_requests
     set status='accepted',
         responded_at = now()
   where id = p_request_id;

  -- Retrouver la room qui a été pré-créée
  select r.id into v_room_id
  from public.chat_rooms r
  join public.chat_room_participants p1 on p1.room_id = r.id and p1.profile_id = v_req.pro_profile_id
  join public.chat_room_participants p2 on p2.room_id = r.id and p2.profile_id = v_req.bride_profile_id
  where r.type = 'private'
  limit 1;

  -- Activer la conversation pour les deux participants
  if v_room_id is not null then
    update public.chat_room_participants
       set conversation_status = 'active'
     where room_id = v_room_id;
  end if;

  return jsonb_build_object('status','ok','roomId', v_room_id);
end;
$$;


ALTER FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_get_professional_details"() RETURNS TABLE("profile_id" "uuid", "business_name" "text", "description" "text", "portfolio_images" "text"[], "profession" "public"."profession", "created_at" timestamp with time zone, "budget_min" integer, "budget_max" integer, "instagram_url" "text", "website_url" "text", "slideshow_images" "text"[], "profile_video_url" "text", "currency" "text", "is_live" boolean, "is_pending" boolean, "location_city" "text", "location_country_code" "text", "location_label" "text", "profile" "jsonb", "fixed_locations" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
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


CREATE OR REPLACE FUNCTION "public"."cleanup_old_notifications"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  DELETE FROM public.notifications WHERE is_read = true AND created_at < now() - interval '90 days';
END;
$$;


ALTER FUNCTION "public"."cleanup_old_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_pro_recent_locations"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  DELETE FROM public.pro_recent_locations
  WHERE is_opt_in = false OR last_seen_at < now() - interval '7 days';
END;
$$;


ALTER FUNCTION "public"."cleanup_pro_recent_locations"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."conn_req_before_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE pro_tier public."subscriptionTierType" := public.get_tier_of(NEW.pro_profile_id);
BEGIN
  -- Sources:
  -- 'wishlist' -> pro must ultimateAccess
  IF NEW.source = 'wishlist' AND pro_tier <> 'ultimateAccess' THEN
    RAISE EXCEPTION 'ULTIMATE_REQUIRED_FOR_WISHLIST';
  END IF;

  -- 'weddingPin' -> pro must premiumVisibility or ultimateAccess
  IF NEW.source = 'weddingPin' AND pro_tier NOT IN ('premiumVisibility','ultimateAccess') THEN
    RAISE EXCEPTION 'PREMIUM_OR_ULTIMATE_REQUIRED_FOR_PIN';
  END IF;

  -- 'map','alert','proToPro' -> pro must premiumVisibility or ultimateAccess
  IF NEW.source IN ('map','alert','proToPro') AND pro_tier NOT IN ('premiumVisibility','ultimateAccess') THEN
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


CREATE OR REPLACE FUNCTION "public"."create_next_notifications_partition"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
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


CREATE OR REPLACE FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_me uuid := auth.uid();
  v_req record;
  v_room_id uuid;
begin
  if v_me is null then
    return jsonb_build_object('status','error','reason','AUTH_REQUIRED');
  end if;

  select * into v_req
  from public.connection_requests
  where id = p_request_id
  for update;

  if not found then
    return jsonb_build_object('status','error','reason','REQUEST_NOT_FOUND');
  end if;

  if v_req.status <> 'pending' then
    return jsonb_build_object('status','error','reason','INVALID_STATUS');
  end if;

  if v_me <> v_req.bride_profile_id then
    return jsonb_build_object('status','error','reason','FORBIDDEN');
  end if;

  -- Mettre à jour la demande de contact
  update public.connection_requests
     set status='declined',
         responded_at = now()
   where id = p_request_id;

  -- Retrouver la room qui a été pré-créée
  select r.id into v_room_id
  from public.chat_rooms r
  join public.chat_room_participants p1 on p1.room_id = r.id and p1.profile_id = v_req.pro_profile_id
  join public.chat_room_participants p2 on p2.room_id = r.id and p2.profile_id = v_req.bride_profile_id
  where r.type = 'private'
  limit 1;

  -- Marquer la conversation comme déclinée pour les deux participants
  if v_room_id is not null then
    update public.chat_room_participants
       set conversation_status = 'declined'
     where room_id = v_room_id;
  end if;

  return jsonb_build_object('status','ok');
end;
$$;


ALTER FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_user_poi"("p_poi_id" "uuid") RETURNS boolean
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

  DELETE FROM public.user_pois
  WHERE id = p_poi_id AND bride_profile_id = v_me;

  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN v_deleted > 0;
END;
$$;


ALTER FUNCTION "public"."delete_user_poi"("p_poi_id" "uuid") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."enforce_fixed_locations_quota"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE quota int := public.get_fixed_locations_quota(NEW.professional_profile_id);
DECLARE current_count int;
BEGIN
  SELECT COUNT(*) INTO current_count
  FROM public.professional_fixed_locations
  WHERE professional_profile_id = NEW.professional_profile_id;

  IF current_count >= quota THEN
    RAISE EXCEPTION 'FIXED_LOCATIONS_QUOTA_REACHED';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_fixed_locations_quota"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_me uuid := auth.uid();
  v_my_role public."userRole";
  v_my_tier public."subscriptionTierType";
  v_locale text := 'en';
  v_blocked boolean := false;
  v_alert record;
  v_author_prof public.profession;
  v_motif_label text;
  v_is_contactable boolean := false;
BEGIN
  IF v_me IS NOT NULL THEN
    SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me;
    v_my_tier := public.get_tier_of(v_me);
    SELECT COALESCE(NULLIF(lower(up.default_locale), ''), 'en') INTO v_locale FROM public.user_preferences up WHERE up.profile_id = v_me;
  END IF;
  SELECT a.*, pr.full_name, pr.avatar_url INTO v_alert FROM public.professional_alerts a JOIN public.profiles pr ON pr.id = a.author_profile_id WHERE a.id = p_alert_id AND a.status = 'active' AND a.is_deleted = false;
  IF NOT FOUND THEN RAISE EXCEPTION 'ALERT_NOT_FOUND_OR_INACTIVE'; END IF;
  SELECT profession INTO v_author_prof FROM public.professional_details WHERE profile_id = v_alert.author_profile_id;
  SELECT CASE WHEN v_locale = 'fr' THEN am.name_fr ELSE am.name_en END INTO v_motif_label FROM public.alert_motifs am WHERE am.code = v_alert.motif_code;
  IF v_me IS NOT NULL THEN
    SELECT EXISTS(SELECT 1 FROM public.user_blocks b WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = v_alert.author_profile_id) OR (b.blocker_profile_id = v_alert.author_profile_id AND b.blocked_profile_id = v_me)) INTO v_blocked;
  END IF;
  v_is_contactable := (v_my_role = 'professional') AND (v_my_tier IN ('premiumVisibility','ultimateAccess')) AND NOT v_blocked;
  RETURN jsonb_build_object('alertId', v_alert.id, 'motifCode', v_alert.motif_code, 'motifLabel', COALESCE(v_motif_label, v_alert.title), 'message', v_alert.message, 'locationLabel', v_alert.location_label, 'startAt', v_alert.created_at, 'endAt', v_alert.expires_at, 'authorProfileId', v_alert.author_profile_id, 'authorAvatarUrl', v_alert.avatar_url, 'authorFullName', COALESCE(v_alert.full_name, 'Lynewed Professional'), 'authorProfession', v_author_prof::text, 'isOwn', (v_me IS NOT NULL AND v_alert.author_profile_id = v_me), 'isContactable', v_is_contactable);
END;
$$;


ALTER FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_bride_interest_items"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$DECLARE 
  v_me uuid := auth.uid(); 
  v_role public."userRole"; 
  out_items jsonb := '[]'::jsonb;
  v_bride_avatar_url text;  -- ✅ AJOUTÉ
BEGIN 
  IF v_me IS NULL THEN 
    RAISE EXCEPTION 'AUTH_REQUIRED'; 
  END IF; 
  
  SELECT role INTO v_role FROM public.profiles WHERE id = v_me; 
  
  IF v_role <> 'bride' THEN 
    RETURN '[]'::jsonb; 
  END IF; 
  
  -- ✅ RÉCUPÉRER L'AVATAR DE LA BRIDE
  SELECT avatar_url INTO v_bride_avatar_url
  FROM public.public_profiles
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
        'brideAvatarUrl', v_bride_avatar_url  -- ✅ AJOUTÉ
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
        'brideAvatarUrl', v_bride_avatar_url  -- ✅ AJOUTÉ
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


CREATE OR REPLACE FUNCTION "public"."get_favorited_professionals"() RETURNS "jsonb"
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
            'coverImageUrl', pd.portfolio_images[1], -- Prend la première image comme cover
            'isFavorited', true, -- Par définition, ils sont tous favoris
            'isLive', pd.is_live,
            'description', pd.description,
            'portfolioImages', to_jsonb(pd.portfolio_images),
            'fixedLocations', (
                SELECT jsonb_agg(jsonb_build_object('lat', ST_Y(fl.location_coords), 'lng', ST_X(fl.location_coords)))
                FROM public.professional_fixed_locations fl
                WHERE fl.professional_profile_id = p.id
            ),
            'instagramUrl', pd.instagram_url,
            'websiteUrl', pd.website_url,
            'canBeContactedByBride', (ps.subscription_tier IN ('premiumVisibility','ultimateAccess') AND pd.is_live = true),
            'canContactBride', false -- Non pertinent du point de vue de la Bride
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


CREATE OR REPLACE FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text" DEFAULT NULL::"text", "p_page_size" integer DEFAULT 24) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
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

  cs jsonb; -- parsed cursor
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
      COALESCE(
        CASE WHEN v_center IS NOT NULL
          THEN ST_Distance(pd.location_coords::geography, v_center::geography)
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
      AND (
        v_center IS NULL OR v_radius_km IS NULL
        OR ST_DWithin(pd.location_coords::geography, v_center::geography, v_radius_km*1000)
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

  -- next_cursor si +1 existe
  IF items IS NOT NULL AND jsonb_array_length(items) = v_page_size + 1 THEN
    -- extraire le (v_page_size+1)-ème comme prochain curseur
    WITH lst AS (
      SELECT (items->>(v_page_size))::jsonb AS j
    ), lastrow AS (
      SELECT
        (j->>'proProfileId')::uuid AS pid
      FROM lst
    ), full_row_data AS ( -- RENOMMÉ ICI
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
    FROM full_row_data f; -- ET ICI

    -- tronquer items à v_page_size
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
    SET "search_path" TO 'public', 'pg_temp'
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
            'notificationType', n.type, -- CORRIGÉ : On utilise directement le type de la table
            'title',
                -- AMÉLIORÉ : Gère tous les types de notifications
                CASE n.type
                    WHEN 'chatMessage' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouveau message' ELSE 'New message' END
                    WHEN 'connectionRequest' THEN CASE v_my_locale WHEN 'fr' THEN 'Nouvelle demande de contact' ELSE 'New connection request' END
                    WHEN 'connectionRequestAccepted' THEN CASE v_my_locale WHEN 'fr' THEN 'Demande acceptée' ELSE 'Request accepted' END
                    WHEN 'connectionRequestDeclined' THEN CASE v_my_locale WHEN 'fr' THEN 'Demande refusée' ELSE 'Request declined' END
                    WHEN 'wishlistAdd' THEN CASE v_my_locale WHEN 'fr' THEN 'Ajout à une wishlist' ELSE 'Added to a wishlist' END
                    WHEN 'professionalAlertReminder24h' THEN CASE v_my_locale WHEN 'fr' THEN 'Alerte bientôt expirée' ELSE 'Alert expiring soon' END
                    WHEN 'videoIncoming' THEN CASE v_my_locale WHEN 'fr' THEN 'Appel Vidéo Entrant' ELSE 'Incoming Video Call' END
                    ELSE 'Notification'
                END,
            'message',
                -- AMÉLIORÉ : Gère tous les types de notifications
                CASE n.type
                    WHEN 'chatMessage' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' vous a envoyé un message.' ELSE ' sent you a message.' END)
                    WHEN 'connectionRequest' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' souhaite vous contacter.' ELSE ' wants to connect with you.' END)
                    WHEN 'connectionRequestAccepted' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' a accepté votre demande.' ELSE ' accepted your request.' END)
                    WHEN 'connectionRequestDeclined' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' a refusé votre demande.' ELSE ' declined your request.' END)
                    WHEN 'wishlistAdd' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' vous a ajouté à ses favoris.' ELSE ' added you to their favorites.' END)
                    WHEN 'professionalAlertReminder24h' THEN CASE v_my_locale WHEN 'fr' THEN 'Votre alerte expire dans moins de 24h.' ELSE 'Your alert expires in less than 24h.' END
                    WHEN 'videoIncoming' THEN (p.full_name || CASE v_my_locale WHEN 'fr' THEN ' vous appelle en vidéo...' ELSE ' is calling you...' END)
                    ELSE CASE v_my_locale WHEN 'fr' THEN 'Vous avez une nouvelle notification.' ELSE 'You have a new notification.' END
                END,
            'createdAt', n.created_at,
            'isRead', n.is_read,
            'referenceId',
                -- AMÉLIORÉ : Gère tous les types de referenceId
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
    )
    INTO v_items
    FROM notifs n
    LEFT JOIN public.profiles p ON n.sender_id = p.id;

    -- Retourne un tableau JSON, même s'il est vide
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
                        ELSE 
                            jsonb_build_object(
                                'type', block->>'type',
                                'text', null,
                                'imageUrls', COALESCE(block->'urls', '[]'::jsonb)
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
                'websiteUrl', pd.website_url
            )
        )
    INTO v_article_data
    FROM public.wed_articles wa
    JOIN public.profiles p ON p.id = wa.linked_pro_profile_id
    LEFT JOIN public.professional_details pd ON pd.profile_id = wa.linked_pro_profile_id
    WHERE wa.is_published = true
    ORDER BY COALESCE(wa.published_at, wa.created_at) DESC
    LIMIT 1;

    RETURN COALESCE(v_article_data, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_latest_wed_article"("p_lang" "text") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."get_pending_contact_requests"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_me uuid := auth.uid();
begin
  if v_me is null then
    return jsonb_build_object('items', jsonb_build_array());
  end if;

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
          -- AJOUT CI-DESSOUS : On récupère l'ID de la room associée
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
          and (cr.pro_profile_id = v_me or cr.bride_profile_id = v_me)
        order by cr.created_at desc
      ) x
    )
  );
end;
$$;


ALTER FUNCTION "public"."get_pending_contact_requests"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_viewer_id   uuid := auth.uid();
  v_filters     jsonb;
  v_center      geometry;
  v_radius_km   float;
  v_prof_filter text[];
  -- NOUVEAU : Variables pour le filtre de budget
  v_budget_min  numeric;
  v_budget_max  numeric;
  cs            jsonb;
  c_sort_key    text;
  c_pid         uuid;
  c_idx         int;
  v_seed        text := COALESCE(p_seed, md5(random()::text));
  v_page_size2  int  := LEAST(GREATEST(COALESCE(p_page_size, 30), 1), 60);
  items         jsonb;
  next_cursor   text;
BEGIN
  -- Parse filters
  BEGIN
    v_filters := COALESCE(p_filters, '{}'::jsonb);
  EXCEPTION WHEN OTHERS THEN
    v_filters := '{}'::jsonb;
  END;

  -- Extract filter values
  IF v_filters ? 'center' AND jsonb_typeof(v_filters->'center') = 'object' THEN
    v_center := ST_SetSRID(ST_MakePoint((v_filters->'center'->>'longitude')::float, (v_filters->'center'->>'latitude')::float), 4326);
  END IF;

  v_radius_km := NULLIF(v_filters->>'radiusKm','')::float;
  IF v_radius_km IS NOT NULL THEN
    v_radius_km := GREATEST(5, LEAST(v_radius_km, 1000));
  END IF;

  IF v_filters ? 'professions' AND jsonb_typeof(v_filters->'professions') = 'array' THEN
    SELECT ARRAY(SELECT jsonb_array_elements_text(v_filters->'professions')) INTO v_prof_filter;
  END IF;

  -- NOUVEAU : Extraction des valeurs de budget du JSON
  v_budget_min := NULLIF(v_filters->>'budgetMin','')::numeric;
  v_budget_max := NULLIF(v_filters->>'budgetMax','')::numeric;


  -- Parse cursor
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
      pd.location_coords,
      pr.full_name,
      pr.avatar_url,
      pd.profession,
      pd.location_label,
      u.image_url,
      u.image_index,
      md5(u.image_url || '|' || v_seed) AS sort_key
    FROM
      public.professional_subscriptions ps
    JOIN
      public.professional_details pd ON ps.profile_id = pd.profile_id
    JOIN
      public.profiles pr ON ps.profile_id = pr.id
    CROSS JOIN LATERAL
      unnest(pd.portfolio_images) WITH ORDINALITY AS u(image_url, image_index)
    WHERE
      ps.subscription_tier IN ('premiumVisibility', 'ultimateAccess')
      AND array_length(pd.portfolio_images, 1) > 0
      AND u.image_url IS NOT NULL AND u.image_url <> ''
      AND u.image_url NOT LIKE '%thumbnail%'
      AND (
        v_prof_filter IS NULL OR
        COALESCE(array_length(v_prof_filter, 1), 0) = 0 OR
        UPPER(pd.profession::text) = ANY(v_prof_filter)
      )
      AND (
        v_center IS NULL OR
        ST_DWithin(pd.location_coords::geography, v_center::geography, COALESCE(v_radius_km, 100) * 1000)
      )
      -- MODIFIÉ : Ajout de la condition de filtre de budget
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
    WHERE p_cursor IS NULL OR (sort_key, profile_id, image_index) > (c_sort_key, c_pid, c_idx)
    ORDER BY sort_key ASC, profile_id ASC, image_index ASC
    LIMIT v_page_size2 + 1
  )
  SELECT
    (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'imageUrl',         p.image_url,
          'imageIndex',       p.image_index,
          'proProfileId',     p.profile_id,
          'proFullName',      p.full_name,
          'proAvatarUrl',     p.avatar_url,
          'proProfession',    p.profession,
          'proLocationLabel', p.location_label,
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
      ORDER BY sort_key ASC, profile_id ASC, image_index ASC
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
    LANGUAGE "plpgsql"
    SET "search_path" TO 'pg_temp', 'public'
    AS $$DECLARE
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
  v_slideshow text[]; -- NOUVELLE VARIABLE
  v_cover text;
  v_is_fav boolean := false;
  v_instagram_url text;
  v_website_url text;

  v_fixed jsonb := '[]'::jsonb;

  can_contact_by_bride boolean := false;
  can_contact_bride boolean := false;
BEGIN
  IF v_me IS NOT NULL THEN
      SELECT role INTO v_my_role FROM public.profiles WHERE id = v_me;
  END IF;

  -- pro details
  SELECT pr.full_name, pr.avatar_url,
         pd.business_name, pd.profession,
         pd.budget_min, pd.budget_max, pd.currency,
         pd.location_label, pd.description, pd.is_live,
         pd.portfolio_images,
         pd.slideshow_images, -- NOUVELLE COLONNE AJOUTÉE ICI
         pd.instagram_url,
         pd.website_url,
         pd.profile_video_url,
         ps.subscription_tier
  INTO v_full_name, v_avatar_url,
       v_business_name, v_profession,
       v_budget_min, v_budget_max, v_currency,
       v_location_label, v_description, v_is_live,
       v_portfolio,
       v_slideshow, -- NOUVELLE VARIABLE AJOUTÉE ICI
       v_instagram_url,
       v_website_url,
       v_profile_video_url,
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

  -- fixed locations
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'type','Point',
      'coordinates', jsonb_build_array(
        ST_X(fl.location_coords),
        ST_Y(fl.location_coords)
      )
    )
  ), '[]'::jsonb)
  INTO v_fixed
  FROM public.professional_fixed_locations fl
  WHERE fl.professional_profile_id = p_pro_profile_id;

  -- wishlist flag (bride viewer)
  IF v_me IS NOT NULL AND v_my_role = 'bride' THEN
    SELECT EXISTS(
      SELECT 1 FROM public.wishlist_items
      WHERE bride_profile_id = v_me
        AND professional_profile_id = p_pro_profile_id
    ) INTO v_is_fav;
  END IF;

  -- blocages
  IF v_me IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM public.user_blocks b
      WHERE (b.blocker_profile_id = v_me AND b.blocked_profile_id = p_pro_profile_id)
         OR (b.blocker_profile_id = p_pro_profile_id AND b.blocked_profile_id = v_me)
    ) INTO v_blocked;
  END IF;

  -- gating flags
  can_contact_by_bride :=
    (v_subscription_tier IN ('premiumVisibility','ultimateAccess'))
    AND v_is_live = true
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
    'portfolioImages', COALESCE(to_jsonb(v_portfolio), '[]'::jsonb),
    'slideshowImages', COALESCE(to_jsonb(v_slideshow), '[]'::jsonb), -- NOUVELLE LIGNE AJOUTÉE ICI
    'fixedLocations', v_fixed,
    'profileVideoUrl', v_profile_video_url,
    'canBeContactedByBride', can_contact_by_bride,
    'canContactBride', can_contact_bride,
    'socials', jsonb_build_object(
      'instagramUrl', v_instagram_url,
      'websiteUrl', v_website_url
    )
  );
END;$$;


ALTER FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") OWNER TO "postgres";


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
    SET "search_path" TO 'public', 'extensions'
    AS $$ declare items jsonb; begin with base as (select pcr.chat_room_id as room_id, pcr.title, pcr.cover_image_url, (select count(distinct m.profile_id) from public.chat_messages m where m.room_id = pcr.chat_room_id and m.is_deleted = false) as active_users_count from public.public_chat_rooms pcr where pcr.is_active = true and pcr.audience_role = 'bride') select jsonb_agg(jsonb_build_object('roomId', b.room_id, 'title', b.title, 'coverImageUrl', b.cover_image_url, 'activeUsersCount', coalesce(b.active_users_count,0)) order by b.title asc) into items from base b; return jsonb_build_object('items', coalesce(items, '[]'::jsonb)); end; $$;


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
    AS $$ declare v_me uuid := auth.uid(); items jsonb; begin if v_me is null then raise exception 'AUTH_REQUIRED'; end if; with me_part as (select p.room_id, p.last_read_at, p.conversation_status, r.type from public.chat_room_participants p join public.chat_rooms r on r.id = p.room_id where p.profile_id = v_me and r.is_active = true), last_msg as (select m.room_id, jsonb_build_object('id', m.id, 'type', m.message_type::text, 'content', case when m.message_type = 'text' then m.content else null end, 'attachment_url', m.attachment_url, 'created_at', m.created_at) as msg from (select distinct on (room_id) room_id, id, message_type, content, attachment_url, created_at from public.chat_messages where is_deleted = false order by room_id, created_at desc) m), unread as (select mp.room_id, count(*)::int as unread_count from public.chat_messages m join me_part mp on mp.room_id = m.room_id where m.is_deleted = false and m.profile_id <> v_me and (mp.last_read_at is null or m.created_at > mp.last_read_at) group by mp.room_id), counterpart as (select mp.room_id, jsonb_build_object('profile_id', pr.id, 'full_name', pr.full_name, 'avatar_url', pr.avatar_url, 'role', pr.role::text) as data from me_part mp join public.chat_room_participants p2 on p2.room_id = mp.room_id and p2.profile_id <> v_me join public.profiles pr on pr.id = p2.profile_id where mp.type = 'private'), pubmeta as (select mp.room_id, jsonb_build_object('public_title', pcr.title, 'public_cover', pcr.cover_image_url, 'audience_role', pcr.audience_role::text) as data from me_part mp join public.public_chat_rooms pcr on pcr.chat_room_id = mp.room_id where mp.type = 'public' and pcr.is_active = true), rows as (select mp.room_id, mp.type as room_type, mp.conversation_status::text as conversation_status, coalesce(u.unread_count, 0) as unread_count, lm.msg as last_msg, case when mp.type = 'private' then c.data else pm.data end as meta from me_part mp left join unread u on u.room_id = mp.room_id left join last_msg lm on lm.room_id = mp.room_id left join counterpart c on c.room_id = mp.room_id left join pubmeta pm on pm.room_id = mp.room_id) select jsonb_agg(jsonb_build_object('roomId', r.room_id, 'roomType', r.room_type, 'conversationStatus', r.conversation_status, 'unreadCount', r.unread_count, 'lastMessageType', coalesce(r.last_msg->>'type',''), 'lastMessageText', case when (r.last_msg->>'type') = 'text' then coalesce(r.last_msg->>'content','') when (r.last_msg->>'type') = 'image' then 'Photo' when (r.last_msg->>'type') = 'audio' then 'Audio' else '' end, 'lastMessageAt', (r.last_msg->>'created_at'), 'otherProfileId', r.meta->>'profile_id', 'otherFullName', r.meta->>'full_name', 'otherAvatarUrl', r.meta->>'avatar_url', 'otherRole', r.meta->>'role', 'publicTitle', r.meta->>'public_title', 'publicCoverUrl', r.meta->>'public_cover', 'audienceRole', r.meta->>'audience_role') order by coalesce((r.last_msg->>'created_at')::timestamptz, to_timestamp(0)) desc) into items from rows r where r.last_msg is not null or r.room_type = 'public' limit greatest(coalesce(p_limit, 50), 1); return jsonb_build_object('items', coalesce(items, '[]'::jsonb)); end; $$;


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
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT count(*)::integer
  FROM public.notifications
  WHERE profile_id = auth.uid() AND is_read = false;
$$;


ALTER FUNCTION "public"."get_unread_notifications_count"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
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
    v_my_tier := public.get_tier_of(v_me); 
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
  FROM public.public_profiles
  WHERE id = v_pin.bride_profile_id;
  
  RETURN jsonb_build_object(
    'weddingPinId', v_pin.id, 
    'brideProfileId', v_pin.bride_profile_id, 
    'locationLabel', v_pin.location_label, 
    'center', ST_AsGeoJSON(v_pin.location_coords)::jsonb, 
    'radiusKm', v_pin.radius_km, 
    'professionsNeeded', (SELECT jsonb_agg(x) FROM unnest(v_pin.professions_needed) x), 
    'eventStartDate', v_pin.event_start_date,  -- ✅ CONVERSION EN TEXT
    'eventEndDate', v_pin.event_end_date,     -- ✅ CONVERSION EN TEXT
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
            'addedAt', w.added_at
        ) ORDER BY w.added_at DESC
    )
    INTO v_items
    FROM public.wishlist_items w
    JOIN public.profiles p ON w.bride_profile_id = p.id
    WHERE w.professional_profile_id = v_me;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


ALTER FUNCTION "public"."get_wishlisted_by_brides"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_message_report"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
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


CREATE OR REPLACE FUNCTION "public"."insert_user_poi"("p_label" "text", "p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint DEFAULT NULL::smallint, "p_professions" "text"[] DEFAULT NULL::"text"[], "p_budget_min" integer DEFAULT NULL::integer, "p_budget_max" integer DEFAULT NULL::integer, "p_currency" "text" DEFAULT NULL::"text", "p_event_start_date" "date" DEFAULT NULL::"date", "p_event_end_date" "date" DEFAULT NULL::"date", "p_location_label" "text" DEFAULT ''::"text") RETURNS "uuid"
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

  -- Normalisation budget max (100k+ => NULL pour signifier "no upper bound")
  IF p_budget_max IS NOT NULL AND p_budget_max >= 100000 THEN
    v_budget_max_clean := NULL;
  ELSE
    v_budget_max_clean := p_budget_max;
  END IF;

  -- Cast des professions
  IF p_professions IS NOT NULL THEN
    v_professions := ARRAY(SELECT unnest(p_professions)::public.profession);
  END IF;

  INSERT INTO public.user_pois(
    id, bride_profile_id, label, coords, radius_km, professions,
    budget_min, budget_max, currency, event_start_date, event_end_date, location_label
  ) VALUES (
    gen_random_uuid(),
    v_me,
    NULLIF(p_label,''),
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326),
    p_radius_km,
    v_professions,
    p_budget_min,
    v_budget_max_clean,
    CASE WHEN p_currency IS NULL THEN NULL ELSE UPPER(p_currency) END,
    p_event_start_date,
    p_event_end_date,
    COALESCE(p_location_label, '')
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."insert_user_poi"("p_label" "text", "p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$ declare v_me uuid := auth.uid(); v_role public."userRole"; v_room_type text; v_audience public."userRole"; v_is_active boolean; begin if v_me is null then raise exception 'AUTH_REQUIRED'; end if; select role into v_role from public.profiles where id = v_me; if v_role <> 'bride' then raise exception 'ONLY_BRIDES_CAN_JOIN_PUBLIC_SALONS'; end if; select r.type, pcr.audience_role, pcr.is_active into v_room_type, v_audience, v_is_active from public.chat_rooms r join public.public_chat_rooms pcr on pcr.chat_room_id = r.id where r.id = p_room_id; if not found then raise exception 'PUBLIC_ROOM_NOT_FOUND'; end if; if v_room_type <> 'public' then raise exception 'ROOM_NOT_PUBLIC'; end if; if v_audience <> 'bride' then raise exception 'AUDIENCE_NOT_BRIDE'; end if; if not v_is_active then raise exception 'ROOM_INACTIVE'; end if; insert into public.chat_room_participants(room_id, profile_id, conversation_status) values (p_room_id, v_me, 'active') on conflict (room_id, profile_id) do nothing; return p_room_id; end; $$;


ALTER FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_all_notifications_as_read"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  UPDATE public.notifications
  SET is_read = true
  WHERE profile_id = auth.uid() AND is_read = false;
$$;


ALTER FUNCTION "public"."mark_all_notifications_as_read"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  UPDATE public.notifications
  SET is_read = true
  WHERE id = p_notification_id AND profile_id = auth.uid();
$$;


ALTER FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_video_sessions_missed"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  UPDATE public.video_sessions SET status='missed'
  WHERE status='pending' AND created_at < now() - interval '1 minute';
END;
$$;


ALTER FUNCTION "public"."mark_video_sessions_missed"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_auth_user_created"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  -- ... (le code existant pour insérer dans profiles et notification_settings reste le même)
  INSERT INTO public.profiles(id, role, full_name)
  VALUES (
    NEW.id,
    COALESce(NEW.raw_user_meta_data->>'role','bride')::public."userRole",
    NEW.raw_user_meta_data->>'full_name'
  );

  INSERT INTO public.notification_settings(profile_id, notification_type, in_app_enabled, push_enabled)
  SELECT NEW.id, nt::public."notificationType", true, true
  FROM unnest(ARRAY[
    'chatMessage','connectionRequest','connectionRequestAccepted','connectionRequestDeclined',
    'wishlistAdd','professionalAlert','professionalAlertReminder24h',
    'videoIncoming','wedPublished','weddingPinMatch'
  ]) AS nt;

  -- Met à jour l'insertion dans user_preferences pour inclure la devise
  INSERT INTO public.user_preferences(profile_id, distance_unit, default_radius_km, default_locale, map_toggles, currency)
  VALUES (NEW.id, 'km', 20, NULL, '{}'::jsonb, 'EUR') -- Ajout de la devise par défaut
  ON CONFLICT (profile_id) DO UPDATE SET currency = EXCLUDED.currency; -- S'assure que même les anciens profils l'obtiennent

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_auth_user_created"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_first_message_pro_to_bride"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_participants uuid[];
  v_pro uuid;
  v_bride uuid;
  v_has_any boolean;
  v_pending_req uuid;
  v_pro_role public."userRole";
  v_bride_role public."userRole";
begin
  -- On ne s'intéresse qu'à l'insertion de nouveaux messages
  if TG_OP <> 'INSERT' then
    return NEW;
  end if;

  -- Récupérer les 2 participants de la room
  select array_agg(profile_id) into v_participants
    from public.chat_room_participants
   where room_id = NEW.room_id;

  -- S'assurer que c'est bien une conversation privée (2 participants)
  if v_participants is null or array_length(v_participants,1) <> 2 then
    return NEW;
  end if;

  -- Identifier qui est le Pro et qui est la Bride
  select p.id, p.role into v_pro, v_pro_role
    from public.profiles p
   where p.id = ANY(v_participants) and p.role = 'professional'
   limit 1;

  select p.id, p.role into v_bride, v_bride_role
    from public.profiles p
   where p.id = ANY(v_participants) and p.role = 'bride'
   limit 1;

  -- Si ce n'est pas une conversation Pro <-> Bride, on ne fait rien
  if v_pro is null or v_bride is null then
    return NEW;
  end if;

  -- Vérifier s'il y a déjà d'autres messages dans cette room
  select exists(
    select 1 from public.chat_messages m
    where m.room_id = NEW.room_id
      and m.id <> NEW.id
  ) into v_has_any;

  -- LOGIQUE POUR LE TOUT PREMIER MESSAGE
  if not v_has_any then
    -- Si la Bride envoie le premier message
    if NEW.profile_id = v_bride then
      if NEW.message_type <> 'text' then
        raise exception 'FIRST_MESSAGE_TEXT_ONLY';
      end if;
      return NEW;
    end if;

    -- Si le Pro envoie le premier message
    if NEW.profile_id = v_pro then
      if NEW.message_type <> 'text' then
        raise exception 'FIRST_MESSAGE_TEXT_ONLY';
      end if;
      
      -- Créer la demande de contact
      insert into public.connection_requests(
        pro_profile_id, bride_profile_id, initiator_id, initial_message, status, source
      ) values (
        v_pro, v_bride, v_pro, left(coalesce(NEW.content,''), 1000), 'pending', 'map' -- 'map' par défaut
      );

      -- Mettre la conversation en attente pour les deux
      update public.chat_room_participants
         set conversation_status = 'pending'
       where room_id = NEW.room_id;
    end if;
  
  -- LOGIQUE POUR LES MESSAGES SUIVANTS
  else
    -- Si le Pro essaie d'envoyer un autre message alors qu'une demande est en attente
    if NEW.profile_id = v_pro then
      select id into v_pending_req
      from public.connection_requests
      where pro_profile_id = v_pro
        and bride_profile_id = v_bride
        and status = 'pending'
      limit 1;
      
      if v_pending_req is not null then
        -- On bloque l'envoi du message
        raise exception 'PENDING_REQUEST_LIMIT';
      end if;
    end if;
  end if;

  return NEW;
end
$$;


ALTER FUNCTION "public"."on_first_message_pro_to_bride"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
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
  v_conv_status_other public."conversationStatus";
  v_status text;
  v_viewer_is_reviewer boolean := false;
begin
  if v_me is null then
    return jsonb_build_object('status','error','reason','AUTH_REQUIRED');
  end if;
  if p_target is null then
    return jsonb_build_object('status','error','reason','TARGET_REQUIRED');
  end if;
  if v_me = p_target then
    return jsonb_build_object('status','notAllowed','reason','SELF_CONTACT');
  end if;

  select role into v_init_role from public.profiles where id = v_me;
  select role into v_targ_role from public.profiles where id = p_target;

  if v_init_role is null or v_targ_role is null then
    return jsonb_build_object('status','error','reason','MISSING_PROFILE');
  end if;

  select exists(
    select 1 from public.user_blocks b
     where (b.blocker_profile_id = v_me and b.blocked_profile_id = p_target)
        or (b.blocker_profile_id = p_target and b.blocked_profile_id = v_me)
  ) into v_blocked;

  if v_blocked then
    return jsonb_build_object('status','blocked','otherProfileId', p_target);
  end if;

  -- Chercher une room privée existante
  select r.id
    into v_room_id
  from public.chat_rooms r
  join public.chat_room_participants p1 on p1.room_id = r.id and p1.profile_id = v_me
  join public.chat_room_participants p2 on p2.room_id = r.id and p2.profile_id = p_target
  where r.type = 'private'
  limit 1;

  -- Si aucune room n'existe, en créer une selon les règles
  if v_room_id is null then
    if v_init_role = 'professional' and v_targ_role = 'bride' then
      select public.get_tier_of(v_me) into v_init_tier;
      if v_init_tier not in ('premiumVisibility','ultimateAccess') then
        return jsonb_build_object('status','notAllowed','reason','INSUFFICIENT_TIER');
      end if;
      insert into public.chat_rooms(type) values ('private') returning id into v_room_id;
      insert into public.chat_room_participants(room_id, profile_id, conversation_status)
      values (v_room_id, v_me, 'active'), (v_room_id, p_target, 'active');
      v_first_text_only := true;
      v_limit_single := true;
      v_status := 'roomReady';
    elsif v_init_role = 'bride' and v_targ_role = 'professional' then
      insert into public.chat_rooms(type) values ('private') returning id into v_room_id;
      insert into public.chat_room_participants(room_id, profile_id, conversation_status)
      values (v_room_id, v_me, 'active'), (v_room_id, p_target, 'active');
      v_first_text_only := true;
      v_limit_single := false;
      v_status := 'roomReady';
    elsif v_init_role = 'professional' and v_targ_role = 'professional' then
      select public.get_tier_of(v_me) into v_init_tier;
      if v_init_tier not in ('premiumVisibility','ultimateAccess') then
        return jsonb_build_object('status','notAllowed','reason','INSUFFICIENT_TIER');
      end if;
      insert into public.chat_rooms(type) values ('private') returning id into v_room_id;
      insert into public.chat_room_participants(room_id, profile_id, conversation_status)
      values (v_room_id, v_me, 'active'), (v_room_id, p_target, 'active');
      v_first_text_only := false;
      v_limit_single := false;
      v_status := 'roomReady';
    else
      return jsonb_build_object('status','notAllowed','reason','UNSUPPORTED_CONTACT');
    end if;
  else
    v_status := 'roomReady';
  end if;

  -- Vérifier si la room est vide (aucun message)
  select count(*) = 0
    from public.chat_messages
   where room_id = v_room_id
     and is_deleted = false
    into v_is_room_empty;

  -- Vérifier s'il y a une demande de contact en attente pour cette relation
  select cr.id
    into v_req_id
  from public.connection_requests cr
  where cr.status = 'pending'
    and ((cr.pro_profile_id = v_me and cr.bride_profile_id = p_target)
      or (cr.pro_profile_id = p_target and cr.bride_profile_id = v_me))
  limit 1;

  if v_req_id is not null then
    v_status := 'requestPending';
    v_viewer_is_reviewer := (v_init_role = 'bride');
  end if;

  -- Récupérer les infos de l'autre profil
  select full_name, avatar_url, role
    into v_other_full_name, v_other_avatar_url, v_other_role
  from public.profiles
  where id = p_target;

  -- Récupérer le statut de la conversation pour l'utilisateur actuel
  select p1.conversation_status
    into v_conv_status_me
  from public.chat_room_participants p1
  where p1.room_id = v_room_id and p1.profile_id = v_me
  limit 1;

  -- Construire la réponse finale
  return jsonb_build_object(
    'status', v_status,
    'roomId', v_room_id,
    'requestId', v_req_id,
    'otherProfileId', p_target,
    'otherFullName', coalesce(v_other_full_name,''),
    'otherAvatarUrl', coalesce(v_other_avatar_url,''),
    'otherRole', v_other_role,
    'isPublic', false,
    'isRoomEmpty', v_is_room_empty,
    'firstMessageTextOnly', v_first_text_only,
    'limitToSingleInitialMessage', v_limit_single,
    'viewerIsReviewer', v_viewer_is_reviewer,
    'conversationStatus', coalesce(v_conv_status_me, 'active')
  );
end;
$$;


ALTER FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."outbox_on_chat_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_room_type text;
BEGIN
  SELECT type INTO v_room_type
  FROM public.chat_rooms
  WHERE id = NEW.room_id;

  -- n’enqueuer que pour les rooms privés (pas de push sur salons publics)
  IF v_room_type <> 'private' THEN
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
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_actor uuid := auth.uid();  -- peut être NULL si service/cron
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
      IF NEW.status = 'accepted' THEN
        v_event_type := 'connectionRequestAccepted';
      ELSIF NEW.status = 'declined' THEN
        v_event_type := 'connectionRequestDeclined';
      ELSE
        RETURN NEW; -- autres statuts non notifiés
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

      -- Même recherche de room privée pour Accepted/Declined
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
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  -- Insère un événement "videoIncoming" dans la table outbox
  INSERT INTO public.notifications_outbox(event_type, payload, event_key)
  VALUES (
    'videoIncoming',
    jsonb_build_object(
      'video_session_id', NEW.id,
      'agora_channel_name', NEW.agora_channel_name,
      'sender_profile_id', NEW.initiator_id,
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
    SET "search_path" TO 'public', 'pg_temp'
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
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_bbox geometry;

  v_me uuid := auth.uid();
  v_role public."userRole" := public.get_my_role();
  v_is_pro boolean := (v_role = 'professional');
  v_my_tier public."subscriptionTierType" := public.get_my_tier();
  v_my_profession public.profession;

  v_prof_filter text[];
  v_currency text;
  v_budget_min_eur numeric;
  v_budget_max_eur numeric;

  t_show_pros boolean := COALESCE((p_filters->>'showPros')::boolean, true);
  t_show_pro_recent boolean := COALESCE((p_filters->>'showProRecent')::boolean, true);
  t_show_fixed boolean := COALESCE((p_filters->>'showFixedLocations')::boolean, true);
  t_show_poi boolean := COALESCE((p_filters->>'showBridePrivatePoi')::boolean, true);
  t_show_alerts boolean := COALESCE((p_filters->>'showProAlerts')::boolean, true);
  t_show_pins boolean := COALESCE((p_filters->>'showWeddingPins')::boolean, true);
  t_only_my_prof_pins boolean := COALESCE((p_filters->>'showOnlyMyProfessionPins')::boolean, false);

  v_limit_each int;

  out_markers jsonb := '[]'::jsonb;
  out_overlays jsonb := '[]'::jsonb;

  t0 timestamptz := clock_timestamp();
  ms_pros int; ms_fixed int; ms_recent int; ms_alerts int; ms_pins int; ms_poi int;
BEGIN
  -- BBOX seule (viewport-only)
  v_bbox := ST_MakeEnvelope(
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

  -- 1) Pros live (point dans viewport)
  IF t_show_pros THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', pd.profile_id,
          'type', 'professional',
          'position', ST_AsGeoJSON(pd.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url,
            'borderColorHex', public.get_color_for_profession(pd.profession)
          )
        ) as marker_data
        FROM public.professional_details pd
        JOIN public.profiles pr ON pr.id = pd.profile_id
        WHERE pd.is_live = true
          AND ST_Intersects(pd.location_coords, v_bbox)
          AND (COALESCE(array_length(v_prof_filter,1),0) = 0 OR pd.profession::text = ANY(v_prof_filter))
          AND (
            (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
            OR (pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
              AND (v_budget_min_eur IS NULL OR pd.budget_max_eur >= v_budget_min_eur)
              AND (v_budget_max_eur IS NULL OR pd.budget_min_eur <= v_budget_max_eur))
          )
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_pros := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int;

  -- 2) Fixed locations (point dans viewport)
  IF t_show_fixed THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', pd.profile_id,
          'type', 'fixedLocation',
          'position', ST_AsGeoJSON(fl.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url,
            'borderColorHex', public.get_color_for_profession(pd.profession)
          )
        ) AS marker_data
        FROM public.professional_fixed_locations fl
        JOIN public.professional_details pd ON pd.profile_id = fl.professional_profile_id
        JOIN public.profiles pr ON pr.id = fl.professional_profile_id
        WHERE pd.is_live = true
          AND ST_Intersects(fl.location_coords, v_bbox)
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
  ms_fixed := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - ms_pros;

  -- 3) Pro recent (point dans viewport)
  IF t_show_pro_recent THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', rl.profile_id,
          'type', 'proRecent',
          'position', ST_AsGeoJSON(rl.coords_approx)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url,
            'borderColorHex', public.get_color_for_profession(pd.profession)
          )
        ) AS marker_data
        FROM public.pro_recent_locations rl
        JOIN public.profiles pr ON pr.id = rl.profile_id
        JOIN public.professional_details pd ON pd.profile_id = rl.profile_id
        WHERE rl.is_opt_in = true
          AND rl.last_seen_at >= now() - interval '7 days'
          AND ST_Intersects(rl.coords_approx, v_bbox)
          AND (COALESCE(array_length(v_prof_filter,1),0) = 0 OR pd.profession::text = ANY(v_prof_filter))
          AND (
            (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
            OR (pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
              AND (v_budget_min_eur IS NULL OR pd.budget_max_eur >= v_budget_min_eur)
              AND (v_budget_max_eur IS NULL OR pd.budget_min_eur <= v_budget_max_eur))
          )
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_recent := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed);

  -- 4) Alerts (point dans viewport) + avatar auteur (pros only)
  IF v_is_pro AND t_show_alerts THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', a.id,
          'type', 'professionalAlert',
          'position', ST_AsGeoJSON(a.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'isOwn', a.author_profile_id = v_me,
            'avatarUrl', pr.avatar_url
          )
        ) AS marker_data
        FROM public.professional_alerts a
        JOIN public.profiles pr ON pr.id = a.author_profile_id
        WHERE a.status = 'active'
          AND a.is_deleted = false
          AND ST_Intersects(a.location_coords, v_bbox)
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_alerts := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed + ms_recent);

  -- 5) Wedding Pins (point dans viewport, SANS overlays)
  IF t_show_pins THEN
    WITH visible_pins AS (
      SELECT
        wp.id,
        wp.bride_profile_id,
        wp.location_coords,
        wp.professions_needed,
        wp.budget_min_eur,
        wp.budget_max_eur,
        pr.avatar_url as bride_avatar_url,
        wp.created_at
      FROM public.wedding_pins wp
      JOIN public.profiles pr ON pr.id = wp.bride_profile_id
      WHERE wp.is_deleted = false
        AND wp.is_active = true
        AND (wp.event_end_date IS NULL OR wp.event_end_date >= CURRENT_DATE)
        AND ST_Intersects(wp.location_coords, v_bbox)
        AND (
          (NOT v_is_pro AND v_me IS NOT NULL AND wp.bride_profile_id = v_me)
          OR
          (
            v_is_pro
            AND v_my_tier IN ('premiumVisibility','ultimateAccess')
            AND (
              (v_budget_min_eur IS NULL AND v_budget_max_eur IS NULL)
              OR (wp.budget_min_eur IS NOT NULL AND wp.budget_max_eur IS NOT NULL
                AND (v_budget_min_eur IS NULL OR wp.budget_max_eur >= v_budget_min_eur)
                AND (v_budget_max_eur IS NULL OR wp.budget_min_eur <= v_budget_max_eur))
            )
            AND (
              COALESCE(array_length(v_prof_filter,1),0) = 0
              OR (v_my_profession IS NOT NULL AND wp.professions_needed @> ARRAY[v_my_profession])
              OR (exists (select 1 from unnest(wp.professions_needed) p where p::text = ANY(v_prof_filter)))
            )
          )
        )
      ORDER BY wp.created_at DESC
      LIMIT v_limit_each
    )
    SELECT
      out_markers || COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'id', vp.id,
            'type', 'weddingPin',
            'position', ST_AsGeoJSON(vp.location_coords)::jsonb,
            'styleInfo', jsonb_build_object(
              'isOwn', vp.bride_profile_id = v_me,
              'avatarUrl', vp.bride_avatar_url
            )
          )
        ) FILTER (WHERE vp.id IS NOT NULL),
        '[]'::jsonb
      )
    INTO out_markers
    FROM visible_pins vp;
  END IF;
  ms_pins := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed + ms_recent + ms_alerts);

  -- 6) POIs privés (point dans viewport)
  IF (NOT v_is_pro) AND t_show_poi AND v_me IS NOT NULL THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', p.id,
          'type', 'poiPrivate',
          'position', ST_AsGeoJSON(p.coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url
          )
        ) AS marker_data
        FROM public.user_pois p
        JOIN public.profiles pr ON pr.id = v_me
        WHERE p.bride_profile_id = v_me
          AND ST_Intersects(p.coords, v_bbox)
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_poi := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed + ms_recent + ms_alerts + ms_pins);

  RETURN jsonb_build_object(
    'markers', out_markers,
    'overlays', out_overlays,
    'debugStats', format(
      'ms: total=%s | pros=%s, fixed=%s, recent=%s, alerts=%s, pins=%s, poi=%s',
      EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int, ms_pros, ms_fixed, ms_recent, ms_alerts, ms_pins, ms_poi
    )
  );
END;
$$;


ALTER FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) OWNER TO "postgres";


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
    SET "search_path" TO 'public', 'pg_temp'
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
  -- Only sync if is_live changed to true
  IF NEW.is_live = true AND (OLD.is_live IS DISTINCT FROM NEW.is_live) THEN
    -- Call edge function asynchronously using pg_net
    PERFORM
      net.http_post(
        url := 'https://odzkhcplevcqbuhzqsmq.supabase.co/functions/v1/sync-professional-to-app',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kemtoY3BsZXZjcWJ1aHpxc21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2MDY2ODQsImV4cCI6MjA3MzE4MjY4NH0.j8KEBqFoR3aHp2mDpBlf025iEQyiv888FFBGwi_ss-8'
        ),
        body := jsonb_build_object('profile_id', NEW.profile_id)
      );
    
    RAISE NOTICE 'Sync triggered for profile %', NEW.profile_id;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_professional_on_validation"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."sync_professional_on_validation"() IS 'Automatically syncs professional data to the app when is_live is set to true';



CREATE OR REPLACE FUNCTION "public"."sync_profile_to_professional_details"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."user_pois_history_logger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.user_pois_history(poi_id, action, old_values, new_values, changed_by)
    VALUES (NEW.id, 'insert', NULL, to_jsonb(NEW), auth.uid());
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO public.user_pois_history(poi_id, action, old_values, new_values, changed_by)
    VALUES (NEW.id, 'update', to_jsonb(OLD), to_jsonb(NEW), auth.uid());
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO public.user_pois_history(poi_id, action, old_values, new_values, changed_by)
    VALUES (OLD.id, 'delete', to_jsonb(OLD), NULL, auth.uid());
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."user_pois_history_logger"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."wedding_pins_history_logger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'pg_temp'
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
    SET "search_path" TO 'public', 'pg_temp'
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


CREATE OR REPLACE FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_prefix_hierarchy_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix_hierarchy_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."enforce_bucket_name_length"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION "storage"."enforce_bucket_name_length"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION "storage"."extension"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION "storage"."filename"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION "storage"."foldername"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_level"("name" "text") RETURNS integer
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION "storage"."get_level"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_prefix"("name" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION "storage"."get_prefix"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_prefixes"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION "storage"."get_prefixes"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION "storage"."get_size_by_bucket"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "next_key_token" "text" DEFAULT ''::"text", "next_upload_token" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "id" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "next_key_token" "text", "next_upload_token" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "start_after" "text" DEFAULT ''::"text", "next_token" "text" DEFAULT ''::"text") RETURNS TABLE("name" "text", "id" "uuid", "metadata" "jsonb", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "start_after" "text", "next_token" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_delete_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_insert_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_insert_prefix_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_update_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_level_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_level_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_prefix_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."operation"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION "storage"."operation"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."prefixes_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."prefixes_delete_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."prefixes_insert_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."prefixes_insert_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "start_after" "text" DEFAULT ''::"text", "sort_order" "text" DEFAULT 'asc'::"text", "sort_column" "text" DEFAULT 'name'::"text", "sort_column_after" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer, "levels" integer, "start_after" "text", "sort_order" "text", "sort_column" "text", "sort_column_after" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION "storage"."update_updated_at_column"() OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" json,
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE "auth"."audit_log_entries" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';



CREATE TABLE IF NOT EXISTS "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL,
    "auth_code_issued_at" timestamp with time zone
);


ALTER TABLE "auth"."flow_state" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';



CREATE TABLE IF NOT EXISTS "auth"."identities" (
    "provider_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "auth"."identities" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';



COMMENT ON COLUMN "auth"."identities"."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';



CREATE TABLE IF NOT EXISTS "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."instances" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';



CREATE TABLE IF NOT EXISTS "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);


ALTER TABLE "auth"."mfa_amr_claims" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';



CREATE TABLE IF NOT EXISTS "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL,
    "otp_code" "text",
    "web_authn_session_data" "jsonb"
);


ALTER TABLE "auth"."mfa_challenges" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';



CREATE TABLE IF NOT EXISTS "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "phone" "text",
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" "jsonb",
    "web_authn_aaguid" "uuid"
);


ALTER TABLE "auth"."mfa_factors" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';



CREATE TABLE IF NOT EXISTS "auth"."oauth_authorizations" (
    "id" "uuid" NOT NULL,
    "authorization_id" "text" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "redirect_uri" "text" NOT NULL,
    "scope" "text" NOT NULL,
    "state" "text",
    "resource" "text",
    "code_challenge" "text",
    "code_challenge_method" "auth"."code_challenge_method",
    "response_type" "auth"."oauth_response_type" DEFAULT 'code'::"auth"."oauth_response_type" NOT NULL,
    "status" "auth"."oauth_authorization_status" DEFAULT 'pending'::"auth"."oauth_authorization_status" NOT NULL,
    "authorization_code" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:03:00'::interval) NOT NULL,
    "approved_at" timestamp with time zone,
    CONSTRAINT "oauth_authorizations_authorization_code_length" CHECK (("char_length"("authorization_code") <= 255)),
    CONSTRAINT "oauth_authorizations_code_challenge_length" CHECK (("char_length"("code_challenge") <= 128)),
    CONSTRAINT "oauth_authorizations_expires_at_future" CHECK (("expires_at" > "created_at")),
    CONSTRAINT "oauth_authorizations_redirect_uri_length" CHECK (("char_length"("redirect_uri") <= 2048)),
    CONSTRAINT "oauth_authorizations_resource_length" CHECK (("char_length"("resource") <= 2048)),
    CONSTRAINT "oauth_authorizations_scope_length" CHECK (("char_length"("scope") <= 4096)),
    CONSTRAINT "oauth_authorizations_state_length" CHECK (("char_length"("state") <= 4096))
);


ALTER TABLE "auth"."oauth_authorizations" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."oauth_clients" (
    "id" "uuid" NOT NULL,
    "client_secret_hash" "text",
    "registration_type" "auth"."oauth_registration_type" NOT NULL,
    "redirect_uris" "text" NOT NULL,
    "grant_types" "text" NOT NULL,
    "client_name" "text",
    "client_uri" "text",
    "logo_uri" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone,
    "client_type" "auth"."oauth_client_type" DEFAULT 'confidential'::"auth"."oauth_client_type" NOT NULL,
    CONSTRAINT "oauth_clients_client_name_length" CHECK (("char_length"("client_name") <= 1024)),
    CONSTRAINT "oauth_clients_client_uri_length" CHECK (("char_length"("client_uri") <= 2048)),
    CONSTRAINT "oauth_clients_logo_uri_length" CHECK (("char_length"("logo_uri") <= 2048))
);


ALTER TABLE "auth"."oauth_clients" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."oauth_consents" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "scopes" "text" NOT NULL,
    "granted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "revoked_at" timestamp with time zone,
    CONSTRAINT "oauth_consents_revoked_after_granted" CHECK ((("revoked_at" IS NULL) OR ("revoked_at" >= "granted_at"))),
    CONSTRAINT "oauth_consents_scopes_length" CHECK (("char_length"("scopes") <= 2048)),
    CONSTRAINT "oauth_consents_scopes_not_empty" CHECK (("char_length"(TRIM(BOTH FROM "scopes")) > 0))
);


ALTER TABLE "auth"."oauth_consents" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."one_time_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_type" "auth"."one_time_token_type" NOT NULL,
    "token_hash" "text" NOT NULL,
    "relates_to" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "one_time_tokens_token_hash_check" CHECK (("char_length"("token_hash") > 0))
);


ALTER TABLE "auth"."one_time_tokens" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


ALTER TABLE "auth"."refresh_tokens" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';



CREATE SEQUENCE IF NOT EXISTS "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNER TO "supabase_auth_admin";


ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";



CREATE TABLE IF NOT EXISTS "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" "text",
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);


ALTER TABLE "auth"."saml_providers" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';



CREATE TABLE IF NOT EXISTS "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);


ALTER TABLE "auth"."saml_relay_states" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';



CREATE TABLE IF NOT EXISTS "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


ALTER TABLE "auth"."schema_migrations" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';



CREATE TABLE IF NOT EXISTS "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text",
    "oauth_client_id" "uuid"
);


ALTER TABLE "auth"."sessions" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';



COMMENT ON COLUMN "auth"."sessions"."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';



CREATE TABLE IF NOT EXISTS "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);


ALTER TABLE "auth"."sso_domains" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';



CREATE TABLE IF NOT EXISTS "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "disabled" boolean,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);


ALTER TABLE "auth"."sso_providers" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';



COMMENT ON COLUMN "auth"."sso_providers"."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';



CREATE TABLE IF NOT EXISTS "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';



COMMENT ON COLUMN "auth"."users"."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';



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
    "source" "public"."connectionRequestSource" NOT NULL,
    "source_id" "uuid",
    "initial_message" "text",
    "status" "public"."connectionRequestStatus" DEFAULT 'pending'::"public"."connectionRequestStatus" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "responded_at" timestamp with time zone,
    "initiator_id" "uuid" NOT NULL,
    CONSTRAINT "connection_requests_initial_message_check" CHECK (("char_length"("initial_message") <= 1000)),
    CONSTRAINT "connection_requests_initiator_check" CHECK ((("initiator_id" = "pro_profile_id") OR ("initiator_id" = "bride_profile_id")))
);


ALTER TABLE "public"."connection_requests" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."pro_recent_locations" (
    "profile_id" "uuid" NOT NULL,
    "last_seen_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_opt_in" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."pro_recent_locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professional_alerts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "author_profile_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "radius_km" smallint NOT NULL,
    "duration_hours" smallint NOT NULL,
    "status" "public"."alertStatus" DEFAULT 'active'::"public"."alertStatus" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "reminder_sent" boolean DEFAULT false NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "location_label" "text" DEFAULT ''::"text" NOT NULL,
    "motif_code" "text",
    CONSTRAINT "professional_alerts_duration_hours_check" CHECK ((("duration_hours" >= 1) AND ("duration_hours" <= 720))),
    CONSTRAINT "professional_alerts_message_check" CHECK ((("char_length"("message") >= 3) AND ("char_length"("message") <= 2000))),
    CONSTRAINT "professional_alerts_radius_km_check" CHECK ((("radius_km" >= 1) AND ("radius_km" <= 100))),
    CONSTRAINT "professional_alerts_title_check" CHECK ((("char_length"("title") >= 3) AND ("char_length"("title") <= 120)))
);


ALTER TABLE "public"."professional_alerts" OWNER TO "postgres";


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
    "location_coords" "extensions"."geometry"(Point,4326)
);

ALTER TABLE ONLY "public"."professional_details" REPLICA IDENTITY FULL;


ALTER TABLE "public"."professional_details" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professional_fixed_locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "professional_profile_id" "uuid" NOT NULL,
    "label" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "location_coords" "extensions"."geometry"(Point,4326)
);


ALTER TABLE "public"."professional_fixed_locations" OWNER TO "postgres";


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
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."public_chat_rooms" (
    "chat_room_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "cover_image_url" "text",
    "audience_role" "public"."userRole" DEFAULT 'bride'::"public"."userRole" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."public_chat_rooms" OWNER TO "postgres";


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
    CONSTRAINT "replays_thumbnail_url_check" CHECK (("thumbnail_url" ~* '^https?://.+'::"text")),
    CONSTRAINT "replays_youtube_url_check" CHECK (("youtube_url" ~* '^https?://(www\.)?(youtube\.com|youtu\.be)/.+'::"text"))
);


ALTER TABLE "public"."replays" OWNER TO "postgres";


COMMENT ON COLUMN "public"."replays"."is_featured" IS 'Si true, ce replay apparaîtra en haut de la page Replay.';



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
    "professional_profile_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "subject" "text" NOT NULL,
    "message" "text" NOT NULL,
    "admin_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "resolved_at" timestamp with time zone,
    CONSTRAINT "support_tickets_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'resolved'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."support_tickets" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."user_pois" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bride_profile_id" "uuid" NOT NULL,
    "label" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "radius_km" smallint,
    "professions" "public"."profession"[],
    "budget_min" integer,
    "budget_max" integer,
    "currency" "text",
    "event_start_date" "date",
    "event_end_date" "date",
    "location_label" "text" DEFAULT ''::"text" NOT NULL,
    CONSTRAINT "user_poi_dates_chk" CHECK ((("event_end_date" IS NULL) OR ("event_start_date" IS NULL) OR ("event_end_date" >= "event_start_date"))),
    CONSTRAINT "user_poi_radius_chk" CHECK ((("radius_km" IS NULL) OR ("radius_km" = ANY (ARRAY[5, 10, 20, 50, 100]))))
);


ALTER TABLE "public"."user_pois" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_pois_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "poi_id" "uuid",
    "action" "text" NOT NULL,
    "old_values" "jsonb",
    "new_values" "jsonb",
    "changed_by" "uuid",
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "user_pois_history_action_check" CHECK (("action" = ANY (ARRAY['insert'::"text", 'update'::"text", 'delete'::"text"])))
);


ALTER TABLE "public"."user_pois_history" OWNER TO "postgres";


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
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."wed_articles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wedding_pins" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bride_profile_id" "uuid" NOT NULL,
    "radius_km" smallint DEFAULT 20 NOT NULL,
    "professions_needed" "public"."profession"[],
    "budget_brackets" smallint[],
    "event_start_date" "date",
    "event_end_date" "date",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "location_label" "text" DEFAULT ''::"text" NOT NULL,
    "budget_min" integer,
    "budget_max" integer,
    "currency" "text",
    "budget_min_eur" numeric,
    "budget_max_eur" numeric,
    "is_deleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "wedding_pin_dates_chk" CHECK ((("event_end_date" IS NULL) OR ("event_start_date" IS NULL) OR ("event_end_date" >= "event_start_date"))),
    CONSTRAINT "wedding_pins_radius_km_check" CHECK (("radius_km" = ANY (ARRAY[5, 10, 20, 50, 100])))
);


ALTER TABLE "public"."wedding_pins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wedding_pins_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "wedding_pin_id" "uuid",
    "action" "text" NOT NULL,
    "old_values" "jsonb",
    "new_values" "jsonb",
    "changed_by" "uuid",
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "wedding_pins_history_action_check" CHECK (("action" = ANY (ARRAY['insert'::"text", 'update'::"text", 'delete'::"text"])))
);


ALTER TABLE "public"."wedding_pins_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wishlist_items" (
    "bride_profile_id" "uuid" NOT NULL,
    "professional_profile_id" "uuid" NOT NULL,
    "added_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."wishlist_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" "text"[],
    "owner_id" "text",
    "type" "storage"."buckettype" DEFAULT 'STANDARD'::"storage"."buckettype" NOT NULL
);


ALTER TABLE "storage"."buckets" OWNER TO "supabase_storage_admin";


COMMENT ON COLUMN "storage"."buckets"."owner" IS 'Field is deprecated, use owner_id instead';



CREATE TABLE IF NOT EXISTS "storage"."buckets_analytics" (
    "id" "text" NOT NULL,
    "type" "storage"."buckettype" DEFAULT 'ANALYTICS'::"storage"."buckettype" NOT NULL,
    "format" "text" DEFAULT 'ICEBERG'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."buckets_analytics" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "storage"."migrations" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."objects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED,
    "version" "text",
    "owner_id" "text",
    "user_metadata" "jsonb",
    "level" integer
);


ALTER TABLE "storage"."objects" OWNER TO "supabase_storage_admin";


COMMENT ON COLUMN "storage"."objects"."owner" IS 'Field is deprecated, use owner_id instead';



CREATE TABLE IF NOT EXISTS "storage"."prefixes" (
    "bucket_id" "text" NOT NULL,
    "name" "text" NOT NULL COLLATE "pg_catalog"."C",
    "level" integer GENERATED ALWAYS AS ("storage"."get_level"("name")) STORED NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "storage"."prefixes" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads" (
    "id" "text" NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" "text" NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "version" "text" NOT NULL,
    "owner_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_metadata" "jsonb"
);


ALTER TABLE "storage"."s3_multipart_uploads" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads_parts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "upload_id" "text" NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "etag" "text" NOT NULL,
    "owner_id" "text",
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."s3_multipart_uploads_parts" OWNER TO "supabase_storage_admin";


ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_09" FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');



ALTER TABLE ONLY "public"."notifications" ATTACH PARTITION "public"."notifications_2025_10" FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');



ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."chat_messages" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."chat_messages_id_seq"'::"regclass");



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");



ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");



ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."oauth_authorizations"
    ADD CONSTRAINT "oauth_authorizations_authorization_code_key" UNIQUE ("authorization_code");



ALTER TABLE ONLY "auth"."oauth_authorizations"
    ADD CONSTRAINT "oauth_authorizations_authorization_id_key" UNIQUE ("authorization_id");



ALTER TABLE ONLY "auth"."oauth_authorizations"
    ADD CONSTRAINT "oauth_authorizations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."oauth_consents"
    ADD CONSTRAINT "oauth_consents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."oauth_consents"
    ADD CONSTRAINT "oauth_consents_user_client_unique" UNIQUE ("user_id", "client_id");



ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");



ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");



ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."alert_motifs"
    ADD CONSTRAINT "alert_motifs_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."bride_details"
    ADD CONSTRAINT "bride_details_pkey" PRIMARY KEY ("profile_id");



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



ALTER TABLE ONLY "public"."notifications_outbox"
    ADD CONSTRAINT "notifications_outbox_event_key_key" UNIQUE ("event_key");



ALTER TABLE ONLY "public"."notifications_outbox"
    ADD CONSTRAINT "notifications_outbox_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pro_recent_locations"
    ADD CONSTRAINT "pro_recent_locations_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professional_details"
    ADD CONSTRAINT "professional_details_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."professional_fixed_locations"
    ADD CONSTRAINT "professional_fixed_locations_pkey" PRIMARY KEY ("id");



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



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_pkey" PRIMARY KEY ("blocker_profile_id", "blocked_profile_id");



ALTER TABLE ONLY "public"."user_legal_acceptances"
    ADD CONSTRAINT "user_legal_acceptances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_pois_history"
    ADD CONSTRAINT "user_pois_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_pois"
    ADD CONSTRAINT "user_pois_pkey" PRIMARY KEY ("id");



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



ALTER TABLE ONLY "public"."wedding_pins_history"
    ADD CONSTRAINT "wedding_pins_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wedding_pins"
    ADD CONSTRAINT "wedding_pins_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_pkey" PRIMARY KEY ("bride_profile_id", "professional_profile_id");



ALTER TABLE ONLY "storage"."buckets_analytics"
    ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");



ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_pkey" PRIMARY KEY ("bucket_id", "level", "name");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");



CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");



CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");



CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");



CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);



CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");



COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';



CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");



CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");



CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");



CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);



CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");



CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");



CREATE INDEX "oauth_auth_pending_exp_idx" ON "auth"."oauth_authorizations" USING "btree" ("expires_at") WHERE ("status" = 'pending'::"auth"."oauth_authorization_status");



CREATE INDEX "oauth_clients_deleted_at_idx" ON "auth"."oauth_clients" USING "btree" ("deleted_at");



CREATE INDEX "oauth_consents_active_client_idx" ON "auth"."oauth_consents" USING "btree" ("client_id") WHERE ("revoked_at" IS NULL);



CREATE INDEX "oauth_consents_active_user_client_idx" ON "auth"."oauth_consents" USING "btree" ("user_id", "client_id") WHERE ("revoked_at" IS NULL);



CREATE INDEX "oauth_consents_user_order_idx" ON "auth"."oauth_consents" USING "btree" ("user_id", "granted_at" DESC);



CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");



CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");



CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");



CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");



CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");



CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");



CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");



CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);



CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");



CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);



CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");



CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");



CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);



CREATE INDEX "sessions_oauth_client_id_idx" ON "auth"."sessions" USING "btree" ("oauth_client_id");



CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");



CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));



CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");



CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));



CREATE INDEX "sso_providers_resource_id_pattern_idx" ON "auth"."sso_providers" USING "btree" ("resource_id" "text_pattern_ops");



CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");



CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");



CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);



COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';



CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));



CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");



CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");



CREATE INDEX "idx_alerts_active_not_deleted" ON "public"."professional_alerts" USING "btree" ("created_at") WHERE (("status" = 'active'::"public"."alertStatus") AND ("is_deleted" = false));



CREATE INDEX "idx_alerts_expires_active" ON "public"."professional_alerts" USING "btree" ("expires_at") WHERE ("status" = 'active'::"public"."alertStatus");



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



CREATE INDEX "idx_notifications_unread" ON ONLY "public"."notifications" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "idx_outbox_unprocessed" ON "public"."notifications_outbox" USING "btree" ("processed_at", "created_at");



CREATE INDEX "idx_pcr_active_created" ON "public"."public_chat_rooms" USING "btree" ("is_active", "created_at" DESC);



CREATE INDEX "idx_pd_profession_live_partial" ON "public"."professional_details" USING "btree" ("profession") WHERE ("is_live" = true);



CREATE INDEX "idx_pd_wishlist_count" ON "public"."professional_details" USING "btree" ("wishlist_count");



CREATE INDEX "idx_poi_bride_created" ON "public"."user_pois" USING "btree" ("bride_profile_id", "created_at");



CREATE INDEX "idx_pro_details_live" ON "public"."professional_details" USING "btree" ("is_live");



CREATE INDEX "idx_pro_recent_optin_lastseen" ON "public"."pro_recent_locations" USING "btree" ("is_opt_in", "last_seen_at" DESC);



CREATE INDEX "idx_prof_alerts_active_partial" ON "public"."professional_alerts" USING "btree" ("expires_at") WHERE ("status" = 'active'::"public"."alertStatus");



CREATE INDEX "idx_prof_alerts_status_expires" ON "public"."professional_alerts" USING "btree" ("status", "expires_at");



CREATE INDEX "idx_prof_details_live_profession" ON "public"."professional_details" USING "btree" ("is_live", "profession");



CREATE INDEX "idx_prof_details_wishlist_count" ON "public"."professional_details" USING "btree" ("wishlist_count" DESC);



CREATE INDEX "idx_professional_alerts_active" ON "public"."professional_alerts" USING "btree" ("status", "is_deleted", "created_at" DESC);



CREATE INDEX "idx_professional_details_validation_status" ON "public"."professional_details" USING "btree" ("is_live", "is_pending");



CREATE INDEX "idx_ps_visible_tier" ON "public"."professional_subscriptions" USING "btree" ("profile_id") WHERE ("subscription_tier" = ANY (ARRAY['premiumVisibility'::"public"."subscriptionTierType", 'ultimateAccess'::"public"."subscriptionTierType"]));



CREATE INDEX "idx_rl_last_seen_optin" ON "public"."pro_recent_locations" USING "btree" ("last_seen_at" DESC) WHERE ("is_opt_in" = true);



CREATE INDEX "idx_rooms_type_active" ON "public"."chat_rooms" USING "btree" ("type", "is_active");



CREATE INDEX "idx_subscriptions_tier" ON "public"."professional_subscriptions" USING "btree" ("subscription_tier");



CREATE INDEX "idx_support_tickets_created_at" ON "public"."support_tickets" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_support_tickets_professional_profile_id" ON "public"."support_tickets" USING "btree" ("professional_profile_id");



CREATE INDEX "idx_support_tickets_status" ON "public"."support_tickets" USING "btree" ("status");



CREATE INDEX "idx_sync_events_created_at" ON "public"."sync_events" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_sync_events_email" ON "public"."sync_events" USING "btree" ("email");



CREATE INDEX "idx_sync_events_event_type" ON "public"."sync_events" USING "btree" ("event_type");



CREATE INDEX "idx_sync_events_user_id" ON "public"."sync_events" USING "btree" ("user_id");



CREATE UNIQUE INDEX "idx_unique_stripe_customer_id_not_null" ON "public"."professional_subscriptions" USING "btree" ("stripe_customer_id") WHERE ("stripe_customer_id" IS NOT NULL);



CREATE UNIQUE INDEX "idx_unique_stripe_subscription_id_not_null" ON "public"."professional_subscriptions" USING "btree" ("stripe_subscription_id") WHERE ("stripe_subscription_id" IS NOT NULL);



CREATE INDEX "idx_video_sessions_status_time" ON "public"."video_sessions" USING "btree" ("status", "created_at");



CREATE INDEX "idx_wishlist_pro" ON "public"."wishlist_items" USING "btree" ("professional_profile_id");



CREATE INDEX "idx_wp_active_visible" ON "public"."wedding_pins" USING "btree" ("created_at") WHERE (("is_deleted" = false) AND ("is_active" = true));



CREATE INDEX "notifications_2025_09_profile_id_created_at_idx" ON "public"."notifications_2025_09" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE INDEX "notifications_2025_10_profile_id_created_at_idx" ON "public"."notifications_2025_10" USING "btree" ("profile_id", "created_at" DESC) WHERE ("is_read" = false);



CREATE UNIQUE INDEX "uq_pending_conn_request" ON "public"."connection_requests" USING "btree" ("pro_profile_id", "bride_profile_id") WHERE ("status" = 'pending'::"public"."connectionRequestStatus");



CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");



CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");



CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");



CREATE UNIQUE INDEX "idx_name_bucket_level_unique" ON "storage"."objects" USING "btree" ("name" COLLATE "C", "bucket_id", "level");



CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");



CREATE INDEX "idx_objects_lower_name" ON "storage"."objects" USING "btree" (("path_tokens"["level"]), "lower"("name") "text_pattern_ops", "bucket_id", "level");



CREATE INDEX "idx_prefixes_lower_name" ON "storage"."prefixes" USING "btree" ("bucket_id", "level", (("string_to_array"("name", '/'::"text"))["level"]), "lower"("name") "text_pattern_ops");



CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");



CREATE UNIQUE INDEX "objects_bucket_id_level_idx" ON "storage"."objects" USING "btree" ("bucket_id", "level", "name" COLLATE "C");



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_09_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_09_profile_id_created_at_idx";



ALTER INDEX "public"."notifications_pkey" ATTACH PARTITION "public"."notifications_2025_10_pkey";



ALTER INDEX "public"."idx_notifications_unread" ATTACH PARTITION "public"."notifications_2025_10_profile_id_created_at_idx";



CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."on_auth_user_created"();



CREATE OR REPLACE TRIGGER "handle_wed_articles_updated_at" BEFORE UPDATE ON "public"."wed_articles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_alerts_rate_limit_bi" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."alerts_rate_limit_before_insert"();



CREATE OR REPLACE TRIGGER "trg_conn_req_before_insert" BEFORE INSERT ON "public"."connection_requests" FOR EACH ROW EXECUTE FUNCTION "public"."conn_req_before_insert"();



CREATE OR REPLACE TRIGGER "trg_enforce_fixed_locations_quota" BEFORE INSERT ON "public"."professional_fixed_locations" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_fixed_locations_quota"();



CREATE OR REPLACE TRIGGER "trg_handle_message_report" AFTER INSERT ON "public"."reports" FOR EACH ROW EXECUTE FUNCTION "public"."handle_message_report"();



CREATE OR REPLACE TRIGGER "trg_on_first_msg_pro_bride" BEFORE INSERT ON "public"."chat_messages" FOR EACH ROW EXECUTE FUNCTION "public"."on_first_message_pro_to_bride"();



CREATE OR REPLACE TRIGGER "trg_outbox_chat_msg" AFTER INSERT ON "public"."chat_messages" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_chat_message"();



CREATE OR REPLACE TRIGGER "trg_outbox_on_connection_request_aiu" AFTER INSERT OR UPDATE OF "status" ON "public"."connection_requests" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_connection_request_aiu"();



CREATE OR REPLACE TRIGGER "trg_outbox_on_video_session" AFTER INSERT ON "public"."video_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_video_session_created"();



CREATE OR REPLACE TRIGGER "trg_prof_details_budget_eur_biub" BEFORE INSERT OR UPDATE OF "budget_min", "budget_max", "currency" ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."prof_details_set_budget_eur"();



CREATE OR REPLACE TRIGGER "trg_prof_details_set_updated_at" BEFORE UPDATE ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_profiles_set_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_set_alert_expiry" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."set_professional_alert_expiry"();



CREATE OR REPLACE TRIGGER "trg_set_alert_expiry_bi" BEFORE INSERT ON "public"."professional_alerts" FOR EACH ROW EXECUTE FUNCTION "public"."set_professional_alert_expiry"();



CREATE OR REPLACE TRIGGER "trg_user_pois_history_aiud" AFTER INSERT OR DELETE OR UPDATE ON "public"."user_pois" FOR EACH ROW EXECUTE FUNCTION "public"."user_pois_history_logger"();



CREATE OR REPLACE TRIGGER "trg_user_prefs_set_updated_at" BEFORE UPDATE ON "public"."user_preferences" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_wedding_pins_budget_eur_biub" BEFORE INSERT OR UPDATE OF "budget_min", "budget_max", "currency" ON "public"."wedding_pins" FOR EACH ROW EXECUTE FUNCTION "public"."wedding_pins_set_budget_eur"();



CREATE OR REPLACE TRIGGER "trg_wedding_pins_history_aiud" AFTER INSERT OR DELETE OR UPDATE ON "public"."wedding_pins" FOR EACH ROW EXECUTE FUNCTION "public"."wedding_pins_history_logger"();



CREATE OR REPLACE TRIGGER "trg_wedding_pins_set_updated_at" BEFORE UPDATE ON "public"."wedding_pins" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_wishlist_count" AFTER INSERT OR DELETE ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_wishlist_count"();



CREATE OR REPLACE TRIGGER "trg_wishlist_count_aiud" AFTER INSERT OR DELETE ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_wishlist_count"();



CREATE OR REPLACE TRIGGER "trg_wishlist_items_after_insert_enqueue_notification" AFTER INSERT ON "public"."wishlist_items" FOR EACH ROW EXECUTE FUNCTION "public"."outbox_on_wishlist_add"();



CREATE OR REPLACE TRIGGER "trigger_sync_professional_on_validation" AFTER UPDATE ON "public"."professional_details" FOR EACH ROW EXECUTE FUNCTION "public"."sync_professional_on_validation"();



CREATE OR REPLACE TRIGGER "update_support_tickets_updated_at" BEFORE UPDATE ON "public"."support_tickets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "enforce_bucket_name_length_trigger" BEFORE INSERT OR UPDATE OF "name" ON "storage"."buckets" FOR EACH ROW EXECUTE FUNCTION "storage"."enforce_bucket_name_length"();



CREATE OR REPLACE TRIGGER "objects_delete_delete_prefix" AFTER DELETE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();



CREATE OR REPLACE TRIGGER "objects_insert_create_prefix" BEFORE INSERT ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."objects_insert_prefix_trigger"();



CREATE OR REPLACE TRIGGER "objects_update_create_prefix" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW WHEN ((("new"."name" <> "old"."name") OR ("new"."bucket_id" <> "old"."bucket_id"))) EXECUTE FUNCTION "storage"."objects_update_prefix_trigger"();



CREATE OR REPLACE TRIGGER "prefixes_create_hierarchy" BEFORE INSERT ON "storage"."prefixes" FOR EACH ROW WHEN (("pg_trigger_depth"() < 1)) EXECUTE FUNCTION "storage"."prefixes_insert_trigger"();



CREATE OR REPLACE TRIGGER "prefixes_delete_hierarchy" AFTER DELETE ON "storage"."prefixes" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();



CREATE OR REPLACE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."oauth_authorizations"
    ADD CONSTRAINT "oauth_authorizations_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "auth"."oauth_clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."oauth_authorizations"
    ADD CONSTRAINT "oauth_authorizations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."oauth_consents"
    ADD CONSTRAINT "oauth_consents_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "auth"."oauth_clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."oauth_consents"
    ADD CONSTRAINT "oauth_consents_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_oauth_client_id_fkey" FOREIGN KEY ("oauth_client_id") REFERENCES "auth"."oauth_clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bride_details"
    ADD CONSTRAINT "bride_details_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



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



ALTER TABLE ONLY "public"."pro_recent_locations"
    ADD CONSTRAINT "pro_recent_locations_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_author_profile_id_fkey" FOREIGN KEY ("author_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_alerts"
    ADD CONSTRAINT "professional_alerts_motif_code_fkey" FOREIGN KEY ("motif_code") REFERENCES "public"."alert_motifs"("code");



ALTER TABLE ONLY "public"."professional_details"
    ADD CONSTRAINT "professional_details_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professional_fixed_locations"
    ADD CONSTRAINT "professional_fixed_locations_professional_profile_id_fkey" FOREIGN KEY ("professional_profile_id") REFERENCES "public"."professional_details"("profile_id") ON DELETE CASCADE;



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



ALTER TABLE ONLY "public"."sync_events"
    ADD CONSTRAINT "sync_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocked_profile_id_fkey" FOREIGN KEY ("blocked_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocker_profile_id_fkey" FOREIGN KEY ("blocker_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_legal_acceptances"
    ADD CONSTRAINT "user_legal_acceptances_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_pois"
    ADD CONSTRAINT "user_pois_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



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



ALTER TABLE ONLY "public"."wedding_pins"
    ADD CONSTRAINT "wedding_pins_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_bride_profile_id_fkey" FOREIGN KEY ("bride_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlist_items"
    ADD CONSTRAINT "wishlist_items_professional_profile_id_fkey" FOREIGN KEY ("professional_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;



ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Admins can delete wed_articles" ON "public"."wed_articles" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can insert wed_articles" ON "public"."wed_articles" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can read deleted users log" ON "public"."deleted_users_log" FOR SELECT TO "authenticated" USING ((("auth"."jwt"() ->> 'user_role'::"text") = 'admin'::"text"));



CREATE POLICY "Admins can update tickets" ON "public"."support_tickets" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can update wed_articles" ON "public"."wed_articles" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



CREATE POLICY "Admins can view all roles" ON "public"."user_roles" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all sync events" ON "public"."sync_events" FOR SELECT TO "authenticated" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all tickets" ON "public"."support_tickets" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))));



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



CREATE POLICY "Allow owner to manage their recent location setting" ON "public"."pro_recent_locations" TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Allow owner to update their profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "Allow professionals to view alerts" ON "public"."professional_alerts" FOR SELECT TO "authenticated" USING (("public"."get_my_role"() = 'professional'::"public"."userRole"));



CREATE POLICY "Allow public read access to published articles" ON "public"."wed_articles" FOR SELECT USING (("is_published" = true));



CREATE POLICY "Allow public read for live pro locations" ON "public"."professional_fixed_locations" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."professional_details" "pd"
  WHERE (("pd"."profile_id" = "professional_fixed_locations"."professional_profile_id") AND ("pd"."is_live" = true)))));



CREATE POLICY "Allow public read for opted-in recent locations" ON "public"."pro_recent_locations" FOR SELECT TO "authenticated" USING ((("is_opt_in" = true) AND ("last_seen_at" >= ("now"() - '7 days'::interval))));



CREATE POLICY "Allow public read-only access" ON "public"."replays" FOR SELECT USING (true);



CREATE POLICY "Allow public read-only access on assignments" ON "public"."replay_guest_assignments" FOR SELECT USING (true);



CREATE POLICY "Allow public read-only access on guests" ON "public"."replay_guests" FOR SELECT USING (true);



CREATE POLICY "Allow write access to service role only" ON "public"."wed_articles" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Authenticated users can read active report motifs" ON "public"."report_motifs" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Bride owners can manage their own details" ON "public"."bride_details" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Disallow app-side inserts" ON "public"."deleted_users_log" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Owner can manage their own POIs" ON "public"."user_pois" TO "authenticated" USING (("bride_profile_id" = "auth"."uid"())) WITH CHECK (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "Owner can manage their own pins" ON "public"."wedding_pins" TO "authenticated" USING (("bride_profile_id" = "auth"."uid"())) WITH CHECK (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "Owner can update their own subscription record" ON "public"."professional_subscriptions" FOR UPDATE TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Owners can manage their own details" ON "public"."professional_details" TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Public can view professional_details linked to published wed_ar" ON "public"."professional_details" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."wed_articles" "wa"
  WHERE (("wa"."linked_pro_profile_id" = "professional_details"."profile_id") AND ("wa"."is_published" = true)))));



CREATE POLICY "Public can view profiles linked to published wed_articles" ON "public"."profiles" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."wed_articles" "wa"
  WHERE (("wa"."linked_pro_profile_id" = "profiles"."id") AND ("wa"."is_published" = true)))));



CREATE POLICY "Public profiles are viewable by authenticated users" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Service role can manage notifications in 2025_10" ON "public"."notifications_2025_10" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage roles" ON "public"."user_roles" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Service role can manage sync events" ON "public"."sync_events" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can write report motifs" ON "public"."report_motifs" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role only for sync_control" ON "public"."sync_control" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role only for sync_log" ON "public"."sync_log" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role only for user_pois_history" ON "public"."user_pois_history" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role only for wedding_pins_history" ON "public"."wedding_pins_history" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Subscription status is viewable by authenticated users" ON "public"."professional_subscriptions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can create their own tickets" ON "public"."support_tickets" FOR INSERT WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Users can read their own notifications in 2025_10" ON "public"."notifications_2025_10" FOR SELECT USING (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can update their own notifications in 2025_10" ON "public"."notifications_2025_10" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Users can view their own tickets" ON "public"."support_tickets" FOR SELECT USING (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."alert_motifs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "alert_motifs_read_authenticated" ON "public"."alert_motifs" FOR SELECT TO "authenticated" USING (("is_active" = true));



ALTER TABLE "public"."bride_details" ENABLE ROW LEVEL SECURITY;


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


ALTER TABLE "public"."notifications_outbox" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notifications_read_auth" ON "public"."notifications_2025_09" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "outbox_service_read" ON "public"."notifications_outbox" FOR SELECT USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "outbox_service_write" ON "public"."notifications_outbox" USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "pcr_read_auth" ON "public"."public_chat_rooms" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "pcr_write_service" ON "public"."public_chat_rooms" TO "authenticated" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));



ALTER TABLE "public"."pro_recent_locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_alerts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_details" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_fixed_locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professional_subscriptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."public_chat_rooms" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replay_guest_assignments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replay_guests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."replays" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."report_motifs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "reports_owner" ON "public"."reports" USING (("reporter_profile_id" = "auth"."uid"()));



CREATE POLICY "reports_owner_rw" ON "public"."reports" USING (("reporter_profile_id" = "auth"."uid"())) WITH CHECK (("reporter_profile_id" = "auth"."uid"()));



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


ALTER TABLE "public"."user_pois" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_pois_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_preferences" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_prefs_owner_all" ON "public"."user_preferences" USING (("profile_id" = "auth"."uid"()));



CREATE POLICY "user_prefs_owner_rw" ON "public"."user_preferences" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."video_sessions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "video_sessions_participants" ON "public"."video_sessions" USING ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



CREATE POLICY "video_sessions_participants_rw" ON "public"."video_sessions" USING ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"()))) WITH CHECK ((("initiator_id" = "auth"."uid"()) OR ("receiver_id" = "auth"."uid"())));



ALTER TABLE "public"."wed_articles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wedding_pins" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wedding_pins_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "wishlist_bride_all" ON "public"."wishlist_items" USING (("bride_profile_id" = "auth"."uid"()));



ALTER TABLE "public"."wishlist_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "wishlist_items_owner_rw" ON "public"."wishlist_items" USING (("bride_profile_id" = "auth"."uid"())) WITH CHECK (("bride_profile_id" = "auth"."uid"()));



CREATE POLICY "wishlist_pro_ultimate_read" ON "public"."wishlist_items" FOR SELECT USING ((("professional_profile_id" = "auth"."uid"()) AND ("public"."get_my_tier"() = 'ultimateAccess'::"public"."subscriptionTierType")));



CREATE POLICY "Admins can delete images" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'public_images'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role"))))));



CREATE POLICY "Admins can update images" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'public_images'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role")))))) WITH CHECK ((("bucket_id" = 'public_images'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role"))))));



CREATE POLICY "Admins can upload images" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'public_images'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'admin'::"public"."app_role"))))));



CREATE POLICY "Allow service role to delete portfolio images" ON "storage"."objects" FOR DELETE TO "service_role" USING (("bucket_id" = 'portfolio'::"text"));



CREATE POLICY "Allow service role to update portfolio images" ON "storage"."objects" FOR UPDATE TO "service_role" USING (("bucket_id" = 'portfolio'::"text"));



CREATE POLICY "Allow service role to upload portfolio images" ON "storage"."objects" FOR INSERT TO "service_role" WITH CHECK (("bucket_id" = 'portfolio'::"text"));



CREATE POLICY "Avatars delete own path" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Avatars insert own path" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Avatars update own path" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text"))) WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Block new uploads to chat_attachments" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'chat_attachments'::"text") AND false));



CREATE POLICY "Chat media delete own" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = ("split_part"("objects"."name", '/'::"text", 1))::"uuid") AND ("p"."profile_id" = "auth"."uid"()))))));



CREATE POLICY "Chat media insert participants" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = ("split_part"("objects"."name", '/'::"text", 1))::"uuid") AND ("p"."profile_id" = "auth"."uid"()))))));



CREATE POLICY "Chat media read participants" ON "storage"."objects" FOR SELECT TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = ("split_part"("objects"."name", '/'::"text", 1))::"uuid") AND ("p"."profile_id" = "auth"."uid"()))))));



CREATE POLICY "Chat media update own" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = ("split_part"("objects"."name", '/'::"text", 1))::"uuid") AND ("p"."profile_id" = "auth"."uid"())))))) WITH CHECK ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."room_id" = ("split_part"("objects"."name", '/'::"text", 1))::"uuid") AND ("p"."profile_id" = "auth"."uid"()))))));



CREATE POLICY "Portfolio delete own path" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'portfolio'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Portfolio insert own path" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'portfolio'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Portfolio update own path" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'portfolio'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text"))) WITH CHECK ((("bucket_id" = 'portfolio'::"text") AND ("owner" = "auth"."uid"()) AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));



CREATE POLICY "Public images are publicly accessible" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public_images'::"text"));



CREATE POLICY "Public read avatars" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'avatars'::"text"));



CREATE POLICY "Public read portfolio" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'portfolio'::"text"));



ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_attachments_read" ON "storage"."objects" FOR SELECT USING ((("bucket_id" = 'chat_attachments'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."chat_room_participants" "p"
  WHERE (("p"."profile_id" = "auth"."uid"()) AND (("p"."room_id")::"text" = ("storage"."foldername"("objects"."name"))[1]))))));



CREATE POLICY "chat_media_delete" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"())));



CREATE POLICY "chat_media_read" ON "storage"."objects" FOR SELECT TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND "public"."is_room_participant"(("split_part"("name", '/'::"text", 1))::"uuid", "auth"."uid"())));



CREATE POLICY "chat_media_update" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"())));



CREATE POLICY "chat_media_write" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = ANY (ARRAY['chat-images'::"text", 'chat-audio'::"text"])) AND ("owner" = "auth"."uid"()) AND "public"."is_room_participant"(("split_part"("name", '/'::"text", 1))::"uuid", "auth"."uid"())));



ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."prefixes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "auth" TO "anon";
GRANT USAGE ON SCHEMA "auth" TO "authenticated";
GRANT USAGE ON SCHEMA "auth" TO "service_role";
GRANT ALL ON SCHEMA "auth" TO "supabase_auth_admin";
GRANT ALL ON SCHEMA "auth" TO "dashboard_user";
GRANT USAGE ON SCHEMA "auth" TO "postgres";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT USAGE ON SCHEMA "storage" TO "postgres" WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "storage" TO "anon";
GRANT USAGE ON SCHEMA "storage" TO "authenticated";
GRANT USAGE ON SCHEMA "storage" TO "service_role";
GRANT ALL ON SCHEMA "storage" TO "supabase_storage_admin";
GRANT ALL ON SCHEMA "storage" TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."email"() TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."jwt"() TO "postgres";
GRANT ALL ON FUNCTION "auth"."jwt"() TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."role"() TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."uid"() TO "dashboard_user";



REVOKE ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_connection_request"("p_request_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_get_professional_details"() TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_professional_details"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_professional_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."alerts_rate_limit_before_insert"() TO "anon";
GRANT ALL ON FUNCTION "public"."alerts_rate_limit_before_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."alerts_rate_limit_before_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auth_uid"() TO "anon";
GRANT ALL ON FUNCTION "public"."auth_uid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auth_uid"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_professional_alert"("p_alert_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."notifications_outbox" TO "service_role";



GRANT ALL ON FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."claim_outbox_events"("p_batch_size" integer, "p_claim_ttl_minutes" integer, "p_worker_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_old_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_old_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_old_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_pro_recent_locations"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_pro_recent_locations"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_pro_recent_locations"() TO "service_role";



GRANT ALL ON FUNCTION "public"."conn_req_before_insert"() TO "anon";
GRANT ALL ON FUNCTION "public"."conn_req_before_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."conn_req_before_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."convert_to_eur"("p_amount" numeric, "p_currency" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_next_notifications_partition"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_next_notifications_partition"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_next_notifications_partition"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_professional_alert"("p_motif_code" "text", "p_message" "text", "p_end_at" timestamp with time zone, "p_lat" double precision, "p_lng" double precision, "p_location_label" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."decline_connection_request"("p_request_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."delete_user_poi"("p_poi_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_user_poi"("p_poi_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_user_poi"("p_poi_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_wedding_pin"("p_pin_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_fixed_locations_quota"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_fixed_locations_quota"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_fixed_locations_quota"() TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_alerts"() TO "anon";
GRANT ALL ON FUNCTION "public"."expire_alerts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."expire_alerts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_trials"() TO "anon";
GRANT ALL ON FUNCTION "public"."expire_trials"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."expire_trials"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_alert_item_details"("p_alert_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_bride_interest_items"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_bride_interest_items"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_bride_interest_items"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") TO "anon";
GRANT ALL ON FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_color_for_profession"("p_profession" "public"."profession") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_favorited_professionals"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_favorited_professionals"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_favorited_professionals"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_feed_professionals"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_fixed_locations_quota"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_formatted_notifications"("p_limit" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_formatted_notifications"("p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_formatted_notifications"("p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_latest_wed_article"("p_lang" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_latest_wed_article"("p_lang" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_latest_wed_article"("p_lang" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_tier"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_tier"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_tier"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_pending_contact_requests"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_pending_contact_requests"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_pending_contact_requests"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_portfolio_feed"("p_filters" "jsonb", "p_cursor" "text", "p_page_size" integer, "p_seed" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_pro_item_details"("p_pro_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professional_profile"("p_profile_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_public_chat_rooms_for_brides"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_public_chat_rooms_for_brides"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_chat_rooms_for_brides"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_profile_details"("p_profile_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_report_motifs"("p_locale" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_report_motifs"("p_locale" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_report_motifs"("p_locale" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_room_header"("p_room_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_room_header"("p_room_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_room_header"("p_room_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_rooms_with_unread_counts"("p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_tier_of"("p_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_unread_notifications_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_unread_notifications_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_unread_notifications_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_wedding_pin_item_details"("p_pin_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_wishlisted_by_brides"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_wishlisted_by_brides"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_wishlisted_by_brides"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_message_report"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_message_report"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_message_report"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "anon";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "service_role";



REVOKE ALL ON FUNCTION "public"."insert_user_poi"("p_label" "text", "p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."insert_user_poi"("p_label" "text", "p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_user_poi"("p_label" "text", "p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_wedding_pin"("p_lat" double precision, "p_lng" double precision, "p_radius_km" smallint, "p_professions" "text"[], "p_budget_min" integer, "p_budget_max" integer, "p_currency" "text", "p_event_start_date" "date", "p_event_end_date" "date", "p_location_label" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_blocked_between"("a" "uuid", "b" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_public_room"("p_room_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_public_room"("p_room_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_public_room"("p_room_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_room_participant"("p_room_id" "uuid", "p_profile_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."join_public_room_if_needed"("p_room_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "anon";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_video_sessions_missed"() TO "anon";
GRANT ALL ON FUNCTION "public"."mark_video_sessions_missed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_video_sessions_missed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_auth_user_created"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_auth_user_created"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_auth_user_created"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_first_message_pro_to_bride"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_first_message_pro_to_bride"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_first_message_pro_to_bride"() TO "service_role";



GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."open_or_prepare_contact_context"("p_target" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_chat_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."outbox_on_chat_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."outbox_on_chat_message"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_connection_request"() TO "anon";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_connection_request_aiu"() TO "anon";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request_aiu"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."outbox_on_connection_request_aiu"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_video_session_created"() TO "anon";
GRANT ALL ON FUNCTION "public"."outbox_on_video_session_created"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."outbox_on_video_session_created"() TO "service_role";



GRANT ALL ON FUNCTION "public"."outbox_on_wishlist_add"() TO "anon";
GRANT ALL ON FUNCTION "public"."outbox_on_wishlist_add"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."outbox_on_wishlist_add"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prof_details_set_budget_eur"() TO "anon";
GRANT ALL ON FUNCTION "public"."prof_details_set_budget_eur"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."prof_details_set_budget_eur"() TO "service_role";



GRANT ALL ON FUNCTION "public"."recompute_all_budgets_eur"() TO "anon";
GRANT ALL ON FUNCTION "public"."recompute_all_budgets_eur"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."recompute_all_budgets_eur"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."rpc_alerts_capture_to_remind"("p_from" timestamp with time zone, "p_to" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_map_bundle"("p_bbox_coords" "jsonb", "p_viewer_role" "text", "p_filters" "jsonb", "p_zoom" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."seed_map_test_data"("p_bride" "uuid", "p_pro" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_alert_reminders"() TO "anon";
GRANT ALL ON FUNCTION "public"."send_alert_reminders"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_alert_reminders"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_professional_alert_expiry"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_professional_alert_expiry"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_professional_alert_expiry"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_professional_on_validation"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_professional_on_validation"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_professional_on_validation"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_profile_to_professional_details"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_profile_to_professional_details"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_profile_to_professional_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") TO "anon";
GRANT ALL ON FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") TO "authenticated";
GRANT ALL ON FUNCTION "public"."tier_score"("t" "public"."subscriptionTierType") TO "service_role";



REVOKE ALL ON FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_wishlist"("p_pro_profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_wishlist_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_wishlist_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_wishlist_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_pois_history_logger"() TO "anon";
GRANT ALL ON FUNCTION "public"."user_pois_history_logger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_pois_history_logger"() TO "service_role";



GRANT ALL ON FUNCTION "public"."wedding_pins_history_logger"() TO "anon";
GRANT ALL ON FUNCTION "public"."wedding_pins_history_logger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."wedding_pins_history_logger"() TO "service_role";



GRANT ALL ON FUNCTION "public"."wedding_pins_set_budget_eur"() TO "anon";
GRANT ALL ON FUNCTION "public"."wedding_pins_set_budget_eur"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."wedding_pins_set_budget_eur"() TO "service_role";



GRANT ALL ON TABLE "auth"."audit_log_entries" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."audit_log_entries" TO "postgres";
GRANT SELECT ON TABLE "auth"."audit_log_entries" TO "postgres" WITH GRANT OPTION;



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."flow_state" TO "postgres";
GRANT SELECT ON TABLE "auth"."flow_state" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."flow_state" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."identities" TO "postgres";
GRANT SELECT ON TABLE "auth"."identities" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."identities" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."instances" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."instances" TO "postgres";
GRANT SELECT ON TABLE "auth"."instances" TO "postgres" WITH GRANT OPTION;



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_amr_claims" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_amr_claims" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_amr_claims" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_challenges" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_challenges" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_challenges" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_factors" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_factors" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_factors" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."oauth_authorizations" TO "postgres";
GRANT ALL ON TABLE "auth"."oauth_authorizations" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."oauth_clients" TO "postgres";
GRANT ALL ON TABLE "auth"."oauth_clients" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."oauth_consents" TO "postgres";
GRANT ALL ON TABLE "auth"."oauth_consents" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."one_time_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."one_time_tokens" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."one_time_tokens" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."refresh_tokens" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."refresh_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."refresh_tokens" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "dashboard_user";
GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "postgres";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."saml_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_providers" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."saml_relay_states" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_relay_states" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_relay_states" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sessions" TO "postgres";
GRANT SELECT ON TABLE "auth"."sessions" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sessions" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sso_domains" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_domains" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_domains" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sso_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_providers" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."users" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."users" TO "postgres";
GRANT SELECT ON TABLE "auth"."users" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "public"."alert_motifs" TO "anon";
GRANT ALL ON TABLE "public"."alert_motifs" TO "authenticated";
GRANT ALL ON TABLE "public"."alert_motifs" TO "service_role";



GRANT ALL ON TABLE "public"."bride_details" TO "anon";
GRANT ALL ON TABLE "public"."bride_details" TO "authenticated";
GRANT ALL ON TABLE "public"."bride_details" TO "service_role";



GRANT ALL ON TABLE "public"."chat_messages" TO "anon";
GRANT ALL ON TABLE "public"."chat_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_messages" TO "service_role";



GRANT ALL ON SEQUENCE "public"."chat_messages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."chat_messages_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."chat_messages_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."chat_room_participants" TO "anon";
GRANT ALL ON TABLE "public"."chat_room_participants" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_room_participants" TO "service_role";



GRANT ALL ON TABLE "public"."chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."chat_rooms" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_rooms" TO "service_role";



GRANT ALL ON TABLE "public"."connection_requests" TO "anon";
GRANT ALL ON TABLE "public"."connection_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."connection_requests" TO "service_role";



GRANT ALL ON TABLE "public"."content" TO "authenticated";
GRANT ALL ON TABLE "public"."content" TO "service_role";



GRANT ALL ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticated";
GRANT ALL ON TABLE "public"."countries" TO "service_role";



GRANT ALL ON TABLE "public"."deleted_users_log" TO "anon";
GRANT ALL ON TABLE "public"."deleted_users_log" TO "authenticated";
GRANT ALL ON TABLE "public"."deleted_users_log" TO "service_role";



GRANT ALL ON TABLE "public"."device_tokens" TO "anon";
GRANT ALL ON TABLE "public"."device_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."device_tokens" TO "service_role";



GRANT ALL ON TABLE "public"."fx_rates" TO "service_role";
GRANT SELECT ON TABLE "public"."fx_rates" TO "authenticated";



GRANT ALL ON TABLE "public"."notification_settings" TO "anon";
GRANT ALL ON TABLE "public"."notification_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."notification_settings" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."notifications_2025_09" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_09" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications_2025_09" TO "service_role";



GRANT ALL ON TABLE "public"."notifications_2025_10" TO "anon";
GRANT ALL ON TABLE "public"."notifications_2025_10" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications_2025_10" TO "service_role";



GRANT ALL ON TABLE "public"."pro_recent_locations" TO "anon";
GRANT ALL ON TABLE "public"."pro_recent_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."pro_recent_locations" TO "service_role";



GRANT ALL ON TABLE "public"."professional_alerts" TO "anon";
GRANT ALL ON TABLE "public"."professional_alerts" TO "authenticated";
GRANT ALL ON TABLE "public"."professional_alerts" TO "service_role";



GRANT ALL ON TABLE "public"."professional_details" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."professional_details" TO "authenticated";



GRANT ALL ON TABLE "public"."professional_fixed_locations" TO "anon";
GRANT ALL ON TABLE "public"."professional_fixed_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."professional_fixed_locations" TO "service_role";



GRANT ALL ON TABLE "public"."professional_subscriptions" TO "service_role";
GRANT SELECT ON TABLE "public"."professional_subscriptions" TO "authenticated";



GRANT ALL ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."profiles" TO "authenticated";



GRANT ALL ON TABLE "public"."public_chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."public_chat_rooms" TO "authenticated";
GRANT ALL ON TABLE "public"."public_chat_rooms" TO "service_role";



GRANT ALL ON TABLE "public"."public_professionals" TO "anon";
GRANT ALL ON TABLE "public"."public_professionals" TO "authenticated";
GRANT ALL ON TABLE "public"."public_professionals" TO "service_role";



GRANT ALL ON TABLE "public"."public_profiles" TO "anon";
GRANT ALL ON TABLE "public"."public_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."public_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."replay_guest_assignments" TO "anon";
GRANT ALL ON TABLE "public"."replay_guest_assignments" TO "authenticated";
GRANT ALL ON TABLE "public"."replay_guest_assignments" TO "service_role";



GRANT ALL ON TABLE "public"."replay_guests" TO "anon";
GRANT ALL ON TABLE "public"."replay_guests" TO "authenticated";
GRANT ALL ON TABLE "public"."replay_guests" TO "service_role";



GRANT ALL ON TABLE "public"."replays" TO "anon";
GRANT ALL ON TABLE "public"."replays" TO "authenticated";
GRANT ALL ON TABLE "public"."replays" TO "service_role";



GRANT ALL ON TABLE "public"."report_motifs" TO "anon";
GRANT ALL ON TABLE "public"."report_motifs" TO "authenticated";
GRANT ALL ON TABLE "public"."report_motifs" TO "service_role";



GRANT ALL ON TABLE "public"."report_motifs_v" TO "anon";
GRANT ALL ON TABLE "public"."report_motifs_v" TO "authenticated";
GRANT ALL ON TABLE "public"."report_motifs_v" TO "service_role";



GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";



GRANT ALL ON TABLE "public"."stripe_events_log" TO "anon";
GRANT ALL ON TABLE "public"."stripe_events_log" TO "authenticated";
GRANT ALL ON TABLE "public"."stripe_events_log" TO "service_role";



GRANT ALL ON TABLE "public"."support_tickets" TO "anon";
GRANT ALL ON TABLE "public"."support_tickets" TO "authenticated";
GRANT ALL ON TABLE "public"."support_tickets" TO "service_role";



GRANT ALL ON TABLE "public"."sync_control" TO "anon";
GRANT ALL ON TABLE "public"."sync_control" TO "authenticated";
GRANT ALL ON TABLE "public"."sync_control" TO "service_role";



GRANT ALL ON TABLE "public"."sync_events" TO "anon";
GRANT ALL ON TABLE "public"."sync_events" TO "authenticated";
GRANT ALL ON TABLE "public"."sync_events" TO "service_role";



GRANT ALL ON TABLE "public"."sync_log" TO "anon";
GRANT ALL ON TABLE "public"."sync_log" TO "authenticated";
GRANT ALL ON TABLE "public"."sync_log" TO "service_role";



GRANT ALL ON TABLE "public"."sync_stats" TO "anon";
GRANT ALL ON TABLE "public"."sync_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."sync_stats" TO "service_role";



GRANT ALL ON TABLE "public"."user_blocks" TO "anon";
GRANT ALL ON TABLE "public"."user_blocks" TO "authenticated";
GRANT ALL ON TABLE "public"."user_blocks" TO "service_role";



GRANT ALL ON TABLE "public"."user_legal_acceptances" TO "anon";
GRANT ALL ON TABLE "public"."user_legal_acceptances" TO "authenticated";
GRANT ALL ON TABLE "public"."user_legal_acceptances" TO "service_role";



GRANT ALL ON TABLE "public"."user_pois" TO "anon";
GRANT ALL ON TABLE "public"."user_pois" TO "authenticated";
GRANT ALL ON TABLE "public"."user_pois" TO "service_role";



GRANT ALL ON TABLE "public"."user_pois_history" TO "service_role";



GRANT ALL ON TABLE "public"."user_preferences" TO "anon";
GRANT ALL ON TABLE "public"."user_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."user_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";



GRANT ALL ON TABLE "public"."video_sessions" TO "anon";
GRANT ALL ON TABLE "public"."video_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."video_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."wed_articles" TO "anon";
GRANT ALL ON TABLE "public"."wed_articles" TO "authenticated";
GRANT ALL ON TABLE "public"."wed_articles" TO "service_role";



GRANT ALL ON TABLE "public"."wedding_pins" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."wedding_pins" TO "authenticated";



GRANT ALL ON TABLE "public"."wedding_pins_history" TO "service_role";



GRANT ALL ON TABLE "public"."wishlist_items" TO "anon";
GRANT ALL ON TABLE "public"."wishlist_items" TO "authenticated";
GRANT ALL ON TABLE "public"."wishlist_items" TO "service_role";



GRANT ALL ON TABLE "storage"."buckets" TO "anon";
GRANT ALL ON TABLE "storage"."buckets" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "storage"."buckets_analytics" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "anon";



GRANT ALL ON TABLE "storage"."objects" TO "anon";
GRANT ALL ON TABLE "storage"."objects" TO "authenticated";
GRANT ALL ON TABLE "storage"."objects" TO "service_role";
GRANT ALL ON TABLE "storage"."objects" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "storage"."prefixes" TO "service_role";
GRANT ALL ON TABLE "storage"."prefixes" TO "authenticated";
GRANT ALL ON TABLE "storage"."prefixes" TO "anon";



GRANT ALL ON TABLE "storage"."s3_multipart_uploads" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "anon";



GRANT ALL ON TABLE "storage"."s3_multipart_uploads_parts" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "anon";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES TO "dashboard_user";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS TO "dashboard_user";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES TO "dashboard_user";












ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "service_role";




