# Methodology and metric definitions

[Overview](../README.md) · [Validation](validation.md) · [Model](data-model.md)

## Source and coverage

Nine local CSVs from the Olist public dataset were used. [The saved manifest](../reports/results/metrics.json) contains filenames, row counts, file sizes and SHA-256 checksums. The local snapshot was validated on 18 September 2026; this is a validation date, not a claim that the source represents 2026 trading.

Source purchase timestamps span 4 September 2016–17 October 2018. Delivered-order purchase timestamps span 15 September 2016–29 August 2018. Timestamps are interpreted as naive source timestamps, with no timezone conversion. A timezone is not inferred from the analyst's machine.

## Populations and formulas

| Metric | Definition / denominator |
| --- | --- |
| Merchandise sales | Sum of `order_items.price` for delivered orders, in BRL; excludes freight, payments, fees and refunds. |
| Delivered orders | One row per order with `order_status = 'delivered'`. The sales model requires a matching customer and item; checks verify no delivered orders are lost. |
| Monthly sales | Purchase month, January 2017 through August 2018 inclusive, delivered status at extraction. |
| Monthly growth | `(current sales - previous sales) / previous sales × 100`; only consecutive months and nonzero prior sales. |
| State/category sales share | Group merchandise sales / all delivered-order merchandise sales. No monthly-series date filter. |
| Purchasing customer | Distinct `customer_unique_id` among delivered orders. |
| Repeat customer | Person with at least two delivered orders in the observed history. |
| Customer / order / revenue share | Segment people / all people; segment orders / all orders; segment merchandise sales / all merchandise sales, respectively. |
| Average customer spend | Sum of observed merchandise value / customers in that segment, not order value or lifetime value. |
| Customer quintile | `NTILE(5)` by descending observed merchandise value, ties broken by customer ID. |
| First repeat interval | Calendar days from first to second delivered purchase; ordered by timestamp then order ID. Same-day orders included. |
| Delivery-eligible order | Delivered status plus nonnull actual and estimated customer-delivery timestamps. |
| Delivery time | Actual delivery date minus purchase date, in calendar days; not fractional elapsed 24-hour periods. |
| Late rate | Eligible orders whose actual timestamp exceeds estimated timestamp / all eligible orders. |
| Calendar late rate | The same comparison after casting both timestamps to dates. |
| Order-level review | Mean of available valid review scores within each order; then equal-weight mean over reviewed orders. |
| State scatter denominator | Eligible delivered orders with reviews, for both delay rate and review score. |

## Join discipline

Items are aggregated to order level before calculating order and customer metrics. Reviews are separately aggregated to order level. Payments are never joined into the sales calculation: a split payment would multiply rows if joined directly to items. Category analysis intentionally returns to item grain. Missing or untranslated categories are kept as `unclassified`.

The pipeline validates parent keys and child references before model creation. Geolocation contains repeated postal codes and exact duplicate rows; it is profiled but not joined into the analysis. A postal code is not treated as a unique geolocation key.

## Limits on interpretation

- Delivery status is observed at extraction. A purchase-month chart filtered to delivered orders may underrepresent recent purchases whose final outcome has not arrived; boundary months are not guaranteed complete.
- Customer segments use future purchases within the extract. They describe observed behaviour and should not be used directly as baseline treatment groups or as predictive labels without leakage controls.
- Repeat share and first-repeat intervals have unequal follow-up and right-censoring. No cohort retention, survival model or lifetime-value estimate is claimed.
- Spending quintiles are defined by the same outcome used to describe them. Concentration is useful descriptively but does not demonstrate targeting effectiveness.
- Review scores may reflect products, sellers, price, region and timing. Reviews can precede delivery and missing reviews can be selective. No causal model or experiment is included.
- State averages can obscure within-state variation; small states have less stable rates. No confidence intervals are presented.
- No margins, refunds, acquisition costs or intervention results are available. Proposed actions are hypotheses to test.
- SQL execution is verified on DuckDB. Original PostgreSQL files are preserved as research artifacts and are not claimed to run end to end unchanged.
