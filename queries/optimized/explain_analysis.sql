-- ============================================================================
-- EXPLAIN ANALYZE Deep Dive
-- ============================================================================
-- Detailed query plan analysis showing how PostgreSQL executes our key
-- queries and how indexes impact the execution strategy.
-- ============================================================================


-- ============================================================================
-- EXAMPLE 1: Index Scan vs. Sequential Scan on Orders
-- ============================================================================
-- Demonstrate how idx_orders_customer_id changes the plan for a filtered query.

-- Without index hint (planner chooses based on statistics):
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    o.order_id,
    o.order_date,
    o.status,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = 1
    AND o.status NOT IN ('Cancelled', 'Returned')
GROUP BY o.order_id, o.order_date, o.status
ORDER BY o.order_date DESC;

-- Expected plan:
--   -> Index Scan using idx_orders_customer_id on orders o
--        Index Cond: (customer_id = 1)
--        Filter: (status <> ALL ('{Cancelled,Returned}'))
--   -> Index Scan using idx_order_items_order_id on order_items oi
--        Index Cond: (order_id = o.order_id)
--   Planning Time: ~0.5ms
--   Execution Time: ~0.8ms


-- ============================================================================
-- EXAMPLE 2: Covering Index Benefit on Order Items
-- ============================================================================
-- The covering index idx_order_items_order_product INCLUDE (quantity, unit_price,
-- discount_percent) allows an Index Only Scan — no heap access needed.

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_percent
FROM order_items oi
WHERE oi.order_id BETWEEN 1 AND 50;

-- Expected plan:
--   -> Index Only Scan using idx_order_items_order_product on order_items
--        Index Cond: (order_id >= 1 AND order_id <= 50)
--        Heap Fetches: 0    <-- Key benefit: zero heap fetches
--   Execution Time: ~0.3ms


-- ============================================================================
-- EXAMPLE 3: Partial Index for Low-Stock Inventory
-- ============================================================================
-- The partial index idx_inventory_low_stock only indexes rows where
-- quantity_on_hand <= reorder_level, making the index very small.

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    i.product_id,
    p.product_name,
    i.quantity_on_hand,
    i.reorder_level,
    i.warehouse_location
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.quantity_on_hand <= i.reorder_level;

-- Expected plan:
--   -> Nested Loop
--        -> Index Scan using idx_inventory_low_stock on inventory i
--             Filter: (quantity_on_hand <= reorder_level)
--        -> Index Scan using products_pkey on products p
--             Index Cond: (product_id = i.product_id)
--   Execution Time: ~0.2ms (very few rows match)


-- ============================================================================
-- EXAMPLE 4: Date Range Query Using Composite Index
-- ============================================================================
-- The composite index idx_orders_date_status_customer allows efficient
-- range scans on order_date with in-index filtering on status.

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month,
    COUNT(*) AS orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM orders o
WHERE o.order_date >= '2024-01-01'
    AND o.order_date < '2025-01-01'
    AND o.status = 'Delivered'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- Expected plan:
--   -> GroupAggregate
--        -> Index Only Scan using idx_orders_date_status_customer on orders
--             Index Cond: (order_date >= '2024-01-01' AND order_date < '2025-01-01'
--                          AND status = 'Delivered')
--   Planning Time: ~0.8ms
--   Execution Time: ~1.2ms


-- ============================================================================
-- EXAMPLE 5: Hash Join vs. Nested Loop on Large Aggregation
-- ============================================================================
-- For our monthly revenue view, PostgreSQL often chooses a Hash Join strategy
-- when aggregating across orders and order_items.

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0)) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- Expected plan:
--   -> Sort (by month)
--        -> HashAggregate
--             -> Hash Join (order_id = order_id)
--                  -> Seq Scan on orders (filter: status NOT IN ...)
--                  -> Seq Scan on order_items
--                     (or Index Scan if dataset is large enough)
--   Planning Time: ~1.5ms
--   Execution Time: ~5.8ms


-- ============================================================================
-- EXAMPLE 6: Materialized View Performance
-- ============================================================================
-- Compare querying the materialized view mv_daily_sales vs. computing on the fly.

-- On the fly (computed each time):
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    o.order_date::DATE AS sale_date,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0)) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
    AND o.order_date >= '2024-10-01'
    AND o.order_date < '2025-01-01'
GROUP BY o.order_date::DATE
ORDER BY sale_date;

-- Materialized view (pre-computed):
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    sale_date,
    order_count,
    daily_revenue AS revenue
FROM mv_daily_sales
WHERE sale_date >= '2024-10-01'
    AND sale_date < '2025-01-01'
ORDER BY sale_date;

-- Expected improvement:
--   On the fly:  ~8.5ms (Hash Join + GroupAggregate)
--   Mat. view:   ~0.4ms (Index Scan on mv_daily_sales, pre-aggregated)
--   Improvement:  95% for this specific date-range query
--
-- Trade-off: Materialized view requires periodic REFRESH, so data may be
-- slightly stale between refreshes.


-- ============================================================================
-- INDEX USAGE STATISTICS
-- ============================================================================
-- After running the benchmark suite, check which indexes are being used:

SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS times_used,
    idx_tup_read AS rows_read,
    idx_tup_fetch AS rows_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- ============================================================================
-- TABLE SCAN STATISTICS
-- ============================================================================
-- Identify tables with high sequential scan ratios (candidates for more indexes):

SELECT
    relname AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    CASE
        WHEN seq_scan + idx_scan > 0 THEN
            ROUND(idx_scan::NUMERIC / (seq_scan + idx_scan) * 100, 1)
        ELSE 0
    END AS index_usage_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY seq_scan DESC;
