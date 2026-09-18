# Validation report

Assessment: **share with the documented limitations**. The reviewed aggregate outputs reconcile, analytical regression tests pass, and known data issues are disclosed. The original exploratory SQL and figures are retained as archival evidence, not as the reviewed execution path.

## Checks performed

The full local dataset run on 18 September 2026 completed 33 checks across primary keys, composite keys, parent-child relationships, missing fields, numeric ranges, temporal consistency and duplicate records. All blocking checks returned zero affected rows.

Delivered-order merchandise value independently recomputed from the item table is **R$13,221,498.11**. State, category, customer-segment and spending-quintile totals all reconcile to this exact amount. The order-level model contains **96,478** delivered orders and **93,358** people.

The primary workflow has also been executed directly on **PostgreSQL 18.6**, including schema creation, all nine CSV imports, data-quality checks, sales, customer and delivery queries and CSV export. All **10** PostgreSQL result tables match the published aggregates. The native SQL path runs **34** quality checks: the same 33 checks plus an empty-orders guard. All blocking checks returned zero affected rows.

Reproduce through the [PostgreSQL guide](postgresql-setup.md). Evidence: [PostgreSQL validation record](../reports/results/postgres_validation.json), [SQL quality checks](../sql/setup/03_quality.sql), [PostgreSQL regression tests](../tests/postgres_metrics.sql), [initial 33-check results](../reports/results/data_quality.csv) and [metrics and source checksums](../reports/results/metrics.json). The source manifest and chart-generation metadata in `metrics.json` describe the earlier optional helper run; PostgreSQL verification is recorded separately.

## Source issues retained and disclosed

| Check | Affected rows / entities |
|---|---|
| products: missing category | 610 |
| products: untranslated nonnull category | 13 |
| products: missing physical attribute | 2 |
| delivered orders: missing actual delivery | 8 |
| orders: carrier before approval | 1359 |
| orders: customer delivery before carrier | 23 |
| canceled orders: actual delivery exists | 6 |
| orders with multiple reviews | 547 |
| geolocations: exact duplicate rows | 261831 |
| payments: zero values | 9 |

Missing category labels and unmatched translations map to `unclassified`; the 13 untranslated products belong to two untranslated labels. Eight delivered orders with missing actual delivery dates are excluded only from delivery metrics. Temporal inconsistencies are flagged, not silently repaired. The 547 orders with multiple review rows motivate order-level averaging. Geolocation duplicates are not joined into the analysis. Zero-valued payment rows do not affect item-based sales.

## Corrections made for the reviewed edition

| Issue | Impact | Resolution |
| --- | --- | --- |
| Customer-segment revenue-share expression summed order counts | High: 6.14% was described as repeat-customer revenue share. | Report order share as 6.14% and money-based revenue share as 5.51%; keep separate fields and tests. |
| Original monthly-revenue image displays an `order_count` legend and order-volume scale | High: the named revenue artifact does not establish a revenue trend. | Generate separate order-count and BRL revenue plots from the reviewed monthly result table. |
| Original top-10 category pie | Medium: a pie normalises the displayed subset to a full circle, obscuring shares of total sales. | Use ranked bars with each category's share of all sales and an explicit denominator note. |
| Direct join between orders and reviews | Medium: orders with multiple reviews receive extra weight; state delay rates can also be distorted. | Average reviews within order, then join one row per order. Reviewed late/on-time scores are 2.57 and 4.29. |
| Midnight estimated-delivery timestamps | Medium: deliveries on the estimated calendar day can count as late. | Publish timestamp rate 8.11% and calendar-date rate 6.77%, using the same eligible population. |
| Original state chart stacks days and percentages and calls it a trend | Medium: unrelated units become an artificial stacked total; state order is not time. | Separate panels with named units and ranked states. |
| Original SQL contains missing separators and a missing opening parenthesis in table creation | Reproducibility: exploratory statements cannot run as one untouched script. | Preserve originals; provide reviewed PostgreSQL DDL, client-side CSV import and analytical SQL. |
| Category labels missing or untranslated | Coverage risk if inner-joined or dropped. | Retain an explicit unclassified category in the denominator. |

## Regression coverage

Native PostgreSQL regression SQL distinguishes a 20% revenue share from a 66.67% order share, exercises multi-item and multi-review orders, checks canceled-order exclusions, verifies customer identity and first-repeat intervals, and tests missing delivery dates plus same-day lateness. Fixtures run in a temporary test schema inside a transaction that is rolled back. CI starts PostgreSQL 18 and runs the schema, analytical scripts and regression SQL without Python in that job. A separate job checks the optional helper. Full dataset checks and charts are validated locally; CI does not download Kaggle data.

## Presentation review

The reviewed charts show currencies, time windows and denominator notes. Category charts state that the top 10 are a subset. State delivery comparisons keep days and percentages separate. Review charts disclose the reviewed-order sample and lack of causal identification. Original charts remain accessible in the archive with the correction notice.

## Limits

The extract is historical and has incomplete follow-up, selective reviews and observational comparisons. Counts and descriptive aggregates are suitable for portfolio presentation; retention effects, profit, current business performance and causal claims are not established. See the [full methodology](methodology.md).
