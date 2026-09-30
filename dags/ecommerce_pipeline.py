from datetime import datetime, timedelta

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG

PROJECT_DIR = "/opt/project"
DBT_DIR = f"{PROJECT_DIR}/dbt/ecommerce_analytics"
DBT_BIN = "/home/airflow/dbt_venv/bin/dbt"

default_args = {
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="ecommerce_pipeline",
    description="Extract DummyJSON data, load it into PostgreSQL, then build and test dbt models",
    schedule="@daily",
    start_date=datetime(2026, 9, 1),
    catchup=False,
    default_args=default_args,
    tags=["ecommerce"],
    max_active_runs=1,

) as dag:

    extract = BashOperator(
        task_id="extract",
        bash_command=f"cd {PROJECT_DIR} && python src/extract/extract_api.py",
    )

    load_raw = BashOperator(
        task_id="load_raw",
        bash_command=f"cd {PROJECT_DIR} && python -m src.load.load_raw",
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"cd {DBT_DIR} && {DBT_BIN} build --profiles-dir .",
    )

    extract >> load_raw >> dbt_build
