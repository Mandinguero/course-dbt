
-- model: int_user_orders.sql -- generates aggregate values associated with the user orders
-- generates: 
--- Additive values - can be rolled up. (i.e. amount_sold, quantity_sold)
--- Semiadditive - can be added only along some of the dimensions
--- Nonadditive - Cannot be added.. Averages and counts are possible.
-- other possible fields:
--- has_purchased: indicates if the user has purchased before
--- has_cancelled: indicates if the user has canceled orders in the past (improvement suggestion)
--- num_orders_made
--- avg_num_order_items
--- first_order_timestamp_utc
--- last_order_timestamp_utc
--- avg_order_cost_usd
--- lifetime_order_amount_usd


-- get aggregates four order history (count, first order, last order, lifetime order amount)
with user_orders_aggregate as (
  select 
    user_id,
    count(distinct order_id) num_orders_made, 
    min(created_at) first_order_timestamp_utc,
    max(created_at) last_order_timestamp_utc,
    avg(order_cost)::numeric(10,2) avg_order_cost_usd,
    sum(order_total)::numeric(10,2) lifetime_order_amount_usd
 
  from {{ ref('greenery', 'stg_greenery__orders') }}
  group by user_id 
),

-- get number of distinct products and total number of items purchased
user_order_items_aggr as (
    select o.user_id, 
          count(oi.product_id)   as num_distinct_products_pruchased, 
          sum(oi.quantity)       as num_items_purchased

    from {{ ref('greenery', 'stg_greenery__orders') }} o
    left join {{ ref('greenery', 'stg_greenery__order_items') }} oi
      on o.order_id = oi.order_id 
    group by o.user_id
)

select 
    uoa.user_id,
    uoa.num_orders_made, 
    uoa.first_order_timestamp_utc,
    uoa.last_order_timestamp_utc,
    uoa.avg_order_cost_usd,
    uoa.lifetime_order_amount_usd,
    uoia.num_distinct_products_pruchased, 
    uoia.num_items_purchased
from user_order_items_aggr uoia
left join user_orders_aggregate uoa
  on uoia.user_id = uoa.user_id