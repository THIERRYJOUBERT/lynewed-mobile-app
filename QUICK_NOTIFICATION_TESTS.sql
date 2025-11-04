-- ============================================
-- TESTS RAPIDES - Système de notifications iOS
-- ============================================
-- Exécutez ces requêtes dans le SQL Editor de Supabase Dashboard
-- pour vérifier rapidement l'état du système

-- ============================================
-- 1. ÉTAT GLOBAL DU SYSTÈME (Vue d'ensemble)
-- ============================================
WITH stats AS (
  SELECT
    -- Tokens FCM iOS
    (SELECT COUNT(*) FROM device_tokens WHERE platform = 'ios') as tokens_ios_total,
    (SELECT COUNT(*) FROM device_tokens WHERE platform = 'ios' AND last_seen_at > NOW() - INTERVAL '24 hours') as tokens_ios_actifs_24h,
    (SELECT COUNT(*) FROM device_tokens WHERE platform = 'ios' AND last_seen_at > NOW() - INTERVAL '1 hour') as tokens_ios_actifs_1h,
    
    -- Événements outbox
    (SELECT COUNT(*) FROM notifications_outbox WHERE processed_at IS NULL) as events_en_attente,
    (SELECT COUNT(*) FROM notifications_outbox WHERE last_error IS NOT NULL AND processed_at IS NULL) as events_en_erreur,
    (SELECT COUNT(*) FROM notifications_outbox WHERE processed_at > NOW() - INTERVAL '1 hour') as events_traites_1h,
    (SELECT COUNT(*) FROM notifications_outbox WHERE processed_at > NOW() - INTERVAL '24 hours') as events_traites_24h,
    
    -- Notifications in-app
    (SELECT COUNT(*) FROM notifications WHERE created_at > NOW() - INTERVAL '1 hour') as notifs_in_app_1h,
    (SELECT COUNT(*) FROM notifications WHERE created_at > NOW() - INTERVAL '24 hours') as notifs_in_app_24h,
    (SELECT COUNT(*) FROM notifications WHERE is_read = false) as notifs_non_lues,
    
    -- Dernière activité
    (SELECT MAX(created_at) FROM notifications_outbox) as dernier_event,
    (SELECT MAX(processed_at) FROM notifications_outbox) as dernier_traitement
)
SELECT 
  '📱 Tokens iOS' as categorie,
  tokens_ios_total as total,
  tokens_ios_actifs_24h as actifs_24h,
  tokens_ios_actifs_1h as actifs_1h,
  NULL::bigint as en_attente,
  NULL::bigint as en_erreur,
  NULL::timestamp as derniere_activite
FROM stats
UNION ALL
SELECT 
  '📤 Événements Outbox',
  events_traites_24h,
  events_traites_1h,
  NULL,
  events_en_attente,
  events_en_erreur,
  dernier_event
FROM stats
UNION ALL
SELECT 
  '📬 Notifications In-App',
  notifs_in_app_24h,
  notifs_in_app_1h,
  NULL,
  notifs_non_lues,
  NULL,
  NULL
FROM stats
UNION ALL
SELECT 
  '⏱️ Dernière activité',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  dernier_traitement
FROM stats;

-- ============================================
-- 2. VÉRIFICATION RAPIDE DES TOKENS iOS
-- ============================================
-- Affiche les tokens iOS les plus récents
SELECT 
  dt.profile_id,
  p.full_name,
  p.role,
  LEFT(dt.token, 30) || '...' as token_preview,
  dt.last_seen_at,
  AGE(NOW(), dt.last_seen_at) as anciennete
FROM device_tokens dt
JOIN profiles p ON p.id = dt.profile_id
WHERE dt.platform = 'ios'
ORDER BY dt.last_seen_at DESC
LIMIT 5;

-- ============================================
-- 3. ÉVÉNEMENTS RÉCENTS PAR TYPE
-- ============================================
SELECT 
  event_type,
  COUNT(*) as total_24h,
  COUNT(*) FILTER (WHERE processed_at IS NOT NULL) as traites,
  COUNT(*) FILTER (WHERE processed_at IS NULL) as en_attente,
  COUNT(*) FILTER (WHERE last_error IS NOT NULL) as en_erreur,
  MAX(created_at) as dernier_event,
  MAX(processed_at) as dernier_traitement
FROM notifications_outbox
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY event_type
ORDER BY total_24h DESC;

-- ============================================
-- 4. DERNIERS ÉVÉNEMENTS TRAITÉS
-- ============================================
SELECT 
  event_type,
  CASE 
    WHEN event_type = 'chatMessageCreated' THEN payload->>'message_id'
    WHEN event_type LIKE 'connectionRequest%' THEN payload->>'request_id'
    WHEN event_type = 'wishlistAdded' THEN payload->>'professional_profile_id'
    WHEN event_type = 'videoIncoming' THEN payload->>'video_session_id'
    ELSE 'N/A'
  END as reference_id,
  created_at,
  processed_at,
  EXTRACT(EPOCH FROM (processed_at - created_at))::int as secondes_traitement,
  CASE 
    WHEN last_error IS NOT NULL THEN '❌ Erreur'
    WHEN processed_at IS NOT NULL THEN '✅ Traité'
    ELSE '⏳ En attente'
  END as statut
FROM notifications_outbox
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- 5. ÉVÉNEMENTS AVEC ERREURS (À INVESTIGUER)
-- ============================================
SELECT 
  id,
  event_type,
  attempts,
  LEFT(last_error, 150) as erreur,
  created_at,
  AGE(NOW(), created_at) as age,
  claimed_at,
  claimed_by
FROM notifications_outbox
WHERE last_error IS NOT NULL
  AND processed_at IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- 6. STATISTIQUES DE PERFORMANCE
-- ============================================
SELECT 
  event_type,
  COUNT(*) as total_traite,
  ROUND(AVG(EXTRACT(EPOCH FROM (processed_at - created_at))), 2) as temps_moyen_sec,
  MIN(EXTRACT(EPOCH FROM (processed_at - created_at)))::int as temps_min_sec,
  MAX(EXTRACT(EPOCH FROM (processed_at - created_at)))::int as temps_max_sec,
  MAX(processed_at) as dernier_traitement
FROM notifications_outbox
WHERE processed_at IS NOT NULL
  AND processed_at > NOW() - INTERVAL '24 hours'
GROUP BY event_type
ORDER BY total_traite DESC;

-- ============================================
-- 7. SETTINGS DE NOTIFICATION DES UTILISATEURS
-- ============================================
-- Vérifier combien d'utilisateurs ont désactivé les push
SELECT 
  notification_type,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE push_enabled = true) as push_actif,
  COUNT(*) FILTER (WHERE push_enabled = false) as push_inactif,
  ROUND(100.0 * COUNT(*) FILTER (WHERE push_enabled = true) / NULLIF(COUNT(*), 0), 1) as pct_actif
FROM notification_settings
GROUP BY notification_type
ORDER BY notification_type;

-- ============================================
-- 8. DERNIÈRES NOTIFICATIONS IN-APP CRÉÉES
-- ============================================
SELECT 
  n.type,
  p.full_name as destinataire,
  p.role,
  n.is_read,
  n.created_at,
  CASE 
    WHEN n.type = 'chatMessage' THEN n.payload->>'room_id'
    WHEN n.type LIKE 'connectionRequest%' THEN n.payload->>'request_id'
    WHEN n.type = 'wishlistAdd' THEN n.payload->>'bride_profile_id'
    WHEN n.type = 'videoIncoming' THEN n.payload->>'video_session_id'
    ELSE 'N/A'
  END as reference
FROM notifications n
JOIN profiles p ON p.id = n.profile_id
ORDER BY n.created_at DESC
LIMIT 10;

-- ============================================
-- 9. VÉRIFIER LES TRIGGERS ACTIFS
-- ============================================
SELECT 
  trigger_name,
  event_object_table as table_name,
  action_timing || ' ' || event_manipulation as declenchement,
  CASE 
    WHEN trigger_name LIKE '%chat%' THEN '💬 Messages'
    WHEN trigger_name LIKE '%connection%' THEN '🤝 Connexions'
    WHEN trigger_name LIKE '%wishlist%' THEN '⭐ Wishlist'
    WHEN trigger_name LIKE '%video%' THEN '📹 Vidéo'
    ELSE '❓ Autre'
  END as type
