import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.75.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ProfessionalData {
  profile_id: string;
  business_name: string;
  description: string | null;
  portfolio_images: string[];
  slideshow_images: string[];
  profile_video_url: string | null;
  budget_min: number | null;
  budget_max: number | null;
  currency: string | null;
  instagram_url: string | null;
  website_url: string | null;
  location_label: string | null;
  location_city: string | null;
  location_country_code: string | null;
  profession: string;
  is_live: boolean;
  is_pending: boolean;
  budget_min_eur: number | null;
  budget_max_eur: number | null;
  wishlist_count: number;
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    console.log('🚀 Sync professional to app triggered');

    // Get the profile_id from the request body
    const { profile_id } = await req.json();
    
    if (!profile_id) {
      throw new Error('profile_id is required');
    }

    console.log(`📋 Syncing profile: ${profile_id}`);

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

    // Fetch professional data from CRM
    const { data: professionalData, error: fetchError } = await supabaseCRM
      .from('professional_details')
      .select('*')
      .eq('profile_id', profile_id)
      .single();

    if (fetchError) {
      console.error('❌ Error fetching professional data:', fetchError);
      throw fetchError;
    }

    if (!professionalData) {
      throw new Error('Professional not found');
    }

    console.log(`✅ Fetched data for: ${professionalData.business_name}`);

    // Fetch fixed locations
    const { data: fixedLocations } = await supabaseCRM
      .from('professional_fixed_locations')
      .select('*')
      .eq('professional_profile_id', profile_id);

    console.log(`📍 Found ${fixedLocations?.length || 0} fixed locations`);

    // Fetch profile data
    const { data: profileData } = await supabaseCRM
      .from('profiles')
      .select('full_name, avatar_url, country')
      .eq('id', profile_id)
      .single();

    // Fetch subscription data
    const { data: subscriptionData } = await supabaseCRM
      .from('professional_subscriptions')
      .select('subscription_tier, trial_ends_at, stripe_customer_id, stripe_subscription_id')
      .eq('profile_id', profile_id)
      .single();

    // Prepare data for app database
    const dataToSync: ProfessionalData = {
      profile_id: professionalData.profile_id,
      business_name: professionalData.business_name,
      description: professionalData.description,
      portfolio_images: professionalData.portfolio_images || [],
      slideshow_images: professionalData.slideshow_images || [],
      profile_video_url: professionalData.profile_video_url,
      budget_min: professionalData.budget_min,
      budget_max: professionalData.budget_max,
      currency: professionalData.currency,
      instagram_url: professionalData.instagram_url,
      website_url: professionalData.website_url,
      location_label: professionalData.location_label,
      location_city: professionalData.location_city,
      location_country_code: professionalData.location_country_code,
      profession: professionalData.profession,
      is_live: professionalData.is_live,
      is_pending: professionalData.is_pending,
      budget_min_eur: professionalData.budget_min_eur,
      budget_max_eur: professionalData.budget_max_eur,
      wishlist_count: professionalData.wishlist_count || 0,
    };

    // Upsert professional details to app database
    const { error: upsertError } = await supabaseApp
      .from('professional_details')
      .upsert(dataToSync, { onConflict: 'profile_id' });

    if (upsertError) {
      console.error('❌ Error upserting professional details:', upsertError);
      throw upsertError;
    }

    console.log('✅ Professional details synced');

    // Sync profile data if exists
    if (profileData) {
      const { error: profileError } = await supabaseApp
        .from('profiles')
        .upsert({
          id: profile_id,
          full_name: profileData.full_name,
          avatar_url: profileData.avatar_url,
          country: profileData.country,
        }, { onConflict: 'id' });

      if (profileError) {
        console.error('❌ Error syncing profile:', profileError);
      } else {
        console.log('✅ Profile synced');
      }
    }

    // Sync subscription data if exists
    if (subscriptionData) {
      const { error: subError } = await supabaseApp
        .from('professional_subscriptions')
        .upsert({
          profile_id: profile_id,
          subscription_tier: subscriptionData.subscription_tier,
          trial_ends_at: subscriptionData.trial_ends_at,
          stripe_customer_id: subscriptionData.stripe_customer_id,
          stripe_subscription_id: subscriptionData.stripe_subscription_id,
        }, { onConflict: 'profile_id' });

      if (subError) {
        console.error('❌ Error syncing subscription:', subError);
      } else {
        console.log('✅ Subscription synced');
      }
    }

    // Delete existing fixed locations in app
    if (fixedLocations && fixedLocations.length > 0) {
      await supabaseApp
        .from('professional_fixed_locations')
        .delete()
        .eq('professional_profile_id', profile_id);

      // Insert new fixed locations
      const { error: locError } = await supabaseApp
        .from('professional_fixed_locations')
        .insert(
          fixedLocations.map((loc) => ({
            professional_profile_id: profile_id,
            label: loc.label,
            location_coords: loc.location_coords,
          }))
        );

      if (locError) {
        console.error('❌ Error syncing fixed locations:', locError);
      } else {
        console.log(`✅ ${fixedLocations.length} fixed locations synced`);
      }
    }

    // Log sync event in CRM
    await supabaseCRM.from('sync_log').insert({
      pro_id: profile_id,
      operation: 'validation_sync',
      status: 'success',
    });

    console.log('🎉 Sync completed successfully');

    return new Response(
      JSON.stringify({ 
        success: true, 
        profile_id,
        synced_items: {
          professional_details: true,
          profile: !!profileData,
          subscription: !!subscriptionData,
          fixed_locations: fixedLocations?.length || 0,
        }
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
