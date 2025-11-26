-- Fix permissions for service_role to execute RPC functions from edge functions
-- Required for notifications_outbox_drain and other edge functions
-- Date: 2025-11-26
-- Reason: Edge functions using SERVICE_ROLE_KEY need schema and function permissions

-- Grant usage on public schema to service_role
GRANT USAGE ON SCHEMA public TO service_role;

-- Grant execute on all functions in public schema to service_role  
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- Ensure future functions also have permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO service_role;
