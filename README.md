# Data Analytics DB

A SQL + Python project I built to practice the kind of database work that comes up in business analyst and data analyst roles. Sets up a normalized database, loads sample data, and runs a series of analytical queries.

## What's in here

- `schema/` — SQL scripts to create the database tables (customers, transactions, products, etc.)
- `queries/` — analytical SQL queries — things like customer segmentation, revenue trends, cohort analysis, top products by region
- `scripts/` — Python scripts for loading data and running the analysis pipeline
- `analysis/` — output from the queries, charts, summary reports
- `tests/` — basic tests to verify the queries return expected results
- `docs/` — notes on the schema design decisions

## Why I built this

I kept running into SQL questions in interview prep and realized I needed a project where I actually designed the schema, wrote complex queries (JOINs, window functions, CTEs), and analyzed the results — not just solved isolated LeetCode SQL problems.

## Skills practiced

- Database schema design (normalization, foreign keys, indexes)
- Analytical SQL (GROUP BY, window functions, CTEs, self-joins)
- Python + SQL integration
- Data cleaning and validation

## To run

```bash
pip install -r requirements.txt
```
See `docs/` for setup instructions.
