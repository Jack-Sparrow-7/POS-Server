-- up
CREATE TABLE IF NOT EXISTS "stores" (
  "id" varchar NOT NULL PRIMARY KEY,
  "name" varchar NOT NULL,
  "email" varchar NOT NULL,
  "whatsapp_number" varchar NOT NULL,
  "type" varchar NOT NULL
);

-- down
DROP TABLE IF EXISTS "stores";

