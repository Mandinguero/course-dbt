



with session_user_aggregate as (
select 
    e.session_id,
    e.user_id,
    e.session_start_at,
    e.session_stop_at,
    e.products_touched,
    e.add_to_cart_num_events,
    e.page_view_num_events,
    e.checkout_num_events,
    e.package_shipped_num_events,
    e.session_stop_at - e.session_start_at as session_duration,
    case when checkout_num_events = 0 then 1 else 0 end no_checkout_session

 from {{ ref('greenery', 'int_session_users_aggr') }}  e

)

select 
  avg(session_duration) as average_session_duration,
  avg(page_view_num_events) as average_number_page_views,
  max(page_view_num_events) as max_number_page_views,
  min(page_view_num_events) as min_number_page_views,
  count(session_id) as total_number_unique_sessions,
  count(no_checkout_session) as total_number_no_checkout_sessions
from session_user_aggregate


