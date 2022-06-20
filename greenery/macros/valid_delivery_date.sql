{% test valid_delivery_date(model, column_name) %}


   select *
   from {{ model }}
   where {{ column_name }} < created_at


{% endtest %}