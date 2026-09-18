"""Small counterexamples for the analytical errors most likely to change findings."""
from pathlib import Path
import unittest
import duckdb

ROOT = Path(__file__).resolve().parents[1]


class MetricTests(unittest.TestCase):
    def setUp(self):
        self.db = duckdb.connect()
        self.db.execute("""
            CREATE TABLE customers(customer_id VARCHAR, customer_unique_id VARCHAR, customer_state VARCHAR);
            INSERT INTO customers VALUES ('c1','repeat','SP'),('c2','repeat','SP'),('c3','single','RJ'),('c4','cancelled','SP');
            CREATE TABLE orders(order_id VARCHAR, customer_id VARCHAR, order_status VARCHAR,
                order_purchase_timestamp TIMESTAMP, order_delivered_customer_date TIMESTAMP, order_estimated_delivery_date TIMESTAMP);
            INSERT INTO orders VALUES
                ('o1','c1','delivered','2018-01-01','2018-01-10 12:00:00','2018-01-10'),
                ('o2','c2','delivered','2018-02-01','2018-02-05','2018-02-10'),
                ('o3','c3','delivered','2018-01-01',NULL,'2018-01-10'),
                ('o4','c4','canceled','2018-01-01','2018-01-05','2018-01-10');
            CREATE TABLE order_items(order_id VARCHAR, product_id VARCHAR, price DECIMAL(15,2));
            INSERT INTO order_items VALUES ('o1','p1',10),('o1','p1',10),('o2','p1',20),('o3','p1',160),('o4','p1',999);
            CREATE TABLE products(product_id VARCHAR, product_category_name VARCHAR);
            INSERT INTO products VALUES ('p1','cat');
            CREATE TABLE category_name(product_category_name VARCHAR, product_category_name_english VARCHAR);
            INSERT INTO category_name VALUES ('cat','category');
            CREATE TABLE order_reviews(order_id VARCHAR, review_score INTEGER);
            INSERT INTO order_reviews VALUES ('o1',1),('o1',3),('o2',5);
        """)
        self.db.execute((ROOT / 'sql/00_model.sql').read_text(encoding='utf-8'))
        for path in sorted((ROOT / 'sql').glob('0[123]_*.sql')):
            self.db.execute(path.read_text(encoding='utf-8'))

    def tearDown(self):
        self.db.close()

    def test_revenue_share_is_money_share_not_order_share(self):
        row = self.db.execute("SELECT revenue_share_pct, order_share_pct FROM q2_customer_segments WHERE customer_type='Repeat'").fetchone()
        self.assertAlmostEqual(float(row[0]), 20.0)
        self.assertAlmostEqual(float(row[1]), 66.67, places=2)

    def test_items_and_reviews_do_not_multiply_orders(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*), SUM(revenue_brl) FROM delivered_orders').fetchone(), (3, 200))
        rows = dict(self.db.execute('SELECT delivery_status, average_review_score FROM q3_review_scores').fetchall())
        self.assertEqual(float(rows['Late']), 2.0)
        self.assertEqual(float(rows['On time']), 5.0)

    def test_missing_dates_excluded_and_lateness_definition_explicit(self):
        row = self.db.execute('SELECT order_count, late_orders, calendar_late_orders FROM q3_overall').fetchone()
        self.assertEqual(row, (2, 1, 0))

    def test_customer_identifier_and_first_repeat_interval(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM customer_summary').fetchone()[0], 2)
        self.assertEqual(self.db.execute('SELECT interval_bucket, customer_count FROM q2_repurchase').fetchone(), ('31–90 days', 1))

    def test_multiple_reviews_cannot_overweight_one_order(self):
        self.db.execute("""
            INSERT INTO customers VALUES ('c5','another','SP');
            INSERT INTO orders VALUES ('o5','c5','delivered','2018-01-01','2018-01-12','2018-01-10');
            INSERT INTO order_reviews VALUES ('o5',5);
        """)
        # Order means are 2 and 5 -> 3.5. Raw review rows 1, 3, 5 -> 3.0 (wrong).
        score = self.db.execute("SELECT average_review_score FROM q3_review_scores WHERE delivery_status='Late'").fetchone()[0]
        self.assertEqual(float(score), 3.5)

    def test_third_purchase_is_excluded_from_first_repeat_distribution(self):
        self.db.execute("""
            INSERT INTO customers VALUES ('c5','repeat','SP');
            INSERT INTO orders VALUES ('o5','c5','delivered','2018-08-01','2018-08-05','2018-08-10');
        """)
        self.assertEqual(self.db.execute('SELECT interval_bucket, customer_count FROM q2_repurchase').fetchall(), [('31–90 days', 1)])


if __name__ == '__main__':
    unittest.main()
