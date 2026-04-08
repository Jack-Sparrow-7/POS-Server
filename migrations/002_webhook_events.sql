CREATE TABLE webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    event_id VARCHAR(255) NOT NULL UNIQUE,
    merchant_order_id VARCHAR(255),
    event_timestamp TIMESTAMPTZ NOT NULL,
    payload_hash VARCHAR(64),
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status VARCHAR(20) NOT NULL DEFAULT 'received',
    processing_error_code VARCHAR(100)
);

CREATE INDEX idx_webhook_events_provider_received_at
ON webhook_events (provider, received_at DESC);
