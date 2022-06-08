{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with order_items as (

    select  
      order_id,
      product_id,
      quantity

    from {{ source ('greenery', 'order_items') }}
)
select * from order_items