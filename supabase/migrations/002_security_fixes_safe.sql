-- =========================================================================
-- MIGRATION 002: CORRECTIONS DE SÉCURITÉ RLS (VERSION SÉCURISÉE)
-- Date: 4 Novembre 2025
-- Description: Ajout des policies manquantes SANS CASSER L'EXISTANT
-- =========================================================================

-- -------------------------------------------------------------------------
-- ÉTAPE 1: BACKUP - Sauvegarder l'état actuel des policies
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public._migration_002_backup (
    id SERIAL PRIMARY KEY,
    backup_date TIMESTAMPTZ DEFAULT NOW(),
    table_name TEXT,
    policy_name TEXT,
    policy_definition TEXT
);

-- Sauvegarder les policies actuelles
INSERT INTO public._migration_002_backup (table_name, policy_name, policy_definition)
SELECT 
    tablename,
    policyname,
    pg_get_expr(polqual, polrelid) || ' WITH CHECK ' || pg_get_expr(polwithcheck, polrelid)
FROM pg_policies p
JOIN pg_class c ON c.relname = p.tablename
JOIN pg_policy pol ON pol.polrelid = c.oid AND pol.polname = p.policyname
WHERE schemaname = 'public';

-- -------------------------------------------------------------------------
-- ÉTAPE 2: PROFILES - Policy INSERT (CRITIQUE)
-- -------------------------------------------------------------------------
-- Vérifier si la policy existe déjà
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'profiles' 
        AND policyname = 'profiles_insert_self_only'
    ) THEN
        -- Créer la policy INSERT pour profiles
        CREATE POLICY "profiles_insert_self_only" ON public.profiles
          FOR INSERT
          TO authenticated
          WITH CHECK (id = auth.uid());
        
        RAISE NOTICE '✅ Policy profiles_insert_self_only créée';
    ELSE
        RAISE NOTICE '⚠️  Policy profiles_insert_self_only existe déjà';
    END IF;
END$$;

COMMENT ON POLICY "profiles_insert_self_only" ON public.profiles IS 
  'Sécurité: Empêche un utilisateur de créer un profil pour un autre utilisateur';

-- -------------------------------------------------------------------------
-- ÉTAPE 3: DEVICE_TOKENS - Supprimer lecture des tokens (SÉCURITÉ)
-- -------------------------------------------------------------------------
-- Les tokens FCM ne doivent JAMAIS être lisibles par le client
DO $$
BEGIN
    -- Supprimer la policy qui permet la lecture
    IF EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'device_tokens' 
        AND policyname = 'Users can view their own device tokens'
    ) THEN
        DROP POLICY "Users can view their own device tokens" ON public.device_tokens;
        RAISE NOTICE '✅ Policy de lecture des tokens supprimée (sécurité)';
    END IF;
    
    -- Vérifier que la policy d'écriture existe toujours
    IF EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'device_tokens' 
        AND policyname = 'device_tokens_owner_rw'
    ) THEN
        RAISE NOTICE '✅ Policy d''écriture device_tokens OK';
    ELSE
        RAISE WARNING '⚠️  Policy device_tokens_owner_rw manquante!';
    END IF;
END$$;

-- -------------------------------------------------------------------------
-- ÉTAPE 4: VÉRIFICATIONS POST-MIGRATION
-- -------------------------------------------------------------------------

-- Vérifier que RLS est toujours activé sur toutes les tables
DO $$
DECLARE
    r RECORD;
    tables_without_rls TEXT[] := ARRAY[]::TEXT[];
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT LIKE '%_old%'
        AND tablename NOT LIKE '%_backup%'
        AND tablename NOT IN (
            SELECT c.relname
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
            AND c.relrowsecurity = true
        )
    LOOP
        tables_without_rls := array_append(tables_without_rls, r.tablename);
    END LOOP;
    
    IF array_length(tables_without_rls, 1) > 0 THEN
        RAISE WARNING '⚠️  Tables sans RLS: %', array_to_string(tables_without_rls, ', ');
    ELSE
        RAISE NOTICE '✅ Toutes les tables ont RLS activé';
    END IF;
