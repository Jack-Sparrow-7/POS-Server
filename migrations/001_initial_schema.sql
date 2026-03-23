-- Active: 1774204402905@@127.0.0.1@5432@pos_db
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_role AS ENUM ('super_admin', 'merchant', 'cashier', 'customer');

CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'expired', 'suspended');

CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'ready', 'completed', 'cancelled');

CREATE TYPE order_source AS ENUM ('walk_in', 'online');

CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

CREATE TYPE payment_method AS ENUM ('cash', 'upi_walk_in', 'upi_online', 'card');

CREATE TABLE platform_admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    tenant_id UUID NOT NULL REFERENCES tenants (id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    phone VARCHAR(20),
    gstin VARCHAR(15),
    subscription_status subscription_status NOT NULL DEFAULT 'trial',
    subscription_started_at TIMESTAMPTZ,
    subscription_expires_at TIMESTAMPTZ,
    trial_expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '14 days'),
    phonepe_client_id VARCHAR(255),
    phonepe_client_version INTEGER DEFAULT 1,
    phonepe_client_secret VARCHAR(255),
    phonepe_configured BOOLEAN NOT NULL DEFAULT FALSE,
    gst_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stores_tenant_id ON stores (tenant_id);

CREATE INDEX idx_stores_slug ON stores (slug);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    tenant_id UUID NOT NULL REFERENCES tenants (id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores (id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT users_email_tenant_unique UNIQUE (email, tenant_id),
    CONSTRAINT check_cashier_has_store CHECK (
        (
            role = 'cashier'
            AND store_id IS NOT NULL
        )
        OR (
            role = 'merchant'
            AND store_id IS NULL
        )
    )
);

CREATE INDEX idx_users_tenant_id ON users (tenant_id);

CREATE INDEX idx_users_store_id ON users (store_id);

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_customers_phone ON customers (phone);

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    store_id UUID NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT categories_name_store_unique UNIQUE (name, store_id)
);

CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    store_id UUID NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories (id) ON DELETE SET NULL,
    cost_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    gst_percent DECIMAL(5, 2) NOT NULL DEFAULT 0 CHECK (gst_percent >= 0),
    hsn_code VARCHAR(20),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    stock_count INTEGER,
    track_stock BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menu_items_store_id ON menu_items (store_id);

CREATE INDEX idx_menu_items_category ON menu_items (store_id, category_id);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    store_id UUID NOT NULL REFERENCES stores (id) ON DELETE RESTRICT,
    customer_id UUID REFERENCES customers (id) ON DELETE RESTRICT,
    cashier_id UUID REFERENCES users (id) ON DELETE RESTRICT,
    order_number VARCHAR(20) NOT NULL,
    qr_token VARCHAR(50) UNIQUE,
    source order_source NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    gst_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_method payment_method,
    payment_status payment_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    confirmed_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_store_id ON orders (store_id);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);

CREATE INDEX idx_orders_qr_token ON orders (qr_token);

CREATE INDEX idx_orders_order_number ON orders (store_id, order_number);

CREATE INDEX idx_orders_created_at ON orders (store_id, created_at DESC);

CREATE INDEX idx_orders_status ON orders (store_id, status);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    order_id UUID NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items (id) ON DELETE SET NULL,
    item_name VARCHAR(255) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
    unit_price DECIMAL(10, 2) NOT NULL,
    gst_percent DECIMAL(5, 2) NOT NULL DEFAULT 0,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    line_total DECIMAL(10, 2) NOT NULL,
    gst_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_items_order_id ON order_items (order_id);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    order_id UUID NOT NULL REFERENCES orders (id) ON DELETE RESTRICT,
    store_id UUID NOT NULL REFERENCES stores (id) ON DELETE RESTRICT,
    amount DECIMAL(10, 2) NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending',
    merchant_order_id VARCHAR(255) NOT NULL UNIQUE,
    phonepe_order_id VARCHAR(255),
    phonepe_redirect_url TEXT,
    phonepe_expire_at TIMESTAMPTZ,
    phonepe_transaction_id VARCHAR(255),
    phonepe_state VARCHAR(50),
    phonepe_payment_mode VARCHAR(50),
    phonepe_raw_response JSONB,
    initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ
);

CREATE INDEX idx_payments_order_id ON payments (order_id);

CREATE INDEX idx_payments_merchant_order_id ON payments (merchant_order_id);

CREATE INDEX idx_payments_phonepe_order_id ON payments (phonepe_order_id);

CREATE TABLE phonepe_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    store_id UUID NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    access_token TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT phonepe_tokens_store_unique UNIQUE (store_id)
);

CREATE TABLE otp_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    phone VARCHAR(20) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '10 minutes'),
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_tokens_phone ON otp_tokens (phone);

CREATE TABLE store_order_sequences (
    store_id UUID PRIMARY KEY REFERENCES stores (id) ON DELETE CASCADE,
    last_sequence INTEGER NOT NULL DEFAULT 0,
    sequence_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_platform_admins_updated_at BEFORE UPDATE ON platform_admins FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tenants_updated_at BEFORE UPDATE ON tenants FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_stores_updated_at BEFORE UPDATE ON stores FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_menu_items_updated_at BEFORE UPDATE ON menu_items FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION set_updated_at();

INSERT INTO
    platform_admins (email, name, password_hash)
VALUES (
        'jack@dev.local',
        'Platform Admin',
        '$2a$12$0k1xGOhR6CbJ9dH3ZLP0yOPMp4.riGxiTXJBxKgLAJHSz2FpaSofO'
    );