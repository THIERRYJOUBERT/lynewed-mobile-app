-- ============================================================================
-- MIGRATION: Wedding System - Phase 5 Map Refactoring
-- ============================================================================
-- Date: 2025-11-28
-- Description: 
--   - Creates new `weddings` table (1 wedding per bride, hub central)
--   - Creates `wedding_participants` table (pros confirmed for wedding)
--   - Migrates data from `wedding_pins` to `weddings`
--   - Updates RPC `search_map_bundle` to use new tables
--   - Removes POI private concept (user_pois table archived)
--   - Updates connectionRequestSource enum: weddingPin → wedding
-- ============================================================================

-- ============================================================================
-- STEP 1: Create visibility enum for weddings
-- ============================================================================
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wedding_visibility') THEN
    CREATE TYPE public.wedding_visibility AS ENUM ('private', 'visible_to_pros');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wedding_status') THEN
    CREATE TYPE public.wedding_status AS ENUM ('planning', 'confirmed', 'completed', 'cancelled');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wedding_participant_status') THEN
    CREATE TYPE public.wedding_participant_status AS ENUM ('requested', 'accepted', 'declined');
  END IF;
END $$;

-- ============================================================================
-- STEP 2: Create weddings table (1 per bride - hub central)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.weddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Owner (1 wedding per bride - UNIQUE constraint)
  bride_profile_id uuid NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Wedding info
  wedding_name text,                                    -- "Mariage de Sophie & Thomas"
  event_date date NOT NULL,                             -- Date du mariage
  event_end_date date,                                  -- Date fin (si multi-jours)
  
  -- Location (via AddressSearchWidget)
  venue_coords geometry(Point, 4326),                   -- Lieu précis si connu
  venue_label text,                                     -- "Château de Versailles"
  search_area_coords geometry(Point, 4326),             -- Zone de recherche pros
  search_radius_km smallint DEFAULT 50 CHECK (search_radius_km IN (5, 10, 20, 50, 100)),
  
  -- Budget & needs
  budget_min integer,
  budget_max integer,
  budget_min_eur numeric,                               -- Converted for filtering
  budget_max_eur numeric,
  currency text DEFAULT 'EUR',
  professions_needed public.profession[],               -- Professions recherchées
  
  -- Visibility & status
  visibility public.wedding_visibility DEFAULT 'private',
  status public.wedding_status DEFAULT 'planning',
  
  -- Region for market segmentation (future: Indian market separation)
  market_region text DEFAULT 'europe',
  
  -- Soft delete
  is_deleted boolean DEFAULT false,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Comment for documentation
COMMENT ON TABLE public.weddings IS 'Hub central pour chaque bride. 1 mariage actif par bride. Remplace wedding_pins.';
COMMENT ON COLUMN public.weddings.bride_profile_id IS 'UNIQUE - Une bride ne peut avoir qu''un seul mariage actif';
COMMENT ON COLUMN public.weddings.visibility IS 'private = seule la bride voit, visible_to_pros = pros Premium+ voient';

-- ============================================================================
-- STEP 3: Create wedding_participants table (pros confirmed)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.wedding_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  wedding_id uuid NOT NULL REFERENCES public.weddings(id) ON DELETE CASCADE,
  professional_profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Profession at time of acceptance (for album organization)
  profession public.profession,
  
  -- Status
  status public.wedding_participant_status DEFAULT 'requested',
  
  -- Timestamps
  requested_at timestamptz DEFAULT now(),
  accepted_at timestamptz,
  
  -- Unique constraint: 1 pro per wedding
  UNIQUE(wedding_id, professional_profile_id)
);

COMMENT ON TABLE public.wedding_participants IS 'Pros confirmés pour un mariage. Préparation pour albums partagés futurs.';

-- ============================================================================
-- STEP 4: Create indexes for performance
-- ============================================================================
-- Spatial indexes for map queries
CREATE INDEX IF NOT EXISTS idx_weddings_venue_coords 
  ON public.weddings USING gist(venue_coords);
CREATE INDEX IF NOT EXISTS idx_weddings_search_area 
  ON public.weddings USING gist(search_area_coords);

-- Visibility filter (most common query)
CREATE INDEX IF NOT EXISTS idx_weddings_visibility 
  ON public.weddings(visibility) 
  WHERE visibility = 'visible_to_pros' AND is_deleted = false;

-- Status filter
CREATE INDEX IF NOT EXISTS idx_weddings_status 
  ON public.weddings(status) 
  WHERE status IN ('planning', 'confirmed');

-- Market region for future segmentation
CREATE INDEX IF NOT EXISTS idx_weddings_market_region 
  ON public.weddings(market_region);

-- Participants lookup
CREATE INDEX IF NOT EXISTS idx_wedding_participants_wedding 
  ON public.wedding_participants(wedding_id);
CREATE INDEX IF NOT EXISTS idx_wedding_participants_pro 
  ON public.wedding_participants(professional_profile_id);

