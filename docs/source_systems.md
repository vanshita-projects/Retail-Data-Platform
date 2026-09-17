# Source Systems

The Retail Data Platform integrates data from five source systems representing different departments and external services. Each source uses a different data technology and ingestion pattern to demonstrate a range of real-world data engineering scenarios.

## 1. Order Management

**Technology:** PostgreSQL

**Purpose:** Handles core transactional retail operations.

### Datasets

1. `orders`
2. `order_items`
3. `customers`
4. `customer_addresses`
5. `payments`
6. `returns`

### Will Demonstrate

1. Structured relational data
2. Primary and foreign keys
3. Transactional updates
4. Incremental extraction
5. Append-only transaction tables

---

## 2. Customer Engagement

**Technology:** MongoDB

**Purpose:** Stores semi-structured customer interaction and engagement data.

### Datasets

1. `customer_profiles`
2. `product_views`
3. `search_events`
4. `cart_events`

### Will Demonstrate

1. NoSQL ingestion
2. Document-oriented data
3. JSON
4. Nested structures
5. Semi-structured data
6. Schema flexibility
7. JSON flattening
8. Snowflake `VARIANT`
9. Transformation of NoSQL data into relational analytical models

---

## 3. Finance Management

**Technology:** CSV Files

**Purpose:** Provides periodic financial planning and actuals data such as budgets, store targets, and expenses for financial analysis and comparison with operational sales data.

### Datasets

1. `monthly_budget.csv`
2. `store_targets.csv`
3. `store_expenses.csv`

### Will Demonstrate

1. File ingestion
2. File validation
3. Schema validation
4. Duplicate-file handling
5. Missing-file handling
6. Full and periodic loads
7. File metadata
8. Data quality checks

---

## 4. External Services

**Technology:** REST APIs

**Purpose:** Provides third-party data such as exchange rates, shipping status, and market information to enrich internal retail data and support business calculations and metrics.

### Datasets

1. `exchange_rates`
2. `shipping_status`
3. `market_data`

### Will Demonstrate

1. REST API ingestion
2. JSON processing
3. Pagination
4. API failures
5. Retry logic
6. Rate limiting
7. Incremental API extraction
8. Authentication and configuration
9. External-source dependency handling

---

## 5. Supplier / Partner System

**Technology:** SFTP

**Purpose:** External suppliers and business partners deliver scheduled product, pricing, and inventory files to RetailMart through an SFTP server.

### Datasets

1. `products`
2. `supplier_prices`
3. `supplier_inventory`

### Will Demonstrate

1. SFTP connectivity
2. Remote file discovery
3. Secure authentication
4. File-based ingestion
5. Incremental file processing
6. File metadata
7. File hashing
8. Duplicate detection
9. Schema validation
10. Error handling
11. Quarantine handling
12. Retry mechanism
13. Airflow orchestration
14. Raw file preservation

---

# Ingestion Patterns

| #     | Source System           | Technology | Dataset              | Ingestion Pattern     | Key Concepts Demonstrated                        |
| ----- | ----------------------- | ---------- | -------------------- | --------------------- | ------------------------------------------------ |
| **1** | **Order Management**    | PostgreSQL | `orders`             | Incremental           | Watermark, `updated_at`, incremental SQL         |
|       |                         |            | `order_items`        | Append-only           | New transaction rows                             |
|       |                         |            | `customers`          | Incremental           | Watermark, `updated_at`                          |
|       |                         |            | `customer_addresses` | Incremental           | Watermark, `updated_at`                          |
|       |                         |            | `payments`           | Incremental           | Watermark, `updated_at`                          |
|       |                         |            | `returns`            | Incremental           | Watermark, `updated_at`                          |
| **2** | **Customer Engagement** | MongoDB    | `customer_profiles`  | Incremental           | Timestamp filtering, document extraction         |
|       |                         |            | `product_views`      | Append-only           | Event timestamp, JSON documents                  |
|       |                         |            | `search_events`      | Append-only           | Event timestamp, JSON documents                  |
|       |                         |            | `cart_events`        | Append-only           | Event timestamp, JSON documents                  |
| **3** | **Finance Management**  | CSV Files  | `monthly_budget`     | Full File Load        | File ingestion, schema validation, snapshots     |
|       |                         |            | `store_targets`      | Full File Load        | File ingestion, schema validation                |
|       |                         |            | `store_expenses`     | Incremental File Load | File metadata, file date, incremental processing |
| **4** | **External Services**   | REST APIs  | `exchange_rates`     | Incremental API       | Date parameters, JSON, API handling              |
|       |                         |            | `shipping_status`    | Incremental API       | `updated_since`, pagination, retries             |
|       |                         |            | `market_data`        | Incremental API       | Date/timestamp, JSON                             |
| **5** | **Supplier / Partner**  | SFTP       | `products`           | Full File Load        | SFTP, remote file discovery, snapshots           |
|       |                         |            | `supplier_prices`    | Incremental File Load | File date, file hash, duplicate detection        |
|       |                         |            | `supplier_inventory` | Incremental File Load | File date, file hash, duplicate detection        |

---

# Data Ingestion Strategy Summary

| Source System       | Technology         | No. of Datasets | Main Ingestion Patterns               |
| ------------------- | ------------------ | --------------: | ------------------------------------- |
| Order Management    | PostgreSQL         |           **6** | Incremental, Append-only              |
| Customer Engagement | MongoDB            |           **4** | Incremental, Append-only              |
| Finance Management  | CSV                |           **3** | Full File Load, Incremental File Load |
| External Services   | REST API           |           **3** | Incremental API                       |
| Supplier / Partner  | SFTP               |           **3** | Full File Load, Incremental File Load |
| **Total**           | **5 Source Types** |          **19** | **Multiple ingestion patterns**       |
