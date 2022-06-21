
-- setting vars at top helps with readability, and enables multiple references in the code.
-- var calls a m.acro
{% set payment_methods = get_payment_methods_modular() %}


select 
    order_id,
    sum(amount) as total_amount,
    {% for payment_method in payment_methods %}
        sum(case when payment_method = '{{payment_method}}' then amount end) as {{payment_method}}_amount
    -- to avoid trailing comma problems: use if stmt as below
    {% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('raw_payments') }}
group by 1

