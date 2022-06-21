{% macro get_payment_methods_qry() %}

    {% set payment_methods_query %}
        select distinct payment_method
        from {{ ref('raw_payments') }}
        order by 1
    {% endset %} 

    -- now run query and store on a variable
    -- use the built-in run_query macro for this
    -- The result is in Agate Table format: not good for processing
    {% set results = run_query(payment_methods_query) %}

    -- now print results to stdout
    {{ log("Running the get_payment_methods_qry macro:", info=true) }}
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
