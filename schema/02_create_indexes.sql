-- ============================================================================
-- RetailPulse Analytics Database — Index Definitions
-- MIST 4600 | University of Georgia | Spring 2025
-- ============================================================================
-- Strategic indexes designed to optimize the 20+ analytical queries in this
-- project. Each index includes a comment explaining which queries benefit.
-- ============================================================================

-- ============================================================================
-- CUSTOMERS indexes
-- ============================================================================

-- Speeds up geographic analysis (Query 11) and customer segmentation (Query 15)
CREATE INDEX idx_customers_state
    ON customers (state);

-- Supports customer segment filtering in segmentation and CLV queries
CREATE INDEX idx_customers_segment
    ON customers (customer_segment);

-- Enables efficient date-range filtering on registration date
CREATE INDEX idx_customers_registered_at
    ON customers (registered_at);

-- ============================================================================
-- PRODUCTS indexes
-- ============================================================================

-- Speeds up category-based aggregations (Queries 3, 8, 13)
CREATE INDEX idx_products_category_id
    ON products (category_id);

-- Speeds up supplier performance analysis (Query 9)
CREATE INDEX idx_products_supplier_id
    ON products (supplier_id);

-- Filters inactive products in inventory and sales queries
CREATE INDEX idx_products_is_active
    ON products (is_active)
    WHERE is_active = TRUE;

-- ============================================================================
-- ORDERS indexes
-- ============================================================================

-- Critical for customer-order joins — used in nearly every query
CREATE INDEX idx_orders_customer_id
    ON orders (customer_id);

-- Supports employee performance queries (Query 5)
CREATE INDEX idx_orders_employee_id
    ON orders (employee_id);

-- Enables efficient date-range filtering for trends and seasonal analysis
CREATE INDEX idx_orders_order_date
    ON orders (order_date);

-- Status filtering for active/completed order analysis
CREATE INDEX idx_orders_status
    ON orders (status);

-- Covering index: date + status + customer for dashboard-type queries
-- Avoids heap fetches for common filter combinations
CREATE INDEX idx_orders_date_status_customer
    ON orders (order_date, status, customer_id);

-- ============================================================================
-- ORDER_ITEMS indexes
-- ============================================================================

-- Composite index for the most common join pattern: order -> items
CREATE INDEX idx_order_items_order_id
    ON order_items (order_id);

-- Product-level aggregation across all orders (revenue, quantity sold)
CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);

-- Composite covering index for revenue calculations
-- Includes the columns most often selected alongside the join
CREATE INDEX idx_order_items_order_product
    ON order_items (order_id, product_id)
    INCLUDE (quantity, unit_price, discount_percent);

-- ============================================================================
-- INVENTORY indexes
-- ============================================================================

-- Fast lookup by product (1:1 relationship, but useful for joins from products)
CREATE INDEX idx_inventory_product_id
    ON inventory (product_id);

-- Partial index: only products that need reordering
-- Speeds up inventory status query (Query 4)
CREATE INDEX idx_inventory_low_stock
    ON inventory (product_id, quantity_on_hand)
    WHERE quantity_on_hand <= reorder_level;

-- ============================================================================
-- CATEGORIES indexes
-- ============================================================================

-- Parent lookup for category hierarchy traversal
CREATE INDEX idx_categories_parent
    ON categories (parent_category_id);

-- ============================================================================
-- EMPLOYEES indexes
-- ============================================================================

-- Manager hierarchy traversal
CREATE INDEX idx_employees_manager_id
    ON employees (manager_id);

-- Department-based filtering and grouping
CREATE INDEX idx_employees_department
    ON employees (department);

-- ============================================================================
-- SUPPLIERS indexes
-- ============================================================================

-- Rating-based filtering for supplier performance queries
CREATE INDEX idx_suppliers_rating
    ON suppliers (rating);

-- ============================================================================
-- Verify index creation
-- ============================================================================
SELECT
    indexname,
    tablename,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND indexname NOT LIKE '%_pkey'
ORDER BY tablename, indexname;
