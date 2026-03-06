-- up
ALTER TABLE "categories" ADD COLUMN "deleted_at" timestamp;

-- down
ALTER TABLE "categories" DROP COLUMN "deleted_at";
