with source as (

    select * from {{ source('raw', 'carts') }}

),

renamed as (

    select
        id                                            as cart_id,
        (payload->>'userId')::integer                 as user_id,
        (payload->>'totalProducts')::integer          as distinct_products,
        (payload->>'totalQuantity')::integer          as total_quantity,
        (payload->>'total')::numeric(12, 2)           as gross_amount,
        (payload->>'discountedTotal')::numeric(12, 2) as net_amount,
        loaded_at

    from source

)

select * from renamed
