{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with order_items_source as (
    select * from {{ source ('greenery', 'order_items') }}
)

, renamed as (
 select 
      order_id,
      product_id,
      quantity

  from order_items_source 
)

select * from renamed