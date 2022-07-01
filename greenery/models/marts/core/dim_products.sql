-- model: dim_products.sql

-- basic product information
with product_base as (
  select 
    product_id,
    product_name,
    product_price_usd,
    product_inventory, 
    is_out_of_stock
from {{ ref ('greenery','stg_greenery__products') }}
),

-- product_total_quantity_sold
 product_quantity_sold as (
  select 
    oi.product_id,
    sum(oi.quantity) as product_total_quantity_sold
  from {{ ref ('greenery','stg_greenery__order_items') }} oi 
  group by oi.product_id
),

-- product_date_most_recently_sold
product_most_recent_sale as (
   select 
      oi.product_id,
      max(o.created_at) as product_date_most_recently_sold_at

   from {{ ref ('greenery','stg_greenery__orders') }} o
   left join {{ ref ('greenery','stg_greenery__order_items') }} oi
     on o.order_id = oi.order_id
   group by oi.product_id
),

-- product_repurchase_rate -- num_repeated_purchases/total_num_purchases
-- number of times each user bought each product 
 user_product_count as (
  select
    o.user_id,
    oi.product_id,
    count(oi.product_id) as product_count
  from {{ ref ('greenery','stg_greenery__orders') }} o
  left join {{ ref ('greenery','stg_greenery__order_items') }} oi
  on o.order_id = oi.order_id
  group by o.user_id, oi.product_id
),

product_repurchase_rate as (
  select
    product_id,
    sum (case when product_count = 1  then 1 else 0 end ) as "single_purchase",
	  sum (case when product_count > 1  then 1 else 0 end ) as "repeat_purchase"
  from user_product_count
  group by product_id
)

-- generate dim_product
select 
    -- from product_base
    pb.product_id,
    pb.product_name,
    pb.product_price_usd,
    pb.product_inventory, 
    pb.is_out_of_stock,

    -- from product_quantity_sold
    pqs.product_total_quantity_sold,

    -- product_date_most_recently_sold
    pmrs.product_date_most_recently_sold_at,

    -- product_repurchase_rate
    (prr.repeat_purchase::float / (prr.single_purchase + prr.repeat_purchase)::float)::numeric(10,2) as repurchase_rate

from product_base                 pb
left join product_quantity_sold  pqs
  on pb.product_id = pqs.product_id
left join product_most_recent_sale  pmrs
  on pb.product_id = pmrs.product_id  
left join product_repurchase_rate  prr
  on pb.product_id = prr.product_id  
