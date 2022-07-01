-- model: dim_users.sql
-- Should have one row per user_id and contain all the relevant dimensions/features about the users. 
-- It instantiates the denormalization of all the relevant tables that contain user information.
-- i.e. address, city, state, country, first_name, Last_name, user_id, pronoun, marital_status, preferred_user, gender, etc.
-- It should be the "source of truth" for information about users.  
-- other possible fields: 
--- first_time_customer: indicates if the user has purchased before
--- has_cancelled: indicates if the user has cancelled orders in the past
-- 



{{ config( materialized='table' ) }}

-- get user basic info and address info
with user_address as (
SELECT
  -- User information
  u.user_id,
  u.user_email,
  u.user_first_name,
  u.user_last_name,
  u.user_phone_number,
  u.user_created_at_utc,
  u.user_updated_at_utc, 
  date_trunc('day', u.user_created_at_utc) AS user_created_date,
  date_trunc('day', u.user_updated_at_utc) AS user_updated_date,

  -- Address information
  a.address as user_address,
  a.zipcode as user_zipcode,
  a.state as user_state,
  a.country as user_country

FROM {{ ref('stg_greenery__users') }} u
LEFT JOIN {{ ref('stg_greenery__addresses') }} a
  ON u.address_id = a.address_id

),

-- Order history information
-- join user and user_address information with user order aggregated values
user_orders as (
SELECT 
    ua.user_id,
    ua.user_email,
    ua.user_first_name,
    ua.user_last_name,
    ua.user_phone_number,
    ua.user_created_at_utc,
    ua.user_updated_at_utc, 
    ua.user_created_date,
    ua.user_updated_date,
    -- 
    uo.num_orders_made, 
    uo.first_order_timestamp_utc,
    uo.last_order_timestamp_utc,
    uo.avg_order_cost_usd,
    uo.lifetime_order_amount_usd,
    uo.num_distinct_products_pruchased, 
    uo.num_items_purchased
FROM user_address ua
LEFT JOIN {{ ref('greenery', 'int_user_orders_aggr') }} uo 
 ON ua.user_id = uo.user_id

)

select * from user_orders

