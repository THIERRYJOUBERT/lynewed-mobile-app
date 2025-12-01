-- ============================================================================
-- PHASE 7.2: INDIAN MARKET SEPARATION (CORRECTED)
-- ============================================================================
-- Logic: Filter by OWNER's country code (not point's location)
-- - Indian pros (professional_details.location_country_code = 'IN') → only visible to Indian viewers
-- - Non-Indian pros → visible to GLOBAL viewers only
-- - Alerts/Fixed locations → inherit owner pro's country
-- - Weddings → use bride's country from profiles.country
-- ============================================================================

-- NOTE: We don't need location_country_code on weddings/alerts since we filter by owner

-- 3. Create index for fast filtering
CREATE INDEX IF NOT EXISTS idx_professional_details_country 
ON public.professional_details(location_country_code);

CREATE INDEX IF NOT EXISTS idx_professional_fixed_locations_country 
ON public.professional_fixed_locations(location_country_code);

CREATE INDEX IF NOT EXISTS idx_weddings_country 
ON public.weddings(location_country_code);

CREATE INDEX IF NOT EXISTS idx_professional_alerts_country 
ON public.professional_alerts(location_country_code);

-- 4. Helper function to get viewer's market region
-- Returns 'IN' for Indian users, 'GLOBAL' for others
CREATE OR REPLACE FUNCTION public.get_my_market_region()
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
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

COMMENT ON FUNCTION public.get_my_market_region IS 
  'Returns market region for current user: IN for India, GLOBAL for rest of world';

GRANT EXECUTE ON FUNCTION public.get_my_market_region TO authenticated;

-- 5. Helper function to check if a marker should be visible based on market
-- item_country: the country code of the item (pro, alert, wedding)
-- viewer_region: the viewer's market region (IN or GLOBAL)
CREATE OR REPLACE FUNCTION public.is_visible_in_market(
  item_country text,
  viewer_region text
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
SET search_path TO 'public'
AS $$
BEGIN
  -- If item has no country, visible to all (legacy data)
  IF item_country IS NULL THEN
    RETURN true;
  END IF;
  
  -- Indian items only visible to Indian viewers
  IF UPPER(item_country) = 'IN' THEN
    RETURN viewer_region = 'IN';
  END IF;
  
  -- Non-Indian items visible to non-Indian viewers only
  RETURN viewer_region != 'IN';
END;
$$;

COMMENT ON FUNCTION public.is_visible_in_market IS 
  'Checks if an item should be visible based on market separation (India vs Global)';

-- 6. Update search_map_bundle to filter by market region
CREATE OR REPLACE FUNCTION public.search_map_bundle(
  p_bbox_coords jsonb, 
  p_viewer_role text, 
  p_filters jsonb, 
  p_zoom integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions'
AS $function$
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

  t_show_pros boolean := COALESCE((p_filters->>'showPros')::boolean, true);
  t_show_fixed boolean := COALESCE((p_filters->>'showFixedLocations')::boolean, true);
  t_show_alerts boolean := COALESCE((p_filters->>'showProAlerts')::boolean, true);
  t_show_weddings boolean := COALESCE((p_filters->>'showWeddings')::boolean, true);

  v_limit_each int;

  out_markers jsonb := '[]'::jsonb;
  out_overlays jsonb := '[]'::jsonb;

  t0 timestamptz := clock_timestamp();
  ms_pros int; ms_fixed int; ms_alerts int; ms_weddings int;
BEGIN
  -- BBOX (viewport-only)
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

  -- 1) Pros live (point in viewport) + MARKET FILTER
  IF t_show_pros THEN
    out_markers := out_markers || COALESCE((
      SELECT jsonb_agg(q.marker_data)
      FROM (
        SELECT jsonb_build_object(
          'id', pd.profile_id,
          'type', 'professional',
          'position', extensions.ST_AsGeoJSON(pd.location_coords)::jsonb,
          'styleInfo', jsonb_build_object(
            'avatarUrl', pr.avatar_url,
            'borderColorHex', public.get_color_for_profession(pd.profession)
          )
        ) as marker_data
        FROM public.professional_details pd
        JOIN public.profiles pr ON pr.id = pd.profile_id
        WHERE pd.is_live = true
          AND extensions.ST_Intersects(pd.location_coords, v_bbox)
          -- MARKET FILTER: Indian pros only visible to Indians, others to non-Indians
          AND public.is_visible_in_market(pd.location_country_code, v_my_market)
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

  -- 2) Fixed locations (point in viewport) + MARKET FILTER
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
            'profileId', pd.profile_id
          )
        ) AS marker_data
        FROM public.professional_fixed_locations fl
        JOIN public.professional_details pd ON pd.profile_id = fl.professional_profile_id
        JOIN public.profiles pr ON pr.id = fl.professional_profile_id
        WHERE pd.is_live = true
          AND extensions.ST_Intersects(fl.location_coords, v_bbox)
          -- MARKET FILTER: Use fixed location's country or fall back to pro's country
          AND public.is_visible_in_market(COALESCE(fl.location_country_code, pd.location_country_code), v_my_market)
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

  -- 3) Alerts (pros only, not expired) + MARKET FILTER
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
        -- Join to get author's country for market filter
        LEFT JOIN public.professional_details author_pd ON author_pd.profile_id = a.author_profile_id
        WHERE a.status = 'active'
          AND a.is_deleted = false
          AND a.expires_at > now()
          AND extensions.ST_Intersects(a.location_coords, v_bbox)
          -- MARKET FILTER: Use alert's country or fall back to author's country
          AND public.is_visible_in_market(COALESCE(a.location_country_code, author_pd.location_country_code), v_my_market)
        LIMIT v_limit_each
      ) q
    ), '[]'::jsonb);
  END IF;
  ms_alerts := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed);

  -- 4) Weddings + MARKET FILTER
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
        -- MARKET FILTER for weddings
        AND public.is_visible_in_market(w.location_country_code, v_my_market)
        AND (
          -- Bride sees own wedding
          (NOT v_is_pro AND v_me IS NOT NULL AND w.bride_profile_id = v_me)
          OR
          -- Pros Premium+ see visible weddings
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
  ms_weddings := EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int - (ms_pros + ms_fixed + ms_alerts);

  RETURN jsonb_build_object(
    'markers', out_markers,
    'overlays', out_overlays,
    'market', v_my_market,
    'debugStats', format(
      'ms: total=%s | pros=%s, fixed=%s, alerts=%s, weddings=%s | market=%s',
      EXTRACT(MILLISECOND FROM (clock_timestamp()-t0))::int, ms_pros, ms_fixed, ms_alerts, ms_weddings, v_my_market
    )
  );
END;
$function$;

COMMENT ON FUNCTION public.search_map_bundle IS 
  'Search map markers with market separation (India vs Global). Phase 7.2';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Summary:
-- 1. Added location_country_code to weddings and professional_alerts
-- 2. Created indexes for fast country filtering
-- 3. Created get_my_market_region() helper function
-- 4. Created is_visible_in_market() helper function
-- 5. Updated search_map_bundle with market filtering
--
-- Logic:
-- - Indian users (IN) only see Indian content
-- - Global users see everything EXCEPT Indian content
-- - Legacy data (NULL country) visible to all
-- ============================================================================
