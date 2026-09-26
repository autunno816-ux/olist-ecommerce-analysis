# Dataset setup and attribution

Download the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from its publisher's Kaggle page, extract the CSV files, and place the following nine files in `data/raw/`.

| Filename | Rows in validated snapshot |
|---|---|
| olist_customers_dataset.csv | 99441 |
| olist_orders_dataset.csv | 99441 |
| olist_order_items_dataset.csv | 112650 |
| olist_order_payments_dataset.csv | 103886 |
| olist_order_reviews_dataset.csv | 99224 |
| olist_products_dataset.csv | 32951 |
| olist_sellers_dataset.csv | 3095 |
| olist_geolocation_dataset.csv | 1000163 |
| product_category_name_translation.csv | 71 |

Use the [PostgreSQL / pgAdmin setup guide](../docs/postgresql-setup.md) to create the tables and import these files. For command-line import, run the following from the repository root after creating the schema:

```bash
psql -X -h localhost -U postgres -d olist_portfolio -v ON_ERROR_STOP=1 -f sql/setup/02_import.psql
```

The import order is customers, orders, products, sellers, order items, payments, reviews, geolocations and category translation. The `psql` script imports all nine files in one transaction and reads local files without changing them. In pgAdmin, import one table at a time in the same order using CSV format, UTF-8 encoding and Header enabled.

For SQL reproduction, keep separate raw CSV files under the ignored `data/raw/` directory. Do not place CSV copies in `reports/` or `archive/`; those directories are published. The [Excel supplement](../excel/README.md) separately includes the source worksheets and derived working tables embedded in the supplied workbook, so its saved dashboard opens without a CSV download.

The source publisher describes the data as anonymised commercial records covering 2016–2018. Attribution belongs to Olist and the dataset contributors. Consult the publisher's page for the dataset's current license and conditions. This repository publishes aggregate analytical results and the Excel workbook's embedded source and working tables; it does not commit the raw CSV files separately or change the source terms.

The Excel workbook preserves six CSV source queries for orders, order items, payments, products, category translation and customers, plus six derived queries. Their original paths point to the author's local `Desktop/Olist ECOMMERCE/data_excel` folder. To refresh on another machine, follow the [Excel refresh instructions](../excel/README.md#refresh-the-source-data); SQL imports continue to use the nine files listed above.

Source-file SHA-256 hashes and byte counts are saved in [metrics.json](../reports/results/metrics.json). They identify the snapshot used here; a new download may differ and should be revalidated rather than assumed identical.
