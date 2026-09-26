# Olist Excel analysis

[Project overview](../README.md) · [SQL methodology](../docs/methodology.md) · [Excel validation](validation.md)

An interactive Excel supplement to the PostgreSQL project, built from the same historical Olist data. Purchase-year and customer-state slicers connect four KPI cards to monthly GMV, monthly orders and top-state charts.

[Download the workbook](Olist_Excel_Analysis.xlsx)

![Excel dashboard](dashboard.png)

## Use the workbook

Open the downloaded `.xlsx` in desktop Microsoft Excel. The saved workbook includes its data snapshot and can be explored without connecting to PostgreSQL or downloading CSVs separately.

1. Start on `dashboard`. Select a purchase year, a customer state, or both.
2. Read merchandise GMV, delivered orders, distinct purchasing customers and average order value together with the three charts. All use the same selected orders.
3. Use each slicer's clear button to return to the full delivered-order history.
4. Open `analysis` for the full-history category, customer-segment and first-repeat findings. These tables and written insights do not respond to dashboard slicers.

All 10 native PivotTables are on `pivot diagram`. Six support the full-history analysis; four support the dashboard. Both slicers connect to all four dashboard pivots, including the distinct-customer pivot. The original 12 source and working tables and 12 Power Query definitions are preserved. The dashboard's order data comes from the existing `fact_orders` query table, with an added `purchase_year` formula column.

## Metric definitions

| Measure | Definition |
| --- | --- |
| Merchandise GMV | Sum of `order_items.price` for orders recorded as delivered. BRL; excludes freight, payment amounts, fees and refunds. |
| Delivered orders | Distinct `order_id` after the year and state selections. |
| Purchasing customers | Distinct `customer_unique_id` in the selected orders. A person appearing in several months is counted once in the KPI. |
| Average order value | Selected merchandise GMV divided by selected delivered orders. |
| Year / month | Purchase timestamp, without timezone conversion. |
| Customer state | Customer address state, not seller origin. |

The Power Query order table aggregates item values to one row per delivered order before the dashboard pivots. The customer KPI counts distinct person labels under the active filters; it does not add monthly or state customer counts. The identifier `customer_id` belongs to an order-specific customer record and is not the person identifier.

With both filters cleared, the controls are **R$13,221,498.11 GMV**, **96,478 delivered orders**, **93,358 purchasing customers** and **R$137.04 AOV**. Delivered purchases span **15 September 2016–29 August 2018**.

The Excel monthly charts cover the full delivered-order history. The SQL and Power BI monthly series deliberately covers January 2017–August 2018 and totals R$13,181,027.13 across 96,211 orders. The difference is 267 delivered orders worth R$40,470.98 purchased in 2016; the two scopes reconcile. The full-history monthly analysis includes November 2016 as a zero-order month.

## Six findings

- **January–August 2018 GMV rose 141.1% year on year.** Orders rose 139.9%, while AOV increased 0.5%, so the observed growth mainly came from order volume. The comparison uses the same eight purchase months in each year.
- **SP generated 38.33% of GMV.** SP, RJ and MG together contributed 63.38% of merchandise sales, showing substantial concentration in three customer markets.
- **The top 10 product categories contributed 62.43% of GMV.** Health and beauty led with 9.33%. Shares use all delivered merchandise value, including products without a translated category; the displayed top 10 are a subset.
- **Repeat customers were 3.00% of buyers.** They generated 5.51% of GMV from 6.14% of orders. Order share and GMV share are separate measures.
- **Repeat-customer AOV was R$123.02, versus R$137.96 for one-time buyers.** Their higher observed spend per customer came through more orders. Segment AOV divides segment GMV by segment orders; it is not the unweighted mean of individual customer AOVs.
- **29.60% of first repurchases occurred on the same calendar day.** These 829 customers limit how confidently an observed second order can be interpreted as a later retention event.

Repeat means at least two delivered orders within the extract. First-repeat intervals use calendar-date differences, not elapsed 24-hour periods. The six interval groups contain **829** same-day customers, **199** at 1–7 days, **388** at 8–30 days, **492** at 31–90 days, **811** at 91–365 days and **82** after 365 days; together they reconcile to 2,801 repeat customers.

These figures are not a cohort retention rate: follow-up differs across customers, and recent customers have less time to return. All findings describe historical records, not current Olist performance, causal effects or profit. The final purchase periods may have incomplete follow-up of delivery outcomes.

## Refresh the source data

Exploring the saved snapshot does not require a refresh. To replace or refresh its CSV sources:

1. Put the six required source CSVs in a local folder: orders, order items, payments, products, category translation and customers. Keep their original filenames and column structures.
2. In **Data → Queries & Connections**, edit each of the six source queries and update its **Source** file path. The saved paths are absolute paths to the author's `Desktop/Olist ECOMMERCE/data_excel` folder. The six derived queries use those source queries.
3. Choose **Data → Refresh All**, then wait until the source and dependent Power Query queries finish loading. Check Queries & Connections for errors before continuing.
4. After the queries finish, explicitly refresh the PivotTables on `pivot diagram`. PivotTables can otherwise retain a cache from before the query refresh completed.
5. Check that the `purchase_year` calculated column in `fact_orders` has extended to every loaded order row; this table formula is designed to fill into new rows automatically. Recalculate the workbook and clear both dashboard slicers.
6. Reconcile the KPI totals, category and customer totals, interval counts and charts against the refreshed data. Review the written findings manually if the dataset changed, then save the workbook.

The saved snapshot, native pivot refresh and Excel recalculation were verified. A runtime **Refresh All** of the external CSV queries was not tested in this refinement. The figures above are controls for the supplied snapshot, not expected totals for a different dataset.

## Validation and source

The preservation comparison checked **7,693,932 nonempty cells** across the original 12 source and working tables and found **zero mismatches** in the original table ranges. The added year column supports the dashboard filters. See [Excel validation](validation.md) for metric checks and native workbook verification.

Data: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist on Kaggle and described by the publisher as anonymised commercial data. This workbook embeds the source worksheets and derived working tables supplied with the original Excel analysis. Raw CSVs are not committed separately. Consult the publisher's page for the dataset's terms; this project does not replace or alter them.

All nine supplied CSVs match the SHA-256 checksums in the project's [validated source manifest](../reports/results/metrics.json). Original analysis: [autunno816-ux](https://github.com/autunno816-ux). Workbook refinement and validation were prepared with AI assistance. This is an independent portfolio project.
