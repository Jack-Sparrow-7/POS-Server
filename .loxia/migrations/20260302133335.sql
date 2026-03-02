-- up
ALTER TABLE "stores" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;

-- down
ALTER TABLE "stores" DROP COLUMN "is_active";
