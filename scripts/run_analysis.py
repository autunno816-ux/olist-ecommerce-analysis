"""Optional DuckDB/chart helper. The primary SQL workflow runs directly in PostgreSQL."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
FILES = {
    'customers': 'olist_customers_dataset.csv',
    'orders': 'olist_orders_dataset.csv',
    'order_items': 'olist_order_items_dataset.csv',
    'order_payments': 'olist_order_payments_dataset.csv',
    'order_reviews': 'olist_order_reviews_dataset.csv',
    'products': 'olist_products_dataset.csv',
    'sellers': 'olist_sellers_dataset.csv',
    'geolocations': 'olist_geolocation_dataset.csv',
    'category_name': 'product_category_name_translation.csv',
}
VIEWS = ['q1_monthly', 'q1_states', 'q1_categories', 'q2_customer_segments',
         'q2_quintiles', 'q2_repurchase', 'q3_overall', 'q3_states',
         'q3_review_scores', 'q3_state_reviews']


def records(db, query):
    cursor = db.execute(query)
    return [dict(zip([c[0] for c in cursor.description], row)) for row in cursor.fetchall()]


def load_data(db, data_dir):
    missing = [name for name in FILES.values() if not (data_dir / name).is_file()]
    if missing:
        raise FileNotFoundError('Missing CSV files: ' + ', '.join(missing) + '. See data/README.md.')
    manifest = []
    for table, filename in FILES.items():
        path = data_dir / filename
        # Read strings first: protects IDs and leading zeros in postal codes.
        db.execute(f'CREATE TABLE {table} AS SELECT * FROM read_csv(?, header=true, all_varchar=true)', [str(path)])
        columns = [r[0] for r in db.execute(f'DESCRIBE {table}').fetchall()]
        for col in columns:
            dtype = None
            if col in ('price', 'freight_value', 'payment_value'):
                dtype = 'DECIMAL(15,2)'
            elif col in ('order_item_id', 'payment_sequential', 'payment_installments', 'review_score'):
                dtype = 'INTEGER'
            elif col.endswith(('_timestamp', '_date', '_at')):
                dtype = 'TIMESTAMP'
            if dtype:
                db.execute(f'ALTER TABLE {table} ALTER COLUMN {col} TYPE {dtype} USING CAST({col} AS {dtype})')
        with path.open('rb') as source:
            digest = hashlib.file_digest(source, 'sha256').hexdigest()
        manifest.append({'table': table, 'file': filename, 'rows': db.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0],
                         'bytes': path.stat().st_size, 'sha256': digest})
    return manifest


def quality_checks(db):
    checks = []

    def check(name, query, blocking=False):
        value = db.execute(query).fetchone()[0]
        checks.append({'check': name, 'affected_rows': int(value), 'blocking': blocking})

    for table, key in [('orders','order_id'),('customers','customer_id'),('products','product_id'),('sellers','seller_id'),('category_name','product_category_name')]:
        check(f'{table}: duplicate or null primary key', f'SELECT COUNT(*) - COUNT(DISTINCT {key}) FROM {table}', True)
    for table, keys in [('order_items','order_id, order_item_id'),('order_payments','order_id, payment_sequential'),('order_reviews','order_id, review_id')]:
        check(f'{table}: duplicate composite key', f'SELECT COUNT(*) - COUNT(DISTINCT ({keys})) FROM {table}', True)
        condition = ' OR '.join(f'{k.strip()} IS NULL' for k in keys.split(','))
        check(f'{table}: null key component', f'SELECT COUNT(*) FROM {table} WHERE {condition}', True)
    for child, key, parent, pkey in [('orders','customer_id','customers','customer_id'),('order_items','order_id','orders','order_id'),('order_items','product_id','products','product_id'),('order_items','seller_id','sellers','seller_id'),('order_reviews','order_id','orders','order_id'),('order_payments','order_id','orders','order_id')]:
        check(f'{child}.{key}: orphan or null', f'SELECT COUNT(*) FROM {child} c LEFT JOIN {parent} p ON c.{key}=p.{pkey} WHERE p.{pkey} IS NULL', True)
    check('customers: missing person identifier', 'SELECT COUNT(*) FROM customers WHERE customer_unique_id IS NULL', True)
    check('orders: missing purchase timestamp', 'SELECT COUNT(*) FROM orders WHERE order_purchase_timestamp IS NULL', True)
    check('items: nonpositive or null price', 'SELECT COUNT(*) FROM order_items WHERE price <= 0 OR price IS NULL', True)
    check('reviews: invalid or missing score', 'SELECT COUNT(*) FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5 OR review_score IS NULL', True)
    check('delivered orders: missing items', "SELECT COUNT(*) FROM orders o WHERE order_status='delivered' AND NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id=o.order_id)", True)
    check('products: missing category', 'SELECT COUNT(*) FROM products WHERE product_category_name IS NULL')
    check('products: untranslated nonnull category', 'SELECT COUNT(*) FROM products p LEFT JOIN category_name c USING(product_category_name) WHERE p.product_category_name IS NOT NULL AND c.product_category_name IS NULL')
    check('products: missing physical attribute', 'SELECT COUNT(*) FROM products WHERE product_weight_g IS NULL OR product_length_cm IS NULL OR product_height_cm IS NULL OR product_width_cm IS NULL')
    check('delivered orders: missing actual delivery', "SELECT COUNT(*) FROM orders WHERE order_status='delivered' AND order_delivered_customer_date IS NULL")
    check('orders: carrier before approval', 'SELECT COUNT(*) FROM orders WHERE order_delivered_carrier_date < order_approved_at')
    check('orders: customer delivery before carrier', 'SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date < order_delivered_carrier_date')
    check('orders: delivery before purchase', 'SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date < order_purchase_timestamp', True)
    check('canceled orders: actual delivery exists', "SELECT COUNT(*) FROM orders WHERE order_status='canceled' AND order_delivered_customer_date IS NOT NULL")
    check('orders with multiple reviews', 'SELECT COUNT(*) FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*)>1)')
    check('geolocations: exact duplicate rows', 'SELECT (SELECT COUNT(*) FROM geolocations) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM geolocations))')
    check('payments: zero values', 'SELECT COUNT(*) FROM order_payments WHERE payment_value=0')
    return checks


def export_csv(path, rows, fieldnames=None):
    with path.open('w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames if fieldnames is not None else list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def run(data_dir, output, charts=True):
    output.mkdir(parents=True, exist_ok=True)
    results_dir = output / 'results'
    results_dir.mkdir(exist_ok=True)
    with duckdb.connect() as db:
        manifest = load_data(db, data_dir)
        checks = quality_checks(db)
        export_csv(results_dir / 'data_quality.csv', checks)
        failures = [c for c in checks if c['blocking'] and c['affected_rows']]
        if failures:
            raise ValueError('Blocking quality checks failed; see data_quality.csv: ' + str(failures))
        for path in [ROOT / 'sql' / name for name in
                     ('00_model.sql', '01_sales.sql', '02_customers.sql', '03_delivery.sql')]:
            db.execute(path.read_text(encoding='utf-8'))
        tables = {name: records(db, 'SELECT * FROM ' + name) for name in VIEWS}
        for name, rows in tables.items():
            columns = [c[0] for c in db.execute('SELECT * FROM ' + name + ' LIMIT 0').description]
            export_csv(results_dir / (name + '.csv'), rows, fieldnames=columns)
        summary = records(db, '''SELECT COUNT(*) AS delivered_orders, COUNT(DISTINCT customer_unique_id) AS purchasing_customers,
            SUM(revenue_brl) AS revenue_brl, MIN(order_purchase_timestamp) AS first_delivered_purchase,
            MAX(order_purchase_timestamp) AS last_delivered_purchase FROM delivered_orders''')[0]
        # Independent aggregation path verifies the central monetary total.
        direct = db.execute("SELECT SUM(price) FROM order_items i WHERE EXISTS (SELECT 1 FROM orders o WHERE o.order_id=i.order_id AND o.order_status='delivered')").fetchone()[0]
        if direct != summary['revenue_brl']:
            raise ValueError('Direct item revenue does not reconcile with the order model')
        for view in ('q1_states', 'q1_categories', 'q2_customer_segments', 'q2_quintiles'):
            if sum(r['revenue_brl'] for r in tables[view]) != direct:
                raise ValueError('Revenue reconciliation failed: ' + view)
        summary['raw_orders'] = db.execute('SELECT COUNT(*) FROM orders').fetchone()[0]
        summary['first_purchase'], summary['last_purchase'] = db.execute('SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM orders').fetchone()
        payload = {'summary': summary, 'tables': tables, 'source_manifest': manifest, 'quality_checks': checks,
                   'reconciliations': {'revenue_totals_match': True}, 'duckdb_version': duckdb.__version__}
        (results_dir / 'metrics.json').write_text(json.dumps(payload, indent=2, default=str) + '\n', encoding='utf-8')
    if charts:
        from plot_results import make_charts
        make_charts(tables, output / 'figures')
    print(json.dumps(summary, default=str, indent=2))
    print(f'Exported {len(tables)} result tables; {len(checks)} quality checks; output: {output}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir', type=Path, default=ROOT / 'data/raw')
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'reports')
    parser.add_argument('--no-charts', action='store_true')
    args = parser.parse_args()
    try:
        run(args.data_dir.resolve(), args.output_dir.resolve(), charts=not args.no_charts)
    except (FileNotFoundError, ValueError, duckdb.Error) as exc:
        parser.exit(1, f'Analysis stopped: {exc}\n')
