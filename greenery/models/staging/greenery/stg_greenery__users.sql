
{{ config (materialized='view')}}


with users_source as (
    select * from {{ source ('greenery', 'users') }}
)

, renamed as (

 select 
        user_id         AS user_id, 
        first_name      AS user_first_name,
        last_name       AS user_last_name,
        email           AS user_email,
        phone_number    AS user_phone_number,
        created_at      AS user_created_at_utc, 
        updated_at      AS user_updated_at_utc,
        address_id
    from users_source 
)


select * from renamed