-- up
CREATE UNIQUE INDEX IF NOT EXISTS "ux_stock_product_id" ON "stock" ("product_id");

-- down
DROP INDEX IF EXISTS "ux_stock_product_id";
