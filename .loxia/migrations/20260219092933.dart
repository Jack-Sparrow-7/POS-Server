/// Generated migration 20260219092933
class LoxiaMigration_20260219092933 {
  const LoxiaMigration_20260219092933();

  List<String> up() => const [
    'ALTER TABLE "categories" ADD COLUMN "is_active" boolean NOT NULL;',
  ];

  List<String> down() => const [
    'ALTER TABLE "categories" DROP COLUMN "is_active";',
  ];
}
