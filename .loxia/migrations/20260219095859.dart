/// Generated migration 20260219095859
class LoxiaMigration_20260219095859 {
  const LoxiaMigration_20260219095859();

  List<String> up() => const [
    'CREATE TABLE IF NOT EXISTS "counters" (
  "id" varchar NOT NULL PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar NOT NULL,
  "is_active" boolean NOT NULL
);',
  ];

  List<String> down() => const [
    'DROP TABLE IF EXISTS "counters";',
  ];
}
