-- model: fact_shipping.sql


{{ config( materialized='table' )}}
with shipping_aggr as (
select 
    shipping_service,
    count(*)              as num_orders_shipped,
    sum(order_total)      as order_total_usd,
    sum(shipping_cost)    as shipping_costs_usd,
    date_part('day',avg(delivered_at - created_at))  as avg_delivery_days,
    avg(delivered_at - created_at)  as avg_delivery_time,
    SUM (
    CASE WHEN delivered_at > estimated_delivery_at  THEN 1
	  ELSE 0
	  END
	      ) AS "delivered_late",
	  SUM (
		CASE WHEN delivered_at <= estimated_delivery_at  THEN 1
		ELSE 0
		END
	      ) AS "delivered_on_time"

from {{ ref('greenery', 'stg_greenery__orders') }}
group by 1
)

select 
  s.*,
    CASE WHEN (s.delivered_on_time + s.delivered_late)>0  
         THEN (s.delivered_on_time::float/(s.delivered_on_time::float + s.delivered_late::float))::numeric(10,2)
	  ELSE 0
	  END AS timely_delivery_pct
from shipping_aggr s


