import json
from datetime import datetime
from pathlib import Path

import requests

BASE_URL = "https://dummyjson.com"
PAGE_SIZE = 30


def fetch_all(endpoint):
    """Fetch every record from a paginated DummyJSON endpoint."""
    url = f"{BASE_URL}/{endpoint}"
    skip = 0
    all_records = []

    while True:
        params = {"limit": PAGE_SIZE, "skip": skip}
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()

        records = data[endpoint]
        all_records.extend(records)
        print(f"{endpoint}: fetched skip={skip}, {len(records)} records")

        skip += PAGE_SIZE
        if skip >= data["total"]:
            break

    return all_records


def save_raw(records, endpoint):
    """Save records as a timestamped JSON file in data/raw."""
    output_dir = Path("data/raw")
    output_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = output_dir / f"{endpoint}_{timestamp}.json"

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=2)

    print(f"Saved {len(records)} {endpoint} to {output_file}")
    return output_file


if __name__ == "__main__":
    for endpoint in ["products", "users", "carts"]:
        records = fetch_all(endpoint)
        save_raw(records, endpoint)

