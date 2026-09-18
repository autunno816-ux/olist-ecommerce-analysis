-- Customer = customer_unique_id, not the order-specific customer_id.
CREATE OR REPLACE VIEW q2_customer_segments AS
SELECT customer_type, COUNT(*) AS customer_count, SUM(order_count) AS order_count,
       SUM(revenue_brl) AS revenue_brl,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct,
       ROUND(100.0 * SUM(order_count) / SUM(SUM(order_count)) OVER (), 2) AS order_share_pct,
       ROUND(100.0 * SUM(revenue_brl) / NULLIF(SUM(SUM(revenue_brl)) OVER (), 0), 2) AS revenue_share_pct,
       ROUND(AVG(revenue_brl), 2) AS average_revenue_per_customer_brl
FROM customer_summary GROUP BY customer_type ORDER BY customer_type;

CREATE OR REPLACE VIEW q2_quintiles AS
WITH ranked AS (
    SELECT *, NTILE(5) OVER (ORDER BY revenue_brl DESC, customer_unique_id) AS quintile
    FROM customer_summary
)
SELECT quintile, COUNT(*) AS customer_count, SUM(revenue_brl) AS revenue_brl,
       ROUND(100.0 * SUM(revenue_brl) / NULLIF(SUM(SUM(revenue_brl)) OVER (), 0), 2) AS revenue_share_pct
FROM ranked GROUP BY quintile ORDER BY quintile;

CREATE OR REPLACE VIEW q2_repurchase AS
WITH sequenced AS (
    SELECT c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
           ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp, o.order_id) AS purchase_number,
           LAG(o.order_purchase_timestamp) OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp, o.order_id) AS previous_purchase
    FROM orders o JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
), intervals AS (
    SELECT order_purchase_timestamp::DATE - previous_purchase::DATE AS days
    FROM sequenced WHERE purchase_number = 2
), bucketed AS (
    SELECT CASE WHEN days <= 30 THEN '0–30 days' WHEN days <= 90 THEN '31–90 days' ELSE '91+ days' END AS interval_bucket,
           CASE WHEN days <= 30 THEN 1 WHEN days <= 90 THEN 2 ELSE 3 END AS sort_order
    FROM intervals
)
SELECT interval_bucket, sort_order, COUNT(*) AS customer_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct
FROM bucketed GROUP BY interval_bucket, sort_order ORDER BY sort_order;
