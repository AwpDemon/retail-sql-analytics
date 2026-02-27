-- ============================================================================
-- Query 15: Customer Segmentation (Behavioral Clustering)
-- ============================================================================
-- Business Question:
--   Can we segment customers into meaningful behavioral groups based on
--   spending patterns, product preferences, and order characteristics?
--
-- Use Case:
--   Personalized marketing, targeted promotions, customer personas.
--
-- Techniques: Multiple CTEs, CASE, NTILE, window functions, CROSSTAB-style
-- ============================================================================

WITH customer_behavior AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name       AS customer_name,
        c.customer_segment,
        c.state,
        c.registered_at,
        -- Order metrics
        COUNT(DISTINCT o.order_id)                AS total_orders,
        SUM(oi.quantity)                           AS total_items,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                         AS total_revenue,
        -- Timing
        MIN(o.order_date)::DATE                   AS first_order,
        MAX(o.order_date)::DATE                   AS last_order,
        CURRENT_DATE - MAX(o.order_date)::DATE    AS days_since_last,
        -- Preferred shipping
        MODE() WITHIN GROUP (ORDER BY o.shipping_method)
                                                  AS preferred_shipping,
        -- Preferred payment
        MODE() WITHIN GROUP (ORDER BY o.payment_method)
                                                  AS preferred_payment,
        -- Discount sensitivity
        ROUND(AVG(oi.discount_percent)::NUMERIC, 1)
                                                  AS avg_discount_used,
        -- Average items per order
        ROUND(
            SUM(oi.quantity)::NUMERIC / COUNT(DISTINCT o.order_id), 1
        )                                         AS avg_items_per_order
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name,
        c.customer_segment, c.state, c.registered_at
),

category_preference AS (
    -- Find each customer's most-purchased category
    SELECT DISTINCT ON (c.customer_id)
        c.customer_id,
        COALESCE(parent.category_name, cat.category_name) AS top_category,
        SUM(oi.quantity) AS category_units
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    LEFT JOIN categories parent ON parent.category_id = cat.parent_category_id
    GROUP BY c.customer_id,
             COALESCE(parent.category_name, cat.category_name)
    ORDER BY c.customer_id, SUM(oi.quantity) DESC
),

scored AS (
    SELECT
        cb.*,
        cp.top_category                           AS favorite_category,
        -- Spending tier
        NTILE(4) OVER (ORDER BY total_revenue)    AS spending_quartile,
        -- Frequency tier
        NTILE(4) OVER (ORDER BY total_orders)     AS frequency_quartile
    FROM customer_behavior cb
    LEFT JOIN category_preference cp ON cp.customer_id = cb.customer_id
)

SELECT
    customer_id,
    customer_name,
    customer_segment,
    state,
    total_orders,
    total_items,
    total_revenue,
    avg_items_per_order,
    avg_discount_used,
    preferred_shipping,
    preferred_payment,
    favorite_category,
    days_since_last,
    spending_quartile,
    frequency_quartile,
    -- Behavioral segment assignment
    CASE
        -- High spenders, frequent buyers
        WHEN spending_quartile = 4 AND frequency_quartile >= 3
            THEN 'Power Shopper'
        -- High spenders, infrequent (big-ticket buyers)
        WHEN spending_quartile = 4 AND frequency_quartile <= 2
            THEN 'Big Ticket Buyer'
        -- Moderate spenders, very frequent
        WHEN spending_quartile IN (2,3) AND frequency_quartile = 4
            THEN 'Loyal Regular'
        -- Discount-driven buyers
        WHEN avg_discount_used >= 5.0
            THEN 'Bargain Hunter'
        -- New customers (registered within 6 months, few orders)
        WHEN total_orders <= 2 AND days_since_last <= 180
            THEN 'New Customer'
        -- Low engagement
        WHEN spending_quartile = 1 AND days_since_last > 180
            THEN 'Disengaged'
        ELSE 'Mainstream'
    END                                           AS behavioral_segment,
    -- Engagement score (composite 0-100)
    ROUND(
        (LEAST(total_orders, 10)::NUMERIC / 10 * 30) +           -- 30% frequency (capped at 10)
        (LEAST(total_revenue, 5000)::NUMERIC / 5000 * 40) +      -- 40% monetary (capped at 5K)
        (GREATEST(0, 365 - days_since_last)::NUMERIC / 365 * 30), -- 30% recency
        0
    )                                             AS engagement_score
FROM scored
ORDER BY engagement_score DESC, total_revenue DESC;
