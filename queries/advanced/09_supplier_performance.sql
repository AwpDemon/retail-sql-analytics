-- ============================================================================
-- Query 09: Supplier Performance Scorecard
-- ============================================================================
-- Business Question:
--   How do suppliers compare in terms of product revenue, lead time,
--   stock reliability, and overall rating? Which suppliers should we
--   expand or reduce business with?
--
-- Use Case:
--   Vendor management, procurement strategy, supply chain optimization.
--
-- Techniques: CTE, multiple JOINs, conditional aggregation, CASE, RANK
-- ============================================================================

WITH supplier_sales AS (
    SELECT
        s.supplier_id,
        s.company_name,
        s.contact_name,
        s.city || ', ' || s.state             AS location,
        s.lead_time_days,
        s.rating                               AS supplier_rating,
        COUNT(DISTINCT p.product_id)           AS products_supplied,
        COUNT(DISTINCT CASE WHEN p.is_active THEN p.product_id END)
                                               AS active_products,
        SUM(oi.quantity)                        AS total_units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                      AS total_revenue,
        ROUND(
            SUM(oi.quantity * (oi.unit_price *
                (1 - oi.discount_percent / 100.0) - p.cost_price))::NUMERIC,
            2
        )                                      AS total_profit
    FROM suppliers s
    JOIN products p ON p.supplier_id = s.supplier_id
    LEFT JOIN order_items oi ON oi.product_id = p.product_id
    LEFT JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
        s.supplier_id, s.company_name, s.contact_name,
        s.city, s.state, s.lead_time_days, s.rating
),

supplier_inventory AS (
    SELECT
        p.supplier_id,
        COUNT(CASE WHEN i.quantity_on_hand <= i.reorder_level
              THEN 1 END)                      AS low_stock_products,
        COUNT(CASE WHEN i.quantity_on_hand = 0
              THEN 1 END)                      AS out_of_stock_products,
        ROUND(AVG(i.quantity_on_hand)::NUMERIC, 0)
                                               AS avg_stock_level
    FROM products p
    JOIN inventory i ON i.product_id = p.product_id
    WHERE p.is_active = TRUE
    GROUP BY p.supplier_id
)

SELECT
    ss.supplier_id,
    ss.company_name,
    ss.contact_name,
    ss.location,
    ss.supplier_rating,
    ss.lead_time_days,
    ss.products_supplied,
    ss.active_products,
    ss.total_units_sold,
    ss.total_revenue,
    ss.total_profit,
    ROUND(
        ss.total_profit / NULLIF(ss.total_revenue, 0) * 100, 1
    )                                          AS profit_margin_pct,
    ROUND(
        ss.total_revenue / NULLIF(ss.active_products, 0), 2
    )                                          AS revenue_per_product,
    si.avg_stock_level,
    si.low_stock_products,
    si.out_of_stock_products,
    -- Composite score: weighted blend of rating, margin, and reliability
    ROUND(
        (ss.supplier_rating / 5.0 * 40)                          -- 40% weight: rating
        + (COALESCE(ss.total_profit / NULLIF(ss.total_revenue, 0), 0) * 30)  -- 30%: margin
        + (1.0 - LEAST(ss.lead_time_days, 15)::NUMERIC / 15) * 30,           -- 30%: speed
        1
    )                                          AS composite_score,
    RANK() OVER (ORDER BY ss.total_revenue DESC)
                                               AS revenue_rank,
    CASE
        WHEN ss.supplier_rating >= 4.5 AND ss.lead_time_days <= 5
            THEN 'Preferred'
        WHEN ss.supplier_rating >= 3.5
            THEN 'Approved'
        ELSE 'Under Review'
    END                                        AS supplier_tier
FROM supplier_sales ss
LEFT JOIN supplier_inventory si ON si.supplier_id = ss.supplier_id
ORDER BY total_revenue DESC;
