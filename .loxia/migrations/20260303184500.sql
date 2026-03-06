-- up
ALTER TABLE "products" ADD COLUMN "deleted_at" timestamp;

-- down
ALTER TABLE "products" DROP COLUMN "deleted_at";
