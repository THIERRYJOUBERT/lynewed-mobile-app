// supabase/functions/video_sessions_cleanup/index.ts
// Cron job pour nettoyer les sessions vidéo abandonnées

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (_req) => {
  try {
    console.log("🧹 Starting video sessions cleanup...");

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      global: {
        headers: {
          "x-lynewed-worker": "video_sessions_cleanup",
        },
      },
    });

    // Appeler la fonction PostgreSQL
    const { data, error } = await supabase.rpc("cleanup_abandoned_video_sessions");

    if (error) {
      console.error("❌ Cleanup error:", error);
      return new Response(
        JSON.stringify({ error: error.message }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    console.log("✅ Video sessions cleanup completed successfully");

    return new Response(
      JSON.stringify({
        success: true,
        message: "Video sessions cleaned up",
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("❌ Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
