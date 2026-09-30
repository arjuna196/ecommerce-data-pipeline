FROM apache/airflow:3.3.2-python3.13

# Libraries used by the extract and load scripts
RUN pip install --no-cache-dir \
    "apache-airflow==3.3.2" \
    "psycopg[binary]==3.3.6" \
    "python-dotenv==1.2.3"

# dbt in its own virtual environment, so its dependencies can't clash with Airflow's
RUN python -m venv /home/airflow/dbt_venv \
    && /home/airflow/dbt_venv/bin/pip install --no-cache-dir "dbt-postgres==1.11.0"
