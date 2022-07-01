{{ config( materialized='table' ) }}

with sessions_aggregate as (
  select 
      es.session_id,
      es.user_id,
      u.user_first_name,
      u.user_last_name,
      CASE when es.num_session_orders > 0 then TRUE else FALSE END as order_placed,
      es.num_events_in_session,
      es.page_view_num_events,
      es.add_to_cart_num_events,
      es.checkout_num_events,
      es.num_products_viewed,
      es.session_start_at,
      es.session_duration,
      es.no_checkout_session
      -- age(es.session_end,es.session_start) as session_length

from {{ ref('int_sessions_users_aggr')}} es
left join {{ ref('dim_users')}} u 
  on u.user_id = es.user_id
)

select * from sessions_aggregate

