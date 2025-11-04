-- ============================================================================
-- FIX CRITIQUE : Corriger le search_path de search_map_bundle
-- ============================================================================
-- PROBLÈME : Le type "geometry" n'existe pas car PostGIS est dans le schéma
--            "extensions" mais le search_path ne l'inclut pas
-- SOLUTION : Ajouter "extensions" au search_path de la fonction
-- ============================================================================

CREATE OR REPLACE FUNCTION public.search_map_bundle(
  p_bbox_coords jsonb,
  p_viewer_role text,
  p_filters jsonb,
  p_zoom integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'  -- ✅ AJOUT DE 'extensions'
AS $function$
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
$function$;

-- ============================================================================
-- VÉRIFICATION : Tester que la fonction fonctionne maintenant
-- ============================================================================
-- Décommentez pour tester après avoir appliqué le fix :
-- SELECT search_map_bundle(
--   '{"min_lat": 48.8, "max_lat": 48.9, "min_lng": 2.3, "max_lng": 2.4}'::jsonb,
--   'bride',
--   '{}'::jsonb,
--   12
-- );
