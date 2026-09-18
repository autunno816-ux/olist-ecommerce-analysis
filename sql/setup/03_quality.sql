-- PostgreSQL data-quality checks. Execute after importing all nine CSVs.
-- Temporary views are scoped to this session; no source records are changed.
CREATE OR REPLACE TEMP VIEW quality_check_results AS
SELECT 'orders: duplicate or null primary key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT order_id) FROM orders)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'customers: duplicate or null primary key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT customer_id) FROM customers)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'products: duplicate or null primary key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT product_id) FROM products)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'sellers: duplicate or null primary key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT seller_id) FROM sellers)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'category_name: duplicate or null primary key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT product_category_name) FROM category_name)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_items: duplicate composite key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT (order_id, order_item_id)) FROM order_items)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_items: null key component' AS check_name, (SELECT COUNT(*) FROM order_items WHERE order_id IS NULL OR order_item_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_payments: duplicate composite key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT (order_id, payment_sequential)) FROM order_payments)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_payments: null key component' AS check_name, (SELECT COUNT(*) FROM order_payments WHERE order_id IS NULL OR payment_sequential IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_reviews: duplicate composite key' AS check_name, (SELECT COUNT(*) - COUNT(DISTINCT (order_id, review_id)) FROM order_reviews)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_reviews: null key component' AS check_name, (SELECT COUNT(*) FROM order_reviews WHERE order_id IS NULL OR review_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'orders.customer_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM orders c LEFT JOIN customers p ON c.customer_id=p.customer_id WHERE p.customer_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_items.order_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM order_items c LEFT JOIN orders p ON c.order_id=p.order_id WHERE p.order_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_items.product_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM order_items c LEFT JOIN products p ON c.product_id=p.product_id WHERE p.product_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_items.seller_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM order_items c LEFT JOIN sellers p ON c.seller_id=p.seller_id WHERE p.seller_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_reviews.order_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM order_reviews c LEFT JOIN orders p ON c.order_id=p.order_id WHERE p.order_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'order_payments.order_id: orphan or null' AS check_name, (SELECT COUNT(*) FROM order_payments c LEFT JOIN orders p ON c.order_id=p.order_id WHERE p.order_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'customers: missing person identifier' AS check_name, (SELECT COUNT(*) FROM customers WHERE customer_unique_id IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'orders: missing purchase timestamp' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_purchase_timestamp IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'items: nonpositive or null price' AS check_name, (SELECT COUNT(*) FROM order_items WHERE price <= 0 OR price IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'reviews: invalid or missing score' AS check_name, (SELECT COUNT(*) FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5 OR review_score IS NULL)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'delivered orders: missing items' AS check_name, (SELECT COUNT(*) FROM orders o WHERE order_status='delivered' AND NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id=o.order_id))::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'products: missing category' AS check_name, (SELECT COUNT(*) FROM products WHERE product_category_name IS NULL)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'products: untranslated nonnull category' AS check_name, (SELECT COUNT(*) FROM products p LEFT JOIN category_name c USING(product_category_name) WHERE p.product_category_name IS NOT NULL AND c.product_category_name IS NULL)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'products: missing physical attribute' AS check_name, (SELECT COUNT(*) FROM products WHERE product_weight_g IS NULL OR product_length_cm IS NULL OR product_height_cm IS NULL OR product_width_cm IS NULL)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'delivered orders: missing actual delivery' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_status='delivered' AND order_delivered_customer_date IS NULL)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'orders: carrier before approval' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_delivered_carrier_date < order_approved_at)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'orders: customer delivery before carrier' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date < order_delivered_carrier_date)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'orders: delivery before purchase' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date < order_purchase_timestamp)::BIGINT AS affected_rows, TRUE AS blocking
UNION ALL
SELECT 'canceled orders: actual delivery exists' AS check_name, (SELECT COUNT(*) FROM orders WHERE order_status='canceled' AND order_delivered_customer_date IS NOT NULL)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'orders with multiple reviews' AS check_name, (SELECT COUNT(*) FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*)>1))::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'geolocations: exact duplicate rows' AS check_name, (SELECT (SELECT COUNT(*) FROM geolocations) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM geolocations)))::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'payments: zero values' AS check_name, (SELECT COUNT(*) FROM order_payments WHERE payment_value=0)::BIGINT AS affected_rows, FALSE AS blocking
UNION ALL
SELECT 'orders: empty source table', CASE WHEN EXISTS (SELECT 1 FROM orders) THEN 0 ELSE 1 END::BIGINT, TRUE;

DO $$
DECLARE
    failures TEXT;
BEGIN
    SELECT STRING_AGG(FORMAT('%s: %s affected rows/entities', check_name, affected_rows), E'\n' ORDER BY check_name)
    INTO failures
    FROM quality_check_results
    WHERE blocking AND affected_rows > 0;

    IF failures IS NOT NULL THEN
        RAISE EXCEPTION 'Blocking data-quality checks failed.'
            USING DETAIL = failures, HINT = 'Resolve the listed issues, then rerun this quality-check script before analysing.';
    END IF;
END $$;

SELECT * FROM quality_check_results ORDER BY blocking DESC, check_name;

-- In pgAdmin, select this statement separately to inspect source row counts.
SELECT 'customers' AS source_table, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders' AS source_table, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items' AS source_table, COUNT(*) AS row_count FROM order_items
UNION ALL
SELECT 'order_payments' AS source_table, COUNT(*) AS row_count FROM order_payments
UNION ALL
SELECT 'order_reviews' AS source_table, COUNT(*) AS row_count FROM order_reviews
UNION ALL
SELECT 'products' AS source_table, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'sellers' AS source_table, COUNT(*) AS row_count FROM sellers
UNION ALL
SELECT 'geolocations' AS source_table, COUNT(*) AS row_count FROM geolocations
UNION ALL
SELECT 'category_name' AS source_table, COUNT(*) AS row_count FROM category_name;
