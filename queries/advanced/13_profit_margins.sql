-- ============================================================================
-- Query 13: Profit Margin Analysis
-- ============================================================================
-- Business Question:
--   What are the profit margins by product and category? Which products
--   have the best and worst margins after accounting for discounts?
--
-- Use Case:
--   Pricing strategy, discount policy review, product portfolio optimization.
--
-- Techniques: CTE, CASE, window functions (PERCENT_RANK), arithmetic
-- ============================================================================

WITH product_profitability AS (
    SELECT
        p.product_id,
        p.product_name,
        p.sku,
        cat.category_name,
        COALESCE(parent.category_name, cat.category_name)
                                                    AS top_category,
        p.unit_price                                AS list_price,
        p.cost_price,
        p.unit_price - p.cost_price                 AS list_margin,
        ROUND(
            (p.unit_price - p.cost_price) / p.unit_price * 100, 1
        )                                           AS list_margin_pct,
        SUM(oi.quantity)                             AS units_sold,
        -- Actual revenue after line-item discounts
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                           AS actual_revenue,
        -- Cost of goods sold
        ROUND(
            SUM(oi.quantity * p.cost_price)::NUMERIC, 2
        )                                           AS total_cogs,
        -- Actual profit
        ROUND(
            SUM(oi.quantity * (oi.unit_price *
                (1 - oi.discount_percent / 100.0) - p.cost_price))::NUMERIC,
            2
        )                                           AS gross_profit,
        -- Effective discount (average actual discount given)
        ROUND(AVG(oi.discount_percent)::NUMERIC, 1) AS avg_discount_pct
    FROM products p
    JOIN categories cat ON cat.category_id = p.category_id
    LEFT JOIN categories parent ON parent.category_id = cat.parent_category_id
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
        p.product_id, p.product_name, p.sku,
        cat.category_name, parent.category_name,
        p.unit_price, p.cost_price
)

SELECT
    product_id,
    product_name,
    top_category,
    category_name                                   AS subcategory,
    list_price,
    cost_price,
    list_margin_pct,
    units_sold,
    actual_revenue,
    total_cogs,
    gross_profit,
    -- Actual margin percentage (after discounts)
    ROUND(
        gross_profit / NULLIF(actual_revenue, 0) * 100, 1
    )                                               AS actual_margin_pct,
    avg_discount_pct,
    -- Margin erosion from discounts
    ROUND(
        list_margin_pct - (gross_profit / NULLIF(actual_revenue, 0) * 100), 1
    )                                               AS margin_erosion_pct,
    -- Profit per unit
    ROUND(
        gross_profit / NULLIF(units_sold, 0), 2
    )                                               AS profit_per_unit,
    -- Margin percentile rank (0-100, higher = better margin)
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY gross_profit / NULLIF(actual_revenue, 0)
        ) * 100, 0
    )                                               AS margin_percentile,
    -- Margin tier
    CASE
        WHEN gross_profit / NULLIF(actual_revenue, 0) >= 0.40 THEN 'High Margin (40%+)'
        WHEN gross_profit / NULLIF(actual_revenue, 0) >= 0.25 THEN 'Good Margin (25-40%)'
        WHEN gross_profit / NULLIF(actual_revenue, 0) >= 0.10 THEN 'Low Margin (10-25%)'
        ELSE 'Critical (<10%)'
    END                                             AS margin_tier
FROM product_profitability
ORDER BY gross_profit DESC;
