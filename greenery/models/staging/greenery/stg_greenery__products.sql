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
      inventory,

      -- boolean
      case
        when inventory <= 0 then true 
        else false
      end as is_out_of_stock -- new derived table; should it be in the stg layer?

    from products_source 
)
select * from renamed