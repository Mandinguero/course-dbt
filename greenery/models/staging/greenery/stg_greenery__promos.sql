{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with promos_source as (
    select * from {{ source ('greenery', 'promos') }}
)

, renamed as (

 select 
        promo_id,
        discount,
        status 
    from promos_source 
)


select * from renamed