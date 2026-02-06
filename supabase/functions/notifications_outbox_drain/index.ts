// supabase/functions/notifications_outbox_drain/index.ts
// Version FCM HTTP v1 - Notifications instantanées v24
// Déployé: 2025-12-03
// 
// ARCHITECTURE:
// - Cette Edge Function gère les notifications TRANSACTIONNELLES (1-to-1)
// - Les notifications BROADCAST (Wedding of the Week, Replays) sont gérées par
//   l'Edge Function send-broadcast-notification appelée depuis l'Admin Panel
// 
// TYPES ACTIFS: chatMessage, connectionRequest, connectionRequestAccepted, wishlistAdd, videoIncoming
// TYPES BROADCAST (Admin Panel): broadcast avec deep links lynewed://[page]
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
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
  if (!ENABLE_PUSH || !FCM_PROJECT_ID) {
    return { ok: false, skipped: true };
  }
  if (!FIREBASE_SERVICE_ACCOUNT) {
    return { ok: false, skipped: true, reason: "missing_service_account" };
  }
  const accessToken = await getAccessToken();
  const url = `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;
  
  // Build APNS payload - content-available only for high priority (video calls)
  // For normal notifications, we want a standard alert notification
  const apsPayload = isHighPriority 
    ? {
        "content-available": 1,
        alert: { title, body },
        sound: "default",
        "mutable-content": 1
      }
    : {
        alert: { title, body },
        sound: "default",
        "mutable-content": 1
      };
  
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
          "apns-priority": "10",
          "apns-expiration": `${Math.floor(Date.now() / 1000) + ttlSeconds}`
        },
        payload: {
          aps: apsPayload
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
  return { ok: true };
}
// --- MAPPINGS / I18N ---
// NOTE: wedPublished et replayPublished sont gérés par l'Edge Function send-broadcast-notification
// appelée depuis l'Admin Panel. Ils ne passent PAS par cette Edge Function.
const EVENT_TO_NOTIFICATION_TYPE = {
  chatMessageCreated: "chatMessage",
  connectionRequestCreated: "connectionRequest",
  connectionRequestAccepted: "connectionRequestAccepted",
  // connectionRequestDeclined: SUPPRIMÉ - On ne notifie que le succès
  wishlistAdded: "wishlistAdd",
  // professionalAlertReminder24h: SUPPRIMÉ - Code mort
  videoIncoming: "videoIncoming",
  // wedPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
  // replayPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)

  // --- MARKETPLACE EVENTS ---
  marketplaceMessageCreated: "marketplaceNewMessage",
  marketplace_item_sold: "marketplaceItemSold",
  marketplace_order_confirmed: "marketplaceOrderConfirmed",
  marketplace_offer_expired: "marketplaceOfferExpired",
  marketplace_label_ready: "marketplaceLabelReady",
  marketplace_tracking_update: "marketplaceTrackingUpdate",
  marketplace_payment_succeeded: "marketplacePaymentSucceeded",
  marketplace_new_offer: "marketplaceNewOffer",
  marketplace_offer_accepted: "marketplaceOfferAccepted",
  marketplace_offer_rejected: "marketplaceOfferRejected",
  marketplace_offer_withdrawn: "marketplaceOfferWithdrawn",

  // --- MARKETPLACE TRANSACTION LIFECYCLE ---
  marketplace_transaction_expired: "marketplaceTransactionExpired",
  marketplace_refunded: "marketplaceRefunded",
  marketplace_disputed: "marketplaceDisputed",
  marketplace_dispute_resolved: "marketplaceDisputeResolved",
  marketplace_refund_requested: "marketplaceRefundRequested",
  marketplace_refund_approved: "marketplaceRefundApproved",
  marketplace_refund_rejected: "marketplaceRefundRejected",
  marketplace_shipment_cancelled: "marketplaceShipmentCancelled",
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
  // connectionRequestDeclined: SUPPRIMÉ - On ne notifie plus les refus
  wishlistAdd: {
    title: {
      en: "Wishlist",
      fr: "Wishlist"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} vous a ajouté à sa wishlist.` : `${ctx.sender_full_name || "Someone"} added you to their wishlist.`
  },
  // professionalAlertReminder24h: SUPPRIMÉ - Code mort
  videoIncoming: {
    title: {
      en: "Incoming Video Call",
      fr: "Appel Vidéo Entrant"
    },
    body: (ctx, locale)=>locale === "fr" ? `${ctx.sender_full_name || "Quelqu'un"} vous appelle en vidéo...` : `${ctx.sender_full_name || "Someone"} is calling you...`
  },
  // wedPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
  // replayPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
  
  // --- WEDDING EVENTS ---
  weddingProAdded: {
    title: {
      en: "Added to a wedding",
      fr: "Ajouté à un mariage"
    },
    body: (ctx, locale)=>locale === "fr" 
      ? `${ctx.bride_name || "Une mariée"} vous a ajouté à son mariage.`
      : `${ctx.bride_name || "A bride"} added you to their wedding.`
  },
  weddingProExcluded: {
    title: {
      en: "Removed from wedding",
      fr: "Retiré du mariage"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Vous avez été retiré du mariage de ${ctx.bride_name || "une mariée"}.`
      : `You have been removed from ${ctx.bride_name || "a bride"}'s wedding.`
  },
  weddingProLeft: {
    title: {
      en: "Professional left",
      fr: "Professionnel parti"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `${ctx.pro_name || "Un professionnel"} a quitté votre mariage.`
      : `${ctx.pro_name || "A professional"} left your wedding.`
  },
  weddingCancelled: {
    title: {
      en: "Wedding cancelled",
      fr: "Mariage annulé"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Le mariage de ${ctx.bride_name || "une mariée"} a été annulé.`
      : `${ctx.bride_name || "A bride"}'s wedding has been cancelled.`
  },

  // --- MARKETPLACE EVENTS ---
  marketplaceNewMessage: {
    title: {
      en: "New marketplace message",
      fr: "Nouveau message marketplace"
    },
    body: (ctx, locale) => locale === "fr"
      ? `${ctx.sender_full_name || "Quelqu'un"} vous a envoyé un message à propos de "${ctx.listing_title || "votre article"}".`
      : `${ctx.sender_full_name || "Someone"} sent you a message about "${ctx.listing_title || "your item"}".`
  },
  marketplaceItemSold: {
    title: {
      en: "Item Sold!",
      fr: "Article vendu !"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre article "${ctx.listing_title || "article"}" a été vendu.`
      : `Your item "${ctx.listing_title || "item"}" has been sold.`
  },
  marketplaceOrderConfirmed: {
    title: {
      en: "Order Confirmed",
      fr: "Commande confirmée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre achat de "${ctx.listing_title || "article"}" est confirmé.`
      : `Your purchase of "${ctx.listing_title || "item"}" is confirmed.`
  },
  marketplaceOfferExpired: {
    title: {
      en: "Offer Expired",
      fr: "Offre expirée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre offre sur "${ctx.listing_title || "article"}" a expiré.`
      : `Your offer on "${ctx.listing_title || "item"}" has expired.`
  },
  marketplaceLabelReady: {
    title: {
      en: "Shipping Label Ready",
      fr: "Étiquette d'envoi prête"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `L'étiquette FedEx pour "${ctx.listing_title || "article"}" est prête. Numéro: ${ctx.tracking_number || ""}`
      : `FedEx label for "${ctx.listing_title || "item"}" is ready. Tracking: ${ctx.tracking_number || ""}`
  },
  marketplaceTrackingUpdate: {
    title: {
      en: "Shipping Update",
      fr: "Mise à jour livraison"
    },
    body: (ctx, locale)=> {
      const statusLabels = {
        shipped: locale === "fr" ? "expédié" : "shipped",
        in_transit: locale === "fr" ? "en transit" : "in transit",
        out_for_delivery: locale === "fr" ? "en cours de livraison" : "out for delivery",
        delivered: locale === "fr" ? "livré" : "delivered",
        exception: locale === "fr" ? "problème de livraison" : "delivery exception",
      };
      const label = statusLabels[ctx.status] || ctx.status;
      return locale === "fr"
        ? `Votre colis est ${label}.`
        : `Your package is ${label}.`;
    }
  },
  marketplacePaymentSucceeded: {
    title: {
      en: "Payment Received",
      fr: "Paiement reçu"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Paiement reçu pour "${ctx.listing_title || "article"}".`
      : `Payment received for "${ctx.listing_title || "item"}".`
  },
  marketplaceNewOffer: {
    title: {
      en: "New Offer",
      fr: "Nouvelle offre"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `${ctx.buyer_name || "Quelqu'un"} a fait une offre sur "${ctx.listing_title || "article"}".`
      : `${ctx.buyer_name || "Someone"} made an offer on "${ctx.listing_title || "item"}".`
  },
  marketplaceOfferAccepted: {
    title: {
      en: "Offer Accepted!",
      fr: "Offre acceptée !"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre offre sur "${ctx.listing_title || "article"}" a été acceptée !`
      : `Your offer on "${ctx.listing_title || "item"}" was accepted!`
  },
  marketplaceOfferRejected: {
    title: {
      en: "Offer Declined",
      fr: "Offre refusée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre offre sur "${ctx.listing_title || "article"}" a été refusée.`
      : `Your offer on "${ctx.listing_title || "item"}" was declined.`
  },
  marketplaceOfferWithdrawn: {
    title: {
      en: "Offer Withdrawn",
      fr: "Offre retirée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Un acheteur a retiré son offre sur "${ctx.listing_title || "article"}".`
      : `A buyer withdrew their offer on "${ctx.listing_title || "item"}".`
  },

  // --- MARKETPLACE TRANSACTION LIFECYCLE ---
  marketplaceTransactionExpired: {
    title: {
      en: "Order Expired",
      fr: "Commande expirée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `La commande pour "${ctx.listing_title || "article"}" a expiré. ${ctx.reason || "L'article n'a pas été expédié dans les délais."}`
      : `The order for "${ctx.listing_title || "item"}" has expired. ${ctx.reason || "Item was not shipped in time."}`
  },
  marketplaceRefunded: {
    title: {
      en: "Order Refunded",
      fr: "Commande remboursée"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Votre commande pour "${ctx.listing_title || "article"}" a été remboursée.`
      : `Your order for "${ctx.listing_title || "item"}" has been refunded.`
  },
  marketplaceDisputed: {
    title: {
      en: "Payment Disputed",
      fr: "Paiement contesté"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Un litige a été ouvert pour "${ctx.listing_title || "article"}". ${ctx.reason || ""}`
      : `A dispute has been opened for "${ctx.listing_title || "item"}". ${ctx.reason || ""}`
  },
  marketplaceDisputeResolved: {
    title: {
      en: "Dispute Resolved",
      fr: "Litige résolu"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Le litige pour "${ctx.listing_title || "article"}" a été résolu.`
      : `The dispute for "${ctx.listing_title || "item"}" has been resolved.`
  },
  marketplaceRefundRequested: {
    title: {
      en: "Refund Requested",
      fr: "Remboursement demandé"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Un remboursement a été demandé pour "${ctx.listing_title || "article"}". Raison: ${ctx.refund_reason || "Non spécifiée"}`
      : `A refund has been requested for "${ctx.listing_title || "item"}". Reason: ${ctx.refund_reason || "Not specified"}`
  },
  marketplaceRefundApproved: {
    title: {
      en: "Refund Approved",
      fr: "Remboursement approuvé"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `Le remboursement pour "${ctx.listing_title || "article"}" a été approuvé. Vous serez remboursé sous quelques jours.`
      : `The refund for "${ctx.listing_title || "item"}" was approved. You will be refunded within a few days.`
  },
  marketplaceRefundRejected: {
    title: {
      en: "Refund Declined",
      fr: "Remboursement refusé"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `La demande de remboursement pour "${ctx.listing_title || "article"}" a été refusée.`
      : `The refund request for "${ctx.listing_title || "item"}" was declined.`
  },
  marketplaceShipmentCancelled: {
    title: {
      en: "Shipment Cancelled",
      fr: "Envoi annulé"
    },
    body: (ctx, locale)=>locale === "fr"
      ? `L'envoi pour "${ctx.listing_title || "article"}" a été annulé par le vendeur.`
      : `The shipment for "${ctx.listing_title || "item"}" was cancelled by the seller.`
  },
};
// --- HELPERS DB ---
// Claim un seul event par son ID (pour le trigger realtime)
async function claimSingleEvent(eventId, workerId) {
  const { data, error } = await supabase
    .from("notifications_outbox")
    .update({ claimed_at: new Date().toISOString(), claimed_by: workerId })
    .eq("id", eventId)
    .is("processed_at", null)
    .select()
    .single();
  
  if (error) {
    console.log(`Event ${eventId} already processed or not found`);
    return null;
  }
  return data;
}

// Claim un petit batch pour le catch-up (fallback)
async function claimBatch(workerId) {
  const { data, error } = await supabase.rpc("claim_outbox_events", {
    p_batch_size: 5, // Réduit de 100 à 5 pour éviter les timeouts
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
  if (!actions.length) {
    console.log("[executeInAppInserts] No actions to insert");
    return [];
  }
  console.log(`[executeInAppInserts] Inserting ${actions.length} notifications:`, JSON.stringify(actions));
  const { data, error } = await supabase.from("notifications").insert(actions).select("id, profile_id");
  if (error) {
    console.error("[executeInAppInserts] INSERT ERROR:", error);
    throw new Error(`Failed to insert notifications: ${error.message}`);
  }
  console.log(`[executeInAppInserts] Successfully inserted ${data?.length || 0} notifications`);
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
  if (!type) {
    console.log(`[processChatMessageCreated] Unknown type for event_type: ${ev.event_type}`);
    return actions;
  }
  const messageId = ev.payload?.message_id;
  if (!messageId) throw new Error("chatMessageCreated missing message_id");
  
  // Récupérer le message
  console.log(`[processChatMessageCreated] Fetching message ${messageId}`);
  const { data: msg, error: eMsg } = await supabase
    .from("chat_messages")
    .select("id, room_id, profile_id")
    .eq("id", messageId)
    .single();
  if (eMsg || !msg) throw new Error(`Message not found: ${eMsg?.message}`);
  console.log(`[processChatMessageCreated] Message found: room_id=${msg.room_id}, sender=${msg.profile_id}`);
  
  // Vérifier le type de room séparément
  const { data: room, error: eRoom } = await supabase
    .from("chat_rooms")
    .select("type")
    .eq("id", msg.room_id)
    .single();
  if (eRoom || !room) throw new Error(`Room not found: ${eRoom?.message}`);
  console.log(`[processChatMessageCreated] Room type: ${room.type}`);
  if (room.type !== "private") {
    console.log(`[processChatMessageCreated] Skipping non-private room`);
    return actions;
  }
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
// processAlertReminder SUPPRIMÉ - Code mort, jamais déclenché
// processWedPublished SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
// Les notifications Wedding of the Week et Replays passent par le broadcast Admin Panel
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

// --- WEDDING EVENT PROCESSORS ---
// Handles: wedding_pro_added, wedding_pro_excluded, wedding_pro_left, wedding_cancelled
async function processWeddingEvent(ev) {
  const actions = {
    inApp: [],
    push: []
  };
  
  const eventType = ev.event_type;
  // Note: DB triggers use recipient_id for bride, but we also support bride_profile_id for consistency
  const payload = ev.payload || {};
  const weddingId = payload.wedding_id;
  const proId = payload.pro_profile_id;
  const brideId = payload.bride_profile_id || payload.recipient_id; // recipient_id is used by DB triggers
  const proName = payload.pro_name; // Already provided by trigger
  
  if (!weddingId) {
    console.warn(`[processWeddingEvent] Missing wedding_id for event ${eventType}`);
    return actions;
  }
  
  // Determine notification type and recipient based on event
  let notificationType: string;
  let recipientId: string | undefined;
  const ctx: { bride_name?: string; pro_name?: string } = {};
  
  switch(eventType) {
    case "wedding_pro_added":
      // Pro receives notification that they were added
      notificationType = "weddingProAdded";
      recipientId = proId;
      if (brideId) {
        const brideProfile = await getProfileSummary(brideId);
        ctx.bride_name = brideProfile.full_name;
      }
      break;
      
    case "wedding_pro_excluded":
      // Pro receives notification that they were excluded
      notificationType = "weddingProExcluded";
      recipientId = proId;
      if (brideId) {
        const brideProfile = await getProfileSummary(brideId);
        ctx.bride_name = brideProfile.full_name;
      }
      break;
      
    case "wedding_pro_left":
      // Bride receives notification that pro left
      notificationType = "weddingProLeft";
      recipientId = brideId;
      // Use pro_name from payload if available (provided by DB trigger), otherwise fetch
      if (proName) {
        ctx.pro_name = proName;
      } else if (proId) {
        const proProfile = await getProfileSummary(proId);
        ctx.pro_name = proProfile.full_name;
      }
      break;
      
    case "wedding_cancelled":
      // DB trigger already creates one event per pro with recipient_id = pro
      notificationType = "weddingCancelled";
      recipientId = payload.recipient_id; // The pro to notify (set by DB trigger)
      // bride_name is already in payload from DB trigger
      ctx.bride_name = payload.bride_name;
      break;
      
    default:
      console.warn(`[processWeddingEvent] Unknown wedding event type: ${eventType}`);
      return actions;
  }
  
  // For all wedding events, recipient is already determined above
  // (DB trigger creates one event per recipient for wedding_cancelled)
  const recipients = recipientId ? [recipientId] : [];
  
  if (recipients.length === 0) {
    console.log(`[processWeddingEvent] No recipients for event ${eventType}`);
    return actions;
  }
  
  const tmpl = I18N_TEMPLATES[notificationType];
  if (!tmpl) {
    console.warn(`[processWeddingEvent] No template for ${notificationType}`);
    return actions;
  }
  
  // Process each recipient
  for (const rid of recipients) {
    const setting = await getNotificationSetting(rid, notificationType);
    if (!setting.in_app && !setting.push) continue;
    
    const locale = await getUserLocale(rid);
    const title = tmpl.title[locale] || tmpl.title.en;
    const body = tmpl.body(ctx, locale);
    
    // Include relevant IDs for navigation
    const basePayload: Record<string, string> = {
      wedding_id: weddingId,
      notification_type: notificationType
    };
    // For weddingProLeft, bride needs pro_profile_id to navigate to pro details
    if (eventType === "wedding_pro_left" && proId) {
      basePayload.pro_profile_id = proId;
    }
    // For weddingProAdded/Excluded, pro might need bride_profile_id
    if ((eventType === "wedding_pro_added" || eventType === "wedding_pro_excluded") && brideId) {
      basePayload.bride_profile_id = brideId;
    }
    
    if (setting.in_app) {
      actions.inApp.push({
        profile_id: rid,
        type: notificationType,
        payload: basePayload
      });
    }
    
    if (setting.push) {
      const tokens = await getDeviceTokens(rid);
      const pushData: Record<string, string> = {
        type: notificationType,
        wedding_id: String(weddingId)
      };
      if (basePayload.pro_profile_id) pushData.pro_profile_id = basePayload.pro_profile_id;
      if (basePayload.bride_profile_id) pushData.bride_profile_id = basePayload.bride_profile_id;
      
      tokens.forEach((t) => actions.push.push({
        token: t.token,
        platform: t.platform,
        title,
        body,
        isHighPriority: false,
        ttlSeconds: 300,
        data: pushData
      }));
    }
  }
  
  console.log(`[processWeddingEvent] ${eventType}: ${actions.inApp.length} in-app, ${actions.push.length} push`);
  return actions;
}
// --- MARKETPLACE MESSAGE PROCESSOR ---
async function processMarketplaceMessageCreated(ev) {
  const actions = { inApp: [], push: [] };
  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) return actions;

  const payload = ev.payload || {};
  const { message_id, listing_id, sender_id, receiver_id } = payload;
  if (!message_id || !receiver_id) return actions;

  const recipientId = receiver_id;
  const setting = await getNotificationSetting(recipientId, type);
  if (!setting.in_app && !setting.push) return actions;

  // Fetch sender info + listing title
  const senderProfile = await getProfileSummary(sender_id);
  let listingTitle = null;
  if (listing_id) {
    const { data: listing } = await supabase
      .from("marketplace_listings")
      .select("title")
      .eq("id", listing_id)
      .maybeSingle();
    listingTitle = listing?.title;
  }

  const ctx = {
    sender_full_name: senderProfile.full_name,
    listing_title: listingTitle
  };
  const locale = await getUserLocale(recipientId);
  const tmpl = I18N_TEMPLATES[type];
  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body(ctx, locale);

  const basePayload = {
    listing_id: listing_id,
    sender_profile_id: sender_id,
    message_id: message_id
  };

  if (setting.in_app) {
    actions.inApp.push({ profile_id: recipientId, type, payload: basePayload });
  }
  if (setting.push) {
    const tokens = await getDeviceTokens(recipientId);
    tokens.forEach(t => actions.push.push({
      token: t.token, platform: t.platform, title, body,
      isHighPriority: false, ttlSeconds: 300,
      data: { type, ...Object.fromEntries(Object.entries(basePayload).map(([k, v]) => [k, v == null ? "" : String(v)])) }
    }));
  }

  console.log(`[processMarketplaceMessageCreated] ${actions.inApp.length} in-app, ${actions.push.length} push`);
  return actions;
}

// --- MARKETPLACE EVENT PROCESSOR ---
// Handles all marketplace notification events generically
// The payload from Edge Functions already contains: recipient_id, title, body, and context fields
async function processMarketplaceEvent(ev) {
  const actions = {
    inApp: [],
    push: []
  };

  const type = EVENT_TO_NOTIFICATION_TYPE[ev.event_type];
  if (!type) {
    console.log(`[processMarketplaceEvent] Unknown type for event_type: ${ev.event_type}`);
    return actions;
  }

  const payload = ev.payload || {};
  const recipientId = payload.recipient_id;
  if (!recipientId) {
    console.warn(`[processMarketplaceEvent] Missing recipient_id for ${ev.event_type}`);
    return actions;
  }

  const setting = await getNotificationSetting(recipientId, type);
  if (!setting.in_app && !setting.push) return actions;

  const locale = await getUserLocale(recipientId);
  const tmpl = I18N_TEMPLATES[type];
  if (!tmpl) {
    console.warn(`[processMarketplaceEvent] No template for ${type}`);
    return actions;
  }

  // Build context from payload for i18n templates
  const ctx = {
    listing_title: payload.listing_title,
    tracking_number: payload.tracking_number,
    status: payload.status,
    buyer_name: payload.buyer_name,
    reason: payload.reason,
    refund_reason: payload.refund_reason,
    amount_cents: payload.amount_cents,
  };

  const title = tmpl.title[locale] || tmpl.title.en;
  const body = tmpl.body(ctx, locale);

  // Build in-app notification payload (keep relevant IDs for navigation)
  const notifPayload = {};
  if (payload.transaction_id) notifPayload.transaction_id = payload.transaction_id;
  if (payload.listing_id) notifPayload.listing_id = payload.listing_id;
  if (payload.offer_id) notifPayload.offer_id = payload.offer_id;
  if (payload.tracking_number) notifPayload.tracking_number = payload.tracking_number;
  if (payload.label_url) notifPayload.label_url = payload.label_url;
  if (payload.status) notifPayload.status = payload.status;

  if (setting.in_app) {
    actions.inApp.push({
      profile_id: recipientId,
      type,
      payload: notifPayload
    });
  }

  if (setting.push) {
    const tokens = await getDeviceTokens(recipientId);
    const pushData = {
      type,
      ...Object.fromEntries(
        Object.entries(notifPayload).map(([k, v]) => [k, v == null ? "" : String(v)])
      )
    };
    tokens.forEach((t) => actions.push.push({
      token: t.token,
      platform: t.platform,
      title,
      body,
      isHighPriority: false,
      ttlSeconds: 300,
      data: pushData
    }));
  }

  console.log(`[processMarketplaceEvent] ${ev.event_type}: ${actions.inApp.length} in-app, ${actions.push.length} push`);
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
  console.log(`[markFailed] Marking event ${id} as failed. Attempts: ${prevAttempts + 1}, Error: ${lastError}`);
  const { error } = await supabase.from("notifications_outbox").update({
    attempts: prevAttempts + 1,
    last_error: lastError.slice(0, 8000),
    claimed_at: null,  // Reset claim pour permettre retry
    claimed_by: null
  }).eq("id", id);
  if (error) {
    console.error("[markFailed] UPDATE ERROR:", error);
  } else {
    console.log(`[markFailed] Successfully marked event ${id} as failed`);
  }
}
// --- PROCESS SINGLE EVENT ---
async function processEvent(ev) {
  let actions = {
    inApp: [],
    push: []
  };
  
  switch(ev.event_type) {
    case "chatMessageCreated":
      actions = await processChatMessageCreated(ev);
      break;
    case "connectionRequestCreated":
    case "connectionRequestAccepted":
      actions = await processConnectionRequest(ev);
      break;
    // connectionRequestDeclined: SUPPRIMÉ
    case "wishlistAdded":
      actions = await processWishlistAdded(ev);
      break;
    // professionalAlertReminder24h: SUPPRIMÉ
    case "videoIncoming":
      actions = await processVideoIncoming(ev);
      break;
    // wedPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
    // replayPublished: SUPPRIMÉ - Géré par send-broadcast-notification (Admin Panel)
    
    // --- WEDDING EVENTS ---
    case "wedding_pro_added":
    case "wedding_pro_excluded":
    case "wedding_pro_left":
    case "wedding_cancelled":
      actions = await processWeddingEvent(ev);
      break;

    // --- MARKETPLACE EVENTS ---
    case "marketplaceMessageCreated":
      actions = await processMarketplaceMessageCreated(ev);
      break;
    case "marketplace_item_sold":
    case "marketplace_order_confirmed":
    case "marketplace_offer_expired":
    case "marketplace_label_ready":
    case "marketplace_tracking_update":
    case "marketplace_payment_succeeded":
    case "marketplace_new_offer":
    case "marketplace_offer_accepted":
    case "marketplace_offer_rejected":
    case "marketplace_offer_withdrawn":
    case "marketplace_transaction_expired":
    case "marketplace_refunded":
    case "marketplace_disputed":
    case "marketplace_dispute_resolved":
    case "marketplace_refund_requested":
    case "marketplace_refund_approved":
    case "marketplace_refund_rejected":
    case "marketplace_shipment_cancelled":
      actions = await processMarketplaceEvent(ev);
      break;

    default:
      console.warn(`Unknown event_type: ${ev.event_type}`);
      return { inApp: 0, push: 0 };
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
      ia.payload.article_id === pushAction.data.article_id ||
      ia.payload.transaction_id === pushAction.data.transaction_id
    )?.profile_id;
    
    if (recipientId && notificationIdMap.has(recipientId)) {
      pushAction.data.notification_id = String(notificationIdMap.get(recipientId));
    }
  });
  
  await executePushSends(actions.push);
  
  return { inApp: createdNotifications.length, push: actions.push.length };
}

// --- SERVER ---
serve(async (req) => {
  const workerId = crypto.randomUUID();
  const startTime = Date.now();
  
  try {
    // Essayer de parser le body pour récupérer event_id (du trigger realtime)
    let eventId = null;
    try {
      const body = await req.json();
      eventId = body?.event_id;
    } catch {
      // Pas de body JSON, mode batch
    }
    
    // MODE 1: Traitement d'un event spécifique (trigger realtime)
    if (eventId) {
      console.log(`[REALTIME] Processing single event: ${eventId}`);
      const ev = await claimSingleEvent(eventId, workerId);
      
      if (!ev) {
        return new Response(JSON.stringify({ 
          mode: "realtime", 
          status: "skipped", 
          reason: "already_processed_or_not_found" 
        }), { status: 200, headers: { "Content-Type": "application/json" } });
      }
      
      try {
        const result = await processEvent(ev);
        await markProcessed(ev.id);
        const duration = Date.now() - startTime;
        
        console.log(`[REALTIME] Event ${ev.id} processed in ${duration}ms`);
        return new Response(JSON.stringify({ 
          mode: "realtime", 
          status: "success", 
          event_id: ev.id,
          event_type: ev.event_type,
          notifications_created: result.inApp,
          push_sent: result.push,
          duration_ms: duration
        }), { status: 200, headers: { "Content-Type": "application/json" } });
        
      } catch (e) {
        console.error(`[REALTIME] Failed to process event ${ev.id}:`, e);
        await markFailed(ev.id, ev.attempts ?? 0, String(e));
        return new Response(JSON.stringify({ 
          mode: "realtime", 
          status: "error", 
          event_id: ev.id,
          error: String(e)
        }), { status: 200, headers: { "Content-Type": "application/json" } });
      }
    }
    
    // MODE 2: Batch processing (catch-up, appelé manuellement ou par cron désactivé)
    console.log(`[BATCH] Processing batch...`);
    const events = await claimBatch(workerId);
    
    if (!events || events.length === 0) {
      return new Response(JSON.stringify({ 
        mode: "batch", 
        status: "no_events" 
      }), { status: 200, headers: { "Content-Type": "application/json" } });
    }
    
    let processed = 0;
    let failed = 0;
    
    for (const ev of events) {
      try {
        await processEvent(ev);
        await markProcessed(ev.id);
        processed++;
      } catch (e) {
        console.error(`[BATCH] Failed to process event ${ev.id}:`, e);
        await markFailed(ev.id, ev.attempts ?? 0, String(e));
        failed++;
      }
    }
    
    const duration = Date.now() - startTime;
    console.log(`[BATCH] Processed ${processed}/${events.length} events in ${duration}ms`);
    
    return new Response(JSON.stringify({ 
      mode: "batch", 
      status: "complete",
      total: events.length,
      processed,
      failed,
      duration_ms: duration
    }), { status: 200, headers: { "Content-Type": "application/json" } });
    
  } catch (e) {
    console.error("Outbox drain fatal error:", e);
    return new Response(JSON.stringify({ 
      status: "fatal_error", 
      error: e.message 
    }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
