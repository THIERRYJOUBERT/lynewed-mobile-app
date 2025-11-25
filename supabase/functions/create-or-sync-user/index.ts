import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
const supabase = createClient(Deno.env.get('SUPABASE_URL'), Deno.env.get('SUPABASE_SERVICE_ROLE_KEY'));
const CRM_STORAGE_BASE_URL = 'https://pjcorrkwafjskmzmimon.supabase.co/storage/v1/object/public/professional_profiles';
async function geocodeCity(cityName) {
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(cityName)}&format=json&limit=1&email=contact@lynewed.com`;
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'LynewedApp/1.0'
      }
    });
    if (!response.ok) throw new Error(`API Error: ${response.statusText}`);
    const data = await response.json();
    if (data && data.length > 0) {
      const { lat, lon } = data[0];
      console.log(`Géocodage réussi pour ${cityName}: POINT(${lon} ${lat})`);
      return `POINT(${lon} ${lat})`;
    }
    console.warn(`Géocodage échoué pour ${cityName}.`);
    return null;
  } catch (error) {
    console.error(`Erreur lors du géocodage pour ${cityName}:`, error);
    return null;
  }
}
Deno.serve(async (req)=>{
  const profileFromCrm = await req.json();
  let appUser = null;
  const { data: { users }, error: listError } = await supabase.auth.admin.listUsers();
  if (listError) {
    console.error(`Erreur lors de la récupération des utilisateurs:`, listError);
    return new Response(JSON.stringify({
      error: listError.message
    }), {
      status: 500
    });
  }
  const existingUser = users.find((u)=>u.email === profileFromCrm.email);
  if (existingUser) {
    console.log(`Utilisateur ${profileFromCrm.email} trouvé dans l'App. ID: ${existingUser.id}`);
    appUser = existingUser;
  } else {
    console.log(`Utilisateur ${profileFromCrm.email} non trouvé dans l'App. Création...`);
    const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
      email: profileFromCrm.email,
      email_confirm: true,
      user_metadata: {
        crm_id: profileFromCrm.id
      }
    });
    if (createError) {
      console.error(`Erreur lors de la création de l'utilisateur ${profileFromCrm.email}:`, createError);
      return new Response(JSON.stringify({
        error: createError.message
      }), {
        status: 500
      });
    }
    appUser = newUser.user;
  }
  if (!appUser) {
    const errorMsg = 'Impossible d\'obtenir une référence utilisateur valide dans l\'app.';
    console.error(errorMsg);
    return new Response(JSON.stringify({
      error: errorMsg
    }), {
      status: 500
    });
  }
  try {
    const appUserId = appUser.id;
    const baseProfileToUpsert = {
      id: appUserId,
      role: 'professional',
      full_name: `${profileFromCrm.first_name || ''} ${profileFromCrm.last_name || ''}`.trim(),
      avatar_url: profileFromCrm.avatar_url ? `${CRM_STORAGE_BASE_URL}/${profileFromCrm.avatar_url}` : null
    };
    const { error: baseProfileError } = await supabase.from('profiles').upsert(baseProfileToUpsert);
    if (baseProfileError) throw new Error(`Erreur 'profiles': ${baseProfileError.message}`);
    console.log(`Table 'profiles' synchronisée pour l'utilisateur ${appUserId}`);
    let subscriptionTier = 'inactive';
    if (profileFromCrm.plan === 'free') subscriptionTier = 'inactive';
    if (profileFromCrm.plan === 'early_access') subscriptionTier = 'earlyAccess';
    if (profileFromCrm.plan === 'premium') subscriptionTier = 'premiumVisibility';
    if (profileFromCrm.plan === 'ultimate') subscriptionTier = 'ultimateAccess';
    const subscriptionToUpsert = {
      profile_id: appUserId,
      subscription_tier: subscriptionTier,
      stripe_customer_id: profileFromCrm.stripe_customer_id || null,
      stripe_subscription_id: profileFromCrm.stripe_subscription_id || null
    };
    const { error: subscriptionError } = await supabase.from('professional_subscriptions').upsert(subscriptionToUpsert, {
      onConflict: 'profile_id'
    });
    if (subscriptionError) throw new Error(`Erreur 'professional_subscriptions': ${subscriptionError.message}`);
    console.log(`Table 'professional_subscriptions' synchronisée pour l'utilisateur ${appUserId}`);
    const buildPhotoUrls = (photos)=>{
      if (!Array.isArray(photos)) return [];
      return photos.map((p)=>`${CRM_STORAGE_BASE_URL}/${p.path}`);
    };
    const mapSpecialtyToProfession = (specialty)=>{
      const s = (specialty || 'other').toLowerCase();
      switch(s){
        case 'photographer':
          return 'PHOTOGRAPHER';
        case 'filmmaker':
          return 'FILMMAKER';
        case 'planner':
          return 'PLANNER';
        case 'makeup-artist':
          return 'MAKEUPARTIST';
        case 'hairdresser':
          return 'HAIRDRESSER';
        case 'event-designer':
          return 'EVENTDESIGNER';
        case 'photo-movie':
          return 'PHOTO/MOVIE';
        case 'venues':
          return 'VENUE';
        default:
          return 'OTHER';
      }
    };
    const professionalDetailsToUpsert = {
      profile_id: appUserId,
      business_name: profileFromCrm.studio_name || 'Business Name Not Set',
      description: profileFromCrm.bio,
      slideshow_images: buildPhotoUrls(profileFromCrm.slideshow_photos),
      portfolio_images: buildPhotoUrls(profileFromCrm.portfolio_photos),
      location_coords: 'POINT(0 0)',
      profession: mapSpecialtyToProfession(profileFromCrm.specialty),
      is_live: false,
      instagram_url: profileFromCrm.instagram_handle ? `https://instagram.com/${profileFromCrm.instagram_handle}` : null,
      website_url: profileFromCrm.website_url,
      budget_min: profileFromCrm.budget_min,
      budget_max: profileFromCrm.budget_max,
      profile_video_url: profileFromCrm.profile_video_url ? `${CRM_STORAGE_BASE_URL}/${profileFromCrm.profile_video_url}` : null
    };
    const { error: detailsError } = await supabase.from('professional_details').upsert(professionalDetailsToUpsert);
    if (detailsError) throw new Error(`Erreur 'professional_details': ${detailsError.message}`);
    console.log(`Table 'professional_details' synchronisée pour l'utilisateur ${appUserId}`);
    await supabase.from('professional_fixed_locations').delete().eq('professional_profile_id', appUserId);
    if (profileFromCrm.locations && Array.isArray(profileFromCrm.locations.additional)) {
      const locationsToInsert = [];
      for (const cityName of profileFromCrm.locations.additional){
        if (typeof cityName === 'string' && cityName.trim() !== '') {
          const coords = await geocodeCity(cityName.trim());
          if (coords) {
            locationsToInsert.push({
              professional_profile_id: appUserId,
              label: cityName.trim(),
              location_coords: coords
            });
          }
        }
      }
      if (locationsToInsert.length > 0) {
        const { error: insertLocError } = await supabase.from('professional_fixed_locations').insert(locationsToInsert);
        if (insertLocError) throw new Error(`Erreur 'professional_fixed_locations': ${insertLocError.message}`);
      }
    }
    console.log(`Table 'professional_fixed_locations' synchronisée pour l'utilisateur ${appUserId}`);
  } catch (error) {
    console.error('Erreur lors de la synchronisation des tables:', error);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 500
    });
  }
  return new Response(JSON.stringify({
    message: 'Synchronisation complète réussie'
  }), {
    status: 200
  });
});
