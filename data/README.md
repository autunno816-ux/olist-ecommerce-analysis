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

Run from the repository root:

```bash
python scripts/run_analysis.py --data-dir data/raw
```

Alternatively point `--data-dir` at an existing folder. The runner reads CSVs in place and does not modify them. Output goes to `reports/` unless `--output-dir` is set. Do not place raw files in `reports/` or `archive/`; those directories are published.

The source publisher describes the data as anonymised commercial records covering 2016–2018. Attribution belongs to Olist and the dataset contributors. Consult the publisher's page for the dataset's current license and conditions. This repository does not redistribute the raw dataset or change its terms. Only aggregate analytical results are committed.

Source-file SHA-256 hashes and byte counts are saved in [metrics.json](../reports/results/metrics.json). They identify the snapshot used here; a new download may differ and should be revalidated rather than assumed identical.
