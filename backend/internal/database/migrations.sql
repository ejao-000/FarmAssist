-- farmassist backend schema (PostgreSQL)
-- Run once on an empty database (or safely re-run: uses IF NOT EXISTS + idempotent indexes)

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------
-- Users
-- -----------------------
CREATE TABLE IF NOT EXISTS users (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email            TEXT NOT NULL UNIQUE,
  password_hash   TEXT NOT NULL,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- -----------------------
-- Sessions (token hashes)
-- -----------------------
CREATE TABLE IF NOT EXISTS sessions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash   TEXT NOT NULL UNIQUE,

  user_agent    TEXT,
  ip_address    TEXT,

  expires_at   TIMESTAMPTZ NOT NULL,
  revoked_at   TIMESTAMPTZ,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);

-- -----------------------
-- Farms
-- -----------------------
CREATE TABLE IF NOT EXISTS farms (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  name           TEXT NOT NULL,
  location       TEXT,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(owner_user_id, name)
);

CREATE INDEX IF NOT EXISTS idx_farms_owner_user_id ON farms(owner_user_id);

-- -----------------------
-- Inventory: products
-- -----------------------
CREATE TABLE IF NOT EXISTS inventory_products (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id     UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,

  sku          TEXT,
  name         TEXT NOT NULL,
  unit         TEXT NOT NULL DEFAULT 'unit',

  min_stock    INTEGER NOT NULL DEFAULT 0,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(farm_id, COALESCE(sku, ''), name)
);

CREATE INDEX IF NOT EXISTS idx_inventory_products_farm_id ON inventory_products(farm_id);
CREATE INDEX IF NOT EXISTS idx_inventory_products_name ON inventory_products(name);

-- -----------------------
-- Inventory movements (ledger)
-- quantity > 0 increases stock, < 0 decreases stock
-- -----------------------
CREATE TABLE IF NOT EXISTS inventory_movements (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id          UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  product_id      UUID NOT NULL REFERENCES inventory_products(id) ON DELETE RESTRICT,

  quantity         NUMERIC(20,4) NOT NULL CHECK (quantity <> 0),

  reason           TEXT,
  reference_type   TEXT,
  reference_id     UUID,

  created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,

  occurred_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_inventory_movements_farm_product_time
  ON inventory_movements(farm_id, product_id, occurred_at DESC);

-- -----------------------
-- Sales```sql
-- farmassist backend schema (PostgreSQL)
-- Save as: backend/internal/database/migrations.sql
-- Run once (or re-run safely): uses IF NOT EXISTS + IF EXISTS for constraints.

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =======================
-- Users
-- =======================
CREATE TABLE IF NOT EXISTS users (
  id             UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  email          TEXT NOT NULL UNIQUE,
  password\_hash TEXT NOT NULL,
  is\_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created\_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_users\_created\_at ON users(created\_at);

-- =======================
-- Sessions (token hashes)
-- =======================
CREATE TABLE IF NOT EXISTS sessions (
  id           UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  user\_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token\_hash   TEXT NOT NULL UNIQUE,
  user\_agent    TEXT,
  ip\_address    TEXT,
  expires\_at   TIMESTAMPTZ NOT NULL,
  revoked\_at   TIMESTAMPTZ,
  created\_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_sessions\_user\_id ON sessions(user\_id);
CREATE INDEX IF NOT EXISTS idx\_sessions\_expires\_at ON sessions(expires\_at);

-- =======================
-- Farms
-- =======================
CREATE TABLE IF NOT EXISTS farms (
  id             UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  owner\_user\_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name           TEXT NOT NULL,
  location       TEXT,
  created\_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(owner\_user\_id, name)
);
CREATE INDEX IF NOT EXISTS idx\_farms\_owner\_user\_id ON farms(owner\_user\_id);

-- =======================
-- Inventory products
-- =======================
CREATE TABLE IF NOT EXISTS inventory\_products (
  id           UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id      UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  sku          TEXT,
  name         TEXT NOT NULL,
  unit         TEXT NOT NULL DEFAULT 'unit',
  min\_stock    INTEGER NOT NULL DEFAULT 0,
  created\_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(farm\_id, COALESCE(sku, ''), name)
);
CREATE INDEX IF NOT EXISTS idx\_inventory\_products\_farm\_id ON inventory\_products(farm\_id);
CREATE INDEX IF NOT EXISTS idx\_inventory\_products\_name ON inventory\_products(name);

-- =======================
-- Inventory movements (ledger)
-- quantity > 0 increases stock, < 0 decreases stock
-- =======================
CREATE TABLE IF NOT EXISTS inventory\_movements (
  id                UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id           UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  product\_id       UUID NOT NULL REFERENCES inventory\_products(id) ON DELETE RESTRICT,
  quantity         NUMERIC(20,4) NOT NULL CHECK (quantity <> 0),
  reason           TEXT,
  reference\_type   TEXT,
  reference\_id     UUID,
  created\_by\_user\_id UUID REFERENCES users(id) ON DELETE SET NULL,
  occurred\_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  created\_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_inventory\_movements\_farm\_product\_time
  ON inventory\_movements(farm\_id, product\_id, occurred\_at DESC);

-- =======================
-- Sales receipts + items
-- =======================
CREATE TABLE IF NOT EXISTS sales\_receipts (
  id               UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id          UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created\_by\_user\_id UUID REFERENCES users(id) ON DELETE SET NULL,
  customer\_name   TEXT,
  customer\_phone  TEXT,
  total\_amount    NUMERIC(20,4) NOT NULL DEFAULT 0,
  currency        TEXT NOT NULL DEFAULT 'USD',
  notes           TEXT,
  occurred\_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created\_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_sales\_receipts\_farm\_time ON sales\_receipts(farm\_id, occurred\_at DESC);

CREATE TABLE IF NOT EXISTS sales\_receipt\_items (
  id            UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  receipt\_id   UUID NOT NULL REFERENCES sales\_receipts(id) ON DELETE CASCADE,
  product\_id   UUID NOT NULL REFERENCES inventory\_products(id) ON DELETE RESTRICT,
  quantity     NUMERIC(20,4) NOT NULL CHECK (quantity > 0),
  unit\_price   NUMERIC(20,4) NOT NULL CHECK (unit\_price >= 0),
  line\_total   NUMERIC(20,4) NOT NULL CHECK (line\_total >= 0),
  created\_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_sales\_items\_receipt ON sales\_receipt\_items(receipt\_id);

-- Prevent accidental duplicate item rows within a receipt for the same product + price.
CREATE UNIQUE INDEX IF NOT EXISTS uq\_sales\_items\_receipt\_product\_price
  ON sales\_receipt\_items(receipt\_id, product\_id, unit\_price, quantity, line\_total);

-- =======================
-- Weather cache
-- =======================
CREATE TABLE IF NOT EXISTS weather\_cache (
  id                 UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id            UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  location\_key      TEXT NOT NULL,
  forecast\_time     TIMESTAMPTZ NOT NULL,
  fetched\_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  temperature\_c     NUMERIC(10,2),
  humidity\_pct      NUMERIC(10,2),
  wind\_kph          NUMERIC(10,2),
  precipitation\_mm  NUMERIC(10,2),
  conditions        TEXT,
  provider          TEXT NOT NULL DEFAULT 'unknown',
  payload           JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS idx\_weather\_cache\_farm\_time
  ON weather\_cache(farm\_id, forecast\_time DESC);
CREATE INDEX IF NOT EXISTS idx\_weather\_cache\_location\_time
  ON weather\_cache(location\_key, forecast\_time DESC);

-- =======================
-- Disease uploads + results
-- =======================
CREATE TABLE IF NOT EXISTS disease\_uploads (
  id                 UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id            UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  uploaded\_by\_user\_id UUID REFERENCES users(id) ON DELETE SET NULL,

  file\_name          TEXT,
  mime\_type          TEXT,
  file\_size\_bytes   BIGINT,
  storage\_key        TEXT,

  crop\_type          TEXT,
  notes              TEXT,

  status             TEXT NOT NULL DEFAULT 'uploaded', -- uploaded|queued|processing|done|failed
  error\_message      TEXT,

  created\_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_disease\_uploads\_farm\_created
  ON disease\_uploads(farm\_id, created\_at DESC);

CREATE TABLE IF NOT EXISTS disease\_results (
  id                 UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  disease\_upload\_id UUID NOT NULL UNIQUE REFERENCES disease\_uploads(id) ON DELETE CASCADE,
  predicted\_label   TEXT,
  confidence        NUMERIC(5,4),
  recommendations   TEXT,
  severity          TEXT,
  payload           JSONB NOT NULL DEFAULT '{}'::jsonb,
  created\_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_disease\_results\_created\_at ON disease\_results(created\_at);

-- =======================
-- Media
-- =======================
CREATE TABLE IF NOT EXISTS media (
  id               UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id          UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  uploaded\_by\_user\_id UUID REFERENCES users(id) ON DELETE SET NULL,

  media\_type      TEXT NOT NULL, -- image|video|audio|other
  file\_name       TEXT,
  mime\_type       TEXT,
  file\_size\_bytes BIGINT,
  storage\_key     TEXT NOT NULL UNIQUE,
  payload         JSONB NOT NULL DEFAULT '{}'::jsonb,
  created\_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_media\_farm\_created ON media(farm\_id, created\_at DESC);

-- =======================
-- AI requests + responses
-- =======================
CREATE TABLE IF NOT EXISTS ai\_requests (
  id                UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  farm\_id           UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created\_by\_user\_id UUID REFERENCES users(id) ON DELETE SET NULL,

  request\_type     TEXT NOT NULL, -- disease\_inference|assistant|etc.
  status           TEXT NOT NULL DEFAULT 'created', -- created|queued|processing|done|failed
  error\_message    TEXT,

  prompt           JSONB NOT NULL DEFAULT '{}'::jsonb,
  model            TEXT,
  max\_tokens       INTEGER,

  created\_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_ai\_requests\_farm\_time
  ON ai\_requests(farm\_id, created\_at DESC);

CREATE TABLE IF NOT EXISTS ai\_responses (
  id                UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  ai\_request\_id    UUID NOT NULL UNIQUE REFERENCES ai\_requests(id) ON DELETE CASCADE,
  response\_type    TEXT,
  payload          JSONB NOT NULL DEFAULT '{}'::jsonb,
  created\_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx\_ai\_responses\_created\_at ON ai\_responses(created\_at);

-- =======================
-- Notifications (templates/rules live in code; this stores sends/events)
-- =======================
CREATE TABLE IF NOT EXISTS notifications (
  id              UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  user\_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  farm\_id         UUID REFERENCES farms(id) ON DELETE CASCADE,

  channel         TEXT NOT NULL DEFAULT 'sms', -- sms|push|email|in\_app
  template\_key    TEXT,
  message         TEXT NOT NULL,

  status          TEXT NOT NULL DEFAULT 'queued', -- queued|sent|failed
  provider\_msg\_id TEXT,
  error\_message   TEXT,

  created\_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  sent\_at         TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx\_notifications\_user\_time ON notifications(user\_id, created\_at DESC);
CREATE INDEX IF NOT EXISTS idx\_notifications\_farm\_time ON notifications(farm\_id, created\_at DESC);

-- =======================
-- Sync state for offline clients (per user/device)
-- =======================
CREATE TABLE IF NOT EXISTS sync\_state (
  id              UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  user\_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device\_id       TEXT NOT NULL, -- client-generated device identifier
  last\_synced\_at  TIMESTAMPTZ,
  version         BIGINT NOT NULL DEFAULT 0,

  created\_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated\_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(user\_id, device\_id)
);
CREATE INDEX IF NOT EXISTS idx\_sync\_state\_user\_version ON sync\_state(user\_id, version DESC);

-- =======================
-- Simple outbox for client/server sync (optional but useful)
-- =======================
CREATE TABLE IF NOT EXISTS sync\_outbox (
  id              UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  user\_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device\_id       TEXT NOT NULL,
  entity\_type     TEXT NOT NULL,  -- e.g. inventory\_movement|sales\_receipt|disease\_upload|media
  entity\_id       UUID,           -- the affected entity
  operation       TEXT NOT NULL,  -- create|update|delete
  payload         JSONB NOT NULL DEFAULT '{}'::jsonb,

  status          TEXT NOT NULL DEFAULT 'pending', -- pending|sent|failed
  error\_message   TEXT,

  created\_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  sent\_at         TIMESTAMPTZ,

  UNIQUE(user\_id, device\_id, entity\_type, operation, created\_at)
);
CREATE INDEX IF NOT EXISTS idx\_sync\_outbox\_user\_status ON sync\_outbox(user\_id, status, created\_at DESC);

COMMIT;
