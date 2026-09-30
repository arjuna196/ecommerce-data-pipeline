import os

import psycopg
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "dbname": os.environ["DB_NAME"],
    "user": os.environ["DB_USER"],
    "password": os.environ["DB_PASSWORD"],
    "connect_timeout": 5,
}


def get_connection():
    """Open a connection to the PostgreSQL database."""
    return psycopg.connect(**DB_CONFIG)


if __name__ == "__main__":
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT current_database(), current_user;")
            print(cur.fetchone())
