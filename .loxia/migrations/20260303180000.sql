-- up
ALTER TABLE "counters" ADD COLUMN "deleted_at" timestamp;

-- down
ALTER TABLE "counters" DROP COLUMN "deleted_at";
