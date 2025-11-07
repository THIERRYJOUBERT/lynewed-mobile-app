-- Add is_published column to replays table
ALTER TABLE public.replays 
ADD COLUMN IF NOT EXISTS is_published boolean DEFAULT true NOT NULL;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_replays_is_published ON public.replays(is_published);

-- Add comment for documentation
COMMENT ON COLUMN public.replays.is_published IS 'Si true, ce replay est visible dans l''application. Si false, il est masqué.';

-- Update existing replays to be published by default
UPDATE public.replays SET is_published = true WHERE is_published IS NULL;
