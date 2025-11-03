// supabase/functions/account-delete/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// Ces variables seront injectées par l'environnement Supabase au moment de l'exécution.
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
// Fonction helper pour hasher l'email de manière sécurisée avant de le stocker.
async function hashString(str) {
  const data = new TextEncoder().encode(str);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b)=>b.toString(16).padStart(2, '0')).join('');
}
serve(async (req)=>{
  try {
    // 1. Vérifier l'en-tête d'autorisation pour s'assurer que l'appel est authentifié.
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({
        error: "Missing Authorization header"
      }), {
        status: 401,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    // 2. Créer un client Supabase dans le scope de l'utilisateur pour valider son token JWT.
    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: authHeader
        }
      }
    });
    const { data: { user }, error: userErr } = await userClient.auth.getUser();
    if (userErr || !user) {
      return new Response(JSON.stringify({
        error: "Invalid user token"
      }), {
        status: 401,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    const userId = user.id;
    const userEmail = user.email;
    // 3. Créer un client admin avec les privilèges service_role pour effectuer les opérations de suppression.
    const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    // 4. [NOUVELLE ÉTAPE] Journaliser l'événement de suppression avant de supprimer les données.
    if (userEmail) {
      const emailHash = await hashString(userEmail);
      await adminClient.from("deleted_users_log").insert({
        user_id: userId,
        email_hash: emailHash,
        reason: 'user_request'
      });
    }
    // 5. Nettoyer les données qui ne sont pas supprimées par la cascade de la base de données.
    //    - Les tokens de notification push.
    await adminClient.from("device_tokens").delete().eq("profile_id", userId);
    //    - (Optionnel mais recommandé) Les fichiers dans le Stockage (Storage).
    try {
      // Tente de supprimer le dossier de l'avatar.
      const { data: list, error: listError } = await adminClient.storage.from("avatars").list(userId);
      if (list && list.length > 0) {
        const filesToRemove = list.map((file)=>`${userId}/${file.name}`);
        await adminClient.storage.from("avatars").remove(filesToRemove);
      }
    } catch (storageError) {
      console.warn(`Non-blocking error during avatar cleanup for user ${userId}:`, storageError);
    }
    // 6. Supprimer l'utilisateur du service d'authentification de Supabase.
    //    C'est cette action qui déclenche la suppression en cascade dans la base de données (profiles, etc.).
    const { error: deleteErr } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteErr) {
      // Si cette étape échoue, c'est une erreur critique.
      console.error(`CRITICAL: Failed to delete user ${userId} from auth:`, deleteErr);
      return new Response(JSON.stringify({
        error: "Failed to delete user account."
      }), {
        status: 500,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    // 7. Renvoyer une réponse de succès.
    return new Response(JSON.stringify({
      message: "Account deleted successfully"
    }), {
      headers: {
        "Content-Type": "application/json"
      },
      status: 200
    });
  } catch (e) {
    console.error("Critical error in account-delete function:", e);
    return new Response(JSON.stringify({
      error: "An internal server error occurred."
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
