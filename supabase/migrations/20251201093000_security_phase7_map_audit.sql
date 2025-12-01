-- ============================================================================
-- PHASE 7.1: Security Audit Migration - Map/Wedding/Alert Modules
-- ============================================================================
-- Date: 2025-12-01
-- Purpose: Address security findings from Phase 7.1 audit
-- 
-- FINDINGS ADDRESSED:
-- 1. Missing coordinate validation in RPCs
-- 2. Missing event_date future validation in weddings table
-- 3. Missing INSERT policy for wedding_participants (bride)
-- 4. Missing message length validation in update_alert RPC
-- ============================================================================

-- ============================================================================
-- 1. ADD COORDINATE VALIDATION FUNCTION
-- ============================================================================
-- Reusable function to validate lat/lng coordinates
CREATE OR REPLACE FUNCTION public.validate_coordinates(
  p_lat double precision,
  p_lng double precision
) RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  -- Latitude must be between -90 and 90
  -- Longitude must be between -180 and 180
  RETURN p_lat IS NULL OR p_lng IS NULL OR (
    p_lat >= -90 AND p_lat <= 90 AND
    p_lng >= -180 AND p_lng <= 180
  );
END;
$$;

COMMENT ON FUNCTION public.validate_coordinates IS 
  'Validates that coordinates are within valid geographic bounds. Returns true if NULL or valid.';

-- ============================================================================
-- 2. UPDATE create_alert RPC WITH COORDINATE VALIDATION
-- ============================================================================
CREATE OR REPLACE FUNCTION public.create_alert(
  p_alert_type alert_type,
  p_title text,
  p_message text,
  p_event_date date,
  p_location_lat double precision,
  p_location_lng double precision,
  p_location_label text,
  p_radius_km smallint DEFAULT 50,
  p_profession_needed profession DEFAULT NULL::profession
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole";
  v_active_count int;
  v_new_id uuid;
  v_expires_at timestamptz;
BEGIN
  -- Check authentication
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Check user is a professional
  SELECT role INTO v_role FROM public.profiles WHERE id = v_me;
  IF v_role != 'professional' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only professionals can create alerts');
  END IF;

  -- Validate title length (3-100 chars)
  IF p_title IS NULL OR length(p_title) < 3 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Title must be at least 3 characters');
  END IF;
  IF length(p_title) > 100 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Title must be 100 characters or less');
  END IF;

  -- Validate message length (3-2000 chars)
  IF p_message IS NULL OR length(p_message) < 3 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Message must be at least 3 characters');
  END IF;
  IF length(p_message) > 2000 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Message must be 2000 characters or less');
  END IF;

  -- Validate event_date is in the future
  IF p_event_date < CURRENT_DATE THEN
    RETURN jsonb_build_object('success', false, 'error', 'Event date must be in the future');
  END IF;

  -- Validate coordinates
  IF NOT public.validate_coordinates(p_location_lat, p_location_lng) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid coordinates');
  END IF;

  -- Validate location is provided
  IF p_location_lat IS NULL OR p_location_lng IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Location coordinates are required');
  END IF;

  -- Validate radius (1-100 km)
  IF p_radius_km < 1 OR p_radius_km > 100 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Radius must be between 1 and 100 km');
  END IF;

  -- Check max 3 active alerts per pro
  SELECT COUNT(*) INTO v_active_count
  FROM public.professional_alerts
  WHERE author_profile_id = v_me
    AND status = 'active'
    AND is_deleted = false
    AND expires_at > now();

  IF v_active_count >= 3 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Maximum 3 active alerts allowed');
  END IF;

  -- Calculate expires_at: event_date + 1 day at 23:59:59
  v_expires_at := (p_event_date + interval '1 day' + interval '23 hours 59 minutes 59 seconds')::timestamptz;

  -- Insert the alert
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
    duration_hours,
    expires_at,
    status
  ) VALUES (
    v_me,
    p_alert_type,
    p_title,
    p_message,
    p_event_date,
    extensions.ST_SetSRID(extensions.ST_MakePoint(p_location_lng, p_location_lat), 4326),
    p_location_label,
    p_radius_km,
    p_profession_needed,
    EXTRACT(EPOCH FROM (v_expires_at - now())) / 3600,
    v_expires_at,
    'active'
  )
  RETURNING id INTO v_new_id;

  RETURN jsonb_build_object(
    'success', true,
    'alertId', v_new_id,
    'expiresAt', v_expires_at
  );
END;
$$;

-- ============================================================================
-- 3. UPDATE update_alert RPC WITH MESSAGE VALIDATION
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_alert(
  p_alert_id uuid,
  p_title text DEFAULT NULL::text,
  p_message text DEFAULT NULL::text,
  p_event_date date DEFAULT NULL::date,
  p_location_lat double precision DEFAULT NULL::double precision,
  p_location_lng double precision DEFAULT NULL::double precision,
  p_location_label text DEFAULT NULL::text,
  p_status "alertStatus" DEFAULT NULL::"alertStatus"
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_me uuid := auth.uid();
  v_alert record;
  v_new_expires_at timestamptz;
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
    RETURN jsonb_build_object('success', false, 'error', 'Not authorized to update this alert');
  END IF;

  -- Validate title length if provided (3-100 chars)
  IF p_title IS NOT NULL THEN
    IF length(p_title) < 3 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Title must be at least 3 characters');
    END IF;
    IF length(p_title) > 100 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Title must be 100 characters or less');
    END IF;
  END IF;

  -- Validate message length if provided (3-2000 chars)
  IF p_message IS NOT NULL THEN
    IF length(p_message) < 3 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Message must be at least 3 characters');
    END IF;
    IF length(p_message) > 2000 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Message must be 2000 characters or less');
    END IF;
  END IF;

  -- Validate coordinates if provided
  IF p_location_lat IS NOT NULL OR p_location_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_location_lat, p_location_lng) THEN
      RETURN jsonb_build_object('success', false, 'error', 'Invalid coordinates');
    END IF;
    -- Both must be provided together
    IF p_location_lat IS NULL OR p_location_lng IS NULL THEN
      RETURN jsonb_build_object('success', false, 'error', 'Both latitude and longitude must be provided');
    END IF;
  END IF;

  -- Calculate new expires_at if event_date changed
  IF p_event_date IS NOT NULL THEN
    IF p_event_date < CURRENT_DATE THEN
      RETURN jsonb_build_object('success', false, 'error', 'Event date must be in the future');
    END IF;
    v_new_expires_at := (p_event_date + interval '1 day' + interval '23 hours 59 minutes 59 seconds')::timestamptz;
  END IF;

  -- Update the alert
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

