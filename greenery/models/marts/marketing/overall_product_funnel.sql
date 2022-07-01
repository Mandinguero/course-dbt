

{{ config( materialized='view' ) }}
with event_types_counts as (
  select
    count(*) as total_num_sessions,
    (sum(case when page_view_num_events > 0 then 1 else 0 end))::numeric as sessions_with_pageview,
    (sum(case when add_to_cart_num_events > 0 then 1 else 0 end))::numeric as sessions_with_cart,
    (sum(case when checkout_num_events > 0 then 1 else 0 end))::numeric as sessions_with_checkout
  from {{ ref ('greenery', 'fact_sessions') }} 
),
session_funnel as (
  select 
      total_num_sessions as num_sessions_with_any_events,
      round((sessions_with_checkout / sessions_with_pageview),2) as page_view_to_cart_rate,
      round((sessions_with_checkout / sessions_with_cart),2) as cart_to_checkout_rate
      
    from event_types_counts
)

select * from session_funnel 
