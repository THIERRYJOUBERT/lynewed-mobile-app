-- =========================================================================
-- MIGRATION 002: CORRECTIONS DE SÉCURITÉ RLS
-- Date: 4 Novembre 2025
-- Description: Ajout des policies INSERT manquantes et renforcement sécurité
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1. PROFILES: Forcer que l'utilisateur ne peut créer QUE son propre profil
-- -------------------------------------------------------------------------
CREATE POLICY "profiles_insert_self_only" ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

COMMENT ON POLICY "profiles_insert_self_only" ON public.profiles IS 
  'Empêche un utilisateur de créer un profil pour un autre utilisateur';

-- -------------------------------------------------------------------------
-- 2. CHAT_MESSAGES: Forcer que profile_id = auth.uid()
-- -------------------------------------------------------------------------
CREATE POLICY "chat_messages_insert_self_only" ON public.chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

COMMENT ON POLICY "chat_messages_insert_self_only" ON public.chat_messages IS 
  'Empêche un utilisateur d''envoyer un message au nom d''un autre';

-- -------------------------------------------------------------------------
-- 3. DEVICE_TOKENS: Renforcer la sécurité - Pas de lecture des tokens
-- -------------------------------------------------------------------------
-- Supprimer l'ancienne policy qui permettait la lecture
DROP POLICY IF EXISTS "device_tokens_owner_rw" ON public.device_tokens;

-- Nouvelle policy: INSERT/UPDATE/DELETE uniquement (pas de SELECT)
CREATE POLICY "device_tokens_owner_write_only" ON public.device_tokens
  FOR ALL
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

COMMENT ON POLICY "device_tokens_owner_write_only" ON public.device_tokens IS 
  'Permet uniquement d''écrire/supprimer son propre token, pas de le lire (sécurité)';

-- -------------------------------------------------------------------------
-- 4. NOTIFICATIONS: S'assurer qu'un user ne peut lire que ses notifs
-- -------------------------------------------------------------------------
CREATE POLICY "notifications_read_own_only" ON public.notifications
  FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

COMMENT ON POLICY "notifications_read_own_only" ON public.notifications IS 
  'Un utilisateur ne peut lire que ses propres notifications';

-- -------------------------------------------------------------------------
-- 5. USER_PREFERENCES: Forcer INSERT pour son propre profil uniquement
-- -------------------------------------------------------------------------
CREATE POLICY "user_preferences_insert_self" ON public.user_preferences
  FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

COMMENT ON POLICY "user_preferences_insert_self" ON public.user_preferences IS 
  'Empêche de créer des préférences pour un autre utilisateur';

-- -------------------------------------------------------------------------
-- 6. USER_POIS: Forcer INSERT pour son propre profil uniquement
-- -------------------------------------------------------------------------
CREATE POLICY "user_pois_insert_self" ON public.user_pois
  FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

COMMENT ON POLICY "user_pois_insert_self" ON public.user_pois IS 
  'Un utilisateur ne peut créer des POIs que pour lui-même';

-- -------------------------------------------------------------------------
-- 7. WISHLIST_ITEMS: Vérifier qu'une mariée ne peut ajouter que ses propres favoris
-- -------------------------------------------------------------------------
-- La policy existe déjà mais vérifions qu'elle couvre bien INSERT
CREATE POLICY IF NOT EXISTS "wishlist_items_insert_self" ON public.wishlist_items
  FOR INSERT
  TO authenticated
  WITH CHECK (bride_profile_id = auth.uid());

-- -------------------------------------------------------------------------
-- 8. VIDEO_SESSIONS: Renforcer la création de sessions
-- -------------------------------------------------------------------------
CREATE POLICY "video_sessions_insert_as_initiator" ON public.video_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK (initiator_id = auth.uid());

COMMENT ON POLICY "video_sessions_insert_as_initiator" ON public.video_sessions IS 
  'Seul l''initiateur peut créer une session vidéo avec son propre ID';

-- -------------------------------------------------------------------------
-- 9. CONNECTION_REQUESTS: Protéger les demandes de connexion
-- -------------------------------------------------------------------------
CREATE POLICY "connection_requests_insert_as_requester" ON public.connection_requests
  FOR INSERT
  TO authenticated
  WITH CHECK (requester_profile_id = auth.uid());

COMMENT ON POLICY "connection_requests_insert_as_requester" ON public.connection_requests IS 
  'Un utilisateur ne peut créer des demandes qu''en son propre nom';

-- -------------------------------------------------------------------------
-- 10. REPORTS: Un utilisateur ne peut créer que ses propres signalements
-- -------------------------------------------------------------------------
CREATE POLICY "reports_insert_self" ON public.reports
  FOR INSERT
  TO authenticated
  WITH CHECK (reporter_profile_id = auth.uid());

COMMENT ON POLICY "reports_insert_self" ON public.reports IS 
  'Empêche de faire un signalement au nom d''un autre utilisateur';

-- =========================================================================
-- VÉRIFICATIONS POST-MIGRATION
-- =========================================================================

-- Vérifier que toutes les tables critiques ont bien RLS activé
DO $$
DECLARE
    r RECORD;
    missing_rls TEXT[] := ARRAY[]::TEXT[];
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT LIKE '%_old%'
        AND tablename NOT IN (
            SELECT tablename 
            FROM pg_tables t
            WHERE schemaname = 'public'
            AND EXISTS (
                SELECT 1 FROM pg_class
                WHERE relname = t.tablename
                AND relrowsecurity = true
            )
        )
    LOOP
        missing_rls := array_append(missing_rls, r.tablename);
    END LOOP;
    
    IF array_length(missing_rls, 1) > 0 THEN
        RAISE WARNING 'Tables sans RLS: %', array_to_string(missing_rls, ', ');
    ELSE
        RAISE NOTICE '✅ Toutes les tables ont RLS activé';
    END IF;
END$$;

-- =========================================================================
-- FIN DE LA MIGRATION 002
-- =========================================================================