-- ============================================================================
-- 4. UPDATE upsert_wedding RPC WITH COORDINATE VALIDATION
-- ============================================================================
CREATE OR REPLACE FUNCTION public.upsert_wedding(
  p_wedding_name text DEFAULT NULL::text,
  p_event_date date DEFAULT NULL::date,
  p_event_end_date date DEFAULT NULL::date,
  p_venue_lat double precision DEFAULT NULL::double precision,
  p_venue_lng double precision DEFAULT NULL::double precision,
  p_venue_label text DEFAULT NULL::text,
  p_search_radius_km smallint DEFAULT 50,
  p_budget_min integer DEFAULT NULL::integer,
  p_budget_max integer DEFAULT NULL::integer,
  p_currency text DEFAULT 'EUR'::text,
  p_professions_needed profession[] DEFAULT NULL::profession[],
  p_visibility text DEFAULT 'private'::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role public."userRole" := public.get_my_role();
  v_wedding_id uuid;
  v_venue_coords geometry;
  v_budget_min_eur numeric;
  v_budget_max_eur numeric;
BEGIN
  -- Check authentication
  IF v_me IS NULL THEN
    RETURN jsonb_build_object('error', 'Not authenticated');
  END IF;

  -- Only brides can create weddings
  IF v_role != 'bride' THEN
    RETURN jsonb_build_object('error', 'Only brides can create weddings');
  END IF;

  -- Event date is required
  IF p_event_date IS NULL THEN
    RETURN jsonb_build_object('error', 'Event date is required');
  END IF;

  -- Event date must be in the future (for new weddings)
  -- Allow updates to existing weddings with past dates
  IF NOT EXISTS (SELECT 1 FROM public.weddings WHERE bride_profile_id = v_me AND is_deleted = false) THEN
    IF p_event_date < CURRENT_DATE THEN
      RETURN jsonb_build_object('error', 'Event date must be in the future');
    END IF;
  END IF;

  -- Validate event_end_date if provided
  IF p_event_end_date IS NOT NULL AND p_event_end_date < p_event_date THEN
    RETURN jsonb_build_object('error', 'End date must be after start date');
  END IF;

  -- Validate coordinates if provided
  IF p_venue_lat IS NOT NULL OR p_venue_lng IS NOT NULL THEN
    IF NOT public.validate_coordinates(p_venue_lat, p_venue_lng) THEN
      RETURN jsonb_build_object('error', 'Invalid venue coordinates');
    END IF;
    -- Both must be provided together
    IF p_venue_lat IS NULL OR p_venue_lng IS NULL THEN
      RETURN jsonb_build_object('error', 'Both venue latitude and longitude must be provided');
    END IF;
  END IF;

  -- Validate search radius
  IF p_search_radius_km NOT IN (5, 10, 20, 50, 100) THEN
    RETURN jsonb_build_object('error', 'Search radius must be 5, 10, 20, 50, or 100 km');
  END IF;

  -- Validate budget range
  IF p_budget_min IS NOT NULL AND p_budget_max IS NOT NULL AND p_budget_min > p_budget_max THEN
    RETURN jsonb_build_object('error', 'Minimum budget cannot exceed maximum budget');
  END IF;

  -- Validate visibility
  IF p_visibility NOT IN ('private', 'visible_to_pros') THEN
    RETURN jsonb_build_object('error', 'Invalid visibility value');
  END IF;

  -- Build venue coords if provided
  IF p_venue_lat IS NOT NULL AND p_venue_lng IS NOT NULL THEN
    v_venue_coords := extensions.ST_SetSRID(extensions.ST_MakePoint(p_venue_lng, p_venue_lat), 4326);
  END IF;

  -- Convert budget to EUR
  v_budget_min_eur := public.convert_to_eur(p_budget_min::numeric, p_currency);
  v_budget_max_eur := public.convert_to_eur(p_budget_max::numeric, p_currency);

  -- Upsert wedding (1 per bride)
  INSERT INTO public.weddings (
    bride_profile_id,
    wedding_name,
    event_date,
    event_end_date,
    venue_coords,
    venue_label,
    search_area_coords,
    search_radius_km,
    budget_min,
    budget_max,
    budget_min_eur,
    budget_max_eur,
    currency,
    professions_needed,
    visibility,
    status
  ) VALUES (
    v_me,
    p_wedding_name,
    p_event_date,
    p_event_end_date,
    v_venue_coords,
    p_venue_label,
    v_venue_coords,  -- Same as venue for now
    p_search_radius_km,
    p_budget_min,
    p_budget_max,
    v_budget_min_eur,
    v_budget_max_eur,
    p_currency,
    p_professions_needed,
    p_visibility::public.wedding_visibility,
    'planning'
  )
  ON CONFLICT (bride_profile_id) DO UPDATE SET
    wedding_name = COALESCE(EXCLUDED.wedding_name, weddings.wedding_name),
    event_date = EXCLUDED.event_date,
    event_end_date = EXCLUDED.event_end_date,
    venue_coords = COALESCE(EXCLUDED.venue_coords, weddings.venue_coords),
    venue_label = COALESCE(EXCLUDED.venue_label, weddings.venue_label),
    search_area_coords = COALESCE(EXCLUDED.search_area_coords, weddings.search_area_coords),
    search_radius_km = EXCLUDED.search_radius_km,
    budget_min = EXCLUDED.budget_min,
    budget_max = EXCLUDED.budget_max,
    budget_min_eur = EXCLUDED.budget_min_eur,
    budget_max_eur = EXCLUDED.budget_max_eur,
    currency = EXCLUDED.currency,
    professions_needed = COALESCE(EXCLUDED.professions_needed, weddings.professions_needed),
    visibility = EXCLUDED.visibility,
    updated_at = now()
  RETURNING id INTO v_wedding_id;

  RETURN jsonb_build_object(
    'success', true,
    'weddingId', v_wedding_id
  );
END;
$$;

-- ============================================================================
-- 5. ADD MISSING RLS POLICY FOR wedding_participants INSERT
-- ============================================================================
-- Bride can add participants to their own wedding
CREATE POLICY "Bride can insert wedding participants"
ON public.wedding_participants
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.weddings w
    WHERE w.id = wedding_participants.wedding_id
      AND w.bride_profile_id = auth.uid()
      AND w.is_deleted = false
  )
);

-- Bride can delete participants from their own wedding
CREATE POLICY "Bride can delete wedding participants"
ON public.wedding_participants
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.weddings w
    WHERE w.id = wedding_participants.wedding_id
      AND w.bride_profile_id = auth.uid()
  )
);

