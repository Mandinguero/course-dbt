# Course-dbt: Project Week 4
##### _(1) Using dbt snapshots_  

- Snapshot created and changes tracked

 ``` sql
{% snapshot orders_snapshot %}
  {{
    config(
      target_schema='snapshots',
      strategy='check',
      unique_key='order_id',
      check_cols=['status'] )
  }}
  SELECT * FROM {{ ref('greenery', 'stg_greenery__orders') }}
{% endsnapshot %}
```
- After updates, check for one of the udpated orders:
```sql
select tracking_id, shipping_service, estimated_delivery_at, status, dbt_valid_from, dbt_valid_to
from dbt.snapshots.orders_snapshot
where order_id = '914b8929-e04a-40f8-86ee-357f2be3a2a2';

tracking_id         shipping_service    estimated_delivery_at   status      dbt_valid_from      dbt_valid_to
 (NULL)                 (NULL)              (NULL)              preparing   2022-06-30 21:52:51.634283  2022-06-30 22:02:22.799833
a807..bd75f             ups             2021-02-19 10:15:26     shipped     2022-06-30 22:02:22.799833      (NULL)

```

##### _(2)  Product Funnel_  

- **62%** of sessions with a ``page_view`` event have at least one ``add_to_cart`` event
-- For greenery this value is also the overall ``add_to_cart`` rate, since any session generates at least a page view, so all sesssions have ``page_view`` events (578)

- **77%** of the sessions that add something to the cart generate a ``checkout`` event 

__Overall site session funnel:__
```sql
with event_types_counts as (
  select
    count(*) as total_num_sessions,
    (sum(case when page_view_num_events > 0 then 1 else 0 end))::numeric as sessions_with_pageview,
    (sum(case when add_to_cart_num_events > 0 then 1 else 0 end))::numeric as sessions_with_cart,
    (sum(case when checkout_num_events > 0 then 1 else 0 end))::numeric as sessions_with_checkout
  from dbt.dbt_iran_r.fact_sessions
),
greenery_session_funnel as (
  select 
      total_num_sessions as session_with_any_events,
      round((sessions_with_checkout / sessions_with_pageview),2) as page_view_to_cart_rate,
      round((sessions_with_checkout / sessions_with_cart),2) as cart_to_checkout_rate
      
    from event_types_counts
)

select * from greenery_session_funnel 
A:
session_with_any_events: 578
page_view_to_cart_rate:  0.62
cart_to_checkout_rate:  0.77
```
__Product conversion rates/Product funnel:__
- Model ``fact_products_events`` implements conversion rates/product funnel for each product
- Model ``overall_product_funnel`` implements greenery overall conversion rates/product funnel



###### _(3A-1) if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?_
-  Dbt allows the organization to implement good software development practices when working with *data*. It is amazing to be able to easily have a large team collaborating on a data project and managing sql code in a version control system such as git. 
-  Also the fact that each developer can have their own version of the data to work with, facilitated by the data sharing features of data platforms such as snowflake at minimum cost can be very empowering. 
-  Moving to a modern data stack as made possible by dbt and snowflake also makes it much easier to overcome data silos within the organization. This makes the establishment of a *"true"* single source of "truth" more likely to succeed.


###### _(3A-2)  if your organization is using dbt, what are 1-2 things you might recommend based on learning from this course?_
- The development of and commitment to best practices is clearly important for the success of a project using dbt. It may be quite easy to go down a road marked by lots of repeated code, incorrectly documented models, and super convoluted dags.
- Breaking the DRY best practice rule may be especially high when designing *intermediate models*. They are also important to implementing true data sharing and overcoming organizational data silos: it may be easier to go down a path where different groups produce their own "version of the truth." 
- Automating and orchestrating data loads, tests, etc. For example, without successful orchestration it may be possible - when loading data from different sources - to end up with temporarily inconsistent data in the platform.


