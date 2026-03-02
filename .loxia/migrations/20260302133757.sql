-- up
ALTER TABLE "stores" ADD COLUMN "online_ordering_enabled" boolean NOT NULL DEFAULT true;

-- down
ALTER TABLE "stores" DROP COLUMN "online_ordering_enabled";
