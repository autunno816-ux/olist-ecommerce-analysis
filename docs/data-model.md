# Data model

[Overview](../README.md) · [Reviewed model SQL](../sql/00_model.sql)

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : customer_id
    ORDERS ||--o{ ORDER_ITEMS : order_id
    ORDERS ||--o{ ORDER_PAYMENTS : order_id
    ORDERS ||--o{ ORDER_REVIEWS : order_id
    PRODUCTS ||--o{ ORDER_ITEMS : product_id
    SELLERS ||--o{ ORDER_ITEMS : seller_id
```

| Source table | Grain | Join / key notes |
| --- | --- | --- |
| customers | Order-specific customer record | `customer_id` is unique; `customer_unique_id` links purchases by the same person. |
| orders | Order | `order_id` is unique; joins to the order-specific customer record. |
| order_items | Item within order | Composite key `(order_id, order_item_id)`; multiple items per order. |
| order_payments | Payment sequence within order | Composite key `(order_id, payment_sequential)`; profiled, not used for merchandise sales. |
| order_reviews | Review/order pair | `(order_id, review_id)` is unique in this snapshot; an order can have several reviews. |
| products | Product | Joins category translation on Portuguese category label. |
| sellers | Seller | `seller_id` is unique. |
| category_name | Category translation | Two source category labels have no matching translation; missing/untranslated products are retained. |
| geolocations | Postal-coordinate observation | Postal prefix is nonunique; not joined to the analytical model. |

The portable loader preserves IDs and postal codes as strings, casts money to decimals and timestamps to timestamp types, and runs data-quality checks before creating the analytical views. It does not install a PostgreSQL service or alter an existing database.

![Original pgAdmin ERD](../archive/ERD.png)

[Original pgAdmin ERD source](../archive/olist_erd.pgerd). The diagram documents the original research model; the reviewed model adds aggregated analytical views.
