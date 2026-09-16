# Retail Data Platform - Data Engineering Pipeline

End-to-end data engineering pipeline demonstrating multi-source data ingestion,
raw data landing, Snowflake loading, dbt transformations, data quality checks,
and Airflow orchestration.

## Architecture

```mermaid
flowchart TD
    A[PostgreSQL] --> F[Python Extraction Framework]
    B[MongoDB] --> F
    C[CSV Files] --> F
    D[SFTP] --> F
    E[REST APIs] --> F

    F --> G[MinIO / S3 Raw Landing]
    G --> H[Snowflake RAW]
    H --> I[dbt Staging]
    I --> J[dbt Intermediate]
    J --> K[dbt Gold / Marts]
    K --> L[Data Quality]
    L --> M[Analytics-ready Data]
```

## Technologies

* Python
* PostgreSQL
* MongoDB
* Docker
* MinIO
* Snowflake
* dbt
* Great Expectations
* Apache Airflow
* Git / GitHub
