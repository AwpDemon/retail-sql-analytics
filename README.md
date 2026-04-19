# RetailPulse — SQL Analytics Database

A relational e-commerce database in PostgreSQL with 15 analytical queries — customer segmentation, churn risk, cross-sell, cohort analysis, seasonal trends.

The one query I kept coming back to:

```sql
-- RFM churn risk: weight recency highest, classify, recommend action
WITH rfm_scored AS (
  SELECT
    c.customer_id,
    NTILE(5) OVER (ORDER BY MAX(o.order_date) DESC)        AS recency_score,
    NTILE(5) OVER (ORDER BY COUNT(o.order_id) DESC)        AS frequency_score,
    NTILE(5) OVER (ORDER BY SUM(oi.quantity*oi.unit_price) DESC) AS monetary_score
  FROM customers c
  JOIN orders o       ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id   = o.order_id
  GROUP BY c.customer_id
)
SELECT customer_id,
  ROUND((recency_score*0.50 + frequency_score*0.30 + monetary_score*0.20)::NUMERIC, 2) AS rfm_score,
  CASE
    WHEN recency_score<=1 AND frequency_score<=2 THEN 'HIGH RISK — Lost'
    WHEN recency_score<=2 AND monetary_score>=4 THEN 'AT RISK — High Value Cooling'
    WHEN recency_score>=4 AND frequency_score>=4 THEN 'SAFE — Loyal'
    ELSE 'MODERATE — Monitor'
  END AS churn_label
FROM rfm_scored
ORDER BY rfm_score DESC;
```

Recency weighted heaviest because, for churn specifically, time-since-last-order predicts better than total spend does. A high-value customer who hasn't ordered in 200 days is worth chasing; a low-value customer who bought yesterday isn't. That's the "High Value Cooling" branch. Full query with engagement tiers and recommended actions in `queries/advanced/10_churn_prediction.sql`.

## Schema

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : "places"
    EMPLOYEES ||--o{ ORDERS : "manages"
    ORDERS ||--|{ ORDER_ITEMS : "contains"
    PRODUCTS ||--o{ ORDER_ITEMS : "appears in"
    CATEGORIES ||--o{ PRODUCTS : "classifies"
    CATEGORIES ||--o{ CATEGORIES : "parent of"
    SUPPLIERS ||--o{ PRODUCTS : "supplies"
    PRODUCTS ||--|| INVENTORY : "tracked in"
    EMPLOYEES ||--o{ EMPLOYEES : "manages"
```

8 tables, 3NF, self-referencing hierarchies on categories and employees. Full field-level diagram in [`docs/er_diagram.md`](docs/er_diagram.md).

## What's in `queries/`

- `basic/` — 5 queries: category revenue, customer orders, product sales, inventory status, employee performance
- `advanced/` — 10 queries: CLV deciles, cohort retention, cross-sell lift, churn RFM, seasonal patterns, geographic analysis, supplier performance
- `optimized/` — before/after for two queries where a covering index dropped planning time ~80%. See `docs/optimization_report.md`.

Findings summary in [`analysis/findings.md`](analysis/findings.md) — top 10% of customers drive ~42% of revenue, Electronics has the lowest margins, Q4 is 31% of annual sales, laptops + USB-C hubs have a 4.8 lift score.

## Run it

```bash
psql -f schema/01_create_tables.sql
psql -f schema/02_create_indexes.sql
psql -f schema/03_create_views.sql
psql -f schema/04_seed_data.sql
```

Sample data is synthetic (`scripts/generate_data.py`). Postgres 14+.
