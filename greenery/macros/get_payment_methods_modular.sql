{% macro get_payment_methods_modular() %}

    {{ return(get_column_values('payment_method', ref('raw_payments'))) }}

{% endmacro %}