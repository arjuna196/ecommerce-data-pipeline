select
    product_id,
    product_name,
    category,
    coalesce(brand, 'Unbranded') as brand,
    sku,
    price,
    discount_percentage,
    rating,
    stock_quantity,
    availability_status

from {{ ref('stg_products') }}
