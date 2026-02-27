-- ============================================================================
-- Query 05: Employee Sales Performance
-- ============================================================================
-- Business Question:
--   How do sales representatives perform in terms of revenue generated,
--   order count, and average deal size? Who are the top performers?
--
-- Use Case:
--   Sales team evaluation, commission calculations, performance reviews.
--
-- Techniques: JOIN, GROUP BY, window functions (RANK, PERCENT_RANK), CTE
-- ============================================================================

WITH employee_sales AS (
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name  AS employee_name,
        e.role,
        e.department,
        e.hire_date,
        mgr.first_name || ' ' || mgr.last_name
                                             AS manager_name,
        COUNT(DISTINCT o.order_id)           AS orders_handled,
        COUNT(DISTINCT o.customer_id)        AS unique_customers,
        SUM(oi.quantity)                      AS total_units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0))::NUMERIC,
            2
        )                                    AS total_revenue,
        ROUND(
            AVG(sub.order_total)::NUMERIC, 2
        )                                    AS avg_order_value
    FROM employees e
    LEFT JOIN employees mgr ON mgr.employee_id = e.manager_id
    JOIN orders o ON o.employee_id = e.employee_id
        AND o.status NOT IN ('Cancelled', 'Returned')
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN (
        SELECT
            order_id,
            SUM(quantity * unit_price * (1 - discount_percent / 100.0)) AS order_total
        FROM order_items
        GROUP BY order_id
    ) sub ON sub.order_id = o.order_id
    WHERE e.department = 'Sales'
    GROUP BY
        e.employee_id, e.first_name, e.last_name, e.role,
        e.department, e.hire_date, mgr.first_name, mgr.last_name
)

SELECT
    employee_id,
    employee_name,
    role,
    manager_name,
    hire_date,
    orders_handled,
    unique_customers,
    total_units_sold,
    total_revenue,
    avg_order_value,
    RANK() OVER (ORDER BY total_revenue DESC)
                                             AS revenue_rank,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY total_revenue) * 100, 0
    )                                        AS revenue_percentile,
    ROUND(
        total_revenue / NULLIF(orders_handled, 0), 2
    )                                        AS revenue_per_order,
    -- Revenue per month of tenure
    ROUND(
        total_revenue / GREATEST(
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, hire_date)), 1
        ), 2
    )                                        AS monthly_revenue_rate
FROM employee_sales
ORDER BY total_revenue DESC;
