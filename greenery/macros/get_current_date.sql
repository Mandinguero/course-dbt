{% macro get_current_date() %}

    {% set current_date_query %}
        select current_date
    {% endset %} 

    {% set results = run_query(current_date_query) %}

    -- now print results to stdout
    {{ log("Running the get_current_date macro:", info=true) }}
    {{ log(results, info=true) }}

    -- use execute variable to ensure that this part of code runs 
    -- during the parse stage of dbt (or error will occur)
    {% if execute %}
        {% set results_list = results.columns[0].values() %}
    {% else %}
        {% set results_list = [] %}
    {% endif %}

    {{ return(results_list) }}

{% endmacro %}
