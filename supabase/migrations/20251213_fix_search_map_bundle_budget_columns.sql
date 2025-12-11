-- Fix search_map_bundle function to use correct budget columns
-- The weddings table was updated in Sprint 2 to use budget_min/budget_max instead of budget_min_eur/budget_max_eur
-- But the search_map_bundle function was still referencing the old columns

-- Drop the 3-parameter version (unused)
DROP FUNCTION IF EXISTS public.search_map_bundle(jsonb, integer, jsonb);

-- Update the 4-parameter version (used by Flutter app)
CREATE OR REPLACE FUNCTION public.search_map_bundle(
  p_bbox_coords jsonb,
  p_viewer_role text,
  p_filters jsonb,
  p_zoom integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_bbox extensions.geometry;

  v_me uuid := auth.uid();
  v_role public."userRole" := public.get_my_role();
  v_is_pro boolean := (v_role = 'professional');
  v_my_tier public."subscriptionTierType" := public.get_my_tier();
  v_my_profession public.profession;
  
  v_my_market text := public.get_my_market_region();

  v_prof_filter text[];
  v_currency text;
  v_budget_min numeric;
  v_budget_max numeric;

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
  v_budget_min := NULLIF(p_filters->>'budgetMin','')::numeric;
  v_budget_max := NULLIF(p_filters->>'budgetMax','')::numeric;

  IF v_is_pro AND v_me IS NOT NULL THEN
    SELECT pd.profession INTO v_my_profession
    FROM public.professional_details pd
    WHERE pd.profile_id = v_me;
  END IF;

  -- Fixed locations
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
            (v_budget_min IS NULL AND v_budget_max IS NULL)
            OR (pd.budget_min_eur IS NOT NULL AND pd.budget_max_eur IS NOT NULL
              AND (v_budget_min IS NULL OR pd.budget_max_eur >= v_budget_min)
              AND (v_budget_max IS NULL OR pd.budget_min_eur <= v_budget_max))
          )
        ORDER BY fl.created_at DESC
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_fixed := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int;

  -- Alerts
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

  -- Weddings - using budget_min/budget_max (not _eur)
  IF t_show_weddings THEN
    WITH visible_weddings AS (
      SELECT
        w.id,
        w.bride_profile_id,
        w.venue_coords,
        w.professions_needed,
        w.budget_min,
        w.budget_max,
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
              (v_budget_min IS NULL AND v_budget_max IS NULL)
              OR (w.budget_min IS NOT NULL AND w.budget_max IS NOT NULL
                AND (v_budget_min IS NULL OR w.budget_max >= v_budget_min)
                AND (v_budget_max IS NULL OR w.budget_min <= v_budget_max))
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

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
