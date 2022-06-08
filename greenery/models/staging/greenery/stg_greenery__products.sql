{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with products_source as (
    select * from {{ source ('greenery', 'products') }}
)

, renamed as (
    select  
      product_id,
      name as product_name,
      
      --numerics
      price,
      inventory

    from products_source 
)
select * from renamed