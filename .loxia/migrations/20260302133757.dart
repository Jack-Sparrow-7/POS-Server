/// Generated migration 20260302133757
class LoxiaMigration_20260302133757 {
  const LoxiaMigration_20260302133757();

  List<String> up() => const [
    'ALTER TABLE "stores" ADD COLUMN "online_ordering_enabled" boolean NOT NULL DEFAULT true;',
  ];

  List<String> down() => const [
    'ALTER TABLE "stores" DROP COLUMN "online_ordering_enabled";',
  ];
}
