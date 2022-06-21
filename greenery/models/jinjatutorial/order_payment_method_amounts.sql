-- model
/* Problems with this model: 
-- if the logic or field name were to change, the code would need updates in 3 places.
-- often this code is created with copy/paste, which may lead to mistakes
-- people often only scan through repeated code, so it is harder to find mistakes
-- you need a "DRY" approach: dont reapeat yourself!
*/

{{ config (materialized='table') }}
select  
    order_id,
    sum(case when payment_method = 'bank_transfer' then amount end) as bank_transfer_amount, 
    sum(case when payment_method = 'credit_card' then amount end) as credit_card_amount,
    sum(case when payment_method = 'gift_card' then amount end) as gift_card_amount,
    sum(amount) as total_amount
    from {{ ref('raw_payments') }}
    group by 1