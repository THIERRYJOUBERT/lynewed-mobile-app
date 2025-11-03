import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Fonction helper pour logger les sync events
async function logSyncEvent(
  supabase: any,
  eventType: string,
  email: string,
  payload: any,
  response?: any,
  errorMessage?: string,
  httpStatus?: number,
  durationMs?: number,
  userId?: string
) {
  try {
    await supabase.from('sync_events').insert({
      event_type: eventType,
      email,
      payload,
      response,
      error_message: errorMessage,
      http_status: httpStatus,
      duration_ms: durationMs,
      user_id: userId,
      ip_address: null // Could be extracted from req headers if needed
    })
  } catch (err) {
    console.error('Failed to log sync event:', err)
  }
}

Deno.serve(async (req) => {
  const startTime = Date.now()
  
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  let payload: any
  let userEmail = 'unknown'

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    payload = await req.json()
    userEmail = payload.email || 'unknown'
    
    console.log('🔄 [SYNC START]', {
      email: userEmail,
      business_name: payload.business_name,
      timestamp: new Date().toISOString()
    })

    // Log sync attempt
    await logSyncEvent(supabaseAdmin, 'sync_attempt', userEmail, payload)

    const {
      email,
      business_name,
      description,
      profession,
      portfolio_images = [],
      slideshow_images = [],
      profile_video_url,
      budget_min,
      budget_max,
      currency,
      instagram_url,
      website_url,
      location_city,
      location_country_code,
      location_label,
      fixed_locations = []
    } = payload

    // Validate required fields
    if (!email || !business_name || !profession) {
      const errorMsg = 'Missing required fields: email, business_name, profession'
      console.error('❌ [SYNC ERROR] Validation failed:', errorMsg)
      
      const duration = Date.now() - startTime
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload, undefined, errorMsg, 400, duration)
      
      return new Response(
        JSON.stringify({ error: errorMsg }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Find user by email
    console.log('🔍 [SYNC] Searching for user with email:', email)
    const { data: userData, error: userError } = await supabaseAdmin.auth.admin.listUsers()
    
    if (userError) {
      console.error('❌ [SYNC ERROR] Failed to fetch users:', userError)
      const duration = Date.now() - startTime
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload, undefined, 'Failed to fetch users', 500, duration)
      
      return new Response(
        JSON.stringify({ error: 'Failed to fetch users' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const user = userData.users.find(u => u.email === email)

    if (!user) {
      const errorMsg = `User not found with email: ${email}`
      console.error('❌ [SYNC ERROR]', errorMsg)
      const duration = Date.now() - startTime
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload, undefined, errorMsg, 404, duration)
      
      return new Response(
        JSON.stringify({ error: errorMsg }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ [SYNC] Found user:', user.id, '(', email, ')')

    // Check user role - block if already a bride account
    const { data: profileData } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileData && profileData.role === 'bride') {
      const errorMsg = `Cannot create professional profile: email ${email} is already registered as a bride account`
      console.error('❌ [SYNC ERROR]', errorMsg)
      const duration = Date.now() - startTime
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload, undefined, errorMsg, 403, duration, user.id)
      
      return new Response(
        JSON.stringify({ 
          error: errorMsg,
          detail: 'A bride account with this email already exists. Professional profiles cannot use the same email as bride accounts.'
        }),
        { 
          status: 403, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ [SYNC] User role check passed:', profileData?.role || 'no profile')

    // Check if professional_details already exists
    const { data: existingDetails } = await supabaseAdmin
      .from('professional_details')
      .select('profile_id')
      .eq('profile_id', user.id)
      .single()

    const professionalData = {
      profile_id: user.id,
      business_name,
      description: description || null,
      profession: profession.toUpperCase(),
      portfolio_images: portfolio_images || [],
      slideshow_images: slideshow_images || [],
      profile_video_url: profile_video_url || null,
      budget_min: budget_min || null,
      budget_max: budget_max || null,
      currency: currency ? currency.toUpperCase() : null,
      instagram_url: instagram_url || null,
      website_url: website_url || null,
      location_city: location_city || null,
      location_country_code: location_country_code || null,
      location_label: location_label || null,
      is_live: false,
      is_pending: false,
      updated_at: new Date().toISOString()
    }

    let result

    if (existingDetails) {
      // Update existing record
      console.log(`Updating existing professional_details for user ${user.id}`)
      const { data, error } = await supabaseAdmin
        .from('professional_details')
        .update(professionalData)
        .eq('profile_id', user.id)
        .select()
        .single()

      result = { data, error }
    } else {
      // Insert new record
      console.log(`Creating new professional_details for user ${user.id}`)
      const { data, error } = await supabaseAdmin
        .from('professional_details')
        .insert({
          ...professionalData,
          created_at: new Date().toISOString()
        })
        .select()
        .single()

      result = { data, error }
    }

    if (result.error) {
      console.error('❌ [SYNC ERROR] Failed to upsert professional_details:', result.error)
      const duration = Date.now() - startTime
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload, undefined, result.error.message, 500, duration, user.id)
      
      return new Response(
        JSON.stringify({ error: result.error.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ [SYNC] Professional profile synced successfully for:', user.id)

    // Sync fixed locations if provided
    if (Array.isArray(fixed_locations) && fixed_locations.length > 0) {
      console.log(`Syncing ${fixed_locations.length} fixed locations for user ${user.id}`)
      
      // Delete existing fixed locations
      await supabaseAdmin
        .from('professional_fixed_locations')
        .delete()
        .eq('professional_profile_id', user.id)

      // Insert new fixed locations
      const locationsToInsert = fixed_locations.map((loc: any) => ({
        professional_profile_id: user.id,
        label: loc.label || null
      }))

      const { error: locError } = await supabaseAdmin
        .from('professional_fixed_locations')
        .insert(locationsToInsert)

      if (locError) {
        console.error('Error syncing fixed locations:', locError)
        // Don't fail the whole request, just log it
      } else {
        console.log('Fixed locations synced successfully')
      }
    }

    const duration = Date.now() - startTime
    const responseData = { 
      success: true, 
      message: 'Professional profile synced successfully',
      profile_id: user.id,
      data: result.data,
      fixed_locations_synced: fixed_locations.length,
      duration_ms: duration
    }

    // Log sync success
    await logSyncEvent(supabaseAdmin, 'sync_success', userEmail, payload, responseData, undefined, 200, duration, user.id)
    
    console.log('✅ [SYNC SUCCESS]', {
      email: userEmail,
      profile_id: user.id,
      business_name,
      duration_ms: duration,
      timestamp: new Date().toISOString()
    })

    return new Response(
      JSON.stringify(responseData),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    const duration = Date.now() - startTime
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    
    console.error('❌ [SYNC FATAL ERROR]', {
      error: errorMessage,
      email: userEmail,
      duration_ms: duration,
      timestamp: new Date().toISOString()
    })
    
    // Try to log the error even if supabaseAdmin is not available
    try {
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      )
      await logSyncEvent(supabaseAdmin, 'sync_error', userEmail, payload || {}, undefined, errorMessage, 500, duration)
    } catch (logError) {
      console.error('Failed to log fatal error:', logError)
    }
    
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
