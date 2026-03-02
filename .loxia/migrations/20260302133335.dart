/// Generated migration 20260302133335
class LoxiaMigration_20260302133335 {
  const LoxiaMigration_20260302133335();

  List<String> up() => const [
    'ALTER TABLE "stores" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;',
  ];

  List<String> down() => const [
    'ALTER TABLE "stores" DROP COLUMN "is_active";',
  ];
}
