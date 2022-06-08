-- model: stg_greenery__orders.sql

{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with orders_source as (
    select * from {{ source ('greenery', 'orders') }}
)

, renamed as (
    select 
        -- ids
        order_id,
        user_id,
        promo_id,
        address_id,
        tracking_id,

        -- numerics
        order_cost,
        shipping_cost,
        order_total,
        
        shipping_service,
        
        -- timestamps
        created_at,
        estimated_delivery_at,
        delivered_at,
        
        -- dates
        date_trunc('day', created_at) as created_date,
        
        status

    from orders_source 
)

select * from renamed