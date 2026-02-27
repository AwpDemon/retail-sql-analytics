-- ============================================================================
-- Query 07: Sales Trends — Monthly and Year-over-Year
-- ============================================================================
-- Business Question:
--   What are the monthly revenue trends? How does each month compare to
--   the same month in the prior year? Are we growing or contracting?
--
-- Use Case:
--   Executive dashboards, financial forecasting, growth tracking.
--
-- Techniques: CTE, window functions (LAG), date functions, COALESCE
-- ============================================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE      AS month,
        EXTRACT(YEAR FROM o.order_date)::INT          AS sale_year,
        EXTRACT(MONTH FROM o.order_date)::INT         AS sale_month,
        COUNT(DISTINCT o.order_id)                    AS order_count,
        COUNT(DISTINCT o.customer_id)                 AS unique_customers,
        SUM(oi.quantity)                               AS units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                             AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
        DATE_TRUNC('month', o.order_date),
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
)

SELECT
    month,
    sale_year,
    sale_month,
    order_count,
    unique_customers,
    units_sold,
    monthly_revenue,
    -- Month-over-month change
    LAG(monthly_revenue) OVER (ORDER BY month)        AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0) * 100,
        1
    )                                                 AS mom_growth_pct,
    -- Year-over-year: compare to same month last year
    LAG(monthly_revenue, 12) OVER (ORDER BY month)    AS same_month_prior_year,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 12) OVER (ORDER BY month))
        / NULLIF(LAG(monthly_revenue, 12) OVER (ORDER BY month), 0) * 100,
        1
    )                                                 AS yoy_growth_pct,
    -- Rolling 3-month average
    ROUND(
        AVG(monthly_revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::NUMERIC, 2
    )                                                 AS rolling_3mo_avg,
    -- Cumulative year-to-date revenue
    SUM(monthly_revenue) OVER (
        PARTITION BY sale_year
        ORDER BY sale_month
    )                                                 AS ytd_revenue
FROM monthly_sales
ORDER BY month;
