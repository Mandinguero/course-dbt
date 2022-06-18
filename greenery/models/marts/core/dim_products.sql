-- model: dim_products.sql
product_id
product_name
product_price_usd
product_inventory
product_is_out_of_stock
-- calculated
product_date_most_recently_sold -- uses orders and order_items
product_total_num_purchases     -- uses orders and order_items
product_repurchase_rate -- num_repeated_purchases/total_num_purchases
