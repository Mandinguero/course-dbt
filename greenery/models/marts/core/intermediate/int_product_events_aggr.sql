-- model: int_product_events_aggr.sql
/* cols:
Product_num_add_to_cart
Product_num_shipments -- package_shipped
product_num_page_views
product_num_checkouts
Product_checkout_rate -- num_checkouts/num_add_to_cart
Product_conversion_rate -- num_product_views/num_product_checkouts
*/


{% set event_types = 
    dbt_utils.get_query_results_as_dict("select distinct event_type from" ~ ref('greenery','stg_greenery__events'))  %}

-- number of page_view and add_to_cart event types per product 
-- checkout and shipping events are not associated with a product in the events relation
with num_event_type_per_product as (
  select 
      e.product_id,
      {% for event_type in event_types['event_type'] %}
        sum(case when event_type = '{{event_type}}' then 1 else 0 end) as product_num_{{event_type}}
      -- to avoid trailing comma problems: use if stmt as below
      {% if not loop.last %},{% endif %}
      {%  endfor %}
  from {{ ref('greenery', 'stg_greenery__events') }} e
  where e.product_id is not null
  group by e.product_id
),

product_events_checkout_shipped as (
  select
    product_id, 
    num_checkouts,
    num_package_shipped
  from {{ ref('greenery', 'int_product_events_checkout_shipped') }} 
)

 
-- list number of
select
  e.product_id,
  e.product_num_page_view,
  e.product_num_add_to_cart,
  pecs.num_checkouts,
  pecs.num_package_shipped,
  -- Product_checkout_rate -- num_checkouts/num_add_to_cart
  (pecs.num_checkouts::float/e.product_num_add_to_cart::float)::numeric(10,2) as product_checkout_rate,
  -- Product_conversion_rate -- num_product_checkouts/num_product_views
  (pecs.num_checkouts::float/e.product_num_page_view::float)::numeric(10,2) as product_conversion_rate
from num_event_type_per_product e
left outer join product_events_checkout_shipped pecs
 on e.product_id = pecs.product_id
