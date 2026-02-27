-- ============================================================================
-- Query 11: Geographic Sales Analysis
-- ============================================================================
-- Business Question:
--   How do sales, order volumes, and customer acquisition vary by state
--   and region? Where should we focus marketing spend geographically?
--
-- Use Case:
--   Regional marketing strategy, warehouse placement, shipping optimization.
--
-- Techniques: CTE, CASE for region mapping, window functions, GROUP BY
-- ============================================================================

WITH state_metrics AS (
    SELECT
        c.state,
        CASE
            WHEN c.state IN ('CT','ME','MA','NH','RI','VT','NJ','NY','PA') THEN 'Northeast'
            WHEN c.state IN ('IL','IN','IA','KS','MI','MN','MO','NE','ND','OH','SD','WI') THEN 'Midwest'
            WHEN c.state IN ('AL','AR','DE','FL','GA','KY','LA','MD','MS','NC','OK','SC','TN','TX','VA','WV','DC') THEN 'South'
            WHEN c.state IN ('AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY') THEN 'West'
            ELSE 'Other'
        END                                         AS region,
        COUNT(DISTINCT c.customer_id)               AS total_customers,
        COUNT(DISTINCT o.order_id)                  AS total_orders,
        SUM(oi.quantity)                             AS total_units,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                           AS total_revenue,
        ROUND(
            AVG(sub.order_total)::NUMERIC, 2
        )                                           AS avg_order_value,
        -- New customers in last 6 months
        COUNT(DISTINCT CASE
            WHEN c.registered_at >= CURRENT_DATE - INTERVAL '6 months'
            THEN c.customer_id
        END)                                        AS new_customers_6mo
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN (
        SELECT
            order_id,
            SUM(quantity * unit_price * (1 - discount_percent / 100.0)) AS order_total
        FROM order_items
        GROUP BY order_id
    ) sub ON sub.order_id = o.order_id
    GROUP BY c.state
)

SELECT
    state,
    region,
    total_customers,
    total_orders,
    total_units,
    total_revenue,
    avg_order_value,
    new_customers_6mo,
    -- Orders per customer
    ROUND(total_orders::NUMERIC / NULLIF(total_customers, 0), 2)
                                                    AS orders_per_customer,
    -- Revenue per customer
    ROUND(total_revenue / NULLIF(total_customers, 0), 2)
                                                    AS revenue_per_customer,
    -- State's share of total revenue
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100, 1
    )                                               AS pct_of_total_revenue,
    -- Rank within region
    RANK() OVER (
        PARTITION BY region ORDER BY total_revenue DESC
    )                                               AS rank_in_region,
    -- Rank overall
    RANK() OVER (ORDER BY total_revenue DESC)       AS national_rank
FROM state_metrics
ORDER BY region, total_revenue DESC;
