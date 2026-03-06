/// Generated migration 20260303184500
class LoxiaMigration_20260303184500 {
  const LoxiaMigration_20260303184500();

  List<String> up() => const [
    'ALTER TABLE "products" ADD COLUMN "deleted_at" timestamp;',
  ];

  List<String> down() => const [
    'ALTER TABLE "products" DROP COLUMN "deleted_at";',
  ];
}
