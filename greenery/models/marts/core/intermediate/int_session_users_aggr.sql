-- model: int_session_users_aggr.sql

{{ config( materialized='table' ) }}
{% set event_types = 
    dbt_utils.get_query_results_as_dict("select distinct event_type from" ~ ref('greenery','stg_greenery__events'))  %}

-- int_session_users_aggr.sql
with sessions_aggregated as (
  select 
    session_id, 
    user_id,
    min(created_at) session_start_at,
    max(created_at) session_stop_at,
    -- product_id can be null for checkout and package_shipped events
    count(distinct product_id) products_touched, 
    
    -- iteract through the event types to build a case statement
    {% for event_type in event_types['event_type'] %}
       count(case when event_type = '{{event_type}}' then 1 else 0 end) as {{event_type}}_num_events
    -- to avoid trailing comma problems: use if stmt as below
    {% if not loop.last %},{% endif %}
    {%  endfor %}

  FROM {{ ref('greenery', 'stg_greenery__events') }} e
  group by 1,2
)

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

 from sessions_aggregated e