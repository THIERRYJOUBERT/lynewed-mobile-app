-- Migration: Cleanup des sessions vidéo abandonnées
-- Date: 2025-11-04
-- Description: Ajoute un cron job pour marquer comme "missed" les sessions pending > 2 minutes

-- Fonction pour nettoyer les sessions abandonnées
CREATE OR REPLACE FUNCTION public.cleanup_abandoned_video_sessions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $$
BEGIN
  -- Marquer comme "missed" les sessions en "pending" depuis plus de 2 minutes
  UPDATE public.video_sessions
  SET 
    status = 'missed',
    completed_at = NOW()
  WHERE 
    status = 'pending'
    AND created_at < (NOW() - INTERVAL '2 minutes')
    AND completed_at IS NULL;
    
  -- Log le nombre de sessions nettoyées (optionnel)
  RAISE NOTICE 'Cleaned up abandoned video sessions';
END;
$$;

-- Créer le cron job pour exécuter toutes les minutes
SELECT cron.schedule(
  'cleanup_abandoned_video_sessions',  -- Nom du job
  '* * * * *',                          -- Toutes les minutes
  $$SELECT public.cleanup_abandoned_video_sessions()$$
);

-- Commentaire pour documentation
COMMENT ON FUNCTION public.cleanup_abandoned_video_sessions() IS 
'Nettoie automatiquement les sessions vidéo en status pending depuis plus de 2 minutes en les marquant comme missed';
