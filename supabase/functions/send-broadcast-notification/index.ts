// Edge Function: send-broadcast-notification v2
// Envoie des notifications broadcast (Wedding of the Week, Replays, Annonces)
// Crée des notifications IN-APP + Push FCM
// Appelée depuis l'Admin Panel
//
// TYPES SUPPORTÉS:
// - wedPublished: Nouveau Wedding of the Week
// - replayPublished: Nouveau Replay disponible
// - broadcast: Annonce générique (fallback)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create } from "https://deno.land/x/djwt@v2.8/mod.ts";

// --- CONFIG ---
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ENABLE_PUSH = (Deno.env.get("ENABLE_PUSH") || "false").toLowerCase() === "true";
const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID") || "";
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// --- DEEP LINKS ---
const NOTIFICATION_TYPE_TO_LINK: Record<string, string> = {
  wedPublished: "lynewed://wedding",
  replayPublished: "lynewed://replays",
  broadcast: "", // Lien personnalisé fourni par l'Admin
};

// --- FCM v1 helpers ---
let cachedAccessToken: { token: string; expiresAt: number } | null = null;

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const raw = atob(b64);
  const buf = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) buf[i] = raw.charCodeAt(i);
  return buf.buffer;
}

async function getAccessToken(): Promise<string> {
  const sa = JSON.parse(FIREBASE_SERVICE_ACCOUNT);
  const now = Math.floor(Date.now() / 1000);
  
  if (cachedAccessToken && cachedAccessToken.expiresAt > now + 60) {
    return cachedAccessToken.token;
  }
  
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: sa.token_uri || "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  
  const jwt = await create({ alg: "RS256", typ: "JWT" }, payload, cryptoKey);
  
  const res = await fetch(sa.token_uri || "https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }).toString(),
  });
  
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`OAuth token error: ${res.status} ${t}`);
  }
  
  const { access_token, expires_in } = await res.json();
  cachedAccessToken = { token: access_token, expiresAt: now + (expires_in ?? 3600) };
  return access_token;
}

