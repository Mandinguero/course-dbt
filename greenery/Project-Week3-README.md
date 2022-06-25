# Course-dbt: Project Week 3
##### _(1) What is our user repeat rate?_  

- Overall conversion rate = (# of unique sessions with a purchase event / 
total number of unique sessions)
- Overall conversion rate was implemented in the model: events_conversion_rate
- The SQL used is:
 ``` sql
with base as (
select
 sum(page_view_present)::float as num_page_views,
 sum(checkout_present)::float as num_checkouts
from dbt_iran_r.int_session_event_types
)
select
 num_checkouts, num_page_views,
 (num_checkouts/num_page_views)::numeric(10,2) as overall_conversion_rate
from base
 
Answer:
Num_checkouts:			    361
Num_page_views:		        578
Overall_conversion_rate:	0.62
```

##### _(2)  What are the product conversion rates?_  
- Conversion rate by product was implemented in the model: ```_int_product_events_aggr_```
- Conversion rate range: 

```sql
with rate_range as (
 select
    product_id, product_conversion_rate, 'max' as rank_conversion_rate
 from dbt_iran_r.int_product_events_aggr
 where product_conversion_rate = (
    select max(product_conversion_rate) from dbt_iran_r.int_product_events_aggr)
 union
 select
   product_id, product_conversion_rate, 'min' as rank_conversion_rate
 from dbt_iran_r.int_product_events_aggr
where product_conversion_rate = (
   select min(product_conversion_rate) from dbt_iran_r.int_product_events_aggr)
)
 
select p.product_name, r.product_conversion_rate, r.rank_conversion_rate
from dbt_iran_r.stg_greenery__products p
inner join rate_range r
on p.product_id = r.product_id;
 
A:
product_name		product_conversion_rate rank_conversion_rate
Monstera		    0.88				    max
String of pearls	0.88			    	max
Alocasia Polly	    0.63				    min
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
