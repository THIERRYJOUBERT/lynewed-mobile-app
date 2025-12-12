-- Add RPC to fetch a specific WOTW article with the same payload format as get_latest_wed_article

CREATE OR REPLACE FUNCTION public.get_wed_article_by_id(
  p_article_id uuid,
  p_lang text DEFAULT 'en'
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions'
AS $$
DECLARE
  v_article_data jsonb;
  v_lang TEXT := lower(p_lang);
  v_my_market text := public.get_my_market_region();
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
            WHEN (block->>'type') = 'video' THEN
              jsonb_build_object(
                'type', 'video',
                'text', null,
                'imageUrls', jsonb_build_array(COALESCE(block->>'url', ''))
              )
            ELSE
              jsonb_build_object(
                'type', block->>'type',
                'text', null,
                'imageUrls', COALESCE(block->'urls', '[]'::jsonb),
                'layout', block->>'layout',
                'columns', (block->>'columns')::int
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
        'websiteUrl', pd.website_url,
        'socials', jsonb_build_object(
          'instagramUrl', pd.instagram_url,
          'websiteUrl', pd.website_url
        )
      )
    )
  INTO v_article_data
  FROM public.wed_articles wa
  JOIN public.profiles p ON p.id = wa.linked_pro_profile_id
  LEFT JOIN public.professional_details pd ON pd.profile_id = wa.linked_pro_profile_id
  WHERE wa.is_published = true
    AND wa.id = p_article_id
    AND (
      wa.target_region = 'all'
      OR (v_my_market = 'IN' AND wa.target_region = 'IN')
      OR (v_my_market = 'GLOBAL' AND wa.target_region = 'ROW')
    )
  LIMIT 1;

  RETURN COALESCE(v_article_data, '{}'::jsonb);
END;
$$;

GRANT ALL ON FUNCTION public.get_wed_article_by_id(uuid, text) TO authenticator;
GRANT ALL ON FUNCTION public.get_wed_article_by_id(uuid, text) TO service_role;
