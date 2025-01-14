-- model: stg_greenery__events.sql

{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with events_source as (
    select * from {{ source ('greenery', 'events') }}
)

, renamed as (
    
    select 
        event_id,
        session_id,
        user_id,
        page_url,
        created_at,
        event_type,
        order_id,
        product_id

    from events_source 
)

select * from renamed