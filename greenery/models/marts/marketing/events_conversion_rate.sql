
-- overall conversion rate: is a single value
with base as (
select 
  sum(page_view_present)::float as num_page_views,
  sum(checkout_present)::float as num_checkouts
from {{ ref('greenery', 'int_session_event_types') }} 
)
select 
  num_checkouts  as total_number_checkouts, 
  num_page_views as total_number_page_views, 
  (num_checkouts/num_page_views)::numeric(10,2) as overall_conversion_rate
from base