-- ============================================================
-- Retail Data Platform
-- Order Management - PostgreSQL Source System
-- ============================================================

-- ============================================================
-- 1. customers
-- Incremental extraction using updated_at
-- ============================================================

CREATE TABLE customers (
    customer_id      BIGSERIAL PRIMARY KEY,
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    customer_status  VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. customer_addresses
-- Incremental extraction using updated_at
-- ============================================================

CREATE TABLE customer_addresses (
    address_id       BIGSERIAL PRIMARY KEY,
    customer_id      BIGINT NOT NULL,
    address_type     VARCHAR(20) NOT NULL,
    address_line1    VARCHAR(255) NOT NULL,
    address_line2    VARCHAR(255),
    city             VARCHAR(100) NOT NULL,
    state            VARCHAR(100) NOT NULL,
    postal_code      VARCHAR(20) NOT NULL,
    country          VARCHAR(100) NOT NULL DEFAULT 'India',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer_addresses_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 3. orders
-- Incremental extraction using updated_at
-- ============================================================

CREATE TABLE orders (
    order_id          BIGSERIAL PRIMARY KEY,
    customer_id       BIGINT NOT NULL,
    order_date        TIMESTAMP NOT NULL,
    order_status      VARCHAR(30) NOT NULL,
    currency          VARCHAR(10) NOT NULL DEFAULT 'INR',
    total_amount      NUMERIC(12,2) NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 4. order_items
-- Append-only transaction table
-- ============================================================

CREATE TABLE order_items (
    order_item_id     BIGSERIAL PRIMARY KEY,
    order_id          BIGINT NOT NULL,
    product_id        VARCHAR(50) NOT NULL,
    product_name      VARCHAR(255) NOT NULL,
    quantity          INTEGER NOT NULL,
    unit_price        NUMERIC(12,2) NOT NULL,
    discount_amount   NUMERIC(12,2) NOT NULL DEFAULT 0,
    line_amount       NUMERIC(12,2) NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT chk_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_items_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_order_items_discount
        CHECK (discount_amount >= 0)
);


-- ============================================================
-- 5. payments
-- Incremental extraction using updated_at
-- ============================================================

CREATE TABLE payments (
    payment_id        BIGSERIAL PRIMARY KEY,
    order_id          BIGINT NOT NULL,
    payment_method    VARCHAR(30) NOT NULL,
    payment_status    VARCHAR(30) NOT NULL,
    transaction_ref   VARCHAR(100),
    amount            NUMERIC(12,2) NOT NULL,
    payment_date      TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT chk_payments_amount
        CHECK (amount >= 0)
);


-- ============================================================
-- 6. returns
-- Incremental extraction using updated_at
-- ============================================================

CREATE TABLE returns (
    return_id         BIGSERIAL PRIMARY KEY,
    order_id          BIGINT NOT NULL,
    order_item_id     BIGINT NOT NULL,
    return_quantity   INTEGER NOT NULL,
    return_reason     VARCHAR(255),
    return_status     VARCHAR(30) NOT NULL,
    refund_amount     NUMERIC(12,2) NOT NULL DEFAULT 0,
    return_date       TIMESTAMP NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_returns_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_returns_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id),

    CONSTRAINT chk_returns_quantity
        CHECK (return_quantity > 0),

    CONSTRAINT chk_returns_refund
        CHECK (refund_amount >= 0)
);
