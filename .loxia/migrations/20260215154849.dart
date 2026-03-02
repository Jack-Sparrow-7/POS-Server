/// Generated migration 20260215154849
class LoxiaMigration_20260215154849 {
  const LoxiaMigration_20260215154849();

  List<String> up() => const [
    'CREATE TABLE IF NOT EXISTS "stores" (
  "id" varchar NOT NULL PRIMARY KEY,
  "name" varchar NOT NULL,
  "email" varchar NOT NULL,
  "whatsapp_number" varchar NOT NULL,
  "type" varchar NOT NULL
);',
  ];

  List<String> down() => const [
    'DROP TABLE IF EXISTS "stores";',
  ];
}
