{% macro get_event_types_macro() %}

    {{ return(get_column_values('event_type', ref('greenery', 'stg_greenery__events'))) }}

{% endmacro %}