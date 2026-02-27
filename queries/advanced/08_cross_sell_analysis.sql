-- ============================================================================
-- Query 08: Cross-Sell / Market Basket Analysis
-- ============================================================================
-- Business Question:
--   Which products are frequently purchased together? What are the strongest
--   product affinities that could drive cross-sell recommendations?
--
-- Use Case:
--   Product recommendation engine, bundle pricing, "Frequently Bought Together".
--
-- Techniques: Self-join, CTE, window function, conditional aggregation
-- ============================================================================

WITH product_pairs AS (
    -- Generate all pairs of products bought in the same order
    SELECT
        oi1.product_id   AS product_a,
        oi2.product_id   AS product_b,
        oi1.order_id
    FROM order_items oi1
    JOIN order_items oi2
        ON oi1.order_id = oi2.order_id
        AND oi1.product_id < oi2.product_id   -- avoid duplicates and self-pairs
    JOIN orders o ON o.order_id = oi1.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
),

pair_counts AS (
    SELECT
        product_a,
        product_b,
        COUNT(DISTINCT order_id)              AS co_purchase_count
    FROM product_pairs
    GROUP BY product_a, product_b
    HAVING COUNT(DISTINCT order_id) >= 2      -- minimum co-occurrence threshold
),

product_order_counts AS (
    -- Total orders per product (for lift calculation)
    SELECT
        oi.product_id,
        COUNT(DISTINCT oi.order_id)           AS product_orders
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY oi.product_id
),

total_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total
    FROM orders
    WHERE status NOT IN ('Cancelled', 'Returned')
)

SELECT
    pa.product_name                           AS product_a_name,
    pb.product_name                           AS product_b_name,
    cat_a.category_name                       AS category_a,
    cat_b.category_name                       AS category_b,
    pc.co_purchase_count,
    poc_a.product_orders                      AS product_a_orders,
    poc_b.product_orders                      AS product_b_orders,
    -- Support: what fraction of all orders contain this pair?
    ROUND(
        pc.co_purchase_count::NUMERIC / t.total * 100, 2
    )                                         AS support_pct,
    -- Confidence A→B: if a customer buys A, what % also buy B?
    ROUND(
        pc.co_purchase_count::NUMERIC / poc_a.product_orders * 100, 1
    )                                         AS confidence_a_to_b_pct,
    -- Confidence B→A: if a customer buys B, what % also buy A?
    ROUND(
        pc.co_purchase_count::NUMERIC / poc_b.product_orders * 100, 1
    )                                         AS confidence_b_to_a_pct,
    -- Lift: how much more likely are they bought together vs. independently?
    ROUND(
        (pc.co_purchase_count::NUMERIC / t.total)
        / ((poc_a.product_orders::NUMERIC / t.total)
           * (poc_b.product_orders::NUMERIC / t.total)),
        2
    )                                         AS lift
FROM pair_counts pc
JOIN products pa ON pa.product_id = pc.product_a
JOIN products pb ON pb.product_id = pc.product_b
JOIN categories cat_a ON cat_a.category_id = pa.category_id
JOIN categories cat_b ON cat_b.category_id = pb.category_id
JOIN product_order_counts poc_a ON poc_a.product_id = pc.product_a
JOIN product_order_counts poc_b ON poc_b.product_id = pc.product_b
CROSS JOIN total_orders t
ORDER BY lift DESC, co_purchase_count DESC
LIMIT 30;
