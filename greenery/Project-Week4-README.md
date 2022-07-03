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



##### _(3) Why might certain products be converting at higher/lower rates than others?_
- Product landing page may need improvement
- Promotions or other forms of increased visibility may improve the conversion rate of some products

##### _(4)  Create a macro to simplify part of a model(s)_
- Added the generic macro ```get_column_values```
- Added the specific macro ```get_event_types_macro```
- Refactored the model ```int_session_event_types```


