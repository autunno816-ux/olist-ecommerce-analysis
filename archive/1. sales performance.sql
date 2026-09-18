
-- 1. sales performance
-- 1.1 monthly order volume, revenue and mom growth

with monthly_sales as (
select
date_trunc('month', o.order_purchase_timestamp) as months,
count(distinct o.order_id) as order_count,
sum(oi.price) as revenue
from order_items as oi
join orders as o
on o.order_id = oi.order_id
where o.order_status = 'delivered'
and o.order_purchase_timestamp >= '2017-01-01'
and o.order_purchase_timestamp < '2018-09-01'
group by months
)

select
months,
order_count,
round(revenue, 2) as revenue,

round(
lag(revenue) over (order by months),2) as previous_month_revenue,
case
when lag(months) over (order by months)= months - interval '1 month'
then round(
100.0 *
(revenue - lag(revenue) over (order by months))/ lag(revenue) over (order by months),2)
end as monthly_growth_percent
from monthly_sales
order by months;


-- -----------------------------------------------------
-- 1.2 which states contribute the most orders and sales?
-- -----------------------------------------------------

select
c.customer_state,
count(distinct o.order_id) as order_count,
round(sum(oi.price), 2) as revenue,
round(100.0 * sum(oi.price)/ sum(sum(oi.price)) over (),2) as revenue_share_by_state

from customers as c
join orders as o on c.customer_id = o.customer_id
join order_items as oi on o.order_id = oi.order_id

where o.order_status = 'delivered'
group by c.customer_state
order by revenue desc;

--sp was the state with the highest sales contribution,
--accounting for about 38.33% of the sales of laided-order goods; 
--This is followed by rj and mg. The top three states together contribute about 63.38% of sales, 
--indicating a high concentration of sales in a few core states.


-- 1.3 which product categories contribute the most sales?
select * from category_name limit 10;
select * from order_items limit 10;
select * from products limit 10;


select
coalesce(cn.product_category_name_english, 'unknow')product_category,
sum(oi.price) as revenue,
count(*) as items_sold,
count (distinct oi.order_id) as order_count,
round(100.0 * sum(oi.price)/ sum(sum(oi.price)) over (),2)
as revenue_share_by_category
from orders as o
join order_items as oi on  o.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
left join category_name as cn
on p.product_category_name = cn.product_category_name
where o.order_status = 'delivered'
group by cn.product_category_name_english
order by revenue desc
limit 10;
--the chart shows the top 10 product categories ranked by revenue, 
--together with each category’s share of total delivered-order revenue.