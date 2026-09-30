with source as (

    select * from {{ source('raw', 'carts') }}

),

items as (

    select
        source.id as cart_id,
        t.line_number,
        t.item
    from source
    cross join lateral jsonb_array_elements(source.payload->'products')
        with ordinality as t(item, line_number)

),

renamed as (

    select
                concat_ws('-', cart_id, line_number)          as cart_item_id,
        cart_id,
        line_number::integer                          as line_number,
        (item->>'id')::integer                        as product_id,
        (item->>'quantity')::integer                  as quantity,
        (item->>'price')::numeric(10, 2)              as unit_price,
        (item->>'discountPercentage')::numeric(5, 2)  as discount_percentage,
        (item->>'total')::numeric(12, 2)              as gross_amount,
        (item->>'discountedTotal')::numeric(12, 2)    as net_amount

    from items

)

select * from renamed
