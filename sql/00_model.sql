-- Primary execution target: PostgreSQL. Also exercised by the optional DuckDB helper.
-- Monetary values remain NUMERIC/DECIMAL during aggregation.
-- Aggregate each one-to-many fact before joining it to orders.
CREATE OR REPLACE VIEW delivered_orders AS
WITH item_totals AS (
    SELECT order_id, SUM(price) AS revenue_brl, COUNT(*) AS item_count
    FROM order_items GROUP BY order_id
)
SELECT o.*, c.customer_unique_id, c.customer_state, i.revenue_brl, i.item_count
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN item_totals i ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';

CREATE OR REPLACE VIEW customer_summary AS
SELECT customer_unique_id, COUNT(*) AS order_count, SUM(revenue_brl) AS revenue_brl,
       CASE WHEN COUNT(*) = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type
FROM delivered_orders GROUP BY customer_unique_id;

-- An order with several reviews contributes one mean score, giving each order equal weight.
CREATE OR REPLACE VIEW review_per_order AS
SELECT order_id, AVG(review_score) AS review_score, COUNT(*) AS review_count
FROM order_reviews WHERE review_score BETWEEN 1 AND 5 GROUP BY order_id;

-- Delivery population is independent of item/review availability.
-- Keep timestamp lateness for comparability; expose calendar-date sensitivity alongside it.
CREATE OR REPLACE VIEW delivery_base AS
SELECT o.order_id, c.customer_state,
       CAST(o.order_delivered_customer_date AS DATE) - CAST(o.order_purchase_timestamp AS DATE) AS delivery_days,
       o.order_delivered_customer_date > o.order_estimated_delivery_date AS is_late,
       CAST(o.order_delivered_customer_date AS DATE) > CAST(o.order_estimated_delivery_date AS DATE) AS is_calendar_late
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;
