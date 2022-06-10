
-- model: stg_greenery_addresses.sql
-- best practices for staging: https://docs.getdbt.com/guides/best-practices/how-we-structure/2-staging

{{ config (materialized='view') }}

-- use a CTE to name all sources in the top of file
with addresses_source as (
    select * from {{ source ('greenery', 'addresses') }}
)

, renamed_recast as (
    select  
     address_id,
     address,
     zipcode,
     state,
     country

    from addresses_source 
)
select * from renamed_recast