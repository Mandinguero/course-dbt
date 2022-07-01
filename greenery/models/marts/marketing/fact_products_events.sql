-- model: fact_products_events.sql


{{  config(  materialized='table' ) }}

with aggregated_and_pivoted_to_product as (
  select
      ip.product_id,
      ip.product_name,
      ip.product_num_page_view,
      ip.product_num_add_to_cart,
      ip.num_checkouts,

      -- product add_to_cart rate: num_times_added_to_cart/num_times_viewed_on_page
      round((ip.product_num_add_to_cart::numeric / ip.product_num_page_view::numeric), 2) as view_to_cart_rate,

      -- product order_rate: num_times_ordered/num_times_viewed_on_page
      round((ip.num_checkouts::numeric / ip.product_num_page_view::numeric) ,2) as order_rate,
      
      -- product abandonment rate:  (1 - (Num_times_checkout / num_times_add_to_cart))
      -- rate in which a product purchase was not completed (abandoned in the cart)
      (ip.product_num_add_to_cart - ip.num_checkouts ) as num_times_abandoned,
      round(1 - (ip.num_checkouts::numeric / ip.product_num_add_to_cart),2) as abandonment_rate

  from {{ ref('int_product_events_aggr')}} ip
  left join {{ ref('dim_products')}} p
    on p.product_id = ip.product_id
)

select * from aggregated_and_pivoted_to_product
