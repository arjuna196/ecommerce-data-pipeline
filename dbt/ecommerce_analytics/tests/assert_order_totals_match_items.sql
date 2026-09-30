-- Fails if any order's net amount differs from the sum of its line items.

with item_totals as (

    select
        order_id,
        sum(net_amount) as items_net_amount
    from {{ ref('fct_order_items') }}
    group by order_id

)

select
    orders.order_id,
    orders.net_amount,
    item_totals.items_net_amount
from {{ ref('fct_orders') }} as orders
left join item_totals
    on orders.order_id = item_totals.order_id
where orders.net_amount <> coalesce(item_totals.items_net_amount, 0)
