-- ============================================================================
-- Query 12: Seasonal Sales Patterns
-- ============================================================================
-- Business Question:
--   What are the seasonal purchasing patterns by month and day of week?
--   Which categories have the strongest seasonal variation?
--
-- Use Case:
--   Inventory planning, promotional calendar, staffing decisions.
--
-- Techniques: EXTRACT, CASE, window functions, conditional aggregation, CTE
-- ============================================================================

-- Part A: Monthly seasonality by category
WITH monthly_category_sales AS (
    SELECT
        EXTRACT(MONTH FROM o.order_date)::INT         AS sale_month,
        TO_CHAR(o.order_date, 'Month')                AS month_name,
        COALESCE(parent.category_name, cat.category_name)
                                                      AS category,
        COUNT(DISTINCT o.order_id)                    AS order_count,
        SUM(oi.quantity)                               AS units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                             AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    LEFT JOIN categories parent ON parent.category_id = cat.parent_category_id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
        EXTRACT(MONTH FROM o.order_date),
        TO_CHAR(o.order_date, 'Month'),
        COALESCE(parent.category_name, cat.category_name)
)

SELECT
    sale_month,
    TRIM(month_name)                                  AS month_name,
    category,
    order_count,
    units_sold,
    monthly_revenue,
    -- Category's average monthly revenue
    ROUND(
        AVG(monthly_revenue) OVER (PARTITION BY category), 2
    )                                                 AS avg_monthly_revenue,
    -- Seasonal index: how this month compares to category average
    ROUND(
        monthly_revenue /
        NULLIF(AVG(monthly_revenue) OVER (PARTITION BY category), 0) * 100,
        1
    )                                                 AS seasonal_index,
    -- Peak flag
    CASE
        WHEN monthly_revenue = MAX(monthly_revenue) OVER (PARTITION BY category)
            THEN 'PEAK'
        WHEN monthly_revenue = MIN(monthly_revenue) OVER (PARTITION BY category)
            THEN 'TROUGH'
        ELSE ''
    END                                               AS season_flag
FROM monthly_category_sales
ORDER BY category, sale_month;

-- Part B: Day-of-week patterns (overall)
-- Uncomment to run separately
/*
SELECT
    EXTRACT(DOW FROM o.order_date)::INT               AS day_of_week_num,
    TO_CHAR(o.order_date, 'Day')                      AS day_name,
    COUNT(DISTINCT o.order_id)                        AS order_count,
    ROUND(
        SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0))::NUMERIC,
        2
    )                                                 AS day_revenue,
    ROUND(
        AVG(sub.order_total)::NUMERIC, 2
    )                                                 AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN (
    SELECT order_id,
           SUM(quantity * unit_price * (1 - discount_percent / 100.0)) AS order_total
    FROM order_items GROUP BY order_id
) sub ON sub.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY
    EXTRACT(DOW FROM o.order_date),
    TO_CHAR(o.order_date, 'Day')
ORDER BY day_of_week_num;
*/
