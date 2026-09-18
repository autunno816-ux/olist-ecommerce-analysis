-- Run with psql -X -v ON_ERROR_STOP=1 -f tests/postgres_metrics.sql.
-- All fixtures and views live in a transaction-scoped test schema; rollback preserves the database.
BEGIN;
CREATE SCHEMA olist_metric_test;
SET LOCAL search_path TO olist_metric_test;

CREATE TABLE customers(customer_id TEXT, customer_unique_id TEXT, customer_state TEXT);
INSERT INTO customers VALUES ('c1','repeat','SP'),('c2','repeat','SP'),('c3','single','RJ'),('c4','cancelled','SP');
CREATE TABLE orders(order_id TEXT, customer_id TEXT, order_status TEXT,
    order_purchase_timestamp TIMESTAMP, order_delivered_customer_date TIMESTAMP, order_estimated_delivery_date TIMESTAMP);
INSERT INTO orders VALUES
    ('o1','c1','delivered','2018-01-01','2018-01-10 12:00:00','2018-01-10'),
    ('o2','c2','delivered','2018-02-01','2018-02-05','2018-02-10'),
    ('o3','c3','delivered','2018-01-01',NULL,'2018-01-10'),
    ('o4','c4','canceled','2018-01-01','2018-01-05','2018-01-10');
CREATE TABLE order_items(order_id TEXT, product_id TEXT, price NUMERIC(15,2));
INSERT INTO order_items VALUES ('o1','p1',10),('o1','p1',10),('o2','p1',20),('o3','p1',160),('o4','p1',999);
CREATE TABLE products(product_id TEXT, product_category_name TEXT);
INSERT INTO products VALUES ('p1','cat');
CREATE TABLE category_name(product_category_name TEXT, product_category_name_english TEXT);
INSERT INTO category_name VALUES ('cat','category');
CREATE TABLE order_reviews(order_id TEXT, review_score INTEGER);
INSERT INTO order_reviews VALUES ('o1',1),('o1',3),('o2',5);

\ir ../sql/00_model.sql
\ir ../sql/01_sales.sql
\ir ../sql/02_customers.sql
\ir ../sql/03_delivery.sql

DO $$
BEGIN
    IF (SELECT revenue_share_pct FROM q2_customer_segments WHERE customer_type='Repeat') IS DISTINCT FROM 20.00
       OR (SELECT order_share_pct FROM q2_customer_segments WHERE customer_type='Repeat') IS DISTINCT FROM 66.67 THEN
        RAISE EXCEPTION 'Revenue and order shares must use different denominators';
    END IF;
    IF (SELECT COUNT(*) FROM delivered_orders) <> 3 OR (SELECT SUM(revenue_brl) FROM delivered_orders) <> 200 THEN
        RAISE EXCEPTION 'Items multiply orders, or canceled orders enter sales';
    END IF;
    IF (SELECT order_count FROM q3_overall) <> 2 OR (SELECT late_orders FROM q3_overall) <> 1
       OR (SELECT calendar_late_orders FROM q3_overall) <> 0 THEN
        RAISE EXCEPTION 'Missing delivery dates or same-day lateness handled incorrectly';
    END IF;
    IF (SELECT COUNT(*) FROM customer_summary) <> 2 THEN
        RAISE EXCEPTION 'Customer identity must use customer_unique_id';
    END IF;
END $$;

INSERT INTO customers VALUES ('c5','another','SP');
INSERT INTO orders VALUES ('o5','c5','delivered','2018-01-01','2018-01-12','2018-01-10');
INSERT INTO order_reviews VALUES ('o5',5);
DO $$
BEGIN
    IF (SELECT average_review_score FROM q3_review_scores WHERE delivery_status='Late') IS DISTINCT FROM 3.5000 THEN
        RAISE EXCEPTION 'Review rows overweight an order: order means 2 and 5 should average to 3.5';
    END IF;
END $$;

INSERT INTO customers VALUES ('c6','repeat','SP');
INSERT INTO orders VALUES ('o6','c6','delivered','2018-08-01','2018-08-05','2018-08-10');
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM q2_repurchase) <> 1
       OR (SELECT interval_bucket FROM q2_repurchase) IS DISTINCT FROM '31–90 days'
       OR (SELECT customer_count FROM q2_repurchase) <> 1 THEN
        RAISE EXCEPTION 'First-repeat distribution includes later repeat purchases';
    END IF;
END $$;

ROLLBACK;
SELECT 'PostgreSQL analytical regression checks passed' AS result;
