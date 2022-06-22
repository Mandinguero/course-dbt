{% macro cents_to_dollars(column_name, scale=2) %}
    ( {{ column_name }} )::numeric(16, {{ scale }})
{% endmacro %}
