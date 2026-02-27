-- ============================================================================
-- Query 10: Customer Churn Risk Analysis
-- ============================================================================
-- Business Question:
--   Which customers are at risk of churning? Based on recency, frequency,
--   and monetary (RFM) metrics, who should we target with retention campaigns?
--
-- Use Case:
--   Churn prevention, targeted email campaigns, win-back programs.
--
-- Techniques: CTE, NTILE, window functions, CASE, composite scoring
-- ============================================================================

WITH rfm_raw AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name       AS customer_name,
        c.email,
        c.customer_segment,
        c.state,
        -- Recency: days since last order
        CURRENT_DATE - MAX(o.order_date)::DATE    AS days_since_last_order,
        -- Frequency: total order count
        COUNT(DISTINCT o.order_id)                AS order_count,
        -- Monetary: total revenue
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                         AS total_revenue,
        MIN(o.order_date)::DATE                   AS first_order,
        MAX(o.order_date)::DATE                   AS last_order
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name,
        c.email, c.customer_segment, c.state
),

rfm_scored AS (
    SELECT
        *,
        -- Score each dimension 1-5 (5 is best)
        -- Recency: lower days = higher score
        NTILE(5) OVER (ORDER BY days_since_last_order ASC)  AS recency_score,
        -- Frequency: more orders = higher score
        NTILE(5) OVER (ORDER BY order_count DESC)           AS frequency_score,
        -- Monetary: more revenue = higher score
        NTILE(5) OVER (ORDER BY total_revenue DESC)         AS monetary_score
    FROM rfm_raw
)

SELECT
    customer_id,
    customer_name,
    email,
    customer_segment,
    state,
    days_since_last_order,
    order_count,
    total_revenue,
    first_order,
    last_order,
    recency_score,
    frequency_score,
    monetary_score,
    -- Combined RFM score (weighted: recency matters most for churn)
    ROUND(
        (recency_score * 0.50 +
         frequency_score * 0.30 +
         monetary_score * 0.20)::NUMERIC,
        2
    )                                                       AS rfm_weighted_score,
    -- Churn risk classification
    CASE
        WHEN recency_score <= 1 AND frequency_score <= 2
            THEN 'HIGH RISK - Lost'
        WHEN recency_score <= 2 AND frequency_score <= 2
            THEN 'HIGH RISK - Hibernating'
        WHEN recency_score <= 2 AND frequency_score >= 3
            THEN 'AT RISK - Need Attention'
        WHEN recency_score <= 3 AND monetary_score >= 4
            THEN 'AT RISK - High Value Cooling'
        WHEN recency_score >= 4 AND frequency_score >= 4
            THEN 'SAFE - Loyal'
        WHEN recency_score >= 4 AND monetary_score >= 4
            THEN 'SAFE - Champion'
        WHEN recency_score >= 4 AND frequency_score <= 2
            THEN 'NEW - Promising'
        ELSE 'MODERATE - Monitor'
    END                                                     AS churn_risk_label,
    -- Recommended action
    CASE
        WHEN recency_score <= 1
            THEN 'Win-back campaign with aggressive discount'
        WHEN recency_score <= 2 AND monetary_score >= 3
            THEN 'Personal outreach — high-value at-risk customer'
        WHEN recency_score <= 3
            THEN 'Re-engagement email series'
        WHEN frequency_score <= 2 AND recency_score >= 4
            THEN 'Encourage repeat purchase — loyalty program invite'
        ELSE 'Standard retention — continue engagement'
    END                                                     AS recommended_action
FROM rfm_scored
ORDER BY
    CASE
        WHEN recency_score <= 1 AND monetary_score >= 3 THEN 0  -- Highest priority: high-value lost
        WHEN recency_score <= 2 THEN 1
        WHEN recency_score <= 3 THEN 2
        ELSE 3
    END,
    total_revenue DESC;
