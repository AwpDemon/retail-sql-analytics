-- ============================================================================
-- Query 02: Product Sales Rankings
-- ============================================================================
-- Business Question:
--   Which products generate the most revenue and volume? How do current
--   inventory levels compare to sales velocity?
--
-- Use Case:
--   Product performance review, purchasing decisions, bestseller lists.
--
-- Techniques: JOIN, GROUP BY, aggregate functions, CASE expression, ORDER BY
-- ============================================================================

SELECT
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    p.unit_price                            AS current_price,
    SUM(oi.quantity)                         AS units_sold,
    COUNT(DISTINCT o.order_id)              AS order_appearances,
    ROUND(
        SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0))::NUMERIC,
        2
    )                                       AS total_revenue,
    ROUND(
        AVG(oi.unit_price)::NUMERIC, 2
    )                                       AS avg_selling_price,
    ROUND(
        AVG(oi.discount_percent)::NUMERIC, 1
    )                                       AS avg_discount_pct,
    i.quantity_on_hand                      AS current_stock,
    CASE
        WHEN SUM(oi.quantity) > 10 THEN 'High Performer'
        WHEN SUM(oi.quantity) > 5  THEN 'Moderate'
        ELSE 'Low Volume'
    END                                     AS sales_tier
FROM products p
JOIN order_items oi
    ON oi.product_id = p.product_id
JOIN orders o
    ON o.order_id = oi.order_id
    AND o.status NOT IN ('Cancelled', 'Returned')
JOIN categories cat
    ON cat.category_id = p.category_id
LEFT JOIN inventory i
    ON i.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    p.unit_price,
    i.quantity_on_hand
ORDER BY total_revenue DESC;
