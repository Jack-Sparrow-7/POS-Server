/// Generated migration 20260215100030
class LoxiaMigration_20260215100030 {
  const LoxiaMigration_20260215100030();

  List<String> up() => const [
    'ALTER TABLE "terminals" DROP COLUMN "merchant_id";',
  ];

  List<String> down() => const [
    'ALTER TABLE "terminals" ADD COLUMN "merchant_id" varchar NOT NULL;',
  ];
}
