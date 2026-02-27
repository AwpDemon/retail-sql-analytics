# Entity-Relationship Diagram

## RetailPulse Database — ER Model

This diagram represents the normalized (3NF) relational schema for the RetailPulse e-commerce analytics database. All relationships enforce referential integrity via foreign key constraints.

### Mermaid ER Diagram

```mermaid
erDiagram
    CUSTOMERS {
        int customer_id PK
        varchar first_name
        varchar last_name
        varchar email
        varchar phone
        varchar address_line1
        varchar address_line2
        varchar city
        varchar state
        varchar zip_code
        varchar country
        date date_of_birth
        timestamp registered_at
        varchar customer_segment
    }

    CATEGORIES {
        int category_id PK
        varchar category_name
        varchar description
        int parent_category_id FK
    }

    SUPPLIERS {
        int supplier_id PK
        varchar company_name
        varchar contact_name
        varchar contact_email
        varchar phone
        varchar address
        varchar city
        varchar state
        varchar country
        int lead_time_days
        decimal rating
    }

    PRODUCTS {
        int product_id PK
        varchar product_name
        text description
        decimal unit_price
        decimal cost_price
        int category_id FK
        int supplier_id FK
        varchar sku
        decimal weight_kg
        boolean is_active
        timestamp created_at
    }

    EMPLOYEES {
        int employee_id PK
        varchar first_name
        varchar last_name
        varchar email
        varchar role
        varchar department
        date hire_date
        decimal salary
        int manager_id FK
    }

    ORDERS {
        int order_id PK
        int customer_id FK
        int employee_id FK
        timestamp order_date
        timestamp shipped_date
        timestamp delivered_date
        varchar status
        varchar shipping_method
        decimal shipping_cost
        varchar payment_method
        decimal discount_amount
    }

    ORDER_ITEMS {
        int order_item_id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal unit_price
        decimal discount_percent
    }

    INVENTORY {
        int inventory_id PK
        int product_id FK
        int quantity_on_hand
        int reorder_level
        int reorder_quantity
        varchar warehouse_location
        timestamp last_restock_date
    }

    CUSTOMERS ||--o{ ORDERS : "places"
    EMPLOYEES ||--o{ ORDERS : "manages"
    ORDERS ||--|{ ORDER_ITEMS : "contains"
    PRODUCTS ||--o{ ORDER_ITEMS : "appears in"
    CATEGORIES ||--o{ PRODUCTS : "classifies"
    CATEGORIES ||--o{ CATEGORIES : "parent of"
    SUPPLIERS ||--o{ PRODUCTS : "supplies"
    PRODUCTS ||--|| INVENTORY : "tracked in"
    EMPLOYEES ||--o{ EMPLOYEES : "manages"
```

### Relationship Summary

| Relationship | Type | Description |
|---|---|---|
| Customers → Orders | One-to-Many | A customer can place many orders |
| Employees → Orders | One-to-Many | An employee (sales rep) handles many orders |
| Orders → Order Items | One-to-Many | An order contains one or more line items |
| Products → Order Items | One-to-Many | A product can appear in many order line items |
| Categories → Products | One-to-Many | A category contains many products |
| Categories → Categories | Self-referencing | Supports subcategory hierarchy |
| Suppliers → Products | One-to-Many | A supplier provides many products |
| Products → Inventory | One-to-One | Each product has one inventory record |
| Employees → Employees | Self-referencing | Manager hierarchy |

### Design Decisions

1. **Normalization (3NF):** All tables are in Third Normal Form. No transitive dependencies exist — for example, customer address fields are stored directly on the customers table rather than in a separate address table, since each customer has a single primary address in this model.

2. **Category hierarchy:** The `categories` table uses a self-referencing foreign key (`parent_category_id`) to support a two-level hierarchy (e.g., Electronics → Laptops, Home & Kitchen → Cookware).

3. **Price snapshot on order_items:** The `unit_price` column on `order_items` captures the price at the time of purchase, decoupled from the current `products.unit_price`. This preserves historical accuracy for revenue calculations.

4. **Employee self-reference:** The `manager_id` column in `employees` enables org-chart queries and hierarchical reporting.

5. **Inventory separation:** Inventory is kept in its own table rather than as columns on `products` to support future multi-warehouse scenarios and independent stock tracking.
