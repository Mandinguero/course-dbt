/* macros in jinja are pieces of code that can be called multiple times - functions
- very useful for DRY
- use the return function to return a list - without the function return, the macro would return a string.
*/

{% macro get_payment_methods() %}
{{ return(["bank_transfer", "credit_card", "gift_card"]) }}
{% endmacro %}

