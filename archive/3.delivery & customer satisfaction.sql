--3.delivery & customer satisfaction
--3.1 overall delivery performance
select * from orders limit 8
select
count(*) as order_count,

round(avg(order_delivered_customer_date::date - order_purchase_timestamp::date),2)
as average_delivered_time_by_days,

count(
case
when order_delivered_customer_date > order_estimated_delivery_date
then 1 end) as count_delay_order,

round(100.0*(count(case
when order_delivered_customer_date > order_estimated_delivery_date
then 1 end)::numeric/count(*)),2)
as share_of_delay_percent,

count(
case
when order_delivered_customer_date <= order_estimated_delivery_date
then 1 end) as count_punctual_order,

round(100.0*(count(
case
when order_delivered_customer_date <= order_estimated_delivery_date
then 1 end))::numeric/count(*),2) as share_of_punctual_percent

from orders
where order_status = 'delivered'
and order_delivered_customer_date is not null
and order_estimated_delivery_date is not null
--overall delivery performance was relatively strong: 
--delivered orders took an average of 12.5 days to reach customers, 
--and approximately 91.9% arrived on or before the estimated delivery date. 
--however, around 8.1% of delivered orders were late, 
--indicating that delivery delays remain a meaningful operational issue.

--3.2delivery performance by state
select * from customers limit 8

select c.customer_state,
count(
case
when o.order_delivered_customer_date > o.order_estimated_delivery_date
then 1 end) as delay_order_count,
round(avg(order_delivered_customer_date::date - order_purchase_timestamp::date),2)
as average_delivered_time_by_days,
round(100.0 *count(
case
when o.order_delivered_customer_date > o.order_estimated_delivery_date
then 1 end)::numeric/ count(*),2) as delay_rate_percent
from customers as c join orders as o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
and order_delivered_customer_date is not null
and order_estimated_delivery_date is not null
group by c.customer_state
order by delay_rate_percent desc
limit 10
--delivery performance varies substantially across states. ce and
--ba show relatively weak performance,
--with both long average delivery times and high late-delivery rates. 
--in contrast, sp records the largest number of delayed orders in 
--absolute terms but has a comparatively low delay rate and shorter 
--average delivery time, reflecting its much larger order volume.


--3.3delivery delay vs review score
select * from order_reviews limit 10
select c.customer_state,
count(
case
when o.order_delivered_customer_date > o.order_estimated_delivery_date
then 1 end) as delay_order_count,
round(100.0*(count(
case
when o.order_delivered_customer_date > o.order_estimated_delivery_date
then 1 end)/count(*)::numeric),2) as share_delay_statepercent,
avg(ors.review_score) as average_review_score
from customers as c join orders as o
on c.customer_id = o.customer_id
join order_reviews as ors on o.order_id = ors.order_id
where o.order_status = 'delivered'
and order_delivered_customer_date is not null
and order_estimated_delivery_date is not null
group by c.customer_state

select
case
when o.order_delivered_customer_date > o.order_estimated_delivery_date
then 'late'
else 'on time'
end as delivery_status,
count(distinct o.order_id) as order_count,
round(avg(ors.review_score)::numeric,2)
as average_review_score
from orders as o
join order_reviews as ors
on o.order_id = ors.order_id
where o.order_status = 'delivered'
and o.order_delivered_customer_date is not null
and o.order_estimated_delivery_date is not null
and ors.review_score is not null
group by delivery_status;