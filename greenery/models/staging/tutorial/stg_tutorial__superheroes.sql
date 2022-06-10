
-- model: stg_grestg_tutorial__superheroes.sql
-- best practices for staging: https://docs.getdbt.com/guides/best-practices/how-we-structure/2-staging

{{ 
    config (
        materialized='table'
        )
}}

select 
 id as superhero_id,
 name,
 gender,
 eye_color,
 race,
 NULLIF(height, -99) as height_cm,
 NULLIF(weight, -99) as weight_lbs,
 {{ lbs_to_kgs('weight')  }} as weight_kg,
 publisher,
 skin_color,
 alignment
 
from {{ source ('tutorial','superheroes')}}

