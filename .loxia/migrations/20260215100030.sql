-- up
ALTER TABLE "terminals" DROP COLUMN "merchant_id";

-- down
ALTER TABLE "terminals" ADD COLUMN "merchant_id" varchar NOT NULL;

