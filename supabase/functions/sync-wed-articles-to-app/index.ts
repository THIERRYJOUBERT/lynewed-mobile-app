import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.75.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    console.log('🚀 Sync wed_articles to app triggered');

    // Connect to CRM database (current project)
    const supabaseCRM = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Connect to APP database (target project)
    const supabaseApp = createClient(
      Deno.env.get('APP_SUPABASE_URL') ?? '',
      Deno.env.get('APP_SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Fetch all wed_articles from CRM
    const { data: articles, error: fetchError } = await supabaseCRM
      .from('wed_articles')
      .select('*')
      .order('created_at', { ascending: false });

    if (fetchError) {
      console.error('❌ Error fetching wed_articles:', fetchError);
      throw fetchError;
    }

    console.log(`📋 Found ${articles?.length || 0} articles to sync`);

    if (!articles || articles.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'No articles to sync',
          synced_count: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Delete all existing articles in app (for clean sync)
    const { error: deleteError } = await supabaseApp
      .from('wed_articles')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all

    if (deleteError) {
      console.error('❌ Error deleting existing articles:', deleteError);
      throw deleteError;
    }

    console.log('✅ Cleared existing articles in app');

    // Normalize data (ensure title and content_blocks)
    const normalized = articles.map((a: any) => {
      const hasTitle = a && a.title && Object.keys(a.title || {}).length > 0;
      const title = hasTitle ? a.title : { en: 'Wedding of the Week', fr: 'Wedding of the Week' };
      const content_blocks = Array.isArray(a?.content_blocks) ? a.content_blocks : [];
      // Ensure published_at if published
      const published_at = a.is_published && !a.published_at ? new Date().toISOString() : a.published_at;
      return { ...a, title, content_blocks, published_at };
    });

    // Insert all articles to app database
    const { error: insertError } = await supabaseApp
      .from('wed_articles')
      .insert(normalized);

    if (insertError) {
      console.error('❌ Error inserting articles:', insertError);
      throw insertError;
    }

    console.log(`✅ ${articles.length} articles synced successfully`);

    return new Response(
      JSON.stringify({ 
        success: true, 
        synced_count: articles.length,
        articles: articles.map(a => ({ id: a.id, is_published: a.is_published }))
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('❌ Sync error:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: errorMessage
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});
