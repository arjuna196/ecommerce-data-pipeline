# E-Commerce Data Pipeline

An end-to-end data engineering pipeline that extracts e-commerce data from a REST API, loads it into PostgreSQL, and transforms it into analytics-ready tables.

> 🚧 Work in progress: built stage by stage.

## Architecture

```
DummyJSON REST API
      ↓  Python (requests, pagination)
Raw JSON files (data/raw)
      ↓  Python (psycopg, idempotent upsert)
PostgreSQL: raw schema (JSONB)
      ↓  dbt                     (planned)
Staging & analytics tables       (planned)
      ↓  Apache Airflow          (planned)
Scheduled, orchestrated pipeline
```

## Tech stack

| Area | Technology |
|---|---|
| Language | Python |
| Source | REST API ([DummyJSON](https://dummyjson.com)) |
| Database | PostgreSQL 16 (Docker) |
| Transformation | dbt (planned) |
| Orchestration | Apache Airflow (planned) |
| CI/CD | GitHub Actions (planned) |

## What's built so far

- **Extract:** paginated API extraction for products, users and carts, saved as timestamped raw JSON files
- **Load:** raw records stored as `JSONB` in PostgreSQL, with source-file lineage and load timestamps
- **Idempotent loads:** upsert on primary key, so reruns never create duplicates
- **Config:** credentials kept in environment variables (`.env`), never in code

## Run it locally

```bash
# 1. Start PostgreSQL
docker run -d --name ecommerce-postgres \
  -e POSTGRES_USER=pipeline -e POSTGRES_PASSWORD=pipeline -e POSTGRES_DB=ecommerce \
  -p 5432:5432 -v ecommerce_pgdata:/var/lib/postgresql/data postgres:16

# 2. Install dependencies
python -m venv venv
pip install -r requirements.txt

# 3. Configure credentials
cp .env.example .env   # then edit values

# 4. Create raw tables
docker exec -i ecommerce-postgres psql -U pipeline -d ecommerce < sql/01_create_raw_tables.sql

# 5. Extract and load
python src/extract/extract_api.py
python -m src.load.load_raw
```
