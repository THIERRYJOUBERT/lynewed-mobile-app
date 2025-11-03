import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.75.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { articleId } = await req.json();
    
    if (!articleId) {
      throw new Error('Article ID is required');
    }

    console.log('🔄 [SYNC] Starting sync for article:', articleId);

    // Get article from admin DB
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { data: article, error: fetchError } = await supabaseAdmin
      .from('wed_articles')
      .select('*')
      .eq('id', articleId)
      .single();

    if (fetchError) {
      throw new Error(`Failed to fetch article: ${fetchError.message}`);
    }

    console.log('✅ [SYNC] Article fetched:', article.id);

    // Get CRM credentials from secrets
    const crmUrl = Deno.env.get('CRM_SUPABASE_URL');
    const crmKey = Deno.env.get('CRM_SUPABASE_SERVICE_KEY');

    if (!crmUrl || !crmKey) {
      throw new Error('CRM credentials not configured');
    }

    // Create CRM client
    const supabaseCRM = createClient(crmUrl, crmKey);

    // Prepare data for CRM
    const crmData = {
      id: article.id,
      linked_pro_profile_id: article.linked_pro_profile_id,
      cover_images: article.cover_images,
      title: article.title,
      content_blocks: article.content_blocks,
      is_published: article.is_published,
      published_at: article.published_at,
      created_at: article.created_at,
      updated_at: article.updated_at,
    };

    console.log('📤 [SYNC] Syncing to CRM...');

    // Upsert to CRM
    const { error: syncError } = await supabaseCRM
      .from('wed_articles')
      .upsert(crmData, { onConflict: 'id' });

    if (syncError) {
      throw new Error(`Failed to sync to CRM: ${syncError.message}`);
    }

    console.log('✅ [SYNC] Article synced successfully to CRM');

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Article synced to CRM successfully',
        articleId: article.id
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    console.error('❌ [SYNC ERROR]', errorMessage);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: errorMessage 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});
