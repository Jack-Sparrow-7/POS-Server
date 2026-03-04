/// Generated migration 20260304183000
class LoxiaMigration_20260304183000 {
  const LoxiaMigration_20260304183000();

  List<String> up() => const [
    'CREATE TABLE IF NOT EXISTS "customers" (\n'
        '  "id" varchar NOT NULL PRIMARY KEY,\n'
        '  "name" varchar NOT NULL,\n'
        '  "mobile_number" varchar NOT NULL UNIQUE,\n'
        '  "email" varchar NOT NULL UNIQUE,\n'
        '  "password_hash" varchar NOT NULL,\n'
        '  "is_active" bool NOT NULL,\n'
        '  "token_version" int NOT NULL,\n'
        '  "created_at" timestamp,\n'
        '  "updated_at" timestamp,\n'
        '  "deleted_at" timestamp\n'
        ');',
  ];

  List<String> down() => const [
    'DROP TABLE IF EXISTS "customers";',
  ];
}
