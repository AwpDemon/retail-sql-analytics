-- ============================================================================
-- RetailPulse Analytics Database — Query Validation Tests
-- MIST 4600 | University of Georgia | Spring 2025
-- ============================================================================
-- These tests validate data integrity and query correctness.
-- Run after loading seed data: psql -d retailpulse -f tests/test_queries.sql
-- All tests should return TRUE or 'PASS'.
-- ============================================================================


-- ============================================================================
-- TEST 1: Referential Integrity — All order customer_ids exist in customers
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' orders reference non-existent customers'
    END AS test_1_order_customer_fk
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================================
-- TEST 2: Referential Integrity — All order_items reference valid orders
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' order_items reference non-existent orders'
    END AS test_2_order_items_order_fk
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;


-- ============================================================================
-- TEST 3: Referential Integrity — All order_items reference valid products
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' order_items reference non-existent products'
    END AS test_3_order_items_product_fk
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;


-- ============================================================================
-- TEST 4: All products have inventory records
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' active products missing inventory records'
    END AS test_4_product_inventory_coverage
FROM products p
LEFT JOIN inventory i ON i.product_id = p.product_id
WHERE p.is_active = TRUE
    AND i.inventory_id IS NULL;


-- ============================================================================
-- TEST 5: No negative quantities in order_items
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' order_items have non-positive quantity'
    END AS test_5_positive_quantities
FROM order_items
WHERE quantity <= 0;


-- ============================================================================
-- TEST 6: No negative inventory on hand
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' inventory records have negative stock'
    END AS test_6_non_negative_inventory
FROM inventory
WHERE quantity_on_hand < 0;


-- ============================================================================
-- TEST 7: Product cost_price is less than unit_price (sanity check)
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' products have cost >= retail price'
    END AS test_7_cost_below_price
FROM products
WHERE cost_price >= unit_price;


-- ============================================================================
-- TEST 8: Customer emails are unique
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = (SELECT COUNT(DISTINCT email) FROM customers)
        THEN 'PASS'
        ELSE 'FAIL: Duplicate customer emails found'
    END AS test_8_unique_emails
FROM customers;


-- ============================================================================
-- TEST 9: Order dates are logical (shipped after ordered, delivered after shipped)
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' orders have illogical date sequences'
    END AS test_9_date_logic
FROM orders
WHERE (shipped_date IS NOT NULL AND shipped_date < order_date)
   OR (delivered_date IS NOT NULL AND shipped_date IS NULL)
   OR (delivered_date IS NOT NULL AND delivered_date < shipped_date);


-- ============================================================================
-- TEST 10: Order status consistency with dates
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' orders have status inconsistent with dates'
    END AS test_10_status_date_consistency
FROM orders
WHERE (status = 'Delivered' AND delivered_date IS NULL)
   OR (status = 'Pending' AND shipped_date IS NOT NULL)
   OR (status = 'Cancelled' AND delivered_date IS NOT NULL);


-- ============================================================================
-- TEST 11: Category hierarchy — no circular references
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' categories are their own parent'
    END AS test_11_no_self_parent
FROM categories
WHERE category_id = parent_category_id;


-- ============================================================================
-- TEST 12: Employee hierarchy — no self-management
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' employees are their own manager'
    END AS test_12_no_self_manager
FROM employees
WHERE employee_id = manager_id;


-- ============================================================================
-- TEST 13: Revenue calculation consistency
-- Verify that the v_order_summary view totals match raw calculation
-- ============================================================================
SELECT
    CASE
        WHEN ABS(view_total - raw_total) < 0.01 THEN 'PASS'
        ELSE 'FAIL: View total (' || ROUND(view_total, 2) ||
             ') differs from raw total (' || ROUND(raw_total, 2) || ')'
    END AS test_13_revenue_consistency
FROM (
    SELECT
        (SELECT COALESCE(SUM(subtotal), 0) FROM v_order_summary
         WHERE status NOT IN ('Cancelled', 'Returned')) AS view_total,
        (SELECT COALESCE(SUM(oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)), 0)
         FROM order_items oi
         JOIN orders o ON o.order_id = oi.order_id
         WHERE o.status NOT IN ('Cancelled', 'Returned')) AS raw_total
) calc;


-- ============================================================================
-- TEST 14: Discount percentages are within valid range (0-100)
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' order_items have invalid discount_percent'
    END AS test_14_valid_discounts
FROM order_items
WHERE discount_percent < 0 OR discount_percent > 100;


-- ============================================================================
-- TEST 15: Supplier ratings are within valid range (0-5)
-- ============================================================================
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' suppliers have invalid ratings'
    END AS test_15_valid_ratings
FROM suppliers
WHERE rating < 0 OR rating > 5;


-- ============================================================================
-- TEST 16: Table row count sanity checks
-- ============================================================================
SELECT
    CASE
        WHEN c >= 10 AND cat >= 8 AND s >= 10 AND p >= 20
             AND e >= 10 AND o >= 50 AND oi >= 100 AND inv >= 20
        THEN 'PASS'
        ELSE 'FAIL: One or more tables have fewer rows than expected'
    END AS test_16_minimum_row_counts
FROM (
    SELECT
        (SELECT COUNT(*) FROM customers) AS c,
        (SELECT COUNT(*) FROM categories) AS cat,
        (SELECT COUNT(*) FROM suppliers) AS s,
        (SELECT COUNT(*) FROM products) AS p,
        (SELECT COUNT(*) FROM employees) AS e,
        (SELECT COUNT(*) FROM orders) AS o,
        (SELECT COUNT(*) FROM order_items) AS oi,
        (SELECT COUNT(*) FROM inventory) AS inv
) counts;


-- ============================================================================
-- SUMMARY
-- ============================================================================
SELECT 'All 16 tests executed. Review results above for any FAIL indicators.' AS summary;
