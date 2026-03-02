-- up
CREATE TABLE IF NOT EXISTS "counters" (
  "id" varchar NOT NULL PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar NOT NULL,
  "is_active" boolean NOT NULL
);

-- down
DROP TABLE IF EXISTS "counters";

