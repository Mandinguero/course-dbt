{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with promos as (

    select  
        promo_id,
        discount,
        status 

    from {{ source ('greenery', 'promos') }}
)
select * from promos

