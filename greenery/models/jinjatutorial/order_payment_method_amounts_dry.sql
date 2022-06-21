
-- setting vars at top helps with readability, and enables multiple references in the code.
{% set payment_methods = ["bank_transfer", "credit_card", "gift_card"] %}

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