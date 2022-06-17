
{{ config( materialized='table' ) }}

SELECT
  o.order_id,
  o.created_at      as order_created_utc,
  o.created_date    as order_created_date,
  o.tracking_id,
  o.estimated_delivery_at,
  o.delivered_at,     
  o.status,
  o.delivered_at - o.created_at AS days_to_deliver,

  -- numerics
  o.order_cost,
  o.shipping_cost,
  o.order_total,
  o.shipping_service,

  -- user information
  u.user_id,
  u.first_name,
  u.last_name,

  -- promo information
  p.discount as order_promo_discount,

  -- delivery information
  a.address as order_delivery_address,
  a.zipcode as order_delivery_zipcode,
  a.state   as order_delivery_state,
  a.country as order_delivery_country

FROM {{ ref('stg_greenery__orders') }} o
LEFT JOIN {{ ref('stg_greenery__users') }} u
  ON o.user_id = u.user_id
LEFT JOIN {{ ref('stg_greenery__promos') }}  p
  ON o.promo_id = p.promo_id
LEFT JOIN  {{ ref('stg_greenery__addresses') }} a
  ON o.address_id = a.address_id