
{{ config (materialized='view')}}


with users_source as (
    select * from {{ source ('greenery', 'users') }}
)

, renamed as (

 select 
        user_id, 
        first_name,
        last_name,
        email,
        phone_number,
        created_at as created_at_utc, 
        updated_at  as updated_at_utc,
        address_id
    from users_source 
)


select * from renamed