# Ingestion Strategy

## 1. Overview

The Retail Data Platform uses a Python-based ingestion framework to extract data from five different source systems:

* PostgreSQL
* MongoDB
* CSV files
* REST APIs
* SFTP

The ingestion layer is responsible for:

1. Connecting to source systems
2. Extracting new or changed data
3. Validating extracted data
4. Preserving the source data without transformation
5. Storing raw data in MinIO/S3
6. Maintaining metadata such as extraction time, source, dataset, and file information
7. Handling failures, retries, and duplicate data
8. Providing data for loading into Snowflake RAW

The ingestion flow is:

```text
Source Systems
      ↓
Python Extraction Framework
      ↓
Validation
      ↓
MinIO / S3 Raw Landing
      ↓
Snowflake RAW
      ↓
dbt Transformations
```

---

## 2. Ingestion Principles

The ingestion layer follows these principles:

### 2.1 Preserve Raw Data

Data is stored in MinIO/S3 before transformation.

The raw layer should represent the extracted source data as closely as possible.

```text
Source
  ↓
Extract
  ↓
Raw Landing
  ↓
Transform later
```

Transformations such as renaming columns, changing data types, joining datasets, or calculating metrics are handled downstream using dbt.

### 2.2 Source-Specific Extraction

Different source systems require different extraction techniques.

```text
PostgreSQL → SQL queries
MongoDB    → MongoDB queries
CSV        → File processing
REST API   → HTTP requests
SFTP       → Remote file discovery/download
```

### 2.3 Incremental Processing

Where possible, the framework avoids extracting the complete source dataset repeatedly.

Incremental extraction identifies records or files that have not been processed previously.

Examples:

```text
PostgreSQL → updated_at
MongoDB    → event timestamp
REST API   → date/timestamp parameter
SFTP       → file date + file hash
```

### 2.4 Idempotent Processing

Running the same ingestion job more than once should not unnecessarily create duplicate data.

The framework uses techniques such as:

* Watermarks
* File hashes
* Duplicate detection
* Source identifiers
* Metadata tracking

---

# 3. PostgreSQL Ingestion

The PostgreSQL source contains six datasets:

| Dataset              | Pattern     | Extraction Method        |
| -------------------- | ----------- | ------------------------ |
| `customers`          | Incremental | `updated_at` + watermark |
| `customer_addresses` | Incremental | `updated_at` + watermark |
| `orders`             | Incremental | `updated_at` + watermark |
| `order_items`        | Append-only | New transaction rows     |
| `payments`           | Incremental | `updated_at` + watermark |
| `returns`            | Incremental | `updated_at` + watermark |

## 3.1 Incremental Extraction

For incremental datasets, the framework maintains a watermark representing the latest successfully processed timestamp.

Example:

```text
Previous watermark:
2026-09-01 10:00:00

Source query:

SELECT *
FROM customers
WHERE updated_at > '2026-09-01 10:00:00';
```

After successful extraction:

```text
New maximum updated_at
        ↓
2026-09-02 14:35:21
        ↓
Save as new watermark
```

The next extraction starts from this value.

### Watermark Flow

```text
Read previous watermark
        ↓
Query changed records
        ↓
Extract data
        ↓
Store raw data
        ↓
Successfully loaded?
     /        \
   Yes         No
   ↓            ↓
Update       Keep old
watermark    watermark
```

The watermark should only be advanced after the extraction and raw landing have completed successfully.

## 3.2 Append-Only Extraction

`order_items` is treated as an append-only dataset for this project.

New transaction rows are identified using their creation timestamp or newly generated records.

Example:

```sql
SELECT *
FROM order_items
WHERE created_at > '2026-09-01 10:00:00';
```

Existing rows are not updated during the normal ingestion process.

## 3.3 PostgreSQL Connection

The Python extractor will connect using configuration rather than hard-coded credentials.

Example configuration:

```yaml
postgres:
  host: postgres
  port: 5432
  database: retail
  user: ${POSTGRES_USER}
  password: ${POSTGRES_PASSWORD}
```

When the extractor runs inside the Docker Compose network, the PostgreSQL service is accessed using:

```text
postgres:5432
```

---

# 4. MongoDB Ingestion

The MongoDB source contains four datasets:

| Dataset             | Pattern     | Extraction Method   |
| ------------------- | ----------- | ------------------- |
| `customer_profiles` | Incremental | Timestamp filtering |
| `product_views`     | Append-only | Event timestamp     |
| `search_events`     | Append-only | Event timestamp     |
| `cart_events`       | Append-only | Event timestamp     |

MongoDB stores documents rather than relational rows.

Example document:

```json
{
  "customer_id": "C1001",
  "event_type": "product_view",
  "product_id": "P100",
  "event_timestamp": "2026-09-01T10:30:00",
  "device": {
    "type": "mobile",
    "os": "Android"
  }
}
```

The raw document should be preserved during ingestion.

## 4.1 Incremental MongoDB Extraction

For `customer_profiles`, the extractor uses a timestamp field to identify changed documents.

Conceptually:

```text
Read watermark
      ↓
Query documents where updated_at > watermark
      ↓
Extract documents
      ↓
Store raw JSON
      ↓
Update watermark
```

## 4.2 Append-Only Events

The event datasets are treated as append-only.

Examples:

```text
product_views
search_events
cart_events
```

New events are identified using their event timestamp.

The original JSON structure is preserved in the raw layer.

Later, dbt can flatten nested fields into analytical columns.

---

# 5. CSV File Ingestion

The Finance Management source contains:

| Dataset              | Pattern               |
| -------------------- | --------------------- |
| `monthly_budget.csv` | Full File Load        |
| `store_targets.csv`  | Full File Load        |
| `store_expenses.csv` | Incremental File Load |

## 5.1 Full File Load

For full-file datasets, the complete file is processed whenever a new load is required.

Example:

```text
monthly_budget.csv
        ↓
Validate file
        ↓
Read complete file
        ↓
Store raw snapshot
```

The raw file is preserved before transformation.

## 5.2 Incremental File Load

For `store_expenses.csv`, the framework identifies newly received files or file versions.

File metadata can include:

```text
file_name
file_size
file_modified_time
file_hash
extraction_time
```

Example:

```text
store_expenses_2026_09_01.csv
        ↓
Calculate SHA-256 hash
        ↓
Check previously processed files
        ↓
New file?
   /          \
 Yes           No
 ↓             ↓
Process       Skip
```

This prevents the same file from being processed repeatedly.

## 5.3 CSV Validation

Before storing or loading the data, the framework can validate:

* File exists
* File is readable
* Expected columns exist
* Required columns are not missing
* File is not empty
* Data types are reasonable
* Duplicate records are checked where applicable

---

# 6. REST API Ingestion

The External Services source contains:

| Dataset           | Pattern         | Main Technique               |
| ----------------- | --------------- | ---------------------------- |
| `exchange_rates`  | Incremental API | Date parameters              |
| `shipping_status` | Incremental API | `updated_since` + pagination |
| `market_data`     | Incremental API | Date/timestamp               |

REST API extraction is different from database extraction because the source is accessed through HTTP requests.

Conceptual flow:

```text
Read checkpoint
      ↓
Build API request
      ↓
Send HTTP request
      ↓
Receive JSON response
      ↓
Handle pagination
      ↓
Store raw response
      ↓
Update checkpoint
```

## 6.1 Date and Timestamp Parameters

The extractor sends a date or timestamp to request only the required period.

Example:

```text
/api/shipping-status?updated_since=2026-09-01T00:00:00
```

The exact parameter will depend on the API used by the project.

## 6.2 Pagination

APIs may return a limited number of records per request.

Example:

```text
Request page 1
      ↓
Receive data + next page
      ↓
Request page 2
      ↓
Receive data + next page
      ↓
Continue
      ↓
No next page
      ↓
Finish extraction
```

The extractor must continue until all required pages have been processed.

## 6.3 Retry Handling

Temporary failures should not immediately fail the entire pipeline.

Examples:

* HTTP 500
* Connection timeout
* Temporary network failure
* Service unavailable

The extractor can retry failed requests using controlled retry attempts and delays.

Example:

```text
API request
    ↓
Failed?
  /    \
No      Yes
↓        ↓
Continue Retry
         ↓
      Success?
       /    \
     Yes     No
     ↓        ↓
 Continue   Fail task
```

## 6.4 Rate Limiting

External APIs may limit the number of requests allowed within a specific time period.

The extractor must respect API rate limits by controlling request frequency and handling HTTP rate-limit responses where applicable.

---

# 7. SFTP Ingestion

The Supplier / Partner System contains:

| Dataset              | Pattern               | Extraction Method     |
| -------------------- | --------------------- | --------------------- |
| `products`           | Full File Load        | Remote file discovery |
| `supplier_prices`    | Incremental File Load | File date + hash      |
| `supplier_inventory` | Incremental File Load | File date + hash      |

SFTP ingestion involves discovering files on a remote server and transferring them to the ingestion environment.

## 7.1 SFTP Flow

```text
Connect to SFTP
      ↓
Discover remote files
      ↓
Identify required dataset files
      ↓
Check file metadata/hash
      ↓
Download new files
      ↓
Validate files
      ↓
Store raw snapshot
      ↓
Mark file as processed
```

## 7.2 File Date

The framework can use the file's date or naming convention to determine whether a file belongs to a new processing period.

Example:

```text
supplier_inventory_2026_09_01.csv
supplier_inventory_2026_09_02.csv
supplier_inventory_2026_09_03.csv
```

