-- Add weight_kg column to marketplace_listings for FedEx dynamic shipping rates.
-- If null, FedEx API will use category defaults (dress: 3.0 kg, shoes: 2.0 kg).
-- Valid range: 0.1 - 50.0 kg (enforced by CHECK constraint).

ALTER TABLE marketplace_listings
  ADD COLUMN IF NOT EXISTS weight_kg NUMERIC(5,2)
  CHECK (weight_kg IS NULL OR (weight_kg >= 0.1 AND weight_kg <= 50.0));

COMMENT ON COLUMN marketplace_listings.weight_kg IS
  'Item weight in kilograms for FedEx shipping rate calculation. NULL = use category default.';
