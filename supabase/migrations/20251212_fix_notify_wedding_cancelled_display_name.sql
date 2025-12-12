-- Fix notify_wedding_cancelled trigger function: profiles.display_name -> profiles.full_name
-- Applied: 2025-12-12

CREATE OR REPLACE FUNCTION public.notify_wedding_cancelled()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = ''
AS $function$
DECLARE
  participant RECORD;
  bride_name TEXT;
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    SELECT full_name INTO bride_name
    FROM public.profiles WHERE id = NEW.bride_profile_id;

    FOR participant IN
      SELECT professional_profile_id FROM public.wedding_participants
      WHERE wedding_id = NEW.id AND status = 'active'
    LOOP
      PERFORM public.queue_wedding_notification(
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
$function$;
