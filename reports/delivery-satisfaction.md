# Delivery & Satisfaction

[Project overview](../README.md) · [SQL](../sql/03_delivery.sql) · [Metric definitions](../docs/methodology.md)

![Power BI — Delivery & Satisfaction](../powerbi/previews/delivery-satisfaction.png)

[Open the interactive report or PDF](../powerbi/README.md).

Among 96,470 delivered orders with actual and estimated delivery dates, mean delivery time is 12.50 calendar days. Using the original timestamp comparison, 7,826 orders are late: 8.11%. Among reviewed eligible orders, late orders average 2.57/5 and on-time orders average 4.29/5.

## The definition of “late” changes the answer

| Definition | Late orders | Eligible orders | Late rate |
| --- | ---: | ---: | ---: |
| Actual timestamp > estimated timestamp | 7,826 | 96,470 | 8.11% |
| Actual calendar date > estimated calendar date | 6,534 | 96,470 | 6.77% |

The estimate is generally recorded at midnight. An order delivered later on that same date can be late under the timestamp definition and on time under the calendar-date definition. The difference is 1,292 orders, or 1.34 percentage points. No source service-level agreement is provided, so both definitions are disclosed rather than treating either as a verified contractual SLA.

Evidence: [overall delivery results](results/q3_overall.csv). Eight orders marked delivered lack the actual delivery timestamp and are excluded from both denominators.

## State comparisons

| State | Eligible orders | Late orders | Late rate (%) | Mean days |
|---|---|---|---|---|
| AL | 397 | 95 | 23.93 | 24.5 |
| MA | 717 | 141 | 19.67 | 21.51 |
| PI | 476 | 76 | 15.97 | 19.39 |
| CE | 1279 | 196 | 15.32 | 21.2 |
| SE | 335 | 51 | 15.22 | 21.46 |

Evidence: [all state results](results/q3_states.csv). Ranking by percentage exposes high-delay states but can emphasise small populations. Review both counts and rates before prioritising routes. Delivery days and percentages are shown on separate axes; states are discrete categories.

## Review scores

| Delivery status | Reviewed orders | Mean score (1–5) |
|---|---|---|
| Late | 7661 | 2.5665 |
| On time | 88163 | 4.2943 |

Evidence: [delivery-status comparison](results/q3_review_scores.csv) and [state comparison](results/q3_state_reviews.csv). Multiple review rows are averaged within an order before aggregation. For the scatter plot, both axes use the same reviewed-order population. Orders without a review do not enter these comparisons.

## What to investigate next

Investigate high-delay routes and operational causes using carrier, seller and category data. Compare review outcomes after controlling for product mix, customer region and season. The observed score gap and state-level pattern are associations; they do not establish that delays alone caused lower satisfaction. Reviews may also be submitted before final delivery.