## 7.3 File Hash

A SHA-256 hash can be calculated for each downloaded file.

Example:

```text
File A
   ↓
SHA-256
   ↓
abc123...
```

If the same file is received again with the same hash, it can be identified as a duplicate.

If the filename is the same but the hash is different, the framework can treat it as a new file version and process it according to the configured rules.

## 7.4 Duplicate Detection

The ingestion metadata can maintain:

```text
dataset
file_name
file_hash
file_date
processed_at
status
```

Before processing a file:

```text
Calculate hash
      ↓
Check metadata
      ↓
Hash already exists?
   /           \
 Yes            No
 ↓              ↓
Skip           Process
```

## 7.5 Quarantine

Files that fail validation should not continue into the normal pipeline.

Example:

```text
SFTP file
   ↓
Validation
   ↓
Invalid
   ↓
Quarantine
```

Possible validation failures:

* Missing required columns
* Empty file
* Invalid file format
* Corrupted file
* Unexpected schema
* Invalid data

The original invalid file can be retained for investigation.

---

# 8. Raw Landing in MinIO

MinIO acts as the raw object-storage layer in the local development environment.

The planned bucket is:

```text
retail-raw
```

A source-oriented structure is used:

```text
retail-raw/
├── postgres/
├── mongodb/
├── finance/
├── suppliers/
└── api/
```

A dataset and extraction-date structure can then be used underneath each source.

Example:

```text
retail-raw/
└── postgres/
    └── customers/
        └── extraction_date=2026-09-01/
            └── customers_20260901_103000.json
```

Another example:

```text
retail-raw/
└── finance/
    └── store_expenses/
        └── extraction_date=2026-09-01/
            └── store_expenses_20260901.csv
```

The exact file format can vary by source, but the raw layer should preserve the extracted source information without applying analytical transformations.

---

# 9. Metadata and Checkpoints

The ingestion framework needs metadata to track processing state.

Important metadata can include:

```text
source_system
dataset
extraction_started_at
extraction_completed_at
record_count
status
watermark
file_name
file_hash
error_message
```

For incremental sources, checkpoints prevent the pipeline from repeatedly processing the same data.

Example:

```text
customers
last_successful_watermark
        ↓
2026-09-05 14:30:00
```

If a pipeline fails after extraction but before successful completion, the previous checkpoint remains unchanged.

This allows the next run to safely retry the uncompleted extraction.

---

# 10. Error Handling

The ingestion framework should handle failures at the source and dataset level.

Common failures include:

```text
Connection failure
Authentication failure
Timeout
Invalid file
Invalid API response
Schema mismatch
Duplicate file
Database query failure
Network failure
```

The framework should:

1. Log the error
2. Record the failed dataset/job
3. Retry where appropriate
4. Avoid advancing the checkpoint on failure
5. Preserve useful failure information
6. Allow Airflow to mark the task as failed

---

# 11. Retry Strategy

Retries are useful for temporary failures but should not be used indefinitely.

Examples where retry can be useful:

| Failure                     | Retry      |
| --------------------------- | ---------- |
| Network timeout             | Yes        |
| Temporary API error         | Yes        |
| SFTP connection failure     | Yes        |
| Database connection failure | Yes        |
| Authentication failure      | Usually no |
| Invalid CSV schema          | No         |
| Corrupted file              | No         |
| Invalid API request         | No         |

Airflow will later control task-level retries, while the Python extraction framework can handle source-specific retry behavior such as API requests.

---

# 12. Ingestion Summary

| Source     | Dataset Count | Pattern                   | Main Technique              |
| ---------- | ------------: | ------------------------- | --------------------------- |
| PostgreSQL |             6 | Incremental / Append-only | SQL + watermark             |
| MongoDB    |             4 | Incremental / Append-only | Timestamp + JSON            |
| CSV        |             3 | Full / Incremental File   | File metadata               |
| REST APIs  |             3 | Incremental API           | Date/timestamp + pagination |
| SFTP       |             3 | Full / Incremental File   | File date + hash            |
| **Total**  |        **19** | Multiple patterns         | Python framework            |

---

# 13. Final Ingestion Flow

```text
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │    MongoDB      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   CSV Files     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   REST APIs     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │      SFTP       │
                    └────────┬────────┘
                             │
                             ▼
                ┌─────────────────────────┐
                │ Python Extraction       │
                │ Framework               │
                └────────────┬────────────┘
                             │
                    ┌────────▼────────┐
                    │   Validation    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ MinIO / S3 Raw  │
                    │    Landing      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Snowflake RAW   │
                    └────────┬────────┘
                             │
                             ▼
                    dbt Transformations
```

The ingestion framework is intentionally separated from transformation logic. Its primary responsibility is to reliably extract, validate, track, and preserve source data so that downstream Snowflake and dbt processing can operate on a consistent raw layer.
