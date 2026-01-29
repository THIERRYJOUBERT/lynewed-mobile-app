-- Migration: 20260128000001_add_guest_role
-- Description: Add 'guest' value to userRole enum for guest user support
-- Created: 2026-01-29
-- Author: Epic-06-PREREQUISITES

-- ATTENTION: Executer en periode de faible trafic (3h-5h)
-- Cette migration modifie un enum Postgres et est irreversible si des guests existent

-- Ajouter la valeur 'guest' a l'enum userRole
ALTER TYPE "public"."userRole" ADD VALUE IF NOT EXISTS 'guest';

-- Verification (ne doit pas echouer)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'guest'
    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'userRole')
  ) THEN
    RAISE EXCEPTION 'Migration failed: guest value not added to userRole enum';
  END IF;
END $$;

-- Log de la migration
COMMENT ON TYPE "public"."userRole" IS 'User roles: bride, professional, admin, guest';
