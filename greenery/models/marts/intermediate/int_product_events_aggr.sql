-- model: int_product_events_aggr.sql
{{ config( materialized='table' ) }}

-- Call to macro get_event_types_macro() (--> calls get_column_values()) to return 
-- a LIST (not dict) of event types and set variable.
{% set event_types = get_event_types_macro() %}

-- number of page_view and add_to_cart event types per product 
-- checkout and shipping events are not associated with a product in the events relation
with num_event_type_per_product as (
  select 
      e.product_id,
      -- to iteract through the list ( dont use "for event_type in event_types['event_type']"")
      {% for event_type in event_types %}
        sum(case when event_type = '{{event_type}}' then 1 else 0 end) as product_num_{{event_type}}
      -- to avoid trailing comma problems: use if stmt as below
      {% if not loop.last %},{% endif %}
      {%  endfor %}
  from {{ ref('greenery', 'stg_greenery__events') }} e
  where e.product_id is not null
  group by e.product_id
)

-- aggregating by product
select 
  e.product_id,
  pecs.product_name,
  e.product_num_page_view,
  e.product_num_add_to_cart,
  pecs.quantity_sold,
  pecs.expected_revenue_usd,
  pecs.num_times_ordered as num_checkouts,
  pecs.num_users_ordered,
  pecs.last_ordered,
  -- Product_checkout_rate -- num_checkouts/num_add_to_cart
  (pecs.num_times_ordered::float/e.product_num_add_to_cart::float)::numeric(10,2) as product_checkout_rate,
  -- Product_conversion_rate -- num_product_checkouts/num_product_views
  (pecs.num_times_ordered::float/e.product_num_page_view::float)::numeric(10,2) as product_conversion_rate
from num_event_type_per_product e
left outer join {{ ref('greenery', 'int_products_per_order_aggr') }}   pecs
 on e.product_id = pecs.product_id
