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

tracking_id         shipping_service    estimated_delivery_at   status  dbt_valid_from  dbt_valid_to
 (NULL)                 (NULL)              (NULL)              preparing   2022-06-30 21:52:51.634283  2022-06-30 22:02:22.799833
a807fe66-d8b1-4d38-b409-558fed8bd75f    ups 2021-02-19 10:15:26 shipped 2022-06-30 22:02:22.799833  (NULL)

```

##### _(2)  Product Funnel_  
- Conversion rate by product was implemented in the model: ```_int_product_events_aggr_```
- Conversion rate range: 

```sql
with event_types_counts as (
  select
    count(*) as total_num_sessions,
    (sum(case when page_view_num_events > 0 then 1 else 0 end))::numeric as sessions_with_pageview,
    (sum(case when add_to_cart_num_events > 0 then 1 else 0 end))::numeric as sessions_with_cart,
    (sum(case when checkout_num_events > 0 then 1 else 0 end))::numeric as sessions_with_checkout
  from dbt.dbt_iran_r.fact_sessions
),
session_funnel as (
  select 
      total_num_sessions as session_with_any_events,
      round((sessions_with_checkout / sessions_with_pageview),2) as page_view_to_cart_rate,
      round((sessions_with_checkout / sessions_with_cart),2) as cart_to_checkout_rate
      
    from event_types_counts
)

select * from session_funnel 
A:
session_with_any_events: 578
page_view_to_cart_rate:  0.62
cart_to_checkout_rate:  0.77

```

##### _(3) Why might certain products be converting at higher/lower rates than others?_
- Product landing page may need improvement
- Promotions or other forms of increased visibility may improve the conversion rate of some products

##### _(4)  Create a macro to simplify part of a model(s)_
- Added the generic macro ```get_column_values```
- Added the specific macro ```get_event_types_macro```
- Refactored the model ```int_session_event_types```


##### _(5) Add a post-hook to your project to apply grants to the role “reporting”._

- ```end-of-run``` hook added to the project
- ```Post-hook``` added to the project

```sh
# create to new roles
gitpod /workspace/course-dbt/greenery $ psql
postgres=# create role test_for_hooks;
CREATE ROLE
postgres=# create role reporting;
CREATE ROLE

# list existing roles
postgres=# \du
                                      List of roles
   Role name    |                         Attributes                         | Member of 
----------------+------------------------------------------------------------+--------
 gitpod         | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 reporting      | Cannot login                                               | {}
 test_for_hooks | Cannot login                                               | {}


# On file: dbt-project.yml:
(..)
models:
  greenery:
    Post-hook:
      - "GRANT SELECT ON {{ this }} TO reporting"
  
on-run-end:
 - "GRANT USAGE ON SCHEMA {{ schema }} TO reporting
(..)
```

##### _(6) Install a package and apply macros to your project_

- ```dbt-utils``` installed
- Using ```dbt-utils.get_query_results_as_dict``` on model: ```int_session_event_types```