FROM information_schema.triggers
WHERE (
  trigger_name LIKE '%notif%' 
  OR trigger_name LIKE '%outbox%'
  OR action_statement LIKE '%notifications_outbox%'
)
ORDER BY event_object_table, trigger_name;

-- ============================================
-- 10. TEST DE LA FONCTION claim_outbox_events
-- ============================================
-- Simuler ce que fait l'Edge Function
SELECT 
  id,
  event_type,
  payload,
  attempts,
  created_at,
  AGE(NOW(), created_at) as age
FROM claim_outbox_events(
  p_batch_size := 5,
  p_claim_ttl_minutes := 5,
  p_worker_id := 'test-manual-' || gen_random_uuid()::text
);

-- ============================================
-- 11. COHÉRENCE OUTBOX ↔ NOTIFICATIONS IN-APP
-- ============================================
-- Vérifier que chaque événement traité a créé une notification in-app
WITH recent_events AS (
  SELECT 
    event_type,
    COUNT(*) as outbox_count
  FROM notifications_outbox
  WHERE processed_at > NOW() - INTERVAL '1 hour'
    AND last_error IS NULL
  GROUP BY event_type
),
recent_notifs AS (
  SELECT 
    type,
    COUNT(*) as notif_count
  FROM notifications
  WHERE created_at > NOW() - INTERVAL '1 hour'
  GROUP BY type
)
SELECT 
  COALESCE(re.event_type, rn.type) as type,
  COALESCE(re.outbox_count, 0) as events_traites,
  COALESCE(rn.notif_count, 0) as notifs_creees,
  CASE 
    WHEN COALESCE(re.outbox_count, 0) = COALESCE(rn.notif_count, 0) THEN '✅ OK'
    WHEN COALESCE(re.outbox_count, 0) > COALESCE(rn.notif_count, 0) THEN '⚠️ Manque notifs'
    ELSE '⚠️ Trop de notifs'
  END as statut
FROM recent_events re
FULL OUTER JOIN recent_notifs rn ON 
  (re.event_type = 'chatMessageCreated' AND rn.type = 'chatMessage')
  OR (re.event_type = 'connectionRequestCreated' AND rn.type = 'connectionRequest')
  OR (re.event_type = 'connectionRequestAccepted' AND rn.type = 'connectionRequestAccepted')
  OR (re.event_type = 'connectionRequestDeclined' AND rn.type = 'connectionRequestDeclined')
  OR (re.event_type = 'wishlistAdded' AND rn.type = 'wishlistAdd')
  OR (re.event_type = 'videoIncoming' AND rn.type = 'videoIncoming');

-- ============================================
-- 12. DIAGNOSTIC RAPIDE - POURQUOI PAS DE NOTIF ?
-- ============================================
-- Pour un utilisateur spécifique, vérifier tous les points
-- REMPLACEZ 'VOTRE_PROFILE_ID' par un vrai UUID
DO $$
DECLARE
  v_profile_id uuid := 'VOTRE_PROFILE_ID'; -- ⚠️ REMPLACER ICI
  v_has_token boolean;
  v_token_age interval;
  v_push_enabled boolean;
  v_recent_events int;
  v_recent_notifs int;