async function sendFcmV1(
  token: string, 
  title: string, 
  body: string, 
  data: Record<string, string>
): Promise<{ ok: boolean; error?: string }> {
  if (!ENABLE_PUSH || !FCM_PROJECT_ID) {
    return { ok: false, error: "Push disabled or FCM not configured" };
  }
  
  try {
    const accessToken = await getAccessToken();
    const url = `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;
    
    const message = {
      message: {
        token,
        data,
        notification: { title, body },
        android: {
          priority: "high",
          notification: { sound: "default" },
        },
        apns: {
          headers: { "apns-priority": "10" },
          payload: {
            aps: {
              alert: { title, body },
              sound: "default",
            },
          },
        },
      },
    };
    
    const res = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    });
    
    if (!res.ok) {
      const t = await res.text();
      return { ok: false, error: `FCM error: ${res.status} ${t}` };
    }
    
    return { ok: true };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

// --- MAIN ---
serve(async (req) => {
  // CORS
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }
  
  try {
    // Vérifier l'authentification
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), { status: 401 });
    }
    
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), { status: 401 });
    }
    
    // Vérifier que l'utilisateur est admin
    const { data: roleData } = await supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", user.id)
      .eq("role", "admin")
      .single();
    
    if (!roleData) {
      return new Response(JSON.stringify({ error: "Admin access required" }), { status: 403 });
    }
    
    // Parser le body
    const body = await req.json();
    const { 
      title, 
      message, 
      link, 
      targetRoles, 
      targetRegion, 
      targetProfileIds,
      notificationType = "broadcast", // wedPublished, replayPublished, ou broadcast
      referenceId = null, // article_id ou replay_id
    } = body;
    
    // Validation
    if (!title || title.length > 50) {
      return new Response(JSON.stringify({ error: "Title required (max 50 chars)" }), { status: 400 });
    }
    if (!message || message.length > 120) {
      return new Response(JSON.stringify({ error: "Message required (max 120 chars)" }), { status: 400 });
    }
    
    // Valider le type de notification
    const validTypes = ["wedPublished", "replayPublished", "broadcast"];
    if (!validTypes.includes(notificationType)) {
      return new Response(JSON.stringify({ 
        error: `Invalid notificationType. Must be one of: ${validTypes.join(", ")}` 
      }), { status: 400 });
    }
    
    // Déterminer le deep link
    const deepLink = link || NOTIFICATION_TYPE_TO_LINK[notificationType] || "";
    
    // Créer l'entrée dans broadcast_history
    const { data: broadcast, error: insertError } = await supabase
      .from("broadcast_history")
      .insert({
        title,
        body: message,
        link: deepLink,
        target_roles: targetRoles || [],
        target_region: targetRegion || "all",
        target_profile_ids: targetProfileIds || [],
        sent_by: user.id,
        status: "processing",
        notification_type: notificationType,
      })
      .select()
      .single();
    
    if (insertError) {
      console.error("Insert error:", insertError);
      return new Response(JSON.stringify({ error: "Failed to create broadcast record" }), { status: 500 });
    }
    
    // Construire la requête pour récupérer les profils cibles
    let profileQuery = supabase
      .from("profiles")
      .select("id, role, location_country_code");
    
    // Filtrer par profile_ids spécifiques si fournis
    if (targetProfileIds && targetProfileIds.length > 0) {
      profileQuery = profileQuery.in("id", targetProfileIds);
    } else {
      // Filtrer par rôles
      if (targetRoles && targetRoles.length > 0) {
        profileQuery = profileQuery.in("role", targetRoles);
      }
      
      // Filtrer par région
      if (targetRegion && targetRegion !== "all") {
        if (targetRegion === "IN") {
          profileQuery = profileQuery.eq("location_country_code", "IN");
        } else if (targetRegion === "ROW") {
          profileQuery = profileQuery.neq("location_country_code", "IN");
        }
      }
    }
    
    const { data: profiles, error: profilesError } = await profileQuery;
    
    if (profilesError) {
      console.error("Profiles query error:", profilesError);
      await supabase.from("broadcast_history").update({ status: "failed" }).eq("id", broadcast.id);
      return new Response(JSON.stringify({ error: "Failed to fetch profiles" }), { status: 500 });
    }
    
    if (!profiles || profiles.length === 0) {
      await supabase.from("broadcast_history").update({ 
        status: "sent", 
        recipients_count: 0 
      }).eq("id", broadcast.id);
      
      return new Response(JSON.stringify({ 
        success: true, 
        broadcast_id: broadcast.id,
        recipients_count: 0,
        message: "No recipients found" 
      }), {
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      });
    }
    
    console.log(`[Broadcast] Processing ${profiles.length} profiles for ${notificationType}`);
    
    // --- ÉTAPE 1: Créer les notifications IN-APP ---
    // Vérifier les préférences de chaque utilisateur
    const profileIds = profiles.map(p => p.id);
    
    const { data: settings } = await supabase
      .from("notification_settings")
      .select("profile_id, in_app_enabled, push_enabled")
      .eq("notification_type", notificationType)
      .in("profile_id", profileIds);
    
    const settingsMap = new Map(
      (settings || []).map(s => [s.profile_id, { in_app: s.in_app_enabled, push: s.push_enabled }])
    );
    
    // Créer les notifications in-app pour ceux qui l'ont activé
    const inAppNotifications = profiles
      .filter(p => {
        const setting = settingsMap.get(p.id);
        return setting?.in_app !== false; // Par défaut true si pas de setting
      })
      .map(p => ({
        profile_id: p.id,
        type: notificationType,
        payload: {
          broadcast_id: broadcast.id,
          reference_id: referenceId,
          link: deepLink,
        },
      }));
    
    let inAppCount = 0;
    if (inAppNotifications.length > 0) {
      // Insérer par batches de 100 pour éviter les timeouts
      const batchSize = 100;
      for (let i = 0; i < inAppNotifications.length; i += batchSize) {
        const batch = inAppNotifications.slice(i, i + batchSize);
        const { error: notifError } = await supabase
          .from("notifications")
          .insert(batch);
        
        if (notifError) {
          console.error(`[Broadcast] In-app insert error (batch ${i}):`, notifError);
        } else {
          inAppCount += batch.length;
        }
      }
    }
    
    console.log(`[Broadcast] Created ${inAppCount} in-app notifications`);
    
    // --- ÉTAPE 2: Envoyer les Push FCM ---
    // Récupérer les tokens pour les users qui ont push activé
    const pushEnabledProfileIds = profiles
      .filter(p => {
        const setting = settingsMap.get(p.id);
        return setting?.push !== false; // Par défaut true si pas de setting
      })
      .map(p => p.id);
    
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token, platform, profile_id")
      .in("profile_id", pushEnabledProfileIds);
    
    let pushSuccessCount = 0;
    let pushFailCount = 0;
    
    if (tokens && tokens.length > 0) {
      const pushData = {
        type: notificationType,
        broadcast_id: broadcast.id,
        link: deepLink,
        reference_id: referenceId || "",
      };
      
      // Envoyer en parallèle par batches de 50
      const batchSize = 50;
      for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        const results = await Promise.allSettled(
          batch.map((t: any) => sendFcmV1(t.token, title, message, pushData))
        );
        
        results.forEach((result) => {
          if (result.status === "fulfilled" && result.value.ok) {
            pushSuccessCount++;
          } else {
            pushFailCount++;
          }
        });
      }
    }
    
    console.log(`[Broadcast] Push sent: ${pushSuccessCount} success, ${pushFailCount} failed`);
    
    // Mettre à jour le statut
    await supabase.from("broadcast_history").update({
      status: "sent",
      recipients_count: inAppCount,
    }).eq("id", broadcast.id);
    
    return new Response(JSON.stringify({
      success: true,
      broadcast_id: broadcast.id,
      notification_type: notificationType,
      in_app_created: inAppCount,
      push_sent: pushSuccessCount,
      push_failed: pushFailCount,
      total_profiles: profiles.length,
    }), {
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
    
  } catch (e) {
    console.error("Unexpected error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }
});
