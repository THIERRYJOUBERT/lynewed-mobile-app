// supabase/functions/agora_token_issue/index.ts
// Version corrigée qui utilise un UID numérique pour la génération du token
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { RtcTokenBuilder, RtcRole } from 'npm:agora-access-token';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
serve(async (req)=>{
  // 1. Validation de la méthode et du corps de la requête
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({
      error: 'Method Not Allowed'
    }), {
      status: 405,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
  try {
    const body = await req.json();
    const channelName = body.channelName;
    // --- CHANGEMENT CRITIQUE: Nous attendons un Integer ---
    const agoraUid = body.agoraUid;
    if (!channelName || typeof agoraUid !== 'number') {
      return new Response(JSON.stringify({
        error: 'channelName (String) and agoraUid (Integer) are required'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }
    // 2. Vérification de l'authentification de l'utilisateur (inchangée)
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization') ?? ''
        }
      }
    });
    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({
        error: 'Unauthorized'
      }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }
    // 3. Récupération des secrets Agora (inchangée)
    const appId = Deno.env.get('AGORA_APP_ID');
    const appCertificate = Deno.env.get('AGORA_APP_CERTIFICATE');
    const expirationSeconds = parseInt(Deno.env.get('AGORA_TOKEN_EXPIRATION_SECONDS') ?? '3600', 10);
    if (!appId || !appCertificate) {
      console.error('Agora secrets are not set.');
      return new Response(JSON.stringify({
        error: 'Server configuration error'
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }
    // 4. Génération du token avec l'UID numérique
    const role = RtcRole.PUBLISHER;
    const privilegeExpireTs = Math.floor(Date.now() / 1000) + expirationSeconds;
    // --- CHANGEMENT CRITIQUE: Utilisation de `agoraUid` (Integer) ---
    const token = RtcTokenBuilder.buildTokenWithUid(appId, appCertificate, channelName, agoraUid, role, privilegeExpireTs);
    return new Response(JSON.stringify({
      token
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    console.error('agora_token_issue critical error:', error);
    return new Response(JSON.stringify({
      error: 'Internal Server Error'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
});
