# E-Commerce Data Pipeline

![CI](https://github.com/arjuna196/ecommerce-data-pipeline/actions/workflows/ci.yml/badge.svg)

An end-to-end ELT pipeline that extracts e-commerce data from a REST API, loads it into PostgreSQL, transforms it into a tested star schema with dbt, and runs daily on Apache Airflow. It's containerised with Docker and checked by GitHub Actions CI on every push.

## Architecture

```
DummyJSON REST API
      │  Python: paginated extraction, retries with exponential backoff
      ▼
Raw JSON files (data/raw, timestamped)
      │  Python: idempotent upsert (psycopg)
      ▼
PostgreSQL ── raw schema (JSONB + lineage columns)
      │  dbt
      ▼
analytics_staging ── typed, cleaned views (PII excluded)
      │  dbt
      ▼
analytics_marts ── star schema: fct_orders, fct_order_items, dim_products, dim_customers
      │
      ▼
SQL analysis (sql/analysis)

Orchestration: Airflow DAG  extract ─► load_raw ─► dbt_build  (daily)
CI: GitHub Actions runs the full pipeline and all dbt tests on every push
```

## Tech stack

| Area | Technology |
|---|---|
| Language | Python 3.13, SQL |
| Source | REST API ([DummyJSON](https://dummyjson.com)) |
| Warehouse | PostgreSQL 16 |
| Transformation & testing | dbt (dbt-postgres) |
| Orchestration | Apache Airflow 3 |
| Containers | Docker, Docker Compose |
| CI | GitHub Actions |

## Data model

| Model | Grain | Rows |
|---|---|---|
| `fct_orders` | One row per order | 208 |
| `fct_order_items` | One row per order line | 800 |
| `dim_products` | One row per product | 194 |
| `dim_customers` | One row per customer | 208 |

**33 dbt tests** cover unique and not-null keys, foreign-key relationships between facts and dimensions, and a custom reconciliation test that checks every order total equals the sum of its line items.

## Engineering highlights

- **Idempotent loads:** raw tables upsert on the primary key, so Airflow retries and overlapping runs never create duplicates (verified with two concurrent DAG runs)
- **Resilient extraction:** pagination, request timeouts, and retries with exponential backoff that respect the `Retry-After` header
- **ELT with a JSONB raw layer:** source records are stored untouched, with `source_file` lineage and `loaded_at` timestamps, and all transformation happens in dbt
- **Grain discovered, not assumed:** validation showed that the same product can appear on several lines of one cart, so order items are keyed by cart + line number (`WITH ORDINALITY`)
- **PII excluded at staging:** passwords, SSNs, card numbers, and IP addresses from the source never reach the analytics layer
- **Secrets out of code:** all credentials come from environment variables (`.env` locally, Compose/CI env in containers)
- **Fail fast:** HTTP errors, connection timeouts, and failed dbt tests stop the pipeline before bad data flows downstream

## Key findings

| Finding | Detail |
|---|---|
| Net revenue | $3.46M across 208 orders, after $377K of discounts (9.85%) |
| Revenue concentration | The top 10 products (5% of the catalogue) generate ~76% of revenue |
| Category split | Vehicles alone are 48.7% of revenue from just 19 orders; groceries and kitchen accessories are the most frequently ordered but under 0.2% of revenue each |
| Customer concentration | The top 10 customers (5%) account for ~36% of revenue |
| Data quality | 47% of products have no brand; they're labelled 'Unbranded' in the marts |

## Known limitations

These are properties of the source data, documented rather than worked around with invented values:
- Carts have **no order date**, so time-series analysis (e.g. daily sales trends) isn't possible
- Every customer has **exactly one order**, so repeat-purchase analysis isn't meaningful
- All customers are in the **United States**, so country-level analysis isn't meaningful

## Project structure

```
├── .github/workflows/ci.yml     # CI: full pipeline and dbt tests on every push
├── dags/ecommerce_pipeline.py   # Airflow DAG
├── dbt/ecommerce_analytics/     # dbt project: sources, staging, marts, tests
├── docker/airflow/Dockerfile    # Airflow image with pipeline and dbt dependencies
├── sql/
│   ├── 01_create_raw_tables.sql
│   └── analysis/                # Business questions answered in SQL
├── src/
│   ├── extract/extract_api.py   # API → raw JSON files
│   └── load/                    # Raw JSON → PostgreSQL
├── docker-compose.yml           # PostgreSQL, Airflow metadata DB, Airflow
└── .env.example                 # Required environment variables
```

## Run it

Requires Docker with Docker Compose.

```bash
# 1. Configure credentials
cp .env.example .env              # then set the passwords

# 2. Create the warehouse volume and start everything
docker volume create ecommerce_pgdata
docker compose up -d --build

# 3. Create the raw tables (one time)
docker exec -i ecommerce-postgres psql -U pipeline -d ecommerce < sql/01_create_raw_tables.sql

# 4. Get the Airflow admin password
docker exec airflow cat /opt/airflow/simple_auth_manager_passwords.json.generated
```

Open http://127.0.0.1:8080, log in as `admin`, unpause `ecommerce_pipeline`, and trigger it.

To query the results:

```bash
docker exec -i ecommerce-postgres psql -U pipeline -d ecommerce < sql/analysis/01_headline_kpis.sql
```
