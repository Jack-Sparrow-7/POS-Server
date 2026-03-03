/// Generated migration 20260303173000
class LoxiaMigration_20260303173000 {
  const LoxiaMigration_20260303173000();

  List<String> up() => const [
    'ALTER TABLE "categories" ADD COLUMN "deleted_at" timestamp;',
  ];

  List<String> down() => const [
    'ALTER TABLE "categories" DROP COLUMN "deleted_at";',
  ];
}