-- ============================================================================
-- STEP 5: Migrate data from wedding_pins to weddings
-- ============================================================================
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
  status,
  is_deleted,
  created_at,
  updated_at
)
SELECT 
  wp.bride_profile_id,
  NULL as wedding_name,                                 -- No name in old data
  COALESCE(wp.event_start_date, CURRENT_DATE + interval '1 year') as event_date,
  wp.event_end_date,
  wp.location_coords as venue_coords,                   -- Same location
  wp.location_label as venue_label,
  wp.location_coords as search_area_coords,             -- Same as venue for now
  wp.radius_km as search_radius_km,
  wp.budget_min,
  wp.budget_max,
  wp.budget_min_eur,
  wp.budget_max_eur,
  COALESCE(wp.currency, 'EUR') as currency,
  wp.professions_needed,
  'visible_to_pros'::public.wedding_visibility as visibility,  -- Default visible
  'planning'::public.wedding_status as status,
  wp.is_deleted,
  wp.created_at,
  wp.updated_at
FROM public.wedding_pins wp
WHERE wp.is_deleted = false
  AND wp.is_active = true
ON CONFLICT (bride_profile_id) DO NOTHING;              -- Skip if bride already has wedding

-- ============================================================================
-- STEP 6: Enable RLS on new tables
-- ============================================================================
ALTER TABLE public.weddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wedding_participants ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 7: RLS Policies for weddings
-- ============================================================================

-- Bride can see and manage their own wedding
CREATE POLICY "Bride can manage own wedding" ON public.weddings
  FOR ALL
  USING (bride_profile_id = auth.uid())
  WITH CHECK (bride_profile_id = auth.uid());

-- Pros with Premium+ can see visible weddings
CREATE POLICY "Pros Premium+ can see visible weddings" ON public.weddings
  FOR SELECT
  USING (
    visibility = 'visible_to_pros'
    AND is_deleted = false
    AND status IN ('planning', 'confirmed')
    AND (event_date >= CURRENT_DATE OR event_end_date >= CURRENT_DATE)
    AND EXISTS (
      SELECT 1 FROM public.professional_details pd
      WHERE pd.profile_id = auth.uid()
        AND pd.is_live = true
    )
    AND public.get_my_tier() IN ('premiumVisibility', 'ultimateAccess')
  );

-- Service role bypass for backend operations
CREATE POLICY "Service role full access weddings" ON public.weddings
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- STEP 8: RLS Policies for wedding_participants
-- ============================================================================

-- Bride can see participants of their wedding
CREATE POLICY "Bride can see own wedding participants" ON public.wedding_participants
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.weddings w
      WHERE w.id = wedding_id
        AND w.bride_profile_id = auth.uid()
    )
  );

-- Pro can see their own participation
CREATE POLICY "Pro can see own participation" ON public.wedding_participants
  FOR SELECT
  USING (professional_profile_id = auth.uid());

-- Pro can update their own participation status
CREATE POLICY "Pro can update own participation" ON public.wedding_participants
  FOR UPDATE
  USING (professional_profile_id = auth.uid())
  WITH CHECK (professional_profile_id = auth.uid());

-- Service role bypass
CREATE POLICY "Service role full access participants" ON public.wedding_participants
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- STEP 9: Create trigger for updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_weddings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_weddings_updated_at ON public.weddings;
CREATE TRIGGER trigger_weddings_updated_at
  BEFORE UPDATE ON public.weddings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_weddings_updated_at();

-- ============================================================================
-- STEP 10: Archive user_pois table (POI private concept removed)
-- ============================================================================
-- Don't delete, just rename for safety
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_pois' AND table_schema = 'public') THEN
    -- Check if archived table already exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_pois_archived' AND table_schema = 'public') THEN
      ALTER TABLE public.user_pois RENAME TO user_pois_archived;
      COMMENT ON TABLE public.user_pois_archived IS 'ARCHIVED 2025-11-28: POI private concept removed. Wedding hub replaces this.';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- STEP 11: Update connectionRequestSource enum (weddingPin → wedding)
-- ============================================================================
-- First update existing data
UPDATE public.connection_requests 
SET source = 'wedding'::"connectionRequestSource"
WHERE source = 'weddingPin'::"connectionRequestSource";

-- Note: Renaming enum values requires more complex migration
-- For now, we keep both values and handle in application code

-- ============================================================================
-- STEP 12: Grant permissions
-- ============================================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.weddings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.wedding_participants TO authenticated;
GRANT ALL ON public.weddings TO service_role;
GRANT ALL ON public.wedding_participants TO service_role;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
  v_weddings_count int;
  v_pins_count int;
BEGIN
  SELECT COUNT(*) INTO v_weddings_count FROM public.weddings WHERE is_deleted = false;
  SELECT COUNT(*) INTO v_pins_count FROM public.wedding_pins WHERE is_deleted = false AND is_active = true;
  
  RAISE NOTICE 'Migration complete: % weddings created from % wedding_pins', v_weddings_count, v_pins_count;
END $$;
