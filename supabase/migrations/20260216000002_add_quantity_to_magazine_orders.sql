-- S09: Add quantity column to magazine_orders
-- Allows ordering multiple copies of a magazine (1-10)
-- DEFAULT 1 ensures backward-compatibility with existing orders

ALTER TABLE magazine_orders ADD COLUMN quantity integer NOT NULL DEFAULT 1;

-- Add CHECK constraint to enforce valid range
ALTER TABLE magazine_orders ADD CONSTRAINT magazine_orders_quantity_check
  CHECK (quantity >= 1 AND quantity <= 10);
