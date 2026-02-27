-- ============================================================================
-- RetailPulse Analytics Database — Views
-- MIST 4600 | University of Georgia | Spring 2025
-- ============================================================================
-- Reusable views that simplify common analytical patterns.
-- ============================================================================

-- ============================================================================
-- VIEW: v_order_summary
-- Pre-joins orders with line-item totals for quick revenue lookups.
-- ============================================================================
CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    o.order_id,
    o.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.employee_id,
    o.order_date,
    o.status,
    o.shipping_method,
    o.payment_method,
    COUNT(oi.order_item_id)                         AS item_count,
    SUM(oi.quantity)                                 AS total_units,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0))          AS subtotal,
    o.shipping_cost,
    o.discount_amount,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0))
        + o.shipping_cost - o.discount_amount       AS order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY
    o.order_id, o.customer_id, c.first_name, c.last_name,
    o.employee_id, o.order_date, o.status, o.shipping_method,
    o.payment_method, o.shipping_cost, o.discount_amount;

COMMENT ON VIEW v_order_summary IS 'Pre-aggregated order totals with customer name';

-- ============================================================================
-- VIEW: v_product_revenue
-- Product-level revenue and quantity metrics across all completed orders.
-- ============================================================================
CREATE OR REPLACE VIEW v_product_revenue AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    p.unit_price       AS current_price,
    p.cost_price,
    COUNT(DISTINCT o.order_id)                      AS order_count,
    SUM(oi.quantity)                                 AS units_sold,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0))          AS total_revenue,
    SUM(oi.quantity * (oi.unit_price *
        (1 - oi.discount_percent / 100.0) - p.cost_price)) AS gross_profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price *
            (1 - oi.discount_percent / 100.0) - p.cost_price))
        / NULLIF(SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)), 0)
        * 100, 2
    )                                               AS margin_percent
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
    AND o.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.product_id, p.product_name, p.sku,
         cat.category_name, p.unit_price, p.cost_price;

COMMENT ON VIEW v_product_revenue IS 'Product-level sales, revenue, and margin metrics';

-- ============================================================================
-- VIEW: v_monthly_revenue
-- Monthly aggregated revenue for trend analysis.
-- ============================================================================
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT
    DATE_TRUNC('month', o.order_date)::DATE         AS month,
    COUNT(DISTINCT o.order_id)                      AS order_count,
    COUNT(DISTINCT o.customer_id)                   AS unique_customers,
    SUM(oi.quantity)                                 AS units_sold,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0))          AS gross_revenue,
    SUM(o.discount_amount)                           AS total_discounts,
    SUM(o.shipping_cost)                             AS total_shipping
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

COMMENT ON VIEW v_monthly_revenue IS 'Monthly revenue trends for dashboard and reporting';

-- ============================================================================
-- VIEW: v_inventory_status
-- Current inventory status with stock alerts.
-- ============================================================================
CREATE OR REPLACE VIEW v_inventory_status AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    s.company_name      AS supplier_name,
    i.quantity_on_hand,
    i.reorder_level,
    i.reorder_quantity,
    i.warehouse_location,
    i.last_restock_date,
    CASE
        WHEN i.quantity_on_hand = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level THEN 'LOW STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level * 2 THEN 'ADEQUATE'
        ELSE 'WELL STOCKED'
    END                  AS stock_status,
    s.lead_time_days
FROM inventory i
JOIN products p ON p.product_id = i.product_id
JOIN categories cat ON cat.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = TRUE;

COMMENT ON VIEW v_inventory_status IS 'Inventory levels with stock status classification';

-- ============================================================================
-- VIEW: v_customer_metrics
-- Customer-level lifetime metrics for segmentation and CLV analysis.
-- ============================================================================
CREATE OR REPLACE VIEW v_customer_metrics AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name             AS customer_name,
    c.email,
    c.state,
    c.customer_segment,
    c.registered_at,
    COUNT(DISTINCT o.order_id)                      AS total_orders,
    SUM(oi.quantity)                                 AS total_units,
    COALESCE(SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0)), 0)      AS lifetime_revenue,
    COALESCE(AVG(sub.order_total), 0)               AS avg_order_value,
    MIN(o.order_date)                               AS first_order_date,
    MAX(o.order_date)                               AS last_order_date,
    EXTRACT(DAY FROM MAX(o.order_date) - MIN(o.order_date)) AS customer_tenure_days
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
    AND o.status NOT IN ('Cancelled', 'Returned')
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN (
    SELECT
        oi2.order_id,
        SUM(oi2.quantity * oi2.unit_price *
            (1 - oi2.discount_percent / 100.0)) AS order_total
    FROM order_items oi2
    GROUP BY oi2.order_id
) sub ON sub.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email,
         c.state, c.customer_segment, c.registered_at;

COMMENT ON VIEW v_customer_metrics IS 'Customer-level lifetime value and activity metrics';

-- ============================================================================
-- MATERIALIZED VIEW: mv_daily_sales
-- Pre-computed daily sales for fast dashboard rendering.
-- Refresh with: REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales;
-- ============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_daily_sales AS
SELECT
    o.order_date::DATE                              AS sale_date,
    COUNT(DISTINCT o.order_id)                      AS order_count,
    COUNT(DISTINCT o.customer_id)                   AS unique_customers,
    SUM(oi.quantity)                                 AS units_sold,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0))          AS daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY o.order_date::DATE
ORDER BY sale_date;

-- Unique index required for CONCURRENTLY refresh
CREATE UNIQUE INDEX idx_mv_daily_sales_date ON mv_daily_sales (sale_date);

COMMENT ON MATERIALIZED VIEW mv_daily_sales IS 'Pre-computed daily sales (refresh periodically)';
