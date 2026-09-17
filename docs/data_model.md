# Data Model

## 1. Order Management - PostgreSQL

The Order Management source system uses PostgreSQL and contains six relational datasets.

### Entity Relationship Diagram

```mermaid
erDiagram

    CUSTOMERS {
        bigint customer_id PK
        varchar first_name
        varchar last_name
        varchar email UK
        varchar phone
        varchar customer_status
        timestamp created_at
        timestamp updated_at
    }

    CUSTOMER_ADDRESSES {
        bigint address_id PK
        bigint customer_id FK
        varchar address_type
        varchar address_line1
        varchar address_line2
        varchar city
        varchar state
        varchar postal_code
        varchar country
        timestamp created_at
        timestamp updated_at
    }

    ORDERS {
        bigint order_id PK
        bigint customer_id FK
        timestamp order_date
        varchar order_status
        varchar currency
        numeric total_amount
        timestamp created_at
        timestamp updated_at
    }

    ORDER_ITEMS {
        bigint order_item_id PK
        bigint order_id FK
        varchar product_id
        varchar product_name
        integer quantity
        numeric unit_price
        numeric discount_amount
        numeric line_amount
        timestamp created_at
    }

    PAYMENTS {
        bigint payment_id PK
        bigint order_id FK
        varchar payment_method
        varchar payment_status
        varchar transaction_ref
        numeric amount
        timestamp payment_date
        timestamp created_at
        timestamp updated_at
    }

    RETURNS {
        bigint return_id PK
        bigint order_id FK
        bigint order_item_id FK
        integer return_quantity
        varchar return_reason
        varchar return_status
        numeric refund_amount
        timestamp return_date
        timestamp created_at
        timestamp updated_at
    }

    CUSTOMERS ||--o{ CUSTOMER_ADDRESSES : has
    CUSTOMERS ||--o{ ORDERS : places
    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS ||--o{ PAYMENTS : has
    ORDERS ||--o{ RETURNS : has
    ORDER_ITEMS ||--o{ RETURNS : contains
