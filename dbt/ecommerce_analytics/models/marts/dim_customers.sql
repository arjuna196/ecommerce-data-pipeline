select
    user_id                           as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name    as full_name,
    email,
    gender,
    age,
    city,
    state,
    country

from {{ ref('stg_users') }}
