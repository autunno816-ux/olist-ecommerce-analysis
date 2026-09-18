# Sales Performance

[Project overview](../README.md) · [SQL](../sql/01_sales.sql) · [Metric definitions](../docs/methodology.md)

![Power BI — Sales Performance](../powerbi/previews/sales-performance.png)

[Open the interactive report or PDF](../powerbi/README.md).

Sales are concentrated geographically: SP contributes 38.33%, followed by RJ at 13.31% and MG at 11.74%. Together these states contribute 63.38% of delivered-order merchandise sales. The top product category, health and beauty, contributes 9.33%, suggesting less concentration at the individual category level.

## Monthly sales

The monthly series covers purchase months January 2017–August 2018, filtered to orders recorded as delivered. Month-over-month change uses the previous consecutive month's merchandise value. January has no baseline in this query. The first months have a small base, and final months may be affected by incomplete follow-up of delivery outcomes.

Evidence: [monthly results](results/q1_monthly.csv).

## Geographic concentration

| State | Delivered orders | Sales (BRL) | Sales share (%) |
|---|---|---|---|
| SP | 40501 | 5067633.16 | 38.33 |
| RJ | 12350 | 1759651.13 | 13.31 |
| MG | 11354 | 1552481.83 | 11.74 |
| RS | 5345 | 728897.47 | 5.51 |
| PR | 4923 | 666063.51 | 5.04 |

Evidence: [all 27 states](results/q1_states.csv). States refer to the customer address, not seller origin. The denominator is all delivered-order merchandise sales across the full observed history.

## Product categories

Evidence: [all category results](results/q1_categories.csv). Shares use total sales across all categories, including unclassified products; the displayed top 10 therefore do not sum to 100%. An order containing multiple categories contributes to each relevant category's order count, so those counts are not additive.

## What to investigate next

The three largest markets are natural places to examine fulfilment capacity and service quality. Expansion decisions also need acquisition costs, margins and demand estimates, which this dataset does not provide. Category sales should be paired with freight and margin information before allocating promotional spend.
