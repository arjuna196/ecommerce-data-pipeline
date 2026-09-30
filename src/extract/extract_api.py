import requests
import json
from datetime import datetime
from pathlib import Path

url = "https://dummyjson.com/products"
limit = 30
skip = 0
all_products = []

while True:
    params = {"limit":limit, "skip":skip}
    response = requests.get(url,params=params,timeout=10)
    response.raise_for_status()
    data = response.json()

    products = data["products"]
    all_products.extend(products)
    print(f"Fetched skip={skip}: {len(products)} products")

    skip += limit
    if skip >= data["total"]:
        break

print("Total fetched: ",len(all_products))

output_dir = Path("data/raw")
output_dir.mkdir(parents=True, exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = output_dir / f"products_{timestamp}.json"

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(all_products, f, indent=2)

print("Saved to:", output_file)

