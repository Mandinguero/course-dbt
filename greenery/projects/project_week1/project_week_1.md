# Course-dbt: Project Week 1 
#### _(1) How many users do we have?_  

``` sql
select count(*) as number_of_users from dbt_iran_r.stg_greenery__users;
A: 130
```
#### _(2) On average, how many orders do we receive per hour?_  
``` sql
-- Average number of orders per hour
with orders_per_day_hour as (
  select date_part('day', created_at )||'/'|| date_part('hour', created_at ) as day_hour,  
          count(*) as num_orders
  from dbt_iran_r.stg_greenery__orders
  group by date_part('day', created_at )||'/'|| date_part('hour', created_at ) 
)
select avg(num_orders)::numeric(10,2) from orders_per_day_hour;
A: 7.52
```

#### _(3) On average, how long does an order take from being placed to being delivered?_
``` sql
-- how long (in secs) between order creation and delivery?
-- considering only delivered orders
with avg_time_to_deliver_secs as (
  select avg(extract(epoch from (delivered_at  - created_at ))) time_secs 
  from dbt_iran_r.stg_greenery__orders
  where status = 'delivered'
),
-- 24*60*60 = 86400secs/day
avg_days_to_deliver as (
  select (time_secs/86400)::numeric(10,2) as time_days 
  from avg_time_to_deliver_secs
)

select * from avg_days_to_deliver;
A: 3.89 days
```

#### _(4) How many users have only made one purchase? Two purchases? Three+ purchases?_
``` sql
-- users and number of orders made
-- considering each order as a purchase
with orders_per_user as (
  select user_id, count(*) num_orders
  from dbt_iran_r.stg_greenery__orders
  group by user_id
),

-- users that made 1 or 2 orders
order_ranking12 as (
  select num_orders, count(*) as num_users
  from orders_per_user
  where num_orders in (1,2)
  group by num_orders
),

-- users that made 3 or more orders
order_ranking3plus as (
  select  count(*) as num_users
  from orders_per_user
  where num_orders > 2
)

select num_orders::char, num_users from order_ranking12
union all
select '3+', num_users from order_ranking3plus;

A: 
Num_orders	num_users
1		25
2		28
3+		71
```

#### _(5) On average, how many unique sessions do we have per hour?_
``` sql
-- list the distinct sessions in each day/hour
with distinct_sessions_per_day_hour as (
  select  distinct session_id, 
          date_part('day', created_at )||'/'|| date_part('hour', created_at ) as day_hour
  from dbt_iran_r.stg_greenery__events
),

-- count the distinct sessions in each hour
num_distinct_sessions_per_day_hour as (
  select day_hour, count(session_id) as num_distinct_sessions
  from distinct_sessions_per_day_hour
  group by day_hour
)

-- get the average number of unique sessions per hour
select avg(num_distinct_sessions)::numeric(10,2) 
from num_distinct_sessions_per_day_hour;

A:
16.33
```