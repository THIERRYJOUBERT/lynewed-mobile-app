-- ============================================
-- MY WEDDING SUITE - TRIGGERS & FUNCTIONS
-- Version: 2.0 | Date: 2025-12-10
-- ============================================

-- ----------------------------------------
-- 1. Création automatique du chat wedding_team
-- CORRIGÉ: Gère INSERT et UPDATE, vérifie existence
-- ----------------------------------------
CREATE OR REPLACE FUNCTION create_wedding_team_chat()
RETURNS TRIGGER AS $$
DECLARE
  new_room_id UUID;
  existing_room UUID;
BEGIN
  -- Ne créer le chat que si onboarding terminé (step IS NULL)
  IF NEW.onboarding_step IS NULL THEN
    -- Vérifier qu'un chat wedding_team n'existe pas déjà pour ce mariage
    SELECT id INTO existing_room 
    FROM chat_rooms 
    WHERE wedding_id = NEW.id AND type = 'wedding_team';
    
    IF existing_room IS NULL THEN
      -- Créer uniquement si:
      -- 1. C'est un INSERT avec onboarding déjà terminé (cas import/migration)
      -- 2. C'est un UPDATE et onboarding_step vient de passer à NULL
      IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.onboarding_step IS NOT NULL) THEN
        -- Créer la room wedding_team
        INSERT INTO chat_rooms (type, name, wedding_id)
        VALUES ('wedding_team', 'Wedding Team', NEW.id)
        RETURNING id INTO new_room_id;
        
        -- Ajouter la bride comme participant
        INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
        VALUES (new_room_id, NEW.bride_profile_id, 'active');
        
        RAISE NOTICE 'Created wedding_team chat % for wedding %', new_room_id, NEW.id;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer l'ancien trigger s'il existe
DROP TRIGGER IF EXISTS trigger_create_wedding_team_chat ON weddings;

-- Créer le trigger sur INSERT et UPDATE
CREATE TRIGGER trigger_create_wedding_team_chat
AFTER INSERT OR UPDATE OF onboarding_step ON weddings
FOR EACH ROW
EXECUTE FUNCTION create_wedding_team_chat();

-- ----------------------------------------
-- 2. Ajout/retrait automatique du pro au chat wedding_team
-- ----------------------------------------
CREATE OR REPLACE FUNCTION manage_pro_in_wedding_team_chat()
RETURNS TRIGGER AS $$
DECLARE
  team_room_id UUID;
BEGIN
  -- Trouver la room wedding_team
  SELECT id INTO team_room_id
  FROM chat_rooms
  WHERE wedding_id = NEW.wedding_id AND type = 'wedding_team';
  
  -- Si pas de room, rien à faire (sera créé quand onboarding terminé)
  IF team_room_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Quand un pro est ajouté (status = 'active')
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status != 'active') THEN
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
    VALUES (team_room_id, NEW.professional_profile_id, 'active')
    ON CONFLICT (room_id, profile_id) DO UPDATE SET conversation_status = 'active';
    
    RAISE NOTICE 'Added pro % to wedding_team chat %', NEW.professional_profile_id, team_room_id;
  END IF;
  
  -- Quand un pro quitte ou est exclu
  IF NEW.status IN ('left', 'excluded') AND OLD.status = 'active' THEN
    UPDATE chat_room_participants
    SET conversation_status = 'archived'
    WHERE room_id = team_room_id AND profile_id = NEW.professional_profile_id;
    
    RAISE NOTICE 'Archived pro % from wedding_team chat %', NEW.professional_profile_id, team_room_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_manage_pro_in_wedding_team_chat ON wedding_participants;

CREATE TRIGGER trigger_manage_pro_in_wedding_team_chat
AFTER INSERT OR UPDATE OF status ON wedding_participants
FOR EACH ROW
EXECUTE FUNCTION manage_pro_in_wedding_team_chat();

-- ----------------------------------------
-- 3. Helper function pour queue notifications
-- ----------------------------------------
CREATE OR REPLACE FUNCTION queue_wedding_notification(
  p_event_type TEXT,
  p_payload JSONB
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO notifications_outbox (event_type, payload, event_key)
  VALUES (
    p_event_type,
    p_payload,
    p_event_type || '_' || COALESCE((p_payload->>'wedding_id')::TEXT, 'unknown') || '_' || extract(epoch from now())::TEXT
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------
-- 4. Notification: wedding_pro_added
-- ----------------------------------------
CREATE OR REPLACE FUNCTION notify_wedding_pro_added()
RETURNS TRIGGER AS $$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status != 'active') THEN
    -- Récupérer infos pour le payload
    SELECT p.display_name, w.wedding_name INTO bride_name, wedding_name
    FROM weddings w
    JOIN profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;
    
    PERFORM queue_wedding_notification(
      'wedding_pro_added',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', NEW.professional_profile_id,
        'bride_name', bride_name,
        'wedding_name', wedding_name
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_wedding_pro_added ON wedding_participants;

CREATE TRIGGER trigger_notify_wedding_pro_added
AFTER INSERT OR UPDATE OF status ON wedding_participants
FOR EACH ROW
EXECUTE FUNCTION notify_wedding_pro_added();

-- ----------------------------------------
-- 5. Notification: wedding_pro_excluded
-- ----------------------------------------
CREATE OR REPLACE FUNCTION notify_wedding_pro_excluded()
RETURNS TRIGGER AS $$
DECLARE
  bride_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'excluded' AND OLD.status = 'active' THEN
    SELECT p.display_name, w.wedding_name INTO bride_name, wedding_name
    FROM weddings w
    JOIN profiles p ON p.id = w.bride_profile_id
    WHERE w.id = NEW.wedding_id;
    
    PERFORM queue_wedding_notification(
      'wedding_pro_excluded',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', NEW.professional_profile_id,
        'bride_name', bride_name,
        'wedding_name', wedding_name,
        'reason', NEW.excluded_reason
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_wedding_pro_excluded ON wedding_participants;

CREATE TRIGGER trigger_notify_wedding_pro_excluded
AFTER UPDATE OF status ON wedding_participants
FOR EACH ROW
WHEN (NEW.status = 'excluded')
EXECUTE FUNCTION notify_wedding_pro_excluded();

-- ----------------------------------------
-- 6. Notification: wedding_pro_left
-- ----------------------------------------
CREATE OR REPLACE FUNCTION notify_wedding_pro_left()
RETURNS TRIGGER AS $$
DECLARE
  bride_id UUID;
  pro_name TEXT;
  wedding_name TEXT;
BEGIN
  IF NEW.status = 'left' AND OLD.status = 'active' THEN
    SELECT w.bride_profile_id, w.wedding_name INTO bride_id, wedding_name
    FROM weddings w WHERE w.id = NEW.wedding_id;
    
    SELECT display_name INTO pro_name
    FROM profiles WHERE id = NEW.professional_profile_id;
    
    PERFORM queue_wedding_notification(
      'wedding_pro_left',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', bride_id,
        'pro_name', pro_name,
        'wedding_name', wedding_name,
        'reason', NEW.left_reason
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_wedding_pro_left ON wedding_participants;

CREATE TRIGGER trigger_notify_wedding_pro_left
AFTER UPDATE OF status ON wedding_participants
FOR EACH ROW
WHEN (NEW.status = 'left')
EXECUTE FUNCTION notify_wedding_pro_left();

-- ----------------------------------------
-- 7. Notification: wedding_cancelled
-- ----------------------------------------
CREATE OR REPLACE FUNCTION notify_wedding_cancelled()
RETURNS TRIGGER AS $$
DECLARE
  participant RECORD;
  bride_name TEXT;
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    SELECT display_name INTO bride_name
    FROM profiles WHERE id = NEW.bride_profile_id;
    
    FOR participant IN 
      SELECT professional_profile_id FROM wedding_participants 
      WHERE wedding_id = NEW.id AND status = 'active'
    LOOP
      PERFORM queue_wedding_notification(
        'wedding_cancelled',
        jsonb_build_object(
          'wedding_id', NEW.id,
          'recipient_id', participant.professional_profile_id,
          'bride_name', bride_name,
          'wedding_name', NEW.wedding_name
        )
      );
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_wedding_cancelled ON weddings;

CREATE TRIGGER trigger_notify_wedding_cancelled
AFTER UPDATE OF status ON weddings
FOR EACH ROW
WHEN (NEW.status = 'cancelled')
EXECUTE FUNCTION notify_wedding_cancelled();

-- ----------------------------------------
-- 8. Notification: wedding_team_message
-- ----------------------------------------
CREATE OR REPLACE FUNCTION notify_wedding_team_message()
RETURNS TRIGGER AS $$
DECLARE
  participant RECORD;
  wedding_id_var UUID;
  sender_name TEXT;
BEGIN
  -- Vérifier si c'est un message dans un wedding_team room
  SELECT cr.wedding_id INTO wedding_id_var
  FROM chat_rooms cr 
  WHERE cr.id = NEW.room_id AND cr.type = 'wedding_team';
  
  IF wedding_id_var IS NOT NULL THEN
    -- Récupérer le nom de l'expéditeur
    SELECT display_name INTO sender_name
    FROM profiles WHERE id = NEW.profile_id;
    
    -- Notifier tous les participants sauf l'expéditeur
    FOR participant IN 
      SELECT crp.profile_id 
      FROM chat_room_participants crp
      WHERE crp.room_id = NEW.room_id 
      AND crp.profile_id != NEW.profile_id
      AND crp.conversation_status = 'active'
    LOOP
      -- Vérifier si le participant n'a pas muté ce mariage
      IF NOT EXISTS (
        SELECT 1 FROM wedding_participants wp
        WHERE wp.wedding_id = wedding_id_var
        AND wp.professional_profile_id = participant.profile_id
        AND wp.is_muted = true
      ) THEN
        PERFORM queue_wedding_notification(
          'wedding_team_message',
          jsonb_build_object(
            'wedding_id', wedding_id_var,
            'room_id', NEW.room_id,
            'sender_id', NEW.profile_id,
            'sender_name', sender_name,
            'recipient_id', participant.profile_id,
            'message_id', NEW.id,
            'message_preview', LEFT(NEW.content, 100)
          )
        );
      END IF;
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_wedding_team_message ON chat_messages;

CREATE TRIGGER trigger_notify_wedding_team_message
AFTER INSERT ON chat_messages
FOR EACH ROW
EXECUTE FUNCTION notify_wedding_team_message();

-- ============================================
-- MIGRATION ONE-TIME: Mariages existants
-- Exécuter UNE SEULE FOIS après les autres migrations
-- ============================================

-- Créer les chat rooms wedding_team pour les mariages existants
-- qui ont terminé l'onboarding (onboarding_step IS NULL)
-- et qui n'ont pas encore de chat wedding_team

DO $$
DECLARE
  wedding_record RECORD;
  new_room_id UUID;
BEGIN
  FOR wedding_record IN 
    SELECT w.id, w.bride_profile_id
    FROM weddings w
    WHERE w.onboarding_step IS NULL
    AND NOT EXISTS (
      SELECT 1 FROM chat_rooms cr 
      WHERE cr.wedding_id = w.id AND cr.type = 'wedding_team'
    )
  LOOP
    -- Créer la room
    INSERT INTO chat_rooms (type, name, wedding_id)
    VALUES ('wedding_team', 'Wedding Team', wedding_record.id)
    RETURNING id INTO new_room_id;
    
    -- Ajouter la bride
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
    VALUES (new_room_id, wedding_record.bride_profile_id, 'active');
    
    -- Ajouter les pros actifs
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
    SELECT new_room_id, wp.professional_profile_id, 'active'
    FROM wedding_participants wp
    WHERE wp.wedding_id = wedding_record.id
    AND wp.status = 'active';
    
    RAISE NOTICE 'Created wedding_team chat for wedding %', wedding_record.id;
  END LOOP;
END $$;
