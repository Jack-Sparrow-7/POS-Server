/// Generated migration 20260303180000
class LoxiaMigration_20260303180000 {
  const LoxiaMigration_20260303180000();

  List<String> up() => const [
    'ALTER TABLE "counters" ADD COLUMN "deleted_at" timestamp;',
  ];

  List<String> down() => const [
    'ALTER TABLE "counters" DROP COLUMN "deleted_at";',
  ];
}
