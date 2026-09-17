## Ingestion Patterns

### PostgreSQL

- **Incremental**
  - Watermark-based extraction
  - `updated_at` filtering
- **Append-only**
  - Extract newly created transaction rows

### MongoDB

- **Incremental**
  - Timestamp-based filtering
- **Append-only**
  - Event timestamp
  - JSON document extraction

### CSV Files

- **Full File Load**
  - Process the complete file
- **Incremental File Load**
  - Process newly received or changed files
  - Track file metadata

### REST APIs

- **Incremental API**
  - Date/timestamp parameters
  - Pagination
  - Retry handling
  - Rate limiting

### SFTP

- **Full File Load**
  - Discover and process the required files
- **Incremental File Load**
  - File date
  - File hash
  - Duplicate detection
  - Quarantine invalid files