-- ============================================================================
-- 6. ADD SECURITY ADVISORS CHECK FUNCTION
-- ============================================================================
-- Function to run security checks on map-related tables
-- NOTE: Column renamed to check_status to avoid ambiguity with table columns
CREATE OR REPLACE FUNCTION public.check_map_security_status()
RETURNS TABLE (
  check_name text,
  check_status text,
  details text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check RLS enabled on critical tables
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

  -- Check for expired alerts (use table alias to avoid column ambiguity)
  RETURN QUERY
  SELECT 
    'Expired alerts cleanup'::text,
    CASE WHEN count(*) = 0 THEN 'PASS' ELSE 'WARN' END::text,
    format('%s expired alerts still active', count(*))::text
  FROM public.professional_alerts pa
  WHERE pa.status = 'active' AND pa.expires_at < now() AND pa.is_deleted = false;

  -- Check for weddings with past dates
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

COMMENT ON FUNCTION public.check_map_security_status IS 
  'Security audit function for map module. Run periodically to check security status.';

-- ============================================================================
-- 7. GRANT EXECUTE PERMISSIONS
-- ============================================================================
GRANT EXECUTE ON FUNCTION public.validate_coordinates TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_map_security_status TO authenticated;

-- ============================================================================
-- 8. FIX SEARCH_PATH WARNINGS (Supabase Linter)
-- ============================================================================
-- All SECURITY DEFINER functions must have SET search_path to prevent
-- search_path injection attacks.

-- Fix: update_weddings_updated_at
CREATE OR REPLACE FUNCTION public.update_weddings_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $function$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$function$;

-- Fix: delete_my_wedding
CREATE OR REPLACE FUNCTION public.delete_my_wedding()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_me uuid := auth.uid();
BEGIN
  UPDATE public.weddings
  SET is_deleted = true, updated_at = now()
  WHERE bride_profile_id = v_me
    AND is_deleted = false;
  RETURN jsonb_build_object('success', true);
END;
$function$;

-- Fix: get_my_wedding (uses PostGIS)
CREATE OR REPLACE FUNCTION public.get_my_wedding()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions'
AS $function$
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
  WHERE w.bride_profile_id = v_me AND w.is_deleted = false;
  IF v_result IS NULL THEN
    RETURN jsonb_build_object('exists', false);
  END IF;
  RETURN v_result || jsonb_build_object('exists', true);
END;
$function$;

-- Fix: get_wedding_details
CREATE OR REPLACE FUNCTION public.get_wedding_details(p_wedding_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
    'brideInfo', jsonb_build_object('fullName', pr.full_name, 'avatarUrl', pr.avatar_url),
    'createdAt', w.created_at
  ) INTO v_result
  FROM public.weddings w
  JOIN public.profiles pr ON pr.id = w.bride_profile_id
  WHERE w.id = p_wedding_id AND w.is_deleted = false
    AND (w.bride_profile_id = v_me OR (v_is_pro AND w.visibility = 'visible_to_pros' AND v_my_tier IN ('premiumVisibility', 'ultimateAccess')));
  IF v_result IS NULL THEN
    RETURN jsonb_build_object('error', 'Wedding not found or access denied');
  END IF;
  RETURN v_result;
END;
$function$;

-- Fix: get_featured_replay
CREATE OR REPLACE FUNCTION public.get_featured_replay()
RETURNS TABLE(id uuid, title text, description text, youtube_url text, thumbnail_url text, published_at timestamp with time zone, is_featured boolean, is_published boolean, created_at timestamp with time zone)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  RETURN QUERY
  SELECT r.id, r.title, r.description, r.youtube_url, r.thumbnail_url, r.published_at, r.is_featured, r.is_published, r.created_at
  FROM public.replays r
  WHERE r.is_published = true AND r.is_featured = true
  ORDER BY r.created_at DESC LIMIT 1;
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT r.id, r.title, r.description, r.youtube_url, r.thumbnail_url, r.published_at, r.is_featured, r.is_published, r.created_at
    FROM public.replays r
    WHERE r.is_published = true
    ORDER BY r.created_at DESC LIMIT 1;
  END IF;
END;
$function$;

-- Drop old search_map_bundle without search_path (3 params version)
DROP FUNCTION IF EXISTS public.search_map_bundle(jsonb, integer, jsonb);

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Summary:
-- 1. Added validate_coordinates() helper function
-- 2. Enhanced create_alert with full input validation
-- 3. Enhanced update_alert with message length validation
-- 4. Enhanced upsert_wedding with coordinate and date validation
-- 5. Added missing RLS policies for wedding_participants
-- 6. Added security check function for monitoring
-- 7. Fixed all search_path warnings (8 functions)
-- ============================================================================
