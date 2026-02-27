-- ============================================================================
-- Query 14: Inventory Turnover Analysis
-- ============================================================================
-- Business Question:
--   How quickly is inventory selling through? Which products have the best
--   and worst turnover rates? Where is capital tied up in slow-moving stock?
--
-- Use Case:
--   Working capital optimization, dead stock identification, reorder tuning.
--
-- Techniques: CTE, date intervals, CASE, window function, division guards
-- ============================================================================

WITH annual_sales AS (
    -- Units sold in the trailing 12 months
    SELECT
        oi.product_id,
        SUM(oi.quantity)                              AS units_sold_12mo,
        ROUND(
            SUM(oi.quantity * p.cost_price)::NUMERIC, 2
        )                                             AS cogs_12mo
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
        AND o.order_date >= CURRENT_DATE - INTERVAL '12 months'
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY oi.product_id
),

turnover_calc AS (
    SELECT
        p.product_id,
        p.product_name,
        p.sku,
        cat.category_name,
        p.cost_price,
        i.quantity_on_hand,
        i.reorder_level,
        i.warehouse_location,
        COALESCE(a.units_sold_12mo, 0)                AS units_sold_12mo,
        COALESCE(a.cogs_12mo, 0)                      AS cogs_12mo,
        -- Inventory value at cost
        ROUND(
            (i.quantity_on_hand * p.cost_price)::NUMERIC, 2
        )                                             AS inventory_value,
        -- Turnover ratio = COGS / avg inventory value
        -- Using current stock as proxy for average inventory
        CASE
            WHEN i.quantity_on_hand > 0 AND COALESCE(a.cogs_12mo, 0) > 0 THEN
                ROUND(
                    a.cogs_12mo / (i.quantity_on_hand * p.cost_price), 2
                )
            ELSE 0
        END                                           AS turnover_ratio,
        -- Days of inventory on hand (DOI)
        CASE
            WHEN COALESCE(a.units_sold_12mo, 0) > 0 THEN
                ROUND(
                    i.quantity_on_hand::NUMERIC /
                    (a.units_sold_12mo / 365.0), 0
                )
            ELSE NULL
        END                                           AS days_of_inventory
    FROM products p
    JOIN inventory i ON i.product_id = p.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    LEFT JOIN annual_sales a ON a.product_id = p.product_id
    WHERE p.is_active = TRUE
)

SELECT
    product_id,
    product_name,
    sku,
    category_name,
    cost_price,
    quantity_on_hand,
    units_sold_12mo,
    inventory_value,
    cogs_12mo,
    turnover_ratio,
    days_of_inventory,
    -- Turnover classification
    CASE
        WHEN turnover_ratio >= 8  THEN 'Fast Mover'
        WHEN turnover_ratio >= 4  THEN 'Normal'
        WHEN turnover_ratio >= 1  THEN 'Slow Mover'
        WHEN turnover_ratio > 0   THEN 'Very Slow'
        ELSE 'Dead Stock'
    END                                               AS turnover_class,
    -- Capital efficiency: rank by how much capital is tied up in slow stock
    RANK() OVER (
        ORDER BY
            CASE WHEN turnover_ratio = 0 THEN 0 ELSE 1 END,
            turnover_ratio ASC
    )                                                 AS efficiency_rank,
    -- Action recommendation
    CASE
        WHEN turnover_ratio = 0 AND inventory_value > 100
            THEN 'LIQUIDATE - Dead stock, capital locked'
        WHEN turnover_ratio < 1 AND inventory_value > 200
            THEN 'DISCOUNT - Slow mover, consider clearance'
        WHEN days_of_inventory IS NOT NULL AND days_of_inventory > 180
            THEN 'REDUCE REORDER - Over 6 months supply'
        WHEN days_of_inventory IS NOT NULL AND days_of_inventory < 14
            THEN 'INCREASE REORDER - Under 2 weeks supply'
        ELSE 'NO ACTION'
    END                                               AS recommendation
FROM turnover_calc
ORDER BY turnover_ratio ASC, inventory_value DESC;
