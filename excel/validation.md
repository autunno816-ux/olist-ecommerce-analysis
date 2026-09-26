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

All **32 controls** on `checks` passed in the saved all-history view: the original 21 controls plus 11 checks for the restored analysis. They compare source tables, headline metrics, monthly/state/category totals, customer segments, repeat intervals and dashboard values, and verify Welch statistics, customer-level means, repeat frequency and indexed-series baselines. Full-history dashboard controls ask the reader to check filters when a selection differs from the full population.

No unexpected cached formula errors were found in `Dashboard`, `analysis` or `checks`. The workbook has **12 native PivotTables**, all on `pivot diagram` (eight full-history analysis and four dashboard), two native slicer caches and **14 editable Excel charts** (11 analysis and three dashboard). It has no external workbook links. All 12 original Power Query definitions and their connections were retained. The intentional `#N/A` in `'pivot diagram'!AB123` creates the November 2016 AOV chart gap because that month has no orders.

Twelve retained source tables were compared with the original workbook over 7,693,932 populated cells. There were zero value mismatches. The original `fact_orders` columns A:I are unchanged; the added `purchase_year` formula column supplies the year slicer.

## Original research and statistical verification

The original workbook contains 33 chart objects representing 13 distinct subjects. All 13 subjects are retained, with duplicate chart copies consolidated. The [preservation map](preservation-map.md) records original and restored ranges for the chart subjects and substantive analytical blocks. Source-cell preservation was checked separately from preservation of the research scope.

An independent inspection of the saved workbook's ZIP/XML contents passed **130 checks**, including all 13 subjects, restored test statistics, exact repeat-order frequencies, indexed values, shifted formula references and chart series point counts. The final saved workbook was checked again after all six slicer scenarios, with both filters cleared; all 32 workbook controls still passed.

| Restored calculation | Verified result |
| --- | --- |
| Welch customer-level mean AOV, one-time / repeat | R$137.9582954383 / R$122.9585583238 |
| Welch t / degrees of freedom | −5.595997434259582 / 3,229.060207778023 |
| Excel two-sided p-value | 2.3767438686897664 × 10⁻⁸ |
| Repeat orders 2/3/4/5/6/7/9/15 | 2,573/181/28/9/5/3/1/1 customers |
| Repeat-frequency totals | 2,801 customers and 5,921 orders |
| Indexed baseline | January 2017 GMV, order and AOV indices all equal 100 |
| Category coverage and 80% crossover | 72 categories; top 17 = 79.68751561%; top 18 = 81.28866276% |

An independent CSV/SciPy calculation reproduced the Welch result. Using the full fractional degrees of freedom gives p = 2.376740337558702 × 10⁻⁸; using integer degrees of freedom gives 2.3767438692743723 × 10⁻⁸, agreeing with Excel to numerical precision. This small difference reflects Excel's integer degrees-of-freedom treatment. See the [customer-level test note](customer-welch-note.md) for formulas and interpretation.

## Corrections and scope differences

- The old first-repeat summary showed 808 customers in 91-365 days and 85 over 365 days. Refreshing from the correct detail yields **811 and 82**. All 2,801 detail intervals match calendar-date differences independently calculated from the CSVs.
- Repeat GMV share is **5.51%**; **6.14%** is the repeat order share. These denominators remain distinct.
- Repeat order AOV is **R$123.02**, calculated as segment GMV / segment orders. The unweighted average of customer AOVs, **R$122.96**, is retained as the outcome used in the restored Welch t-test. Each metric is labelled with its weighting.
- Missing or unmapped categories remain in **Unknown**, representing R$175,967.21 and 1,559 items. Omitting them would understate category GMV.
- Excel's monthly levels and full-history analyses use September 2016-August 2018. Its original indexed comparison intentionally uses January 2017-August 2018, with January 2017 = 100. The SQL monthly chart also uses January 2017-August 2018. The full-history 2016 difference is **R$40,470.98 and 267 orders**.
- November 2016 has zero delivered orders and is explicitly retained in the monthly calendar. AOV and growth from a zero denominator display `n.a.`.
- Summed monthly customer counts would be 95,194 and summed state customer counts 93,396. Neither is the correct overall customer count of 93,358.

## Visual and refresh verification

The dashboard and four restored analysis pages were rendered through native Excel and visually inspected: [dashboard](dashboard.png), [Welch test and repeat-purchase detail](analysis-ttest.png), [growth](analysis-growth.png), [category ranking and Pareto](analysis-pareto.png), and [pricing and repeat timing](analysis-scatter.png). Reconciliation views were also reviewed. Controls, titles, currency formats, typography and chart labels were checked for legibility.

The delivered snapshot opens and filters without the external CSV folder. Native PivotTables were rebuilt/refreshed from retained tables and formulas recalculated. External Power Query `Refresh All` was not run as part of this release. Its source queries still refer to the original local CSV folder. Follow the [refresh steps](README.md#refresh-the-source-data) before attempting to load a different dataset; independent controls and written insights must also be updated.

## File identity

Workbook SHA-256: `626d1d1e577c20402c106402ca692369c7b2d355652ae8522a7f43a9fdedb802`.
