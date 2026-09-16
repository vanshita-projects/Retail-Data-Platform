# Retail Data Platform - Data Engineering Pipeline

End-to-end data engineering pipeline demonstrating multi-source data ingestion,
raw data landing, Snowflake loading, dbt transformations, data quality checks,
and Airflow orchestration.

## Architecture

PostgreSQL / MongoDB / CSV / SFTP / REST API
        ↓
Python Extraction Framework
        ↓
MinIO / S3 Raw Landing
        ↓
Snowflake RAW
        ↓
dbt Staging
        ↓
dbt Intermediate
        ↓
dbt Gold / Marts
        ↓
Data Quality
        ↓
Analytics-ready Data

## Technologies

- Python
- PostgreSQL
- MongoDB
- Docker
- MinIO
- Snowflake
- dbt
- Great Expectations
- Apache Airflow
- Git / GitHub
