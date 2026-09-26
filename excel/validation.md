# Excel validation

Validated on 26 September 2026 against the same original CSV snapshot as the reviewed PostgreSQL project.

## Controls and definitions

| Full-history metric | Verified result |
| --- | ---: |
| Delivered merchandise GMV | R$13,221,498.11 |
| Delivered orders | 96,478 |
| Unique purchasing customers | 93,358 |
| Merchandise AOV | R$137.04158575 |
| Delivered item rows | 110,197 |

GMV sums item prices and excludes freight and payment values. Orders use `order_id`; people use `customer_unique_id`. All delivered orders in the snapshot have item records. Source controls were recomputed independently from CSVs and agree with the SQL methodology.

## Native Excel interaction checks

The saved workbook was reopened in desktop Microsoft Excel 16.0. Native slicer selection, formula recalculation and chart bindings were checked for these scenarios. Money matched to less than R$0.01; integer counts matched exactly. AOV matched to less than R$0.000001.

| Slicer selection | GMV (BRL) | Orders | Distinct customers | Result |
| --- | ---: | ---: | ---: | --- |
| All | 13,221,498.11 | 96,478 | 93,358 | PASS |
| Year 2017 | 5,962,902.01 | 43,428 | 42,136 | PASS |
| State SP | 5,067,633.16 | 40,501 | 39,156 | PASS |
| Year 2018 and SP | 2,919,328.17 | 23,335 | 22,795 | PASS |
| Year 2016 and AP | 0.00 | 0 | 0 | PASS |
| Reset All | 13,221,498.11 | 96,478 | 93,358 | PASS |

The zero-result selection returns zero GMV, orders and customers, with `n.a.` for AOV. Both slicers were cleared before the final save. The all-history controls were then rechecked.

Both slicers connect to the same four dashboard PivotTables. The distinct-customer pivot contains one row per selected person, so the KPI does not sum overlapping monthly/state customer counts. The three charts reference formula-backed cells tied to the filtered pivots. Their calendar stays fixed at September 2016-August 2018; excluded months show zero selected orders and GMV.

## Workbook reconciliation

All 21 controls on `checks` passed in the saved all-history view. They compare the source tables, headline metrics, monthly totals, state totals, category totals, customer segments, repeat intervals and dashboard with independent source controls. Full-history dashboard controls ask the reader to check filters when a selection differs from the full population.

No unexpected cached formula errors were found in `Dashboard`, `analysis` or `checks`. The workbook has 10 native PivotTables, all on `pivot diagram`, two native slicer caches and three editable Excel charts. It has no external workbook links. All 12 original Power Query definitions and their connections were retained.

Twelve retained source tables were compared with the original workbook over 7,693,932 populated cells. There were zero value mismatches. The original `fact_orders` columns A:I are unchanged; the added `purchase_year` formula column supplies the year slicer.

## Corrections and scope differences

- The old first-repeat summary showed 808 customers in 91-365 days and 85 over 365 days. Refreshing from the correct detail yields **811 and 82**. All 2,801 detail intervals match calendar-date differences independently calculated from the CSVs.
- Repeat GMV share is **5.51%**; **6.14%** is the repeat order share. These denominators remain distinct.
- Repeat order AOV is **R$123.02**, calculated as segment GMV / segment orders. The unweighted average of customer AOVs, R$122.96, is a different measure.
- Missing or unmapped categories remain in **Unknown**, representing R$175,967.21 and 1,559 items. Omitting them would understate category GMV.
- Excel charts use full delivered history. The SQL monthly chart uses January 2017-August 2018. The 2016 difference is **R$40,470.98 and 267 orders**.
- November 2016 has zero delivered orders and is explicitly retained in the monthly calendar. AOV and growth from a zero denominator display `n.a.`.
- Summed monthly customer counts would be 95,194 and summed state customer counts 93,396. Neither is the correct overall customer count of 93,358.

## Visual and refresh verification

Dashboard, final analysis and reconciliation views were exported through native Excel for visual review. The final dashboard preview is `dashboard.png`. Controls, titles, currency formats, typography and chart labels were checked for legibility.

The delivered snapshot opens and filters without the external CSV folder. Native PivotTables were rebuilt/refreshed from retained tables and formulas recalculated. External Power Query `Refresh All` was not run as part of this release. Its source queries still refer to the original local CSV folder. Follow the [refresh steps](README.md#refresh-the-source-data) before attempting to load a different dataset; independent controls and written insights must also be updated.

## File identity

Workbook SHA-256: `c2976fad9980805901467b7d57ce5f8ddd3a99bf6864be5b0d2c5419e20dace8`.
