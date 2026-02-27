-- ============================================================================
-- Query 03: Revenue by Product Category
-- ============================================================================
-- Business Question:
--   How does revenue break down by product category? Which categories
--   drive the most sales, and what is each category's share of total revenue?
--
-- Use Case:
--   Category management, merchandising strategy, budget allocation.
--
-- Techniques: JOIN, GROUP BY, window function (SUM OVER), percentage calc
-- ============================================================================

WITH category_revenue AS (
    SELECT
        COALESCE(parent.category_name, cat.category_name)
                                                AS top_category,
        cat.category_name                       AS subcategory,
        COUNT(DISTINCT o.order_id)              AS order_count,
        SUM(oi.quantity)                         AS units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                       AS category_revenue,
        COUNT(DISTINCT p.product_id)            AS active_products
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    LEFT JOIN categories parent ON parent.category_id = cat.parent_category_id
    GROUP BY
        COALESCE(parent.category_name, cat.category_name),
        cat.category_name
)

SELECT
    top_category,
    subcategory,
    order_count,
    units_sold,
    category_revenue,
    active_products,
    ROUND(
        category_revenue / SUM(category_revenue) OVER () * 100, 1
    )                                           AS pct_of_total_revenue,
    ROUND(
        category_revenue / active_products, 2
    )                                           AS revenue_per_product,
    RANK() OVER (ORDER BY category_revenue DESC)
                                                AS revenue_rank
FROM category_revenue
ORDER BY top_category, category_revenue DESC;
