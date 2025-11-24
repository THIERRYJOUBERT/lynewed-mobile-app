-- Create RPC function to get featured replay with proper priority logic
-- Priority: is_featured = true (most recent) > most recent created_at

CREATE OR REPLACE FUNCTION get_featured_replay()
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  youtube_url text,
  thumbnail_url text,
  published_at timestamptz,
  is_featured boolean,
  is_published boolean,
  created_at timestamptz
) AS $$
BEGIN
  -- First, try to get the most recent replay with is_featured = true
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
    r.created_at
  FROM public.replays r
  WHERE r.is_published = true
    AND r.is_featured = true
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
      r.created_at
    FROM public.replays r
    WHERE r.is_published = true
    ORDER BY r.created_at DESC
    LIMIT 1;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant execute permission to authenticated and anon users
GRANT EXECUTE ON FUNCTION get_featured_replay() TO authenticated;
GRANT EXECUTE ON FUNCTION get_featured_replay() TO anon;

-- Add comment for documentation
COMMENT ON FUNCTION get_featured_replay() IS 'Returns the featured replay based on priority: is_featured=true (most recent) or most recent created_at if none featured';
