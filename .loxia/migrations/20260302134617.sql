-- up
ALTER TABLE "terminals" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;
ALTER TABLE "terminals" ADD COLUMN "token_version" int NOT NULL DEFAULT 0;

-- down
ALTER TABLE "terminals" DROP COLUMN "token_version";
ALTER TABLE "terminals" DROP COLUMN "is_active";
