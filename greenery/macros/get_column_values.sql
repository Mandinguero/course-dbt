

-- Modularizing macros: break the logic into two separate macros:
-- this one to generically return a column from a relation
-- another to call this macro with the correct column_name/relation_name as arguments


{% macro get_column_values(column_name, relation) %}

    -- define the query that will return a list of values
    {% set relation_query %}
       select distinct {{ column_name }} 
       from {{ relation }}
       order by 1
    {% endset %}    

    -- call run_query to execute the query and store results in variable
    {% set results = run_query(relation_query) %}

    -- add if to select code to only run during the dbt execute phase
    {% if execute %}
        {# Return the first column (values only, no labels or descriptives) #}
        {% set results_list = results.columns[0].values() %}
    {% else %}
        {% set results_list = [] %}       
    {% endif %}

    {{ return(results_list) }}

{% endmacro %}