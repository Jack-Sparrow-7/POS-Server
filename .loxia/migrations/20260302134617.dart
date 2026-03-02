/// Generated migration 20260302134617
class LoxiaMigration_20260302134617 {
  const LoxiaMigration_20260302134617();

  List<String> up() => const [
    'ALTER TABLE "terminals" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;',
    'ALTER TABLE "terminals" ADD COLUMN "token_version" int NOT NULL DEFAULT 0;',
  ];

  List<String> down() => const [
    'ALTER TABLE "terminals" DROP COLUMN "token_version";',
    'ALTER TABLE "terminals" DROP COLUMN "is_active";',
  ];
}
