-- ============================================================================
-- Query 06: Customer Lifetime Value (CLV) Analysis
-- ============================================================================
-- Business Question:
--   What is the estimated lifetime value of each customer? Which customers
--   are most valuable, and how do CLV metrics differ across segments?
--
-- Use Case:
--   Marketing budget allocation, retention targeting, loyalty programs.
--
-- Techniques: CTE, window functions, NTILE, date arithmetic, CASE
-- ============================================================================

WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name          AS customer_name,
        c.customer_segment,
        c.state,
        c.registered_at,
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0))       AS order_revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name,
        c.customer_segment, c.state, c.registered_at,
        o.order_id, o.order_date
),

clv_metrics AS (
    SELECT
        customer_id,
        customer_name,
        customer_segment,
        state,
        registered_at,
        COUNT(order_id)                              AS total_orders,
        ROUND(SUM(order_revenue)::NUMERIC, 2)        AS lifetime_revenue,
        ROUND(AVG(order_revenue)::NUMERIC, 2)         AS avg_order_value,
        MIN(order_date)::DATE                        AS first_purchase,
        MAX(order_date)::DATE                        AS last_purchase,
        -- Average days between orders (purchase frequency)
        CASE
            WHEN COUNT(order_id) > 1 THEN
                ROUND(
                    EXTRACT(DAY FROM MAX(order_date) - MIN(order_date))::NUMERIC
                    / (COUNT(order_id) - 1), 1
                )
            ELSE NULL
        END                                          AS avg_days_between_orders,
        -- Recency: days since last purchase
        CURRENT_DATE - MAX(order_date)::DATE         AS days_since_last_order
    FROM customer_orders
    GROUP BY customer_id, customer_name, customer_segment, state, registered_at
)

SELECT
    customer_id,
    customer_name,
    customer_segment,
    state,
    total_orders,
    lifetime_revenue,
    avg_order_value,
    first_purchase,
    last_purchase,
    avg_days_between_orders,
    days_since_last_order,
    -- Predicted annual value (if purchase frequency is known)
    CASE
        WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders > 0 THEN
            ROUND((365.0 / avg_days_between_orders) * avg_order_value, 2)
        ELSE avg_order_value
    END                                              AS predicted_annual_value,
    -- CLV decile (1 = top 10%)
    NTILE(10) OVER (ORDER BY lifetime_revenue DESC)  AS clv_decile,
    -- Engagement status
    CASE
        WHEN days_since_last_order <= 30 THEN 'Active'
        WHEN days_since_last_order <= 90 THEN 'Warm'
        WHEN days_since_last_order <= 180 THEN 'Cooling'
        ELSE 'At Risk'
    END                                              AS engagement_status,
    -- Running total of revenue contribution (cumulative %)
    ROUND(
        SUM(lifetime_revenue) OVER (ORDER BY lifetime_revenue DESC)
        / SUM(lifetime_revenue) OVER () * 100, 1
    )                                                AS cumulative_revenue_pct
FROM clv_metrics
ORDER BY lifetime_revenue DESC;
