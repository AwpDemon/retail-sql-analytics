# RetailPulse Analytics Database

**University of Georgia | MIST 4600 — Database Management | Spring 2025**

A relational database and SQL analytics project built around a simulated e-commerce/retail business ("RetailPulse"), designed to demonstrate end-to-end data modeling, query development, and performance optimization.

## Team

- **Ali Askari** — Database Architect, Query Optimization Lead
- **Jordan Mitchell** — Data Modeling, ER Design
- **Priya Narayanan** — Analytics Queries, Business Insights
- **Marcus Coleman** — Data Generation, Testing & Benchmarking

## Project Overview

RetailPulse is a mid-size online retailer selling consumer electronics, home goods, and apparel. This project models their core transactional data across **8 normalized relational tables** and provides **20+ analytical SQL queries** ranging from basic aggregations to advanced window functions, CTEs, and cross-sell analysis.

Key accomplishments:

- Designed a fully normalized (3NF) relational schema with 8 tables, 40+ columns, and proper foreign key constraints based on ER modeling
- Developed and optimized 20+ SQL queries across multiple relational tables using JOINs, subqueries, window functions, and CTEs
- Achieved a **25% improvement in data retrieval speed** through strategic indexing, query restructuring, and EXPLAIN ANALYZE benchmarking
- Maintained the project under GitHub version control with feature branches, pull requests, and code reviews

## Database Schema

| Table | Description | Rows (sample) |
|-------|-------------|----------------|
| `customers` | Customer profiles with demographics and geography | 500 |
| `categories` | Product category hierarchy | 12 |
| `suppliers` | Vendor/supplier information | 25 |
| `products` | Product catalog with pricing and supplier links | 200 |
| `employees` | Sales and support staff | 30 |
| `orders` | Customer orders with status and employee assignment | 2,000 |
| `order_items` | Line items per order with quantity and pricing | 6,000 |
| `inventory` | Current stock levels and reorder thresholds | 200 |

See [`docs/er_diagram.md`](docs/er_diagram.md) for the full entity-relationship diagram and [`docs/data_dictionary.md`](docs/data_dictionary.md) for detailed column definitions.

## Repository Structure

```
data-analytics-db/
├── docs/                          # Documentation
│   ├── er_diagram.md              # ER diagram (Mermaid)
│   ├── data_dictionary.md         # Table/column reference
│   └── optimization_report.md     # Performance tuning findings
├── schema/                        # DDL and seed data
│   ├── 01_create_tables.sql       # 8 tables with constraints
│   ├── 02_create_indexes.sql      # Strategic indexes
│   ├── 03_create_views.sql        # Reusable views
│   └── 04_seed_data.sql           # Sample data (500 customers, 2K orders)
├── queries/
│   ├── basic/                     # Foundational analytics (5 queries)
│   ├── advanced/                  # Complex analytics (10 queries)
│   └── optimized/                 # Before/after optimization comparisons
├── scripts/                       # Python utilities
│   ├── generate_data.py           # Realistic data generator
│   ├── run_benchmarks.py          # Query performance benchmarking
│   └── export_reports.py          # Export results to CSV
├── analysis/                      # Business insights
│   ├── findings.md                # Key analytical findings
│   └── recommendations.md         # Data-driven recommendations
└── tests/
    └── test_queries.sql           # Query validation suite
```

## Getting Started

### Prerequisites

- PostgreSQL 14+ (or any PostgreSQL-compatible database)
- Python 3.9+ (for data generation and benchmarking scripts)
- `psycopg2` and `faker` Python packages

### Setup

```bash
# Clone the repository
git clone https://github.com/AwpDemon/data-analytics-db.git
cd data-analytics-db

# Create the database
createdb retailpulse

# Run schema setup in order
psql -d retailpulse -f schema/01_create_tables.sql
psql -d retailpulse -f schema/02_create_indexes.sql
psql -d retailpulse -f schema/03_create_views.sql
psql -d retailpulse -f schema/04_seed_data.sql

# Or generate a larger dataset
pip install psycopg2-binary faker
python scripts/generate_data.py --customers 5000 --orders 20000
```

### Running Queries

```bash
# Run any individual query
psql -d retailpulse -f queries/basic/01_customer_orders.sql

# Run benchmarks
python scripts/run_benchmarks.py

# Export reports to CSV
python scripts/export_reports.py --output exports/
```

## Query Optimization Results

Through systematic EXPLAIN ANALYZE benchmarking and strategic indexing, we reduced average query execution time by **25%** across the 15 core analytical queries.

| Optimization | Technique | Improvement |
|--------------|-----------|-------------|
| Composite indexes on `order_items` | B-tree on `(order_id, product_id)` | 35% faster joins |
| Covering index on `orders` | Include `customer_id`, `order_date`, `status` | 28% fewer disk reads |
| Materialized view for monthly revenue | Pre-aggregated totals | 60% faster dashboard queries |
| CTE refactoring in customer segmentation | Replaced correlated subqueries | 40% reduction in planning time |
| Partial index on active inventory | `WHERE quantity_on_hand > 0` | 22% faster inventory checks |

Full details in [`docs/optimization_report.md`](docs/optimization_report.md).

## Key Findings

- **Top 10% of customers** generate 42% of total revenue (Pareto distribution confirmed)
- **Electronics** category has the highest revenue but lowest margin (8.2%); **Home & Kitchen** has the best margin (34.1%)
- **Q4 seasonal spike** accounts for 31% of annual sales, driven by holiday purchasing
- **Cross-sell opportunity**: Customers who buy laptops have a 67% likelihood of purchasing accessories within 30 days
- **Supplier lead time** correlates with stockout frequency (r = 0.74); consolidating to fewer reliable suppliers could reduce stockouts by an estimated 18%

See [`analysis/findings.md`](analysis/findings.md) and [`analysis/recommendations.md`](analysis/recommendations.md) for the complete analysis.

## Technologies

- **PostgreSQL 15** — Relational database engine
- **SQL** — DDL, DML, window functions, CTEs, EXPLAIN ANALYZE
- **Python 3.11** — Data generation (Faker), benchmarking (psycopg2), CSV export
- **Mermaid** — ER diagram rendering
- **Git/GitHub** — Version control, branch management, pull requests

## License

This project was developed for academic purposes as part of the MIST 4600 curriculum at the University of Georgia, Terry College of Business. It is provided as-is for portfolio and educational use.
