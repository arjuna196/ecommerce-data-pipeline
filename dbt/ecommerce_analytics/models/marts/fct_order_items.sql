with items as (

    select * from {{ ref('stg_cart_items') }}

),

carts as (

    select * from {{ ref('stg_carts') }}

)

select
    items.cart_item_id                          as order_item_id,
    items.cart_id                               as order_id,
    carts.user_id                               as customer_id,
    items.product_id,
    items.line_number,
    items.quantity,
    items.unit_price,
    items.discount_percentage,
    items.gross_amount,
    items.net_amount,
    items.gross_amount - items.net_amount       as discount_amount

from items
inner join carts
    on items.cart_id = carts.cart_id

