# Original research archive

[Reviewed project](../README.md) · [Corrections and validation](../docs/validation.md)

These 22 files are preserved byte-for-byte from the original project: five exploratory PostgreSQL SQL files, 15 sales, customer and delivery charts, a PNG ERD and its pgAdmin source. SHA-256 hashes are recorded in [manifest.json](manifest.json).

**Read the reviewed research pages for current findings.** The original monthly-revenue image displays order counts; the Customer-segment revenue-share chart uses an order-share calculation; the State delivery comparison stacks days and percentages; original review joins can weight orders more than once. These original artifacts document the research process and have not been silently rewritten.

## SQL and model

- [1. sales performance.sql](1.%20sales%20performance.sql)
- [2.customer behavior.sql](2.customer%20behavior.sql)
- [3.delivery & customer satisfaction.sql](3.delivery%20%26%20customer%20satisfaction.sql)
- [Check Data Quality.sql](Check%20Data%20Quality.sql)
- [Create database and constraints.sql](Create%20database%20and%20constraints.sql)
- [ERD.png](ERD.png)
- [olist_erd.pgerd](olist_erd.pgerd)

## Original sales figures

### monthly _order_amount_change

![monthly _order_amount_change](Q1/monthly%20order%20volume%20and%20sales%20revenue%20change/monthly%20_order_amount_change.png)

### monthly_revenue_change

![monthly_revenue_change](Q1/monthly%20order%20volume%20and%20sales%20revenue%20change/monthly_revenue_change.png)

### monthly_revenue_growth(17.01-18.08)

![monthly_revenue_growth(17.01-18.08)](Q1/monthly%20order%20volume%20and%20sales%20revenue%20change/monthly_revenue_growth%2817.01-18.08%29.png)

### revenue_share_by_state

![revenue_share_by_state](Q1/monthly%20order%20volume%20and%20sales%20revenue%20change/revenue_share_by_state.png)

### top 10 revenue share by category

![top 10 revenue share by category](Q1/monthly%20order%20volume%20and%20sales%20revenue%20change/top%2010%20revenue%20share%20by%20category.png)

## Original customer figures

### amount_share_by_customer_type

![amount_share_by_customer_type](Q2/amount_share_by_customer_type.png)

### average-revenue_by customer_type

![average-revenue_by customer_type](Q2/average-revenue_by%20customer_type.png)

### repurchase interval share

![repurchase interval share](Q2/repurchase%20interval%20share.png)

### revenue_contribution_by_customer_class5

![revenue_contribution_by_customer_class5](Q2/revenue_contribution_by_customer_class5.png)

### revenue_share_by_customer_type

![revenue_share_by_customer_type](Q2/revenue_share_by_customer_type.png)

### total_revenue_by_customer_type

![total_revenue_by_customer_type](Q2/total_revenue_by_customer_type.png)

## Original delivery figures

### share between delay and punctual order

![share between delay and punctual order](Q3/share%20between%20delay%20and%20punctual%20order.png)

### share_of_delay vs average_review_score

![share_of_delay vs average_review_score](Q3/share_of_delay%20vs%20average_review_score.png)

### top10 delay delivery state

![top10 delay delivery state](Q3/top10%20delay%20delivery%20state.png)

### trend of average delivery time vs delay rate percent

![trend of average delivery time vs delay rate percent](Q3/trend%20of%20average%20delivery%20time%20vs%20delay%20rate%20percent.png)
