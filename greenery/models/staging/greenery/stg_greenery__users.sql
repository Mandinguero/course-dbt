
{{ config (materialized='view')}}


with users_source as (
    select * from {{ source ('greenery', 'users') }}
)

, renamed_recast as (

 select 
        user_id, 
        first_name,
        last_name,
        email,
        phone_number,
        created_at, 
        updated_at,
        address_id
    from users_source 
)


select * from renamed_recast