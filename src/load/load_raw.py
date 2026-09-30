import json
from pathlib import Path

from psycopg.types.json import Jsonb

from src.load.db import get_connection

RAW_DIR = Path("data/raw")
ENTITIES = ["products", "users", "carts"]


def latest_file(entity):
    """Return the most recent raw JSON file for an entity."""
    files = sorted(RAW_DIR.glob(f"{entity}_*.json"))
    if not files:
        raise FileNotFoundError(f"No raw files found for {entity} in {RAW_DIR}")
    return files[-1]


def load_entity(conn, entity):
    """Upsert every record from the latest raw file into raw.<entity>."""
    path = latest_file(entity)
    with open(path, encoding="utf-8") as f:
        records = json.load(f)

    rows = [(r["id"], Jsonb(r), path.name) for r in records]

    with conn.cursor() as cur:
        cur.executemany(
            f"""
            INSERT INTO raw.{entity} (id, payload, source_file)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO UPDATE
            SET payload = EXCLUDED.payload,
                source_file = EXCLUDED.source_file,
                loaded_at = now()
            """,
            rows,
        )
    print(f"Loaded {len(rows)} rows into raw.{entity} from {path.name}")


if __name__ == "__main__":
    with get_connection() as conn:
        for entity in ENTITIES:
            load_entity(conn, entity)
