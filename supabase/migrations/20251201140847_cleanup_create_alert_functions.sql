-- ============================================================================
-- Migration: Cleanup create_alert function overloads
-- Date: 2025-12-01
-- Description: Remove old versions and create single clean version
-- ============================================================================

-- Drop ALL existing create_alert functions
DROP FUNCTION IF EXISTS public.create_alert(text, text, double precision, double precision, integer, text, date, text);
DROP FUNCTION IF EXISTS public.create_alert(text, text, double precision, double precision, integer, text, date, text, text);
DROP FUNCTION IF EXISTS public.create_alert(alert_type, text, text, date, double precision, double precision, text, smallint, profession);

-- Create single clean version matching Flutter code
CREATE OR REPLACE FUNCTION public.create_alert(
  p_alert_type text DEFAULT 'backup_needed',
  p_title text DEFAULT '',
  p_message text DEFAULT '',
  p_event_date date DEFAULT NULL,
  p_location_lat double precision DEFAULT NULL,
  p_location_lng double precision DEFAULT NULL,
  p_location_label text DEFAULT '',
  p_radius_km integer DEFAULT 50,
  p_profession_needed text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions'
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
  FROM public.alerts
  WHERE author_profile_id = v_me
    AND status = 'active'
    AND expires_at > now();
  
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

  -- Insert alert
  INSERT INTO public.alerts (
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
