-- ============================================================================
-- Migration: Fix upsert_wedding to handle soft-deleted weddings
-- Date: 2025-12-01
-- Description: When a bride has a soft-deleted wedding, reactivate it instead
--              of trying to create a new one (which violates unique constraint)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.upsert_wedding(
  p_wedding_name text DEFAULT NULL,
  p_event_date date DEFAULT NULL,
  p_event_end_date date DEFAULT NULL,
  p_venue_label text DEFAULT NULL,
  p_venue_lat double precision DEFAULT NULL,
  p_venue_lng double precision DEFAULT NULL,
  p_search_radius_km integer DEFAULT 50,
  p_budget_min integer DEFAULT NULL,
  p_budget_max integer DEFAULT NULL,
  p_currency text DEFAULT 'EUR',
  p_professions_needed text[] DEFAULT NULL,
  p_visibility text DEFAULT 'private'
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
