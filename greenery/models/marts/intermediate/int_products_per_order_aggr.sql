
{{ config( materialized='table' ) }}

with products_per_order as (
    select
        o.order_id,
        u.user_id,
        p.product_id,
        p.product_name,
        p.product_price_usd,
        oi.quantity as product_qty,
        o.order_created_utc
    from {{ ref('greenery', 'fact_orders')}} o
    left join {{ ref('greenery', 'stg_greenery__order_items')}} oi      on oi.order_id = o.order_id
    left join {{ ref('greenery', 'dim_products')}} p                    on oi.product_id=p.product_id
    left join {{ ref('greenery', 'dim_users')}} u                       on o.user_id=u.user_id
    group by 1,2,3,4,5,6,7
    order by 1
),

pivoted_to_product_and_aggregated as (
  select 
      product_id,
      product_name,
      sum(product_qty) as quantity_sold,
      sum(product_price_usd * product_qty)::numeric(10,2)  as expected_revenue_usd,
      count(distinct order_id) as num_times_ordered,
      count(distinct user_id) as num_users_ordered,
      max(order_created_utc) as last_ordered
      from products_per_order
  group by 1,2
  order by 2
)

select * from pivoted_to_product_and_aggregated

