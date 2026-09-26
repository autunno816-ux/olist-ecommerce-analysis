# Excel validation

Validated on 26 September 2026 against the same original CSV snapshot as the reviewed PostgreSQL project. The expanded nine-chart dashboard passed native interaction checks, formula/data-preservation checks and visual review.

## Expanded dashboard verification

The dashboard contains three slicer-controlled sales charts and six full-history research charts. The latter cover indexed growth, top categories, Pareto concentration, customer/order/GMV shares, repeat depth and first-repeat intervals. A separate full-history customer AOV card links to the Welch test. The research charts and card remained unchanged through all six upper sales selections.

The final inventory confirms 20 chart objects (11 analysis and nine dashboard), 12 pivots and two slicers. The six research charts retain their analysis sources, and the `Dashboard!N85` link points to `analysis!B140`. A before/after comparison found zero mismatches across 989 analysis cells, 208 checks cells and four dashboard KPI cells, with all 11 analysis-chart series and the pivot/slicer sources unchanged. Native visual review covered the three dashboard sections through `A1:W126` and the banded analysis tables.

The customer-ID helper at `pivot diagram!178:100180` is grouped and hidden by default, with its summary above the group at row 177. Its PivotTable, source records and `COUNTA` KPI formula are retained. All six filter scenarios returned the expected GMV, order and distinct-customer counts while the helper stayed collapsed; all 32 workbook controls passed after reset.

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

Both slicers connect to the same four selected-population PivotTables. The distinct-customer pivot contains one row per selected person, so the KPI does not sum overlapping monthly/state customer counts. The upper three charts reference formula-backed cells tied to the filtered pivots. Their calendar stays fixed at September 2016-August 2018; excluded months show zero selected orders and GMV. All six scenarios passed both the monthly GMV/order chart totals check and the research-invariance check: the six research charts and customer-level AOV card retained the same full-history values, including when the upper selection contained no orders.

## Workbook reconciliation

All **32 controls** on `checks` passed in the saved all-history view: the original 21 controls plus 11 checks for the restored analysis. They compare source tables, headline metrics, monthly/state/category totals, customer segments, repeat intervals and dashboard values, and verify Welch statistics, customer-level means, repeat frequency and indexed-series baselines. Full-history dashboard controls ask the reader to check filters when a selection differs from the full population.

No unexpected formula errors were found in `Dashboard`, `analysis` or `checks`. The workbook has **12 native PivotTables**, all on `pivot diagram` (eight unfiltered research and four slicer-connected), two native slicer caches and **20 editable Excel charts** (11 analysis and nine dashboard). The dashboard contains three live charts plus six full-history research charts. There are no external workbook links, and all 12 original Power Query definitions and connections are retained. The intentional `#N/A` in `'pivot diagram'!AB123` creates the November 2016 AOV chart gap because that month has no orders.

Twelve retained source tables were compared with the original workbook over 7,693,932 populated cells. There were zero value mismatches. The original `fact_orders` columns A:I are unchanged; the added `purchase_year` formula column supplies the year slicer.

## Original research and statistical verification

The original workbook contains 33 chart objects representing 13 distinct subjects. All 13 subjects are retained, with duplicate chart copies consolidated. The [preservation map](preservation-map.md) records original and restored ranges for the chart subjects and substantive analytical blocks. Source-cell preservation was checked separately from preservation of the research scope.

The expanded dashboard adds six overview copies of existing research charts. All 11 analysis charts and the detailed calculations remain in place. Formatting changes apply banded `TableStyleMedium2` to the 12 retained tables and alternating white/pale-blue rows across 14 analysis/checks table bodies. All 12 pivots use the native custom `OlistPivotBanded` style; four rendered pivot samples confirmed visible alternating pale-blue/white bands, blue headers and totals. After this final style change, the before/after comparison again found zero mismatches in the preserved analysis/checks/KPI cells, analysis-chart series and pivot/slicer sources, and all 32 workbook controls passed.

The restored research passed **130 independent ZIP/XML checks**, including all 13 subjects, restored test statistics, exact repeat-order frequencies, indexed values, shifted formula references and chart series point counts. The subsequent dashboard expansion passed the preservation comparison described above. All 32 workbook controls passed again after all six native slicer scenarios, with both filters cleared for the saved view.

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

Native Excel previews were visually inspected: [live sales overview](dashboard.png), [products and growth](dashboard-products.png), [customer overview](dashboard-customers.png), [banded analysis tables](analysis-banded.png), [Welch test](analysis-ttest.png), [growth](analysis-growth.png), [category Pareto](analysis-pareto.png), and [pricing and repeat timing](analysis-scatter.png). The review checked all dashboard sections, scope labels, source-table and analysis banding, chart labels, and readable text without clipping or unintended black fills.

The delivered snapshot opens and filters without the external CSV folder. Native PivotTables were rebuilt/refreshed from retained tables and formulas recalculated. External Power Query `Refresh All` was not run as part of this release. Its source queries still refer to the original local CSV folder. Follow the [refresh steps](README.md#refresh-the-source-data) before attempting to load a different dataset; independent controls and written insights must also be updated.

## File identity

The author subsequently saved English PivotTable labels in Excel. This release publishes that exact saved file. Read-only inspection confirmed all 32 cached controls, the headline metrics, Welch results, charts, pivots, slicers and collapsed customer helper; the workbook was not resaved by automation.

Workbook SHA-256: `4322ffd33e426c360643e63e54db323549ab4167fe61a86b60c789c6142b43be`.
