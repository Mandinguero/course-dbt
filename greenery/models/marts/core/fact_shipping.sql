-- model: fact_shipping.sql
shipping_service
num_orders_shipped   -- uses orders
total_orders_usd      -- uses orders
total_shipping_costs_usd      -- uses orders
avg_delivery_time
rate_on_time_delivery


{{ config( materialized='table' )}}
select 
shipping_service
, count(*) orders_done
, sum(order_total) order_total
, sum(shipping_cost) shipping_costs

from {{ ref('greenery', 'int_orders_extended') }}

group by 1
order by 2 desc 

