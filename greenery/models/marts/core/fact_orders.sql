-- model: fact_orders.sql

{{ config( materialized='table' ) }}

SELECT
  o.order_id,
  o.created_at      as order_created_utc,
  o.created_date    as order_created_date,
  o.tracking_id     as order_tracking_id,
  o.estimated_delivery_at as estimated_delivery_at_utc,
  o.delivered_at    as delivered_at_utc,     
  o.status          as order_status,
  CASE
    WHEN (o.status = 'delivered' AND
          (date_part('day',(delivered_at - estimated_delivery_at))> 0)) THEN 'late'
    WHEN (o.status = 'delivered' AND
          (date_part('day',(delivered_at - estimated_delivery_at))= 0)) THEN 'on-time'
    WHEN (o.status = 'delivered' AND
          (date_part('day',(delivered_at - estimated_delivery_at))< 0)) THEN 'early'
    ELSE 'N/A'
  END delivery_status,
  o.delivered_at - o.created_at AS days_to_deliver,

  -- numerics
  o.order_cost        as order_cost_usd,
  o.shipping_cost     as shipping_cost_usd,
  o.order_total       as order_total_usd,
  o.shipping_service  as order_shipping_service,

  -- user information
  u.user_id,
  u.user_first_name,
  u.user_last_name,

  -- promo information
  p.discount as order_promo_discount,

  -- delivery information
  a.address as order_delivery_address,
  a.zipcode as order_delivery_zipcode,
  a.state   as order_delivery_state,
  a.country as order_delivery_country

  -- order aggregates

FROM {{ ref('stg_greenery__orders') }} o
LEFT JOIN {{ ref('stg_greenery__users') }} u
  ON o.user_id = u.user_id
LEFT JOIN {{ ref('stg_greenery__promos') }}  p
  ON o.promo_id = p.promo_id
LEFT JOIN  {{ ref('stg_greenery__addresses') }} a
  ON o.address_id = a.address_id
LEFT JOIN  {{ ref('int_order_products') }} op
  ON o.order_id = op.order_id