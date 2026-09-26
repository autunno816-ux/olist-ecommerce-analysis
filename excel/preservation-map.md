# Original research preservation map

Verified on 26 September 2026 by native Excel recalculation, six slicer scenarios, independent saved-file review and a before/after comparison of the dashboard expansion. The six additional dashboard research views retained their analysis sources and remained unchanged under every filter scenario. See [validation](validation.md) and the [customer-level Welch note](customer-welch-note.md).

The refinement preserves the original analytical questions, calculations, distributions and chart subjects. It standardises formatting and consolidates duplicate chart copies. The analytical scope includes the customer-level Welch t-test, indexed monthly comparison, category price and Pareto analysis, customer shares, full repeat-order frequency distribution, first-repeat intervals and state comparisons.

The original workbook contains **33 chart objects representing 13 distinct subjects**: 13 charts on `analysis`, with additional copies on `pivot diagram` and `Dashboard`. The expanded layout contains **20 charts: 11 on analysis and nine on Dashboard**. The dashboard contains three live charts plus six unfiltered research views. Every original subject remains mapped to the complete research; the six overview copies do not replace analytical detail.

## Original chart subjects

Original locations refer to the supplied workbook before refinement. An anchor is the chart's approximate cell footprint; data ranges identify the underlying subject independently of layout.

| ID | Original subject | Original chart anchor | Original data / supporting range | Replacement | Verified new range / chart |
| --- | --- | --- | --- | --- | --- |
| C01 | Monthly GMV | `analysis!E68:I77` | `'pivot diagram'!A2:B25` | Existing live monthly-GMV dashboard chart; full-history monthly table retained | `Dashboard!B21:O35`; verified |
| C02 | Monthly GMV and order count | `analysis!A43:F61` | `'pivot diagram'!K3:M26` | Full-history GMV/order combo; existing dashboard also retains a separate live monthly-order chart | `analysis!B237:G258`; verified |
| C03 | Monthly GMV and AOV | `analysis!E53:I65` | `'pivot diagram'!A30:C54` | Full-history monthly GMV/AOV combo, with clear units | `analysis!I237:M258`; verified |
| C04 | Indexed monthly GMV, orders and AOV, January 2017 = 100 | `analysis!E37:I52` | `analysis!E16:H36` | All three indexed series, January 2017–August 2018 | `analysis!I207:M229`; verified |
| C05 | Top 10 categories by GMV | `analysis!S1:AD20` | `'pivot diagram'!B58:C68`; `analysis!J1:R74` | Ranked category GMV and shares of all GMV | `analysis!B263:G284`; verified |
| C06 | Category Pareto: GMV, cumulative share and 80% reference | `analysis!S20:AD46` | `'pivot diagram'!A72:H145`; `analysis!J1:R74` | Sorted category GMV, cumulative share and 80% line | `analysis!I263:M284`; verified |
| C07 | Category items sold versus average item price | `analysis!T48:AD71` | `'pivot diagram'!Y2:AD75`; `analysis!J1:M74` | Category scatter, with item volume and average item price | `analysis!B289:G310`; verified |
| C08 | Customer-type shares of GMV, customers and orders | `analysis!AG5:AK23` | `'pivot diagram'!AQ2:AT12`; `analysis!AG1:AK4` | One-time/repeat contribution across all three denominators | `analysis!B182:G202`; verified |
| C09 | Orders per repeat customer | `analysis!AG52:AJ67` | `analysis!AE48:AJ59`; `'pivot diagram'!AW11:AX22` | Exactly-two / three-plus depth pie, with all eight exact order counts in the adjacent research table | `analysis!I182:M202`; verified |
| C10 | Time to second purchase: counts and shares | `analysis!AZ1:BG16` | `analysis!AV1:AX10` | Count/share combo with all six calendar-day interval buckets | `analysis!I289:M310`; verified |
| C11 | Top 10 states by GMV | `analysis!BN1:BW20` | `'pivot diagram'!AZ1:BA12`; `analysis!BI1:BL31` | Existing live dashboard state ranking; all-state full-history detail retained | `Dashboard!Q21:W50`; verified |
| C12 | Top 10 states by order count | `analysis!BY1:CH18` | `'pivot diagram'!BH1:BI12`; `analysis!BI1:BL31` | Distinct delivered-order ranking | `analysis!B315:G336`; verified |
| C13 | State order count versus AOV | `analysis!BN21:BU37` | `'pivot diagram'!BQ1:BW12`; `analysis!BI1:BL31` | State scatter with stated sample and units | `analysis!I315:M336`; verified |

The restored state scatter uses the top 10 states by delivered orders, the same ten-state set as the original selected major-state comparison. Rebuilt chart series exclude summary rows. The dashboard monthly-order chart at `Dashboard!B37:O50` supplements these 13 subjects. C01 and C11 reproduce the full-history subjects when the dashboard slicers are cleared; their filtered state is an additional interactive view.

## Additional dashboard research views

These six charts use the existing unfiltered research sources. Dashboard section bars at rows 53 and 89 identify the research areas. The upper three live charts retain their existing locations and filter behavior. Source bindings, filter invariance and native visual output were checked for the additions.

| Original subject | Complete analysis chart | Dashboard overview copy | Expansion verification |
| --- | --- | --- | --- |
| C04 — Indexed GMV, orders and AOV | `analysis!I207:M229` | `Dashboard!B56:L70` | PASS |
| C05 — Top 10 categories by GMV | `analysis!B263:G284` | `Dashboard!N56:W70` | PASS |
| C06 — Category GMV Pareto | `analysis!I263:M284` | `Dashboard!B72:L86` | PASS |
| C08 — Customer/order/GMV shares | `analysis!B182:G202` | `Dashboard!B93:L107` | PASS |
| C09 — Repeat depth | `analysis!I182:M202` | `Dashboard!N93:W107` | PASS |
| C10 — Time to second purchase | `analysis!I289:M310` | `Dashboard!B109:L123` | PASS |

The full-history customer AOV card occupies `Dashboard!N72:W86`. Its mean values are at `T76:T77`, t statistic at `T79`, p-value at `T80`, and test link at `N85` points to `analysis!B140`. These values use equal customer weighting and do not follow the dashboard slicers. The detailed test and exact repeat-frequency tables remain on `analysis`. A compact findings area at `Dashboard!N109:W123` complements the chart views; the complete dashboard occupies `A1:W126`.

Research views use September 2016–August 2018, with the intentionally retained exception of the indexed comparison: January 2017–August 2018, January 2017 = 100.

## Calculations and supporting detail

| Original research block | Original range | Content that must remain inspectable | New range | Verification |
| --- | --- | --- | --- | --- |
| Full-history monthly GMV, order count and AOV | `'pivot diagram'!A30:C54` and `K3:M26` | All observed purchase months; explicit zero for November 2016; GMV / orders = AOV | `analysis!B24:F49` | PASS |
| Indexed monthly comparison | `analysis!E16:H36` | Three series; each January 2017 base equals 100; no shifted denominators | `analysis!B209:E229` | PASS |
| Category detail | `analysis!J1:R74` | All 72 categories; items, GMV, average item price, GMV share and cumulative share; Pareto rank order and 80% reference retained | `analysis!B59:G132`; average item price `G59:G132`; rank/threshold helpers at 'pivot diagram'!X40:AA112 | PASS |
| Customer segment totals and customer-level mean AOV | `analysis!AG1:AK4`; `customer_order_behaviour!H3:L6` | Segment people, orders and GMV; customer-level mean AOV and separately named weighted order AOV | Weighted table `analysis!I59:M62`; means `B143:E145` | PASS |
| Customer-type GMV/customer/order shares | `'pivot diagram'!AQ2:AT12` | Three separate denominators; each one-time/repeat pair totals 100% | `analysis!B172:E175` | PASS |
| Customer-level Welch t-test | `analysis!AM1:AP19`; `customer_order_behaviour!H17:K20` | Two means, sample SDs and customer counts; difference, SE, t, Welch df, two-sided p-value, decision and qualified interpretation | `analysis!B140:G165`; inputs `B143:E145`; t `C150`; df `C151`; p `C152`; decision `C154` | PASS |
| Exact repeat-order frequency | `analysis!AE48:AJ59`; `customer_order_behaviour!N1:O12`; `'pivot diagram'!AW11:AX22` | All eight exact order counts plus the exactly-two / three-plus summary | `analysis!I143:K152`; depth summary `I160:K162` | PASS |
| First-repeat intervals | `analysis!AV1:AX10` | Six calendar-day buckets, customer counts, shares and same-day limitation | `analysis!I70:K77`; narrative below | PASS |
| All-state detail and interpretation | `analysis!BI1:BL31` | All 27 states, delivered orders, GMV and AOV; top-state rankings trace to this population | `analysis!I24:M52`; geography narrative `B339:M342` | PASS |

## Verified controls

| Check | Verified control |
| --- | --- |
| Full delivered history | 96,478 orders; 93,358 people; GMV R$13,221,498.11; AOV R$137.04158575 |
| January 2017 index base | GMV, order and AOV indices each exactly 100 |
| All-category coverage | 72 categories; GMV R$13,221,498.11; 110,197 items; average item price = category GMV / category items |
| Category 80% crossover | Top 17: 79.68751561%; top 18: 81.28866276%; first crossing at category 18 |
| Repeat customer shares | Customers 3.00%; orders 6.14%; GMV 5.51% |
| Exact repeat frequency | Orders 2/3/4/5/6/7/9/15 → customers 2,573/181/28/9/5/3/1/1 |
| Repeat-frequency reconciliation | 2,801 people; weighted bucket orders sum to 5,921; exactly two = 91.86004998%; three-plus = 228 people |
| First-repeat intervals | Same day / 1–7 / 8–30 / 31–90 / 91–365 / over 365 days → 829/199/388/492/811/82 |
| Welch t-test | t ≈ −5.5959974343; df ≈ 3,229.060207778; original Excel two-sided p ≈ 2.3767438687 × 10⁻⁸ |
| Chart coverage | All C01–C13 mapped; 11 analysis + nine dashboard charts; six added research views retain their source bindings and are unchanged by filters |

Source-table preservation and research-scope preservation were verified separately. The source comparison covered 7,693,932 nonempty cells with zero mismatches, and the restored research passed 130 independent saved-file checks. The expanded dashboard passed all 32 workbook controls and six native slicer scenarios: monthly GMV and order chart totals matched the filtered KPIs, while all six research views remained unchanged. A further comparison found zero mismatches across 989 analysis cells, 208 checks cells and four KPI cells; all 11 analysis-chart series and pivot/slicer sources were preserved. Native dashboard and analysis previews were visually inspected.
