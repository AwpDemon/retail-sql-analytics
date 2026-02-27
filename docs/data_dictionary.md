# Data Dictionary

## RetailPulse Database — Column Reference

All tables use PostgreSQL data types. Primary keys are auto-incrementing `SERIAL` columns. Timestamps default to `CURRENT_TIMESTAMP` where noted.

---

## 1. customers

Customer profiles including demographics and geographic information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `customer_id` | SERIAL | PK | Unique customer identifier |
| `first_name` | VARCHAR(50) | NOT NULL | Customer first name |
| `last_name` | VARCHAR(50) | NOT NULL | Customer last name |
| `email` | VARCHAR(100) | UNIQUE, NOT NULL | Email address |
| `phone` | VARCHAR(20) | | Phone number |
| `address_line1` | VARCHAR(100) | | Street address |
| `address_line2` | VARCHAR(100) | | Apt/Suite/Unit |
| `city` | VARCHAR(50) | | City |
| `state` | VARCHAR(50) | | State or province |
| `zip_code` | VARCHAR(10) | | Postal code |
| `country` | VARCHAR(50) | DEFAULT 'US' | Country code |
| `date_of_birth` | DATE | | Birth date |
| `registered_at` | TIMESTAMP | DEFAULT NOW() | Account creation timestamp |
| `customer_segment` | VARCHAR(20) | DEFAULT 'Regular' | Segment: Regular, Premium, VIP |

---

## 2. categories

Product category hierarchy with optional parent reference for subcategories.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `category_id` | SERIAL | PK | Unique category identifier |
| `category_name` | VARCHAR(50) | UNIQUE, NOT NULL | Category display name |
| `description` | TEXT | | Category description |
| `parent_category_id` | INT | FK → categories(category_id) | Parent category (NULL for top-level) |

---

## 3. suppliers

Vendor and supplier information for product sourcing.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `supplier_id` | SERIAL | PK | Unique supplier identifier |
| `company_name` | VARCHAR(100) | NOT NULL | Supplier company name |
| `contact_name` | VARCHAR(100) | | Primary contact person |
| `contact_email` | VARCHAR(100) | | Contact email address |
| `phone` | VARCHAR(20) | | Contact phone number |
| `address` | VARCHAR(200) | | Supplier address |
| `city` | VARCHAR(50) | | City |
| `state` | VARCHAR(50) | | State or province |
| `country` | VARCHAR(50) | DEFAULT 'US' | Country |
| `lead_time_days` | INT | DEFAULT 7 | Average delivery lead time in days |
| `rating` | DECIMAL(3,2) | CHECK (0-5) | Supplier performance rating (0.00-5.00) |

---

## 4. products

Product catalog with pricing, categorization, and supplier linkage.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `product_id` | SERIAL | PK | Unique product identifier |
| `product_name` | VARCHAR(150) | NOT NULL | Product display name |
| `description` | TEXT | | Product description |
| `unit_price` | DECIMAL(10,2) | NOT NULL, CHECK (>0) | Current retail price |
| `cost_price` | DECIMAL(10,2) | NOT NULL, CHECK (>0) | Wholesale/cost price |
| `category_id` | INT | FK → categories(category_id) | Product category |
| `supplier_id` | INT | FK → suppliers(supplier_id) | Primary supplier |
| `sku` | VARCHAR(30) | UNIQUE, NOT NULL | Stock keeping unit |
| `weight_kg` | DECIMAL(6,2) | | Product weight in kilograms |
| `is_active` | BOOLEAN | DEFAULT TRUE | Whether product is currently sold |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Record creation timestamp |

---

## 5. employees

Staff members including sales representatives and managers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `employee_id` | SERIAL | PK | Unique employee identifier |
| `first_name` | VARCHAR(50) | NOT NULL | Employee first name |
| `last_name` | VARCHAR(50) | NOT NULL | Employee last name |
| `email` | VARCHAR(100) | UNIQUE, NOT NULL | Work email |
| `role` | VARCHAR(50) | NOT NULL | Job title/role |
| `department` | VARCHAR(50) | | Department name |
| `hire_date` | DATE | NOT NULL | Date of hire |
| `salary` | DECIMAL(10,2) | | Annual salary |
| `manager_id` | INT | FK → employees(employee_id) | Direct manager (NULL for top-level) |

---

## 6. orders

Customer orders with status tracking, shipping, and payment details.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `order_id` | SERIAL | PK | Unique order identifier |
| `customer_id` | INT | FK → customers(customer_id), NOT NULL | Ordering customer |
| `employee_id` | INT | FK → employees(employee_id) | Assigned sales representative |
| `order_date` | TIMESTAMP | DEFAULT NOW(), NOT NULL | Date and time order was placed |
| `shipped_date` | TIMESTAMP | | Date order was shipped |
| `delivered_date` | TIMESTAMP | | Date order was delivered |
| `status` | VARCHAR(20) | DEFAULT 'Pending' | Order status: Pending, Processing, Shipped, Delivered, Cancelled, Returned |
| `shipping_method` | VARCHAR(30) | | Shipping carrier/method |
| `shipping_cost` | DECIMAL(8,2) | DEFAULT 0.00 | Shipping charges |
| `payment_method` | VARCHAR(30) | | Payment type: Credit Card, PayPal, Bank Transfer, etc. |
| `discount_amount` | DECIMAL(8,2) | DEFAULT 0.00 | Order-level discount applied |

---

## 7. order_items

Individual line items within each order. Captures price at time of purchase.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `order_item_id` | SERIAL | PK | Unique line item identifier |
| `order_id` | INT | FK → orders(order_id), NOT NULL | Parent order |
| `product_id` | INT | FK → products(product_id), NOT NULL | Product purchased |
| `quantity` | INT | NOT NULL, CHECK (>0) | Quantity ordered |
| `unit_price` | DECIMAL(10,2) | NOT NULL | Price per unit at time of purchase |
| `discount_percent` | DECIMAL(5,2) | DEFAULT 0.00 | Line-item discount percentage (0.00-100.00) |

---

## 8. inventory

Current stock levels and reorder management per product.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `inventory_id` | SERIAL | PK | Unique inventory record identifier |
| `product_id` | INT | FK → products(product_id), UNIQUE, NOT NULL | Associated product |
| `quantity_on_hand` | INT | DEFAULT 0, CHECK (>=0) | Current stock quantity |
| `reorder_level` | INT | DEFAULT 10 | Quantity threshold that triggers reorder |
| `reorder_quantity` | INT | DEFAULT 50 | Standard reorder quantity |
| `warehouse_location` | VARCHAR(20) | | Warehouse bin/aisle location code |
| `last_restock_date` | TIMESTAMP | | Date of most recent restock |

---

## Enum / Domain Values

### customer_segment
- `Regular` — Default segment, no special status
- `Premium` — Mid-tier loyalty program member
- `VIP` — Top-tier, highest lifetime value

### order status
- `Pending` — Order placed, not yet processed
- `Processing` — Payment confirmed, preparing to ship
- `Shipped` — In transit
- `Delivered` — Successfully received
- `Cancelled` — Cancelled before shipment
- `Returned` — Returned after delivery

### shipping_method
- `Standard` — 5-7 business days
- `Express` — 2-3 business days
- `Overnight` — Next business day
- `Free Shipping` — Standard speed, no charge

### payment_method
- `Credit Card`
- `PayPal`
- `Bank Transfer`
- `Gift Card`
