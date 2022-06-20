-- model: int_product_events.sql


-- int_product_events.sql
select 
  e.event_id,
  e.session_id,
  e.user_id,
  e.page_url,
  e.created_at,
  e.event_type,
  e.order_id,
  e.product_id,
  p.product_name,
  p.product_price_usd,
  p.product_inventory, 
  p.is_out_of_stock

from {{ ref('greenery', 'stg_greenery__events') }} e
left join {{ ref('greenery', 'stg_greenery__products') }} p 
  on p.product_id = e.product_id

