with source as (

    select * from {{ source('raw', 'users') }}

),

renamed as (

    select
        id                               as user_id,
        payload->>'firstName'            as first_name,
        payload->>'lastName'             as last_name,
        payload->>'email'                as email,
        payload->>'gender'               as gender,
        (payload->>'age')::integer       as age,
        payload->'address'->>'city'      as city,
        payload->'address'->>'state'     as state,
        payload->'address'->>'country'   as country,
        loaded_at

    from source

)

select * from renamed
