# Olist e-commerce analysis

**Three business questions, answered with SQL: where sales come from, who returns, and how delivery relates to customer reviews.**

[Q1: Sales](reports/Q1-sales.md) · [Q2: Customers](reports/Q2-customers.md) · [Q3: Delivery](reports/Q3-delivery.md) · [Methodology](docs/methodology.md)

This portfolio project analyses the Brazilian e-commerce dataset published by Olist. It starts with a relational model and data-quality checks, then uses joins, CTEs and window functions to investigate sales concentration, repeat purchasing and delivery performance.

The original research was written in PostgreSQL. This repository also includes a reviewed DuckDB workflow so the results can be reproduced locally without a database server. Python handles CSV loading, validation and chart rendering; the analytical logic lives in SQL.

## At a glance

| Measure | Result | Scope |
| --- | ---: | --- |
| Source orders | 99,441 | All order statuses |
| Delivered orders | 96,478 | Sales and customer analysis |
| Purchasing customers | 93,358 | Unique people with a delivered order |
| Merchandise sales | R$13,221,498.11 | Item prices; excludes freight |
| Delivery-eligible orders | 96,470 | Delivered, with actual and estimated delivery dates |

The source contains purchases from September 2016 to October 2018. Delivered purchases end in August 2018. The monthly sales charts focus on January 2017–August 2018; other headline results use the full observed delivered-order history. These are historical observations, not current Olist performance.

## What the analysis found

| Question | Evidence | Business implication to investigate |
| --- | --- | --- |
| **Q1. Where are sales concentrated?** | São Paulo accounts for **38.33%** of merchandise sales; SP, RJ and MG together account for **63.38%**. | Prioritise operational capacity in the largest markets and investigate growth elsewhere. |
| **Q2. How much do repeat customers contribute?** | Repeat customers are **3.00%** of customers, **6.14%** of orders and **5.51%** of sales. The highest-spending fifth contributes **56.62%** of sales. | Test retention initiatives using consistent follow-up windows and a control group. |
| **Q3. How does delivery relate to reviews?** | **8.11%** of eligible deliveries are late by timestamp. Late orders average **2.57/5**, versus **4.29/5** for on-time orders. | Investigate delay-prone routes and test customer communication improvements. |

These implications are proposals for further work. The dataset does not measure the effect of an intervention, profit or customer lifetime value.

![Repeat customer contribution across customers, orders and merchandise sales](reports/figures/Q2/repeat_contribution.png)

![Order-level review scores by delivery status](reports/figures/Q3/review_scores.png)

## Explore the research

- [Q1 — Sales performance](reports/Q1-sales.md): monthly volume, revenue growth, state concentration and product categories.
- [Q2 — Customer behaviour](reports/Q2-customers.md): one-time versus repeat customers, spending quintiles and first repurchase intervals.
- [Q3 — Delivery and satisfaction](reports/Q3-delivery.md): delivery speed, late-delivery rates, geographic differences and review scores.
- [Validation report](docs/validation.md): quality checks, metric corrections, reconciliations and limitations.
- [Original research archive](archive/README.md): all five original SQL files, 15 original charts and the ERD, preserved for provenance.

## Reproduce the results

Requires **Python 3.11+**. Tested locally with Python 3.13; CI runs the synthetic analytical tests without downloading the dataset.

```bash
git clone https://github.com/autunno816-ux/olist-ecommerce-analysis.git
cd olist-ecommerce-analysis
python -m venv .venv
```

Activate the environment:

```powershell
# Windows PowerShell
.venv\Scripts\Activate.ps1
```

```bash
# macOS / Linux
source .venv/bin/activate
```

Then install dependencies, download the nine CSVs listed in [data/README.md](data/README.md) into `data/raw/`, and run:

```bash
python -m pip install -r requirements.txt
python -m unittest discover -s tests -v
python scripts/run_analysis.py --data-dir data/raw
```

The runner checks keys and join coverage, executes the reviewed SQL, reconciles sales totals and writes 10 aggregate result tables, a quality-check table, a source manifest and 17 figures to `reports/`. It stops on blocking quality failures. You can supply an existing CSV folder with `--data-dir` or a separate destination with `--output-dir`. `--no-charts` exports only the evidence tables.

Raw CSVs, databases, environment files and credentials are excluded from Git. The committed aggregates and figures let readers inspect the work without downloading the source data.

## Repository guide

```text
sql/                  Reviewed analytical model and Q1/Q2/Q3 queries
scripts/              CSV loading, quality checks and chart rendering
tests/                Small counterexamples for analytical correctness
reports/              Research pages, reviewed figures and aggregate results
docs/                 Metric definitions, data model and validation
data/                 Dataset instructions; raw CSVs stay local
archive/              Original PostgreSQL SQL, charts and ERD
.github/workflows/    Automated tests and documentation-link checks
```

## Analytical decisions

- Revenue means **merchandise item value in BRL**, excluding freight. It is not Olist's platform revenue, profit or net revenue after refunds.
- Customers are identified with `customer_unique_id`; `customer_id` is the order-level customer record.
- Items are aggregated before joining to orders. Multiple reviews are averaged within each order, so an order receives equal weight in the score comparison.
- Timestamp-based lateness is kept for comparability. A calendar-date definition produces **6.77%** rather than **8.11%**; [Q3](reports/Q3-delivery.md) explains why.
- Repeat purchasing is observed within a finite extract. The 3.00% share is not a cohort retention rate, and first-repeat intervals include same-day purchases.

See [methodology](docs/methodology.md) for populations, denominators, exclusions and temporal caveats.

## Source and attribution

Data: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist on Kaggle. The publisher describes it as anonymised commercial data. The raw dataset is not redistributed here; consult the source page for its terms.

Original SQL analysis and figures: [autunno816-ux](https://github.com/autunno816-ux). Repository packaging, a portable execution workflow and validation refinements were prepared with AI assistance. This is an independent portfolio project, not an official Olist report.
