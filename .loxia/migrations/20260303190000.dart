/// Generated migration 20260303190000
class LoxiaMigration_20260303190000 {
  const LoxiaMigration_20260303190000();

  List<String> up() => const [
    'CREATE UNIQUE INDEX IF NOT EXISTS "ux_stock_product_id" ON "stock" ("product_id");',
  ];

  List<String> down() => const [
    'DROP INDEX IF EXISTS "ux_stock_product_id";',
  ];
}
