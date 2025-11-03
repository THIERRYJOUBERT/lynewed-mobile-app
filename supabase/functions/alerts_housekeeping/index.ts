// Phase 2.3 — alerts_housekeeping (Edge Function) — version RPC atomique
// - Expire les alertes échues
// - Capture atomiquement les alertes expirant dans ~24h via rpc_alerts_capture_to_remind
// - Enqueue l’événement 'professionalAlertReminder24h' (idempotent via event_key)
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  global: {
    headers: {
      "x-lynewed-worker": "alerts_housekeeping"
    }
  }
});
async function expireAlerts() {
  const { error } = await supabase.from("professional_alerts").update({
    status: "expired"
  }).lt("expires_at", new Date().toISOString()).eq("status", "active").eq("is_deleted", false);
  if (error) throw new Error(`expireAlerts error: ${error.message}`);
}
serve(async ()=>{
  try {
    // 1) Expirer les alertes échues
    await expireAlerts();
    // 2) Fenêtre de rappel: entre [now()+24h ; now()+24h+15m]
    const now = new Date();
    const from = new Date(now.getTime() + 24 * 3600 * 1000);
    const to = new Date(from.getTime() + 15 * 60 * 1000);
    // 3) Capture atomique (flag reminder_sent=true + retour des ids)
    const { data: ids, error: capErr } = await supabase.rpc("rpc_alerts_capture_to_remind", {
      p_from: from.toISOString(),
      p_to: to.toISOString()
    });
    if (capErr) throw new Error(`rpc_alerts_capture_to_remind error: ${capErr.message}`);
    const alertIds = (ids || []).map((r)=>r.id);
    if (alertIds.length === 0) {
      return new Response("No reminders to enqueue", {
        status: 200
      });
    }
    // 4) Enqueue dans outbox (idempotent via event_key unique)
    const rows = alertIds.map((id)=>({
        event_type: "professionalAlertReminder24h",
        payload: {
          alert_id: id
        },
        event_key: `alert:reminder24h:${id}`
      }));
    const { error: upErr } = await supabase.from("notifications_outbox").upsert(rows, {
      onConflict: "event_key"
    });
    if (upErr) throw new Error(`outbox upsert error: ${upErr.message}`);
    return new Response(`Enqueued ${alertIds.length} reminders`, {
      status: 200
    });
  } catch (e) {
    console.error("alerts_housekeeping error", e);
    return new Response(`Error: ${e}`, {
      status: 500
    });
  }
});