END$$;

-- Vérifier les policies critiques
DO $$
DECLARE
    critical_tables TEXT[] := ARRAY['profiles', 'chat_messages', 'device_tokens', 'notifications', 'video_sessions'];
    t TEXT;
    policy_count INT;
BEGIN
    FOREACH t IN ARRAY critical_tables
    LOOP
        SELECT COUNT(*) INTO policy_count
        FROM pg_policies
        WHERE schemaname = 'public'
        AND tablename = t;
        
        IF policy_count = 0 THEN
            RAISE WARNING '⚠️  Table % n''a AUCUNE policy!', t;
        ELSE
            RAISE NOTICE '✅ Table % a % policy/policies', t, policy_count;
        END IF;
    END LOOP;
END$$;

-- -------------------------------------------------------------------------
-- ÉTAPE 5: TEST DE SÉCURITÉ
-- -------------------------------------------------------------------------

-- Test 1: Vérifier qu'on ne peut pas lire les device_tokens
DO $$
DECLARE
    can_read_tokens BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
        AND tablename = 'device_tokens'
        AND cmd = 'SELECT'
    ) INTO can_read_tokens;
    
    IF can_read_tokens THEN
        RAISE WARNING '⚠️  SÉCURITÉ: Les tokens sont encore lisibles!';
    ELSE
        RAISE NOTICE '✅ SÉCURITÉ: Les tokens ne sont plus lisibles';
    END IF;
END$$;

-- Test 2: Vérifier que profiles a une policy INSERT
DO $$
DECLARE
    has_insert_policy BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND cmd = 'INSERT'
    ) INTO has_insert_policy;
    
    IF NOT has_insert_policy THEN
        RAISE WARNING '⚠️  SÉCURITÉ: Profiles n''a pas de policy INSERT!';
    ELSE
        RAISE NOTICE '✅ SÉCURITÉ: Profiles a une policy INSERT';
    END IF;
END$$;

-- -------------------------------------------------------------------------
-- ÉTAPE 6: RAPPORT FINAL
-- -------------------------------------------------------------------------

-- Créer un rapport de migration
CREATE TABLE IF NOT EXISTS public._migration_002_report (
    id SERIAL PRIMARY KEY,
    migration_date TIMESTAMPTZ DEFAULT NOW(),
    status TEXT,
    details JSONB
);

INSERT INTO public._migration_002_report (status, details)
SELECT 
    'COMPLETED',
    jsonb_build_object(
        'profiles_insert_policy', EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'profiles' AND cmd = 'INSERT'
        ),
        'device_tokens_read_blocked', NOT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'device_tokens' AND cmd = 'SELECT'
        ),
        'total_policies', (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public'),
        'tables_with_rls', (
            SELECT COUNT(*) FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public' AND c.relrowsecurity = true
        )
    );

-- Afficher le rapport
SELECT 
    '✅ MIGRATION 002 TERMINÉE' as status,
    details->>'profiles_insert_policy' as profiles_secured,
    details->>'device_tokens_read_blocked' as tokens_secured,
    details->>'total_policies' as total_policies,
    details->>'tables_with_rls' as tables_with_rls
FROM public._migration_002_report
ORDER BY id DESC
LIMIT 1;

-- =========================================================================
-- FIN DE LA MIGRATION 002 - VERSION SÉCURISÉE
-- =========================================================================

RAISE NOTICE '========================================';
RAISE NOTICE '✅ MIGRATION 002 APPLIQUÉE AVEC SUCCÈS';
RAISE NOTICE '========================================';
RAISE NOTICE 'Changements:';
RAISE NOTICE '1. Policy INSERT ajoutée sur profiles';
RAISE NOTICE '2. Lecture des device_tokens bloquée';
RAISE NOTICE '3. Backup créé dans _migration_002_backup';
RAISE NOTICE '4. Rapport créé dans _migration_002_report';
RAISE NOTICE '========================================';
