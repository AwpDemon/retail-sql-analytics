-- ============================================================================
-- Query 01: Customer Order History
-- ============================================================================
-- Business Question:
--   What is the complete order history for each customer, including order
--   totals, item counts, and their current loyalty segment?
--
-- Use Case:
--   Customer service lookup, account review, loyalty program evaluation.
--
-- Techniques: JOIN, GROUP BY, aggregate functions, ORDER BY
-- ============================================================================

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name     AS customer_name,
    c.email,
    c.customer_segment,
    c.state,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    SUM(oi.quantity)                         AS total_items_purchased,
    ROUND(
        SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0))::NUMERIC,
        2
    )                                       AS total_spent,
    ROUND(
        AVG(sub.order_total)::NUMERIC, 2
    )                                       AS avg_order_value,
    MIN(o.order_date)::DATE                 AS first_order_date,
    MAX(o.order_date)::DATE                 AS most_recent_order,
    MAX(o.order_date)::DATE - MIN(o.order_date)::DATE
                                            AS customer_tenure_days
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON oi.order_id = o.order_id
JOIN (
    -- Subquery to compute per-order totals for AVG calculation
    SELECT
        oi2.order_id,
        SUM(oi2.quantity * oi2.unit_price *
            (1 - oi2.discount_percent / 100.0)) AS order_total
    FROM order_items oi2
    GROUP BY oi2.order_id
) sub
    ON sub.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.customer_segment,
    c.state
ORDER BY total_spent DESC
LIMIT 25;
