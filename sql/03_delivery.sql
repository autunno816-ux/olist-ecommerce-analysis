CREATE OR REPLACE VIEW q3_overall AS
SELECT COUNT(*) AS order_count, ROUND(AVG(delivery_days), 2) AS average_delivery_days,
       SUM(CASE WHEN is_late THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * AVG(CASE WHEN is_late THEN 1.0 ELSE 0 END), 2) AS late_rate_pct,
       SUM(CASE WHEN is_calendar_late THEN 1 ELSE 0 END) AS calendar_late_orders,
       ROUND(100.0 * AVG(CASE WHEN is_calendar_late THEN 1.0 ELSE 0 END), 2) AS calendar_late_rate_pct
FROM delivery_base;

CREATE OR REPLACE VIEW q3_states AS
SELECT customer_state, COUNT(*) AS order_count,
       SUM(CASE WHEN is_late THEN 1 ELSE 0 END) AS late_orders,
       ROUND(AVG(delivery_days), 2) AS average_delivery_days,
       ROUND(100.0 * AVG(CASE WHEN is_late THEN 1.0 ELSE 0 END), 2) AS late_rate_pct
FROM delivery_base GROUP BY customer_state ORDER BY late_rate_pct DESC, customer_state;

CREATE OR REPLACE VIEW q3_review_scores AS
SELECT CASE WHEN d.is_late THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS reviewed_order_count, ROUND(AVG(r.review_score), 4) AS average_review_score
FROM delivery_base d JOIN review_per_order r ON r.order_id = d.order_id
GROUP BY 1 ORDER BY delivery_status;

CREATE OR REPLACE VIEW q3_state_reviews AS
-- Delay rate and review score use the SAME reviewed-order population here.
SELECT d.customer_state, COUNT(*) AS reviewed_order_count,
       SUM(CASE WHEN d.is_late THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * AVG(CASE WHEN d.is_late THEN 1.0 ELSE 0 END), 2) AS late_rate_pct,
       ROUND(AVG(r.review_score), 4) AS average_review_score
FROM delivery_base d JOIN review_per_order r ON r.order_id = d.order_id
GROUP BY d.customer_state ORDER BY d.customer_state;
