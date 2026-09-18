-- data_quality check

--Row Count check
select
'category_name' as table_names,
count(*) as row_counts
from category_name
union all

select
'customers', count(*)
from customers
union all

select
'geolocations', count(*)
from geolocations
union all

select
'order_items', count(*)
from order_items
union all

select
'order_payments', count(*)
from order_payments
union all

select
'order_reviews', count(*)
from order_reviews
union all

select
'orders', count(*)
from orders
union all

select
'products', count(*)
from products
union all

select
'sellers', count(*)
from sellers;

--Null check for orders
select
count(*) - count(product_category_name)
as category_nulls,
count(*) - count(product_weight_g)
as weight_nulls,
count(*) - count(product_length_cm)
as length_nulls,
count(*) - count(product_height_cm)
as height_nulls,
count(*) - count(product_width_cm)
as width_nulls
from products;

select *
from products
where product_category_name is null
limit 15;

select
product_id,
product_category_name,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
from products
where product_weight_g is null
or product_length_cm is null
or product_height_cm is null
or product_width_cm is null;
--610 products have missing category labels, 
--while only 2 products have missing physical dimensions and weight. 
--Missing category values were retained as unclassified products, 
--while the two incomplete physical-product records were flagged for further review.

select * from orders limit 10

select
count(*) - count(order_id) as order_id_null,
count(*) - count(customer_id) as customer_id_null,
count(*) - count(order_status) as order_status_null,
count(*) - count(order_purchase_timestamp) as order_purchase_time_null,
count(*) - count(order_approved_at) as order_approved_null,
count(*) - count(order_delivered_carrier_date) as order_delivered_carrier_date_null,
count(*) - count(order_delivered_customer_date) as order_delivered_customer_date_null,
count(*) - count(order_estimated_delivery_date) as order_estimated_delivery_date_null
from orders

select distinct order_status from orders limit 20

select
order_status,
count(*) as order_approved_null_count
from orders
where order_approved_at is null
group by order_status
order by order_approved_null_count desc

select
order_status,
count(*) asorder_delivered_carrier_date_null_count
from orders
where order_delivered_carrier_date is null
group by order_status
order by order_delivered_carrier_date_null_count DESC

select
order_status,
count(*) as order_delivered_customer_date_null_count
from orders
where order_delivered_customer_date is null
group by order_status
order by order_delivered_customer_date_null_count DESC

select
order_status,
count(*) as total_orders,

count(*) - count(order_approved_at) as approved_at_nulls,
count(*) - count(order_delivered_carrier_date) as order_delivered_carrier_date_null_count,
count(*) - count(order_delivered_customer_date) as order_delivered_customer_date_null_count
from orders
group by order_status
order by total_orders desc;


select * from orders
where order_status like('delivered')
and (order_approved_at is null
or order_delivered_carrier_date is null
or order_delivered_customer_date is null)
limit 30;

select * from orders
where order_status = 'canceled'
and order_delivered_customer_date is not null;


select
case
when order_delivered_customer_date is not null
then 'Canceled but delivered'

when order_delivered_carrier_date is not null
then 'Canceled after shipping'

when order_approved_at is not null
then 'Canceled after approval'

else 'Canceled before approval'
end as cancellation_stage,

count(*) as order_count
from orders
where order_status = 'canceled'
group by cancellation_stage
order by order_count DESC;
--Among canceled orders,
--most were canceled before shipment. However,
--69 orders had already been handed to the carrier,
--and 6 contained customer delivery timestamps despite being marked as canceled.
--These records were retained and flagged for further investigation
--rather than treated automatically as errors
select
count(case
when order_approved_at < order_purchase_timestamp
then 1
end) as approval_before_purchase,

count(CASE
when order_delivered_carrier_date < order_approved_at
then 1 end) as carrier_before_approval,

count(CASE
when order_delivered_customer_date < order_delivered_carrier_date
then 1 end) as delivered_before_carrier,

count(CASE
when order_delivered_customer_date < order_purchase_timestamp
then 1 end) as delivered_before_purchase
from orders;

select
order_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date
from orders
where order_delivered_carrier_date < order_approved_at
or order_delivered_customer_date < order_delivered_carrier_date
order by order_purchase_timestamp;


select
case
when order_delivered_carrier_date < order_approved_at
and order_delivered_customer_date < order_delivered_carrier_date
then 'Both issues'

when order_delivered_carrier_date < order_approved_at
then 'Carrier before approval'

when order_delivered_customer_date < order_delivered_carrier_date
then 'Customer delivery before carrier'
end as date_issue,

count(*) as order_count

from orders

where order_delivered_carrier_date < order_approved_at
or order_delivered_customer_date < order_delivered_carrier_date
group by date_issue
order by order_count desc;

select
count(case
when order_approved_at is not null
and order_delivered_carrier_date is not null
then 1 end) as comparable_orders,

count(case
when order_delivered_carrier_date < order_approved_at
then 1
end) as mistake_orders,

ROUND(100.0 *
count(case
when order_delivered_carrier_date < order_approved_at
then 1
end)/count(
case
when order_approved_at is not null
and order_delivered_carrier_date is not null
then 1
end),
2) as mistake_rate_percent
from orders;
--1,359 orders showed a carrier timestamp earlier than the approval timestamp, 
--representing 1.39% of orders with both timestamps available. 
--An additional 23 orders recorded customer delivery before carrier handoff. 

select
count(case
when order_delivered_carrier_date is not null
and order_delivered_customer_date is not null
then 1 end) as comparable_orders,

count(case
when order_delivered_customer_date < order_delivered_carrier_date
then 1
end) as mistake_orders,

ROUND(100.0 *
count(case
when order_delivered_customer_date < order_delivered_carrier_date
then 1
end)/count(
case
when order_delivered_customer_date is not null
and order_delivered_carrier_date is not null
then 1
end),
2) as mistake_rate_percent
from orders;
--23 of 96,475 comparable orders (0.02%) recorded customer delivery before carrier handoff,
--indicating a very small number of temporal inconsistencies.

--numeric range check
select *
from order_items
where price <= 0
or freight_value < 0;

select *
from order_reviews
where review_score < 1
or review_score > 5;

select *
from order_payments
where payment_value <= 0
or payment_installments < 0;

--duplicate check
select
review_id,
order_id,
count(*) as row_count
from order_reviews
group by review_id, order_id
having count(*) > 1;

select
geolocation_zip_code_prefix,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state,
count(*) as row_count
from geolocations
group by
geolocation_zip_code_prefix,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state
having count(*) > 1
order by row_count desc;


--check categorical consistency
select
order_status,
count(*) as order_count
from orders
group by order_status
order by order_count desc;

select
payment_type,
count(*) as payment_count
from order_payments
group by payment_type
order by payment_count desc;