-- Display research results in psql or pgAdmin Query Tool.
-- pgAdmin shows the final result grid when a whole script is run;
-- select and execute one SELECT at a time to inspect individual result sets.
SELECT * FROM q1_monthly ORDER BY month;
SELECT * FROM q1_states ORDER BY revenue_brl DESC, customer_state;
SELECT * FROM q1_categories ORDER BY revenue_brl DESC, product_category;
SELECT * FROM q2_customer_segments ORDER BY customer_type;
SELECT * FROM q2_quintiles ORDER BY quintile;
SELECT * FROM q2_repurchase ORDER BY sort_order;
SELECT * FROM q3_overall;
SELECT * FROM q3_states ORDER BY late_rate_pct DESC, customer_state;
SELECT * FROM q3_review_scores ORDER BY delivery_status;
SELECT * FROM q3_state_reviews ORDER BY customer_state;
