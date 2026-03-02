-- up
ALTER TABLE "categories" ADD COLUMN "is_active" boolean NOT NULL;

-- down
ALTER TABLE "categories" DROP COLUMN "is_active";

