# Reproduce in PostgreSQL / pgAdmin

[Project overview](../README.md) · [Data files](../data/README.md) · [Methodology](methodology.md)

The analysis uses PostgreSQL SQL. You can reproduce all 10 result tables using pgAdmin or the `psql` client. Python is not required. The full workflow has been verified on PostgreSQL 18.6.

## 1. Create a project database

Use a new, empty database so the project tables are separate from other work. In pgAdmin, right-click **Databases → Create → Database**, name it `olist_portfolio`, and open its Query Tool.

Run [sql/setup/01_schema.sql](../sql/setup/01_schema.sql). It creates nine source tables in the database's default `public` schema and defines the primary keys, composite keys, foreign keys and numeric checks. It does not drop existing tables; running it again against populated tables will fail. You only need to run schema creation once.

## 2. Import the CSV files

Download the nine files from the [dataset source](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). In pgAdmin, refresh **Schemas → public → Tables**, right-click each target table and use **Import/Export Data**.

Select **Import**, choose the matching file, set **Format = csv**, **Encoding = UTF8**, **Header = Yes** and **Delimiter = comma**. Keep the default double-quote quote/escape characters and import every column in its source order. Empty fields should use the default CSV null handling. The table columns follow the CSV column order.

Import in this order so parent records exist before foreign keys are checked:

| Order | PostgreSQL table | CSV filename |
| --- | --- | --- |
| 1 | customers | olist_customers_dataset.csv |
| 2 | orders | olist_orders_dataset.csv |
| 3 | products | olist_products_dataset.csv |
| 4 | sellers | olist_sellers_dataset.csv |
| 5 | order_items | olist_order_items_dataset.csv |
| 6 | order_payments | olist_order_payments_dataset.csv |
| 7 | order_reviews | olist_order_reviews_dataset.csv |
| 8 | geolocations | olist_geolocation_dataset.csv |
| 9 | category_name | product_category_name_translation.csv |

For pgAdmin hosted on another server, select/upload files through that pgAdmin instance's file picker. The `psql` alternative below reads CSVs from the machine running `psql`.

If one import fails, fix that import before continuing. Do not import an already loaded table again: primary keys prevent duplicate rows in most tables, but geolocations intentionally has no unique key.

## 3. Run quality checks and analytical SQL

Open and execute these `.sql` files in the Query Tool in this order, connected to the same database:

| Step | SQL file | Purpose |
| --- | --- | --- |
| 1 | [setup/03_quality.sql](../sql/setup/03_quality.sql) | 34 data-quality checks and source row counts; raises an error on blocking issues. |
| 2 | [00_model.sql](../sql/00_model.sql) | Order-level sales, customer summaries and review/delivery views. |
| 3 | [01_sales.sql](../sql/01_sales.sql) | Monthly sales, state shares and categories. |
| 4 | [02_customers.sql](../sql/02_customers.sql) | Repeat purchasing, spending quintiles and repurchase intervals. |
| 5 | [03_delivery.sql](../sql/03_delivery.sql) | Delivery rates and review comparisons. |
| 6 | [04_results.sql](../sql/04_results.sql) | SELECT statements to inspect each result table. |

In pgAdmin, select and execute one `SELECT` at a time when a file contains several result sets. For example:

```sql
SELECT * FROM q1_monthly ORDER BY month;
SELECT * FROM q2_customer_segments ORDER BY customer_type;
SELECT * FROM q3_review_scores ORDER BY delivery_status;
```

Views read the imported source tables; the analysis does not update the CSVs or source records. Analytical views can be recreated when the SQL changes. If a blocking quality check fails, the error's `DETAIL` lists the failed checks and affected counts. Resolve those issues and rerun the quality script before proceeding; diagnostic temporary views need not survive a failed batch or closed session.

## Command-line alternative

Open a terminal in the repository root. Make sure PostgreSQL's `bin` directory is on `PATH`; on Windows you can also invoke the executables using their full installation paths. Put the nine CSVs in `data/raw/` and run:

```bash
createdb -h localhost -U postgres olist_portfolio
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f sql/setup/01_schema.sql
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f sql/setup/02_import.psql
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f sql/run_analysis.psql
```

Replace the user, host and database name if needed. Passwords are entered through PostgreSQL's normal authentication prompt. The import script uses `\copy` and a transaction; a failed import stops the script and rolls back all nine imports.

Files ending in **`.psql` contain client commands** such as `\copy` and `\ir`. Run them with `psql`; they are not valid pgAdmin Query Tool SQL. Use pgAdmin's import dialog and the `.sql` sequence above when working in the GUI.

## Export and test

You can save each pgAdmin result grid as CSV. The SQL-only command-line export writes the 10 tables to their existing paths in `reports/results/`, replacing the committed CSV outputs locally:

```bash
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f sql/export_results.psql
```

The existing charts are presentation outputs. Regenerating them is optional; the PostgreSQL workflow reproduces the data behind them.

Run the native SQL regression checks with:

```bash
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f tests/postgres_metrics.sql
```

The test creates `olist_metric_test` within a transaction, sets a local search path, and rolls everything back. It does not edit project source tables. It needs permission to create a schema in the chosen database.
