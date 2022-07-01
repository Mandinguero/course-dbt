{% snapshot orders_snapshot %}

  {{
    config(
      target_schema='snapshots',
      strategy='check',
      unique_key='order_id',
      check_cols=['status']
    )
  }}

  SELECT * FROM {{ ref('greenery', 'stg_greenery__orders') }}

{% endsnapshot %}