CREATE OR REPLACE VIEW q1_monthly AS
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_purchase_timestamp)::DATE AS month,
           COUNT(*) AS order_count, SUM(revenue_brl) AS revenue_brl
    FROM delivered_orders
    WHERE order_purchase_timestamp >= TIMESTAMP '2017-01-01'
      AND order_purchase_timestamp < TIMESTAMP '2018-09-01'
    GROUP BY 1
)
SELECT *, CASE WHEN LAG(month) OVER (ORDER BY month) = month - INTERVAL '1 month'
    THEN ROUND(100.0 * (revenue_brl - LAG(revenue_brl) OVER (ORDER BY month)) /
               NULLIF(LAG(revenue_brl) OVER (ORDER BY month), 0), 2)
    END AS mom_growth_pct
FROM monthly ORDER BY month;

CREATE OR REPLACE VIEW q1_states AS
SELECT customer_state, COUNT(*) AS order_count, SUM(revenue_brl) AS revenue_brl,
       ROUND(100.0 * SUM(revenue_brl) / NULLIF(SUM(SUM(revenue_brl)) OVER (), 0), 2) AS revenue_share_pct
FROM delivered_orders GROUP BY customer_state ORDER BY revenue_brl DESC, customer_state;

CREATE OR REPLACE VIEW q1_categories AS
SELECT COALESCE(cn.product_category_name_english, 'unclassified') AS product_category,
       SUM(i.price) AS revenue_brl, COUNT(*) AS items_sold, COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(100.0 * SUM(i.price) / NULLIF(SUM(SUM(i.price)) OVER (), 0), 2) AS revenue_share_pct
FROM delivered_orders o JOIN order_items i ON i.order_id = o.order_id
LEFT JOIN products p ON p.product_id = i.product_id
LEFT JOIN category_name cn ON cn.product_category_name = p.product_category_name
GROUP BY 1 ORDER BY revenue_brl DESC, product_category;
