-- test on stg_greenery__orders
-- delivery date (delivery_at) should be posterior to order creation date (created_at)
select * 
from  {{ ref ('greenery','stg_greenery__orders')}}
where delivered_at < created_at