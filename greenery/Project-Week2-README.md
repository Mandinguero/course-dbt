# Course-dbt: Project Week 2
##### _(1) What is our user repeat rate?_  

``` sql
--  Get the number of orders for each user
with orders_per_user as (
  select user_id,
         count(distinct order_id) as user_orders
  from dbt_iran_r.stg_greenery__orders
  group by 1
),
-- denormalize orders per user;
-- convert boolean -> int (cannot cast bool to float)
  users_bucket as (
  select user_id,
        (user_orders = 1)::int as ordered_once,
        (user_orders >= 2)::int as ordered_twice_plus
  from orders_per_user
)
-- get the Repeat Rate = Users who purchased 2+ times / users who purchased
-- subquery optional (convert int -> float back to get non-truncated rate
select (r.users_who_purchased_atleast_twice/r.users_who_purchased)::numeric(10,3) as repeat_rate
from (
  select count(user_id)::float as users_who_purchased,
       sum(ordered_twice_plus)::float as users_who_purchased_atleast_twice
  from users_bucket
) r;

A: 0.798
```
##### _(2)  What are good indicators of a user who will likely purchase again?_  
- Users who often had add_to_cart AND checkout events in the same session are likely to purchase again.
- Users with multiple purchases are more likely to return as well.
- Users who have a high rate of sessions_with_purchase/sessions_without_purchase

##### _(3)  What about indicators of users who are likely NOT to purchase again?_
- Users who had add_to_cart events but no checkout event in the same session are less likely to purchase again.
- Users with low rate of sessions_with_purchase/sessions_without_purchase (mostly browse without buying)

##### _(4)  If you had more data, what features would you want to look into to answer this question?_
- Users with high rate of order cancellation are less likely to buy again (needs order_cancelled status)
- Users with long delivery times may be less inclined to buy again (needs time to cancelation)
- Users who returned products are less likely to purchase again (need more order_returns information)

## _About Tests_
##### _(1) What assumptions are you making about each model? (i.e. why are you adding each test?)_

- Bad data should be identified as quickly and closer to its source as possible.
- We should test for uniqueness and not_null for all PK columns; 
- Tests should be performed as close to the sources as possible, which likely means in the staging layer.
- Derived/calculated values should be tested when there are clear requirements (i.e. lifetime_purchase_amount should not be a negative value). Similarly, counts, totals and prices probably should be tested as positive values.


##### _(Tests - 2) Did you find any “bad” data ?_

- no, but probably because I did not build enough tests on derived/calculated values.


##### _(Tests - 3) Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through_

- Storing failed tests.
