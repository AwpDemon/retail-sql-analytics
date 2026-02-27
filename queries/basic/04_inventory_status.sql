-- ============================================================================
-- Query 04: Inventory Status and Reorder Alerts
-- ============================================================================
-- Business Question:
--   Which products are at or below their reorder threshold? What is the
--   estimated days of stock remaining based on recent sales velocity?
--
-- Use Case:
--   Inventory management, purchasing alerts, stockout prevention.
--
-- Techniques: JOIN, CTE, CASE, date arithmetic, COALESCE, subquery
-- ============================================================================

WITH recent_sales_velocity AS (
    -- Calculate average daily units sold over the last 90 days
    SELECT
        oi.product_id,
        ROUND(
            SUM(oi.quantity)::NUMERIC /
            GREATEST(
                EXTRACT(DAY FROM (CURRENT_DATE - MIN(o.order_date)::DATE)),
                1
            ),
            2
        )                                       AS avg_daily_units
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
        AND o.order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY oi.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    s.company_name                              AS supplier,
    s.lead_time_days,
    i.quantity_on_hand,
    i.reorder_level,
    i.reorder_quantity,
    i.warehouse_location,
    i.last_restock_date::DATE                   AS last_restocked,
    COALESCE(rsv.avg_daily_units, 0)            AS avg_daily_sales,
    CASE
        WHEN i.quantity_on_hand = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level THEN 'REORDER NOW'
        WHEN i.quantity_on_hand <= i.reorder_level * 1.5 THEN 'LOW STOCK'
        ELSE 'OK'
    END                                         AS stock_status,
    CASE
        WHEN COALESCE(rsv.avg_daily_units, 0) > 0 THEN
            ROUND(i.quantity_on_hand / rsv.avg_daily_units, 0)
        ELSE NULL
    END                                         AS estimated_days_remaining,
    CASE
        WHEN COALESCE(rsv.avg_daily_units, 0) > 0
            AND (i.quantity_on_hand / rsv.avg_daily_units) < s.lead_time_days
        THEN 'URGENT - Stock may run out before reorder arrives'
        ELSE NULL
    END                                         AS urgency_flag
FROM inventory i
JOIN products p ON p.product_id = i.product_id
JOIN categories cat ON cat.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
LEFT JOIN recent_sales_velocity rsv ON rsv.product_id = i.product_id
WHERE p.is_active = TRUE
ORDER BY
    CASE
        WHEN i.quantity_on_hand = 0 THEN 0
        WHEN i.quantity_on_hand <= i.reorder_level THEN 1
        WHEN i.quantity_on_hand <= i.reorder_level * 1.5 THEN 2
        ELSE 3
    END,
    i.quantity_on_hand ASC;