BEGIN
  -- Vérifier token FCM
  SELECT EXISTS(
    SELECT 1 FROM device_tokens 
    WHERE profile_id = v_profile_id AND platform = 'ios'
  ), COALESCE(MAX(AGE(NOW(), last_seen_at)), INTERVAL '999 days')
  INTO v_has_token, v_token_age
  FROM device_tokens
  WHERE profile_id = v_profile_id AND platform = 'ios';
  
  -- Vérifier settings
  SELECT COALESCE(bool_and(push_enabled), true)
  INTO v_push_enabled
  FROM notification_settings
  WHERE profile_id = v_profile_id;
  
  -- Vérifier événements récents
  SELECT COUNT(*)
  INTO v_recent_events
  FROM notifications_outbox
  WHERE created_at > NOW() - INTERVAL '24 hours'
    AND payload::text LIKE '%' || v_profile_id::text || '%';
  
  -- Vérifier notifications créées
  SELECT COUNT(*)
  INTO v_recent_notifs
  FROM notifications
  WHERE profile_id = v_profile_id
    AND created_at > NOW() - INTERVAL '24 hours';
  
  -- Afficher le diagnostic
  RAISE NOTICE '=== DIAGNOSTIC POUR PROFILE % ===', v_profile_id;
  RAISE NOTICE '📱 Token FCM iOS: %', CASE WHEN v_has_token THEN '✅ Présent (age: ' || v_token_age || ')' ELSE '❌ Absent' END;
  RAISE NOTICE '⚙️ Push activé: %', CASE WHEN v_push_enabled THEN '✅ Oui' ELSE '❌ Non' END;
  RAISE NOTICE '📤 Événements 24h: %', v_recent_events;
  RAISE NOTICE '📬 Notifications in-app 24h: %', v_recent_notifs;
  
  IF NOT v_has_token THEN
    RAISE NOTICE '⚠️ PROBLÈME: Aucun token FCM enregistré pour cet utilisateur';
  ELSIF v_token_age > INTERVAL '7 days' THEN
    RAISE NOTICE '⚠️ ATTENTION: Token FCM ancien (> 7 jours), peut être expiré';
  END IF;
  
  IF NOT v_push_enabled THEN
    RAISE NOTICE '⚠️ PROBLÈME: Push notifications désactivées dans les settings';
  END IF;
  
  IF v_recent_events = 0 THEN
    RAISE NOTICE 'ℹ️ INFO: Aucun événement récent pour cet utilisateur';
  END IF;
END $$;

-- ============================================
-- 13. NETTOYAGE (SI NÉCESSAIRE)
-- ============================================
-- ⚠️ NE PAS EXÉCUTER EN PRODUCTION SANS CONFIRMATION
-- Réinitialiser les événements bloqués avec trop de tentatives
/*
UPDATE notifications_outbox
SET 
  claimed_at = NULL,
  claimed_by = NULL,
  attempts = 0,
  last_error = NULL
WHERE processed_at IS NULL
  AND attempts >= 5
  AND created_at < NOW() - INTERVAL '1 hour';
*/

-- ============================================
-- 14. CRÉER UN ÉVÉNEMENT DE TEST
-- ============================================
-- ⚠️ Utiliser uniquement pour tester
-- REMPLACEZ les UUIDs par des vrais
/*
INSERT INTO notifications_outbox (event_type, payload, event_key)
VALUES (
  'chatMessageCreated',
  jsonb_build_object(
    'message_id', 'test-' || gen_random_uuid()::text,
    'room_id', 'VOTRE_ROOM_ID',
    'profile_id', 'VOTRE_PROFILE_ID'
  ),
  'test:' || gen_random_uuid()::text
);

-- Attendre 60 secondes puis vérifier
SELECT * FROM notifications_outbox 
WHERE event_key LIKE 'test:%'
ORDER BY created_at DESC;
*/

-- ============================================
-- FIN DES TESTS RAPIDES
-- ============================================
-- Pour des tests plus approfondis, consultez:
-- NOTIFICATION_SYSTEM_COMPLETE_TEST.md
