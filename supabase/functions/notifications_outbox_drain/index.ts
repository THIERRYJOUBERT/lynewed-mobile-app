// supabase/functions/notifications_outbox_drain/index.ts
// Version FCM HTTP v1 + payloads room_id pour connectionRequest*
// Minimal-diff avec votre logique actuelle (préparation puis exécution)
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create } from "https://deno.land/x/djwt@v2.8/mod.ts";
// --- CONFIG ---
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const ENABLE_PUSH = (Deno.env.get("ENABLE_PUSH") || "false").toLowerCase() === "true";
const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID") || "";
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "";
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  global: {
    headers: {
      "x-lynewed-worker": "notifications_outbox_drain"
    }
  }
});
// --- FCM v1 helpers ---
let cachedAccessToken = null;
function pemToArrayBuffer(pem) {
  const b64 = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const raw = atob(b64);
  const buf = new Uint8Array(raw.length);
  for(let i = 0; i < raw.length; i++)buf[i] = raw.charCodeAt(i);
  return buf.buffer;
}
async function getAccessToken() {
  const sa = JSON.parse(FIREBASE_SERVICE_ACCOUNT);
  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && cachedAccessToken.expiresAt > now + 60) {
    return cachedAccessToken.token;
  }
  const cryptoKey = await crypto.subtle.importKey("pkcs8", pemToArrayBuffer(sa.private_key), {
    name: "RSASSA-PKCS1-v1_5",
    hash: "SHA-256"
  }, false, [
    "sign"
  ]);
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: sa.token_uri || "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600
  };
  const jwt = await create({
    alg: "RS256",
    typ: "JWT"
  }, payload, cryptoKey);
  const res = await fetch(sa.token_uri || "https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt
    }).toString()
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`OAuth token error: ${res.status} ${t}`);
  }
  const { access_token, expires_in } = await res.json();
  cachedAccessToken = {
    token: access_token,
    expiresAt: now + (expires_in ?? 3600)
  };
  return access_token;
}
async function sendFcmV1(token, title, body, data, isHighPriority = false, ttlSeconds = 300) {
  if (!ENABLE_PUSH || !FCM_PROJECT_ID) return {
    ok: false,
    skipped: true
  };
  const accessToken = await getAccessToken();
  const url = `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;
  const message = {
    message: {
      token,
      data,
      notification: isHighPriority ? undefined : {
        title,
        body
      },
      android: {
        priority: "high",
        ttl: `${ttlSeconds}s`,
        notification: isHighPriority ? undefined : {
          sound: "default"
        }
      },
      apns: {
        headers: {
          "apns-push-type": "alert",
          "apns-priority": isHighPriority ? "10" : "10",
          "apns-expiration": `${Math.floor(Date.now() / 1000) + ttlSeconds}`
        },
        payload: {
          aps: {
            "content-available": 1,
            alert: isHighPriority ? {
              title,
              body
            } : {
              title,
              body
            },
            sound: "default",
            "mutable-content": 1
          },
          fcm_options: {
            image: "AppIcon"
          }
        },
        fcm_options: {
          image: "AppIcon"
        }
      }
    }
  };
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(message)
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`FCM v1 error: ${res.status} ${t}`);
  }
  return {
    ok: true
  };
}
// --- MAPPINGS / I18N (inchangé sauf si mention) ---
const EVENT_TO_NOTIFICATION_TYPE = {
  chatMessageCreated: "chatMessage",
  connectionRequestCreated: "connectionRequest",
  connectionRequestAccepted: "connectionRequestAccepted",
  connectionRequestDeclined: "connectionRequestDeclined",
  wishlistAdded: "wishlistAdd",
  professionalAlertReminder24h: "professionalAlertReminder24h",
  videoIncoming: "videoIncoming"
};
const I18N_TEMPLATES = {
  chatMessage: {
    title: {
      en: "New message",
      fr: "Nouveau message"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} vous a envoyé un message.` : `${ctx.sender_full_name || "Someone"} sent you a message.`
  },
  connectionRequest: {
    title: {
      en: "New contact request",
      fr: "Nouvelle demande de contact"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} souhaite vous contacter.` : `${ctx.sender_full_name || "Someone"} wants to contact you.`
  },
  connectionRequestAccepted: {
    title: {
      en: "Request accepted",
      fr: "Demande acceptée"
    },
    body: (_, locale)=>locale === "fr" ? `Votre demande de contact a été acceptée.` : `Your contact request was accepted.`
  },
  connectionRequestDeclined: {
    title: {
      en: "Request declined",
      fr: "Demande refusée"
    },
    body: (_, locale)=>locale === "fr" ? `Votre demande de contact a été refusée.` : `Your contact request was declined.`
  },
  wishlistAdd: {
    title: {
      en: "Wishlist",
      fr: "Wishlist"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} vous a ajouté à sa wishlist.` : `${ctx.sender_full_name || "Someone"} added you to their wishlist.`
  },
  professionalAlertReminder24h: {
    title: {
      en: "Alert expiring soon",
      fr: "Alerte bientôt expirée"
    },
    body: (_, locale)=>locale === "fr" ? `Votre alerte expire dans moins de 24h.` : `Your alert expires in less than 24h.`
  },
  videoIncoming: {
    title: {
      en: "Incoming Video Call",
      fr: "Appel Vidéo Entrant"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} vous appelle en vidéo...` : `${ctx.sender_full_name || "Someone"} is calling you...`
  }
};
// --- HELPERS DB ---
async function claimBatch(workerId) {
  const { data, error } = await supabase.rpc("claim_outbox_events", {
    p_batch_size: 100,
    p_claim_ttl_minutes: 5,
    p_worker_id: workerId
  });
  if (error) throw new Error(`claim_outbox_events error: ${error.message}`);
  return data || [];
}
async function getUserLocale(profileId) {
  const { data } = await supabase.from("user_preferences").select("default_locale").eq("profile_id", profileId).maybeSingle();
  return (data?.default_locale || "en").toLowerCase().startsWith("fr") ? "fr" : "en";
}
async function getProfileSummary(profileId) {
  const { data } = await supabase.from("profiles").select("full_name, avatar_url").eq("id", profileId).maybeSingle();
  return {
    full_name: data?.full_name ?? null,
    avatar_url: data?.avatar_url ?? null
  };
}
async function getDeviceTokens(profileId) {
  const { data, error } = await supabase.from("device_tokens").select("token, platform").eq("profile_id", profileId);
  if (error) return [];
  return data || [];
}
async function getNotificationSetting(profileId, type) {
  const { data } = await supabase.from("notification_settings").select("in_app_enabled, push_enabled").eq("profile_id", profileId).eq("notification_type", type).maybeSingle();
  return {
    in_app: data?.in_app_enabled ?? true,
    push: data?.push_enabled ?? true
  };
}
// --- EXECUTION HELPERS ---
async function executeInAppInserts(actions) {
  if (!actions.length) return [];
  const { data, error } = await supabase.from("notifications").insert(actions).select("id, profile_id");
  if (error) {
    console.error("executeInAppInserts error", error);
    return [];
  }
  return data || [];
}
async function executePushSends(actions) {
  if (!actions.length) return;
  const results = await Promise.allSettled(actions.map((a)=>sendFcmV1(a.token, a.title, a.body, a.data, a.isHighPriority, a.ttlSeconds ?? 300)));
  results.forEach((res, i)=>{
    if (res.status === "rejected") console.error(`Failed to send push to token ${actions[i].token}:`, res.reason);
  });
}
// --- PROCESSORS ---
async function processChatMessageCreated(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;
  const messageId = ev.payload?.message_id;
  if (!messageId) throw new Error("chatMessageCreated missing message_id");
  const { data: msg, error: eMsg } = await supabase.from("chat_messages").select("id, room_id, profile_id, chat_rooms:room_id(type)").eq("id", messageId).single();
  if (eMsg || !msg) throw new Error(`Message not found or DB error: ${eMsg?.message}`);
  if (msg.chat_rooms?.type !== "private") return actions;
  const { data: parts, error: eParts } = await supabase.from("chat_room_participants").select("profile_id").eq("room_id", msg.room_id);
  if (eParts) throw new Error(`participants error: ${eParts.message}`);
  const recipients = (parts || []).map((p)=>p.profile_id).filter((pid)=>pid && pid !== msg.profile_id);
  const senderProfile = await getProfileSummary(msg.profile_id);
  const ctx = {
    sender_full_name: senderProfile.full_name
  };
  for (const recipientId of recipients){
    const setting = await getNotificationSetting(recipientId, type);
    if (!setting.in_app && !setting.push) continue;
    const locale = await getUserLocale(recipientId);
    const tmpl = I18N_TEMPLATES[type];
    const title = tmpl.title[locale] || tmpl.title.en;
    const body = tmpl.body(ctx, locale);
    if (setting.in_app) {
      actions.inApp.push({
        profile_id: recipientId,
        type,
        payload: {
          room_id: msg.room_id,
          message_id: messageId,
          sender_profile_id: msg.profile_id
        }
      });
    }
    if (setting.push) {
      const tokens = await getDeviceTokens(recipientId);
      tokens.forEach((t)=>actions.push.push({
          token: t.token,
          platform: t.platform,
          title,
          body,
          isHighPriority: false,
          ttlSeconds: 300,
          data: {
            type,
            room_id: String(msg.room_id),
            message_id: String(messageId),
            sender_profile_id: String(msg.profile_id)
          }
        }));
    }
  }
  return actions;
}
async function processConnectionRequest(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;
  const recipientId = ev.payload?.recipient_profile_id;
  const senderId = ev.payload?.sender_profile_id;
  if (!recipientId) return actions;
  const requestId = ev.payload?.request_id;
  if (!requestId) throw new Error("connection request missing request_id");
  // room_id désormais potentiellement fourni par le trigger (sinon null)
  const roomId = ev.payload?.room_id || null;
  const senderProfile = senderId ? await getProfileSummary(senderId) : {
    full_name: null
  };
  const ctx = {
    sender_full_name: senderProfile.full_name
  };
  const setting = await getNotificationSetting(recipientId, type);
  if (!setting.in_app && !setting.push) return actions;
  const locale = await getUserLocale(recipientId);
  const tmpl = I18N_TEMPLATES[type];
  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body(ctx, locale);
  const basePayload = {
    request_id: requestId,
    sender_profile_id: senderId || null,
    room_id: roomId
  };
  if (setting.in_app) {
    actions.inApp.push({
      profile_id: recipientId,
      type,
      payload: basePayload
    });
  }
  if (setting.push) {
    const tokens = await getDeviceTokens(recipientId);
    tokens.forEach((t)=>actions.push.push({
        token: t.token,
        platform: t.platform,
        title,
        body,
        isHighPriority: false,
        ttlSeconds: 300,
        data: {
          type,
          ...Object.fromEntries(Object.entries(basePayload).map(([k, v])=>[
              k,
              v == null ? "" : String(v)
            ]))
        }
      }));
  }
  return actions;
}
async function processWishlistAdded(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;
  const proId = ev.payload?.professional_profile_id;
  const brideId = ev.payload?.bride_profile_id;
  if (!proId || !brideId) throw new Error("wishlistAdded missing ids");
  const senderId = ev.payload?.sender_profile_id || brideId;
  const senderProfile = await getProfileSummary(senderId);
  const ctx = {
    sender_full_name: senderProfile.full_name
  };
  const setting = await getNotificationSetting(proId, type);
  if (!setting.in_app && !setting.push) return actions;
  const locale = await getUserLocale(proId);
  const tmpl = I18N_TEMPLATES[type];
  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body(ctx, locale);
  const basePayload = {
    bride_profile_id: brideId
  };
  if (setting.in_app) {
    actions.inApp.push({
      profile_id: proId,
      type,
      payload: basePayload
    });
  }
  if (setting.push) {
    const tokens = await getDeviceTokens(proId);
    tokens.forEach((t)=>actions.push.push({
        token: t.token,
        platform: t.platform,
        title,
        body,
        isHighPriority: false,
        ttlSeconds: 300,
        data: {
          type,
          bride_profile_id: String(brideId)
        }
      }));
  }
  return actions;
}
async function processAlertReminder(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;
  const alertId = ev.payload?.alert_id;
  if (!alertId) throw new Error("alert reminder missing alert_id");
  const { data: alert, error } = await supabase.from("professional_alerts").select("author_profile_id, status, is_deleted").eq("id", alertId).single();
  if (error || !alert || alert.is_deleted || alert.status !== "active") return actions;
  const recipientId = alert.author_profile_id;
  const setting = await getNotificationSetting(recipientId, type);
  if (!setting.in_app && !setting.push) return actions;
  const locale = await getUserLocale(recipientId);
  const tmpl = I18N_TEMPLATES[type];
  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body({}, locale);
  const basePayload = {
    alert_id: alertId
  };
  if (setting.in_app) {
    actions.inApp.push({
      profile_id: recipientId,
      type,
      payload: basePayload
    });
  }
  if (setting.push) {
    const tokens = await getDeviceTokens(recipientId);
    tokens.forEach((t)=>actions.push.push({
        token: t.token,
        platform: t.platform,
        title,
        body,
        isHighPriority: false,
        ttlSeconds: 300,
        data: {
          type,
          alert_id: String(alertId)
        }
      }));
  }
  return actions;
}
async function processVideoIncoming(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;
  const { video_session_id: sessionId, agora_channel_name: channelName, sender_profile_id: senderId, recipient_profile_id: recipientId } = ev.payload;
  if (!sessionId || !channelName || !senderId || !recipientId) throw new Error("videoIncoming missing fields");
  const setting = await getNotificationSetting(recipientId, type);
  if (!setting.in_app && !setting.push) return actions;
  const senderProfile = await getProfileSummary(senderId);
  const ctx = {
    sender_full_name: senderProfile.full_name
  };
  const locale = await getUserLocale(recipientId);
  const tmpl = I18N_TEMPLATES[type];
  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body(ctx, locale);
  const data = {
    type,
    video_session_id: String(sessionId),
    agora_channel_name: String(channelName),
    sender_profile_id: String(senderId),
    sender_full_name: String(senderProfile.full_name || ""),
    sender_avatar_url: String(senderProfile.avatar_url || "")
  };
  if (setting.in_app) {
    actions.inApp.push({
      profile_id: recipientId,
      type,
      payload: {
        video_session_id: sessionId,
        agora_channel_name: channelName,
        sender_profile_id: senderId,
        sender_full_name: senderProfile.full_name || "",
        sender_avatar_url: senderProfile.avatar_url || ""
      }
    });
  }
  if (setting.push) {
    const tokens = await getDeviceTokens(recipientId);
    tokens.forEach((t)=>actions.push.push({
        token: t.token,
        platform: t.platform,
        title,
        body,
        isHighPriority: true,
        ttlSeconds: 60,
        data
      }));
  }
  return actions;
}
async function markProcessed(id) {
  const { error } = await supabase.from("notifications_outbox").update({
    processed_at: new Date().toISOString(),
    last_error: null
  }).eq("id", id);
  if (error) throw new Error(`markProcessed error: ${error.message}`);
}
async function markFailed(id, prevAttempts, lastError) {
  const { error } = await supabase.from("notifications_outbox").update({
    attempts: prevAttempts + 1,
    last_error: lastError.slice(0, 8000)
  }).eq("id", id);
  if (error) console.error("markFailed error", error);
}
// --- SERVER ---
serve(async (_req)=>{
  const workerId = crypto.randomUUID();
  try {
    const events = await claimBatch(workerId);
    if (!events || events.length === 0) return new Response("No events to process", {
      status: 200
    });
    for (const ev of events){
      try {
        let actions = {
          inApp: [],
          push: []
        };
        switch(ev.event_type){
          case "chatMessageCreated":
            actions = await processChatMessageCreated(ev);
            break;
          case "connectionRequestCreated":
          case "connectionRequestAccepted":
          case "connectionRequestDeclined":
            actions = await processConnectionRequest(ev);
            break;
          case "wishlistAdded":
            actions = await processWishlistAdded(ev);
            break;
          case "professionalAlertReminder24h":
            actions = await processAlertReminder(ev);
            break;
          case "videoIncoming":
            actions = await processVideoIncoming(ev);
            break;
          default:
            console.warn(`Unknown event_type: ${ev.event_type}`);
        }
        const createdNotifications = await executeInAppInserts(actions.inApp);
        
        // Ajouter notification_id aux payloads push
        const notificationIdMap = new Map(createdNotifications.map(n => [n.profile_id, n.id]));
        actions.push.forEach(pushAction => {
          const recipientId = actions.inApp.find(ia => 
            ia.payload.room_id === pushAction.data.room_id || 
            ia.payload.request_id === pushAction.data.request_id ||
            ia.payload.video_session_id === pushAction.data.video_session_id ||
            ia.payload.bride_profile_id === pushAction.data.bride_profile_id ||
            ia.payload.alert_id === pushAction.data.alert_id
          )?.profile_id;
          
          if (recipientId && notificationIdMap.has(recipientId)) {
            pushAction.data.notification_id = String(notificationIdMap.get(recipientId));
          }
        });
        
        await executePushSends(actions.push);
        await markProcessed(ev.id);
      } catch (e) {
        console.error(`Failed to process event ${ev.id} of type ${ev.event_type}:`, e);
        await markFailed(ev.id, ev.attempts ?? 0, String(e));
      }
    }
    return new Response(`Processed ${events.length} events.`, {
      status: 200
    });
  } catch (e) {
    console.error("Outbox drain fatal error:", e);
    return new Response(`Error: ${e.message}`, {
      status: 500
    });
  }
});
