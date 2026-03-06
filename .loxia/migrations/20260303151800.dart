/// Generated migration 20260303151800
class LoxiaMigration_20260303151800 {
  const LoxiaMigration_20260303151800();

  List<String> up() => const [
    'CREATE TABLE IF NOT EXISTS "stock_movements" (
  "id" varchar NOT NULL PRIMARY KEY,
  "reason" varchar NOT NULL,
  "quantity_before" int NOT NULL,
  "quantity_change" int NOT NULL,
  "quantity_after" int NOT NULL,
  "note" varchar,
  "created_at" timestamp,
  "stock_id" varchar,
  "store_id" varchar,
  "product_id" varchar
);',
    'ALTER TABLE "stock_movements" ADD CONSTRAINT "fk_stock_movements_stock_id" FOREIGN KEY ("stock_id") REFERENCES "stock" ("id") ON DELETE SET NULL;',
    'ALTER TABLE "stock_movements" ADD CONSTRAINT "fk_stock_movements_store_id" FOREIGN KEY ("store_id") REFERENCES "stores" ("id") ON DELETE SET NULL;',
    'ALTER TABLE "stock_movements" ADD CONSTRAINT "fk_stock_movements_product_id" FOREIGN KEY ("product_id") REFERENCES "products" ("id") ON DELETE SET NULL;',
    'CREATE INDEX IF NOT EXISTS "idx_stock_movements_store_id" ON "stock_movements" ("store_id");',
    'CREATE INDEX IF NOT EXISTS "idx_stock_movements_product_id" ON "stock_movements" ("product_id");',
    'CREATE INDEX IF NOT EXISTS "idx_stock_movements_created_at" ON "stock_movements" ("created_at");',
  ];

  List<String> down() => const [
    'DROP INDEX IF EXISTS "idx_stock_movements_created_at";',
    'DROP INDEX IF EXISTS "idx_stock_movements_product_id";',
    'DROP INDEX IF EXISTS "idx_stock_movements_store_id";',
    'ALTER TABLE "stock_movements" DROP CONSTRAINT IF EXISTS "fk_stock_movements_product_id";',
    'ALTER TABLE "stock_movements" DROP CONSTRAINT IF EXISTS "fk_stock_movements_store_id";',
    'ALTER TABLE "stock_movements" DROP CONSTRAINT IF EXISTS "fk_stock_movements_stock_id";',
    'DROP TABLE IF EXISTS "stock_movements";',
  ];
}
