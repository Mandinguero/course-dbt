-- model: stg_greenery__events.sql

{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with events as (

    select  
        event_id,
        session_id,
        user_id,
        page_url,
        created_at,
        event_type,
        order_id,
        product_id

    from {{ source ('greenery', 'events') }}
)
select * from events