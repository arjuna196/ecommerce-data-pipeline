select
    cart_id                          as order_id,
    user_id                          as customer_id,
    distinct_products,
    total_quantity,
    gross_amount,
    net_amount,
    gross_amount - net_amount        as discount_amount

from {{ ref('stg_carts') }}
