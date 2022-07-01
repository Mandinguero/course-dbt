
-- model: int_product_events_checkout_shipped

{{ config( materialized='table' ) }}

-- sessions that checked out products 
with sessions_that_checked_out_product as (
select distinct
    e.session_id, 
    e.product_id,
    'checkout'  as action_type
from {{ ref('greenery', 'stg_greenery__events') }}  e
where e.session_id in (
  select distinct session_id 
  from {{ ref('greenery', 'stg_greenery__events') }}
  where event_type = 'checkout' )
and e.product_id is not null
),

-- number of checkout per product_id
number_checkout_per_product as (
select product_id, count(session_id) as num_checkouts
from sessions_that_checked_out_product
group by product_id
order by product_id
),

-- sessions that shipped product
sessions_that_shipped_product as (
select distinct
    e.session_id, 
    e.product_id,
    'package_shipped'  as action_type    
from {{ ref('greenery', 'stg_greenery__events') }}  e
where e.session_id in (
  select distinct session_id 
  from {{ ref('greenery', 'stg_greenery__events') }}
  where event_type = 'package_shipped' )
and e.product_id is not null
),

-- number of package_shipped per product_id
number_package_shipped_per_product as (
select product_id, count(session_id) as num_package_shipped
from sessions_that_shipped_product
group by product_id
)


select 
    p.product_id, 
    ncpp.num_checkouts,
    npspp.num_package_shipped
from {{ ref('greenery', 'stg_greenery__products') }} p
left join number_checkout_per_product ncpp
  on p.product_id = ncpp.product_id
left join number_package_shipped_per_product npspp
 on ncpp.product_id = npspp.product_id
