PostgreSQL
├── Incremental → watermark + updated_at
└── Append-only → new transaction rows

MongoDB
├── Incremental → timestamp filtering
└── Append-only → event timestamp

CSV
├── Full File Load
└── Incremental File Load

REST APIs
└── Incremental API
    ├── date/timestamp parameters
    ├── pagination
    ├── retries
    └── rate limiting

SFTP
├── Full File Load
└── Incremental File Load
    ├── file date
    ├── file hash
    ├── duplicate detection
    └── quarantine
