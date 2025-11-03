// Phase 2.4 — recent_locations_cleanup (Edge Function)
// - Purge pro_recent_locations > 30 jours
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  global: {
    headers: {
      "x-lynewed-worker": "recent_locations_cleanup"
    }
  }
});
serve(async ()=>{
  try {
    const cutoff = new Date(Date.now() - 30 * 24 * 3600 * 1000).toISOString();
    const { error } = await supabase.from("pro_recent_locations").delete().lt("last_seen_at", cutoff);
    if (error) throw new Error(`delete error: ${error.message}`);
    return new Response("recent_locations_cleanup OK", {
      status: 200
    });
  } catch (e) {
    console.error("recent_locations_cleanup error", e);
    return new Response(`Error: ${e}`, {
      status: 500
    });
  }
});
