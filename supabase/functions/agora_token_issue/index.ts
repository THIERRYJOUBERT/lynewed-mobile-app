// supabase/functions/agora_token_issue/index.ts
// Version finale - L'UID est calculé côté Flutter et envoyé ici
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { RtcTokenBuilder, RtcRole } from 'npm:agora-access-token';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
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
    const agoraUid = body.agoraUid; // Recevoir l'UID directement depuis Flutter

    console.log('🚀 Token request received:', {
      channelName: channelName ? '***REDACTED***' : 'MISSING',
      agoraUid: agoraUid
    });

    if (!channelName || typeof agoraUid !== 'number') {
      console.error('❌ Invalid request parameters');
      return new Response(JSON.stringify({
        error: 'channelName (String) and agoraUid (Integer) are required'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    console.log('✅ Using Agora UID from Flutter:', agoraUid);

    // 2. Vérification de l'authentification de l'utilisateur
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: {
            Authorization: req.headers.get('Authorization') ?? ''
          }
        }
      }
    );

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      console.error('❌ Unauthorized request');
      return new Response(JSON.stringify({
        error: 'Unauthorized'
      }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    console.log('✅ User authenticated:', user.id);

    // 3. Récupération des secrets Agora
    const appId = Deno.env.get('AGORA_APP_ID');
    const appCertificate = Deno.env.get('AGORA_APP_CERTIFICATE');
    const expirationSeconds = parseInt(Deno.env.get('AGORA_TOKEN_EXPIRATION_SECONDS') ?? '3600', 10);

    if (!appId || !appCertificate) {
      console.error('❌ Agora secrets are not set');
      return new Response(JSON.stringify({
        error: 'Server configuration error'
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    console.log('✅ Agora secrets loaded:', {
      appId: appId.substring(0, 8) + '...',
      appCertificate: appCertificate.substring(0, 8) + '...',
      expirationSeconds
    });

    // 4. Génération du token avec l'UID numérique
    // Documentation Agora: https://docs.agora.io/en/video-calling/develop/authentication-workflow
    const role = RtcRole.PUBLISHER;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpireTs = currentTimestamp + expirationSeconds;

    console.log('🔑 Generating token with:', {
      role: 'PUBLISHER',
      currentTimestamp,
      privilegeExpireTs,
      expirationSeconds
    });

    // IMPORTANT: buildTokenWithUid signature:
    // buildTokenWithUid(appId: string, appCertificate: string, channelName: string, uid: number, role: RtcRole, privilegeExpireTs: number)
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      agoraUid,
      role,
      privilegeExpireTs
    );

    console.log('✅ Token generated successfully:', {
      tokenLength: token.length,
      tokenPrefix: token.substring(0, 20) + '...'
    });

    return new Response(JSON.stringify({
      token
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    });

  } catch (error) {
    console.error('❌ Critical error in agora_token_issue:', error.message);
    // ⚠️ Stack trace désactivé en production pour sécurité

    return new Response(JSON.stringify({
      error: 'Internal Server Error'
      // ⚠️ Ne pas exposer error.message au client (info sensible)
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
});
