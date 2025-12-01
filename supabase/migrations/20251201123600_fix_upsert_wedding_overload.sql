-- ============================================================================
-- Migration: Fix upsert_wedding function overload conflict
-- Date: 2025-12-01
-- Description: Remove duplicate upsert_wedding function that was causing
--              PostgrestException PGRST203 (Multiple Choices)
-- ============================================================================

-- Drop the old version with profession[] and smallint types
-- Keep the version with text[] and integer types (compatible with current code)
DROP FUNCTION IF EXISTS public.upsert_wedding(
  text, date, date, 
  double precision, double precision, text, 
  smallint, integer, integer, text, 
  profession[], text
);

-- Note: The remaining function signature is:
-- upsert_wedding(
--   p_wedding_name text,
--   p_event_date date,
--   p_event_end_date date,
--   p_venue_label text,
--   p_venue_lat double precision,
--   p_venue_lng double precision,
--   p_search_radius_km integer,
--   p_budget_min integer,
--   p_budget_max integer,
--   p_currency text,
--   p_professions_needed text[],
--   p_visibility text
-- )
