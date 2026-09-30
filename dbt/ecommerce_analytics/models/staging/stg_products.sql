with source as (

    select * from {{ source('raw', 'products') }}

),

renamed as (

    select
        id                                              as product_id,
        payload->>'title'                               as product_name,
        payload->>'category'                            as category,
        payload->>'brand'                               as brand,
        payload->>'sku'                                 as sku,
        (payload->>'price')::numeric(10, 2)             as price,
        (payload->>'discountPercentage')::numeric(5, 2) as discount_percentage,
        (payload->>'rating')::numeric(3, 2)             as rating,
        (payload->>'stock')::integer                    as stock_quantity,
        payload->>'availabilityStatus'                  as availability_status,
        (payload->'meta'->>'createdAt')::timestamptz    as created_at,
        loaded_at

    from source

)

select * from renamed
