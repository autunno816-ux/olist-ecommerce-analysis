# Power BI validation

Validated on 18 September 2026 with Power BI Desktop 2.157.1354.0 on Windows.

## Data and definitions

- The ten aggregate CSVs match the SHA-256 hashes in `snapshot-manifest.json`. The ten source tables were reconciled to their CSV rows; six presentation tables supply rankings and repeat-customer contribution.
- The model contains 16 tables and 37 measures. SQL owns the analytical populations, joins and segmentation. DAX supplies display measures and calculated labels.
- Headline values agree with the reviewed SQL: 96,478 delivered orders, R$13,221,498.11 merchandise sales, 93,358 customers, 2,801 repeat customers and 96,470 delivery-eligible orders.
- Timestamp lateness is 8.11%; calendar-date lateness is 6.77%. Late and on-time review means use 7,661 and 88,163 reviewed orders respectively.
- State sales and category shares use all merchandise sales as their denominator. The spending-fifth cumulative series ends at 100%.
- The delivery scatter uses reviewed eligible orders for both axes. Delay-ranking bars use all delivery-eligible orders; their population is stated separately.

See the [SQL validation record](../docs/validation.md) and [metric definitions](../docs/methodology.md).

## Native report checks

- Power BI Desktop loaded and refreshed the aggregate model, rendered all three report pages and saved the portable PBIX. The delivered PBIX was reopened with its included data.
- All 38 native visual definitions were reviewed, including 12 headline cards and 14 charts. Titles, units, sorting, percentage scales, sample sizes and footer definitions were checked against the SQL results.
- The PBIX report definitions match the versioned PBIR definitions. Display pages are **Sales Performance**, **Customer Behaviour** and **Delivery & Satisfaction**.
- Cross-visual filtering is disabled because the aggregate tables have different grains. Hover, sorting and focus mode remain available.
- The three-page PDF contains native Power BI exports. Correctly scaled pages from two export passes were assembled without changing chart content, resolving a Desktop export scaling inconsistency. All three final pages were visually inspected and rendered to the GitHub PNG previews.
- The PowerShell updater was exercised in a separate copy and regenerated all 16 tables while retaining calculated display columns. The final `-Check` source-freshness check passed.

## Reproduction limits

The PBIX, PDF and previews are historical snapshots. Updating the CSVs or semantic model does not update these files automatically; follow the [refresh instructions](README.md). The editable project retains the BIM semantic-model format supported by the updater.

GitHub Actions validates the SQL regression checks and repository helpers. It does not run Power BI Desktop or render the report. Native visual checks are recorded here rather than represented as automated CI coverage.
