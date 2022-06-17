{{
  config(
    materialized='table'
  )
}}

SELECT
  u.user_id,
  u.email,
  u.first_name,
  u.last_name,
  -- u.birth_date,
  -- u.status,
  -- CASE
  --   WHEN u.status = 1 THEN 'Active'
  --   WHEN u.status = 3 THEN 'Banned'
  --   ELSE 'Other'
  -- END AS status_label,
  a.address as user_address,
  a.zipcode as user_zipcode,
  a.state as user_state,
  a.country as user_country,
  u.created_at_utc,
  u.updated_at_utc, 
  date_trunc('day', u.created_at_utc) AS created_date,
  date_trunc('day', u.updated_at_utc) AS updated_date
FROM {{ ref('stg_greenery__users') }} u
LEFT JOIN {{ ref('stg_greenery__addresses') }} a
  ON u.address_id = a.address_id

