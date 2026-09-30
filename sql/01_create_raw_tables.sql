CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.products (
    id          INTEGER PRIMARY KEY,
    payload     JSONB NOT NULL,
    source_file TEXT NOT NULL,
    loaded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw.users (
    id          INTEGER PRIMARY KEY,
    payload     JSONB NOT NULL,
    source_file TEXT NOT NULL,
    loaded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw.carts (
    id          INTEGER PRIMARY KEY,
    payload     JSONB NOT NULL,
    source_file TEXT NOT NULL,
    loaded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
