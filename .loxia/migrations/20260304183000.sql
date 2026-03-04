-- up
CREATE TABLE IF NOT EXISTS "customers" (
  "id" varchar NOT NULL PRIMARY KEY,
  "name" varchar NOT NULL,
  "mobile_number" varchar NOT NULL UNIQUE,
  "email" varchar NOT NULL UNIQUE,
  "password_hash" varchar NOT NULL,
  "is_active" bool NOT NULL,
  "token_version" int NOT NULL,
  "created_at" timestamp,
  "updated_at" timestamp,
  "deleted_at" timestamp
);

-- down
DROP TABLE IF EXISTS "customers";
