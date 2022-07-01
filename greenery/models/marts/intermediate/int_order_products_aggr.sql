-- model: int_order_products_aggr.sql
-- derives aggregates for each order (num of items, num distinct products)
{{ config( materialized='table' ) }}

with order_counts as (
  select
    order_id, 
    count(product_id) AS num_distinct_products,
    sum(quantity)     AS num_items
  from {{ ref('greenery','stg_greenery__order_items') }}  
  group by order_id
)
select * from order_counts
