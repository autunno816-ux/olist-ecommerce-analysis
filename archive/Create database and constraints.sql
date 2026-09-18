CREATE TABLE IF NOT EXISTS customers (
customer_id VARCHAR(100),
customer_unique_id VARCHAR(100),
customer_zip_code_prefix INTEGER,
customer_city VARCHAR(100),
customer_state VARCHAR(100)
);

select * from customers limit 15;

CREATE TABLE IF NOT EXISTS orders (
order_id VARCHAR(100),
customer_id VARCHAR(100),
order_status VARCHAR(100),
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP
);

select * from orders limit 15;

CREATE TABLE IF NOT EXISTS order_items
order_id VARCHAR(100),
order_item_id VARCHAR(100),
product_id VARCHAR(100),
seller_id VARCHAR(100),
shipping_limit_date TIMESTAMP,
price DECIMAL(15,2),
freight_value DECIMAL(15,2)
);

select * from order_items limit 15;

CREATE TABLE IF NOT EXISTS order_payments (
order_id VARCHAR(100),
payment_sequential INTEGER,
payment_type VARCHAR(100),
payment_installments INTEGER,
payment_value DECIMAL(15,2)
);

select * from order_payments limit 15;

CREATE TABLE IF NOT EXISTS order_reviews (
review_id VARCHAR(100),
order_id VARCHAR(100),
review_score real,
review_comment_title VARCHAR(100),
review_comment_message VARCHAR(500),
review_creation_date TIMESTAMP,
review_answer_timestamp TIMESTAMP
);

select * from order_reviews limit 15;

CREATE TABLE IF NOT EXISTS products (
product_id VARCHAR(100),
product_category_name VARCHAR(100),
product_name_lenght INTEGER,
product_description_lenght INTEGER,
product_photos_qty INTEGER,
product_weight_g real,
product_length_cm real,
product_height_cm real,
product_width_cm real
);

select * from products limit 15;

CREATE TABLE IF NOT EXISTS sellers (
seller_id VARCHAR(100),
seller_zip_code_prefix VARCHAR(100),
seller_city VARCHAR(100),
seller_state VARCHAR(100)
);

select * from sellers limit 15;

CREATE TABLE IF NOT EXISTS geolocations(
geolocation_zip_code_prefix INTEGER,
geolocation_lat DECIMAL(10,4),
geolocation_lng DECIMAL(20,15),
geolocation_city VARCHAR(100),
geolocation_state VARCHAR(100)
);

select * from geolocations limit 15;

CREATE TABLE IF NOT EXISTS category_name (
product_category_name VARCHAR(100),
product_category_name_english VARCHAR(100)
);

select * from category_name limit 15;



SELECT
COUNT(*) AS total_rows,
COUNT(order_id) AS no_null_order_id,
COUNT(DISTINCT order_id) AS unique_order_id
FROM orders;

alter table orders
add primary key(order_id);

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT customer_id) AS unique_customer_id,
COUNT(customer_id) AS no_null_customer_id
FROM customers;

alter table customers
add primary key(customer_id);

SELECT
COUNT(*) AS total_rows,
COUNT(product_id) AS no_null_product_id,
COUNT(DISTINCT product_id) AS unique_product_id
FROM products;

alter table products
add primary key(product_id);

SELECT 
COUNT(*) AS total_rows,
COUNT(seller_id) AS no_null_seller_id,
COUNT(DISTINCT seller_id) AS unique_seller_id
FROM sellers;

alter table sellers
add primary key(seller_id);

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT order_id) AS unique_order_id,
COUNT(DISTINCT order_id) AS unique_order_item_id,
COUNT(DISTINCT (order_id, order_item_id)) AS unique_rows
FROM order_items;

alter table order_items
add primary key(order_id,order_item_id);

select count(*) as total_rows,
count(distinct order_id) as unique_order_id,
count(distinct payment_sequential) as unique_payment_sequential,
count(distinct (order_id,payment_sequential))
from order_payments

alter table order_payments
add primary key(order_id,payment_sequential);

SELECT
count(*) as total_rows,
count(review_id) as no_null_review_id,
count(distinct review_id) as unique_review_id,
count(distinct order_id) as unique_order_id,
count(distinct (review_id, order_id)) as unique_review_order_pair
from order_reviews;

alter table order_reviews
add primary key(order_id,review_id);

select
count(*) as total_rows,
count(product_category_name) as no_null_name,
count(distinct product_category_name) as unique_name
from category_name;

alter table category_name
add primary key(product_category_name);

select
count(*) as total_rows,
count(distinct geolocation_zip_code_prefix) as unique_zip_codes
from geolocations;



select count(*) as unmatched_customers
from orders as o
left join customers as c
on o.customer_id = c.customer_id
where c.customer_id is null;

alter table orders
add constraint fk_orders_customer
foreign key (customer_id)
references customers(customer_id);

select count(*) as unmatched_orders
from order_items as oi
left join orders as o
on oi.order_id = o.order_id
where o.order_id is null;

alter table order_items
add constraint fk_order_items_order
foreign key (order_id)
references orders(order_id);

select count(*) as unmatched_products
from order_items as oi
left join products as p
on oi.product_id = p.product_id
where p.product_id is null;

alter table order_items
add constraint fk_order_items_products
foreign key (product_id)
references products(product_id);

select * from order_items limit 10;

select count(*) as unmatched_products
from order_items as oi
left join sellers as s
on oi.seller_id = s.seller_id
where s.seller_id is null;

alter table order_items
add constraint fk_order_items_sellers
foreign key (seller_id)
references sellers(seller_id);

select * from order_payments limit 10;
select count(*) as unmatched_products
from order_payments as op
left join orders as o
on op.order_id = o.order_id
where o.order_id is null;

alter table order_payments
add constraint fk_order_payment_orders
foreign key(order_id)
references orders(order_id)

select * from order_reviews limit 10;
select count(*) as unmatched_products
from order_reviews as ors
left join orders as o
on ors.order_id = o.order_id
where o.order_id is null;

alter table order_reviews
add constraint fk_order_reviews_orders
foreign key (order_id)
references orders(order_id);

select * from products limit 10;
select count(*) as unmatched_products
from products as p
left join category_name as cn
on p.product_category_name = cn.product_category_name
where p.product_category_name is NOT null
and cn.product_category_name IS NULL;

select * from geolocations limit 10;