-- ============================================================
-- Retail Data Platform
-- Order Management - PostgreSQL Source System
-- Seed Data
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

INSERT INTO customers (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    customer_status,
    created_at,
    updated_at
)
VALUES
    (1001, 'Aarav', 'Sharma', 'aarav.sharma@example.com', '9876501001',
     'ACTIVE', '2026-09-01 09:00:00', '2026-09-01 09:00:00'),

    (1002, 'Ananya', 'Patel', 'ananya.patel@example.com', '9876501002',
     'ACTIVE', '2026-09-01 09:15:00', '2026-09-02 10:30:00'),

    (1003, 'Rohan', 'Mehta', 'rohan.mehta@example.com', '9876501003',
     'ACTIVE', '2026-09-02 11:00:00', '2026-09-02 11:00:00'),

    (1004, 'Priya', 'Kulkarni', 'priya.kulkarni@example.com', '9876501004',
     'INACTIVE', '2026-09-02 12:00:00', '2026-09-04 14:20:00'),

    (1005, 'Vikram', 'Joshi', 'vikram.joshi@example.com', '9876501005',
     'ACTIVE', '2026-09-03 09:30:00', '2026-09-03 09:30:00'),

    (1006, 'Neha', 'Deshmukh', 'neha.deshmukh@example.com', '9876501006',
     'ACTIVE', '2026-09-03 10:15:00', '2026-09-05 16:45:00'),

    (1007, 'Aditya', 'Verma', 'aditya.verma@example.com', '9876501007',
     'ACTIVE', '2026-09-04 11:00:00', '2026-09-04 11:00:00'),

    (1008, 'Isha', 'Nair', 'isha.nair@example.com', '9876501008',
     'ACTIVE', '2026-09-05 13:30:00', '2026-09-05 13:30:00');


-- ============================================================
-- 2. CUSTOMER ADDRESSES
-- ============================================================

INSERT INTO customer_addresses (
    address_id,
    customer_id,
    address_type,
    address_line1,
    address_line2,
    city,
    state,
    postal_code,
    country,
    created_at,
    updated_at
)
VALUES
    (2001, 1001, 'HOME', '12 MG Road', 'Near Central Mall',
     'Pune', 'Maharashtra', '411001', 'India',
     '2026-09-01 09:10:00', '2026-09-01 09:10:00'),

    (2002, 1002, 'HOME', '45 Park Street', NULL,
     'Mumbai', 'Maharashtra', '400001', 'India',
     '2026-09-01 09:30:00', '2026-09-02 10:35:00'),

    (2003, 1003, 'HOME', '18 Indiranagar Road', 'Block B',
     'Bengaluru', 'Karnataka', '560038', 'India',
     '2026-09-02 11:15:00', '2026-09-02 11:15:00'),

    (2004, 1004, 'HOME', '22 FC Road', NULL,
     'Pune', 'Maharashtra', '411004', 'India',
     '2026-09-02 12:15:00', '2026-09-04 14:25:00'),

    (2005, 1005, 'OFFICE', '88 Residency Road', '5th Floor',
     'Bengaluru', 'Karnataka', '560025', 'India',
     '2026-09-03 09:45:00', '2026-09-03 09:45:00'),

    (2006, 1006, 'HOME', '31 Civil Lines', NULL,
     'Nagpur', 'Maharashtra', '440001', 'India',
     '2026-09-03 10:30:00', '2026-09-05 16:50:00'),

    (2007, 1007, 'HOME', '17 Sector 18', NULL,
     'Noida', 'Uttar Pradesh', '201301', 'India',
     '2026-09-04 11:15:00', '2026-09-04 11:15:00'),

    (2008, 1008, 'HOME', '9 Marine Drive', NULL,
     'Mumbai', 'Maharashtra', '400020', 'India',
     '2026-09-05 13:45:00', '2026-09-05 13:45:00');


-- ============================================================
-- 3. ORDERS
-- ============================================================

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    currency,
    total_amount,
    created_at,
    updated_at
)
VALUES
    (3001, 1001, '2026-09-01 10:00:00', 'DELIVERED', 'INR',
     2499.00, '2026-09-01 10:00:00', '2026-09-03 15:00:00'),

    (3002, 1002, '2026-09-01 11:30:00', 'DELIVERED', 'INR',
     1599.00, '2026-09-01 11:30:00', '2026-09-04 12:00:00'),

    (3003, 1003, '2026-09-02 14:00:00', 'SHIPPED', 'INR',
     3299.00, '2026-09-02 14:00:00', '2026-09-05 09:30:00'),

    (3004, 1004, '2026-09-03 09:45:00', 'CANCELLED', 'INR',
     899.00, '2026-09-03 09:45:00', '2026-09-03 11:00:00'),

    (3005, 1005, '2026-09-04 16:20:00', 'DELIVERED', 'INR',
     4599.00, '2026-09-04 16:20:00', '2026-09-06 18:00:00'),

    (3006, 1006, '2026-09-05 10:10:00', 'PROCESSING', 'INR',
     1299.00, '2026-09-05 10:10:00', '2026-09-05 10:10:00'),

    (3007, 1007, '2026-09-06 13:45:00', 'SHIPPED', 'INR',
     2799.00, '2026-09-06 13:45:00', '2026-09-07 09:15:00'),

    (3008, 1008, '2026-09-07 17:30:00', 'DELIVERED', 'INR',
     1999.00, '2026-09-07 17:30:00', '2026-09-09 14:00:00');


-- ============================================================
-- 4. ORDER ITEMS
-- Append-only transaction records
-- ============================================================

INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    product_name,
    quantity,
    unit_price,
    discount_amount,
    line_amount,
    created_at
)
VALUES
    (4001, 3001, 'P1001', 'Wireless Headphones',
     1, 2499.00, 0.00, 2499.00,
     '2026-09-01 10:01:00'),

    (4002, 3002, 'P1002', 'Mechanical Keyboard',
     1, 1599.00, 0.00, 1599.00,
     '2026-09-01 11:31:00'),

    (4003, 3003, 'P1003', 'Smart Watch',
     1, 3499.00, 200.00, 3299.00,
     '2026-09-02 14:01:00'),

    (4004, 3004, 'P1004', 'USB-C Hub',
     1, 999.00, 100.00, 899.00,
     '2026-09-03 09:46:00'),

    (4005, 3005, 'P1005', 'Bluetooth Speaker',
     1, 4599.00, 0.00, 4599.00,
     '2026-09-04 16:21:00'),

    (4006, 3006, 'P1006', 'Wireless Mouse',
     1, 1299.00, 0.00, 1299.00,
     '2026-09-05 10:11:00'),

    (4007, 3007, 'P1007', 'Fitness Band',
     1, 2799.00, 0.00, 2799.00,
     '2026-09-06 13:46:00'),

    (4008, 3008, 'P1008', 'Laptop Stand',
     1, 1999.00, 0.00, 1999.00,
     '2026-09-07 17:31:00'),

    (4009, 3005, 'P1009', 'USB-C Cable',
     2, 299.00, 0.00, 598.00,
     '2026-09-04 16:22:00');


-- ============================================================
-- 5. PAYMENTS
-- ============================================================

INSERT INTO payments (
    payment_id,
    order_id,
    payment_method,
    payment_status,
    transaction_ref,
    amount,
    payment_date,
    created_at,
    updated_at
)
VALUES
    (5001, 3001, 'UPI', 'SUCCESS',
     'TXN100001', 2499.00, '2026-09-01 10:05:00',
     '2026-09-01 10:05:00', '2026-09-01 10:05:00'),

    (5002, 3002, 'CARD', 'SUCCESS',
     'TXN100002', 1599.00, '2026-09-01 11:35:00',
     '2026-09-01 11:35:00', '2026-09-01 11:35:00'),

    (5003, 3003, 'UPI', 'SUCCESS',
     'TXN100003', 3299.00, '2026-09-02 14:05:00',
     '2026-09-02 14:05:00', '2026-09-02 14:05:00'),

    (5004, 3004, 'CARD', 'REFUNDED',
     'TXN100004', 899.00, '2026-09-03 09:50:00',
     '2026-09-03 09:50:00', '2026-09-03 11:10:00'),

    (5005, 3005, 'NET_BANKING', 'SUCCESS',
     'TXN100005', 4599.00, '2026-09-04 16:25:00',
     '2026-09-04 16:25:00', '2026-09-04 16:25:00'),

    (5006, 3006, 'UPI', 'SUCCESS',
     'TXN100006', 1299.00, '2026-09-05 10:15:00',
     '2026-09-05 10:15:00', '2026-09-05 10:15:00'),

    (5007, 3007, 'CARD', 'SUCCESS',
     'TXN100007', 2799.00, '2026-09-06 13:50:00',
     '2026-09-06 13:50:00', '2026-09-06 13:50:00'),

    (5008, 3008, 'UPI', 'SUCCESS',
     'TXN100008', 1999.00, '2026-09-07 17:35:00',
     '2026-09-07 17:35:00', '2026-09-07 17:35:00');


-- ============================================================
-- 6. RETURNS
-- ============================================================

INSERT INTO returns (
    return_id,
    order_id,
    order_item_id,
    return_quantity,
    return_reason,
    return_status,
    refund_amount,
    return_date,
    created_at,
    updated_at
)
VALUES
    (6001, 3003, 4003, 1,
     'Product not as expected',
     'COMPLETED',
     3299.00,
     '2026-09-08 11:00:00',
     '2026-09-08 11:00:00',
     '2026-09-08 15:30:00'),

    (6002, 3005, 4005, 1,
     'Damaged product',
     'APPROVED',
     4599.00,
     '2026-09-09 10:30:00',
     '2026-09-09 10:30:00',
     '2026-09-09 12:00:00');


-- ============================================================
-- Reset sequences
-- Required because explicit IDs were inserted above.
-- ============================================================

SELECT setval(
    pg_get_serial_sequence('customers', 'customer_id'),
    (SELECT MAX(customer_id) FROM customers)
);

SELECT setval(
    pg_get_serial_sequence('customer_addresses', 'address_id'),
    (SELECT MAX(address_id) FROM customer_addresses)
);

SELECT setval(
    pg_get_serial_sequence('orders', 'order_id'),
    (SELECT MAX(order_id) FROM orders)
);

SELECT setval(
    pg_get_serial_sequence('order_items', 'order_item_id'),
    (SELECT MAX(order_item_id) FROM order_items)
);

SELECT setval(
    pg_get_serial_sequence('payments', 'payment_id'),
    (SELECT MAX(payment_id) FROM payments)
);

SELECT setval(
    pg_get_serial_sequence('returns', 'return_id'),
    (SELECT MAX(return_id) FROM returns)
);

