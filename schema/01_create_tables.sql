-- ============================================================================
-- RetailPulse Analytics Database — Table Definitions
-- MIST 4600 | University of Georgia | Spring 2025
-- ============================================================================
-- Execute order: This file first, then 02_create_indexes.sql, 03, 04.
-- Target: PostgreSQL 14+
-- ============================================================================

-- Drop tables in reverse dependency order if they exist
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================================================
-- 1. CUSTOMERS
-- Customer profiles with demographics and geographic data.
-- ============================================================================
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    address_line1   VARCHAR(100),
    address_line2   VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(50),
    zip_code        VARCHAR(10),
    country         VARCHAR(50)  DEFAULT 'US',
    date_of_birth   DATE,
    registered_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    customer_segment VARCHAR(20) DEFAULT 'Regular'
        CHECK (customer_segment IN ('Regular', 'Premium', 'VIP'))
);

COMMENT ON TABLE customers IS 'Customer profiles with demographics and geographic data';
COMMENT ON COLUMN customers.customer_segment IS 'Loyalty tier: Regular, Premium, or VIP';

-- ============================================================================
-- 2. CATEGORIES
-- Product categories with self-referencing hierarchy for subcategories.
-- ============================================================================
CREATE TABLE categories (
    category_id        SERIAL PRIMARY KEY,
    category_name      VARCHAR(50) NOT NULL UNIQUE,
    description        TEXT,
    parent_category_id INT REFERENCES categories(category_id)
        ON DELETE SET NULL
);

COMMENT ON TABLE categories IS 'Product category hierarchy (supports two-level nesting)';

-- ============================================================================
-- 3. SUPPLIERS
-- Vendor/supplier information for product sourcing.
-- ============================================================================
CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    company_name  VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100),
    contact_email VARCHAR(100),
    phone         VARCHAR(20),
    address       VARCHAR(200),
    city          VARCHAR(50),
    state         VARCHAR(50),
    country       VARCHAR(50) DEFAULT 'US',
    lead_time_days INT DEFAULT 7
        CHECK (lead_time_days >= 0),
    rating        DECIMAL(3,2) DEFAULT 3.00
        CHECK (rating >= 0.00 AND rating <= 5.00)
);

COMMENT ON TABLE suppliers IS 'Product vendors and suppliers with performance ratings';

-- ============================================================================
-- 4. PRODUCTS
-- Product catalog with pricing, categorization, and supplier linkage.
-- Unit price is the current retail price; cost_price is wholesale cost.
-- ============================================================================
CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    description  TEXT,
    unit_price   DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    cost_price   DECIMAL(10,2) NOT NULL CHECK (cost_price > 0),
    category_id  INT REFERENCES categories(category_id)
        ON DELETE SET NULL,
    supplier_id  INT REFERENCES suppliers(supplier_id)
        ON DELETE SET NULL,
    sku          VARCHAR(30)  NOT NULL UNIQUE,
    weight_kg    DECIMAL(6,2),
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE products IS 'Product catalog — prices, categories, and supplier links';
COMMENT ON COLUMN products.cost_price IS 'Wholesale cost used for margin calculations';

-- ============================================================================
-- 5. EMPLOYEES
-- Staff members with role, department, and manager hierarchy.
-- ============================================================================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    role        VARCHAR(50)  NOT NULL,
    department  VARCHAR(50),
    hire_date   DATE         NOT NULL,
    salary      DECIMAL(10,2),
    manager_id  INT REFERENCES employees(employee_id)
        ON DELETE SET NULL
);

COMMENT ON TABLE employees IS 'Staff directory with manager hierarchy';

-- ============================================================================
-- 6. ORDERS
-- Customer orders with fulfillment status, shipping, and payment details.
-- ============================================================================
CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    employee_id     INT REFERENCES employees(employee_id)
        ON DELETE SET NULL,
    order_date      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipped_date    TIMESTAMP,
    delivered_date  TIMESTAMP,
    status          VARCHAR(20) DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned')),
    shipping_method VARCHAR(30),
    shipping_cost   DECIMAL(8,2) DEFAULT 0.00,
    payment_method  VARCHAR(30),
    discount_amount DECIMAL(8,2) DEFAULT 0.00
);

COMMENT ON TABLE orders IS 'Customer orders with fulfillment lifecycle tracking';

-- ============================================================================
-- 7. ORDER_ITEMS
-- Line items per order. Unit price is captured at time of sale (snapshot).
-- ============================================================================
CREATE TABLE order_items (
    order_item_id    SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id       INT NOT NULL REFERENCES products(product_id)
        ON DELETE RESTRICT,
    quantity         INT NOT NULL CHECK (quantity > 0),
    unit_price       DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0.00
        CHECK (discount_percent >= 0.00 AND discount_percent <= 100.00)
);

COMMENT ON TABLE order_items IS 'Line items per order with price snapshot at time of sale';
COMMENT ON COLUMN order_items.unit_price IS 'Price at time of purchase (may differ from current product price)';

-- ============================================================================
-- 8. INVENTORY
-- Stock levels and reorder management. One record per product.
-- ============================================================================
CREATE TABLE inventory (
    inventory_id      SERIAL PRIMARY KEY,
    product_id        INT NOT NULL UNIQUE REFERENCES products(product_id)
        ON DELETE CASCADE,
    quantity_on_hand  INT DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_level     INT DEFAULT 10,
    reorder_quantity  INT DEFAULT 50,
    warehouse_location VARCHAR(20),
    last_restock_date TIMESTAMP
);

COMMENT ON TABLE inventory IS 'Current stock levels and reorder thresholds per product';

-- ============================================================================
-- Verify table creation
-- ============================================================================
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
