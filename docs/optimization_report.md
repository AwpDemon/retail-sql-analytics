# Query optimization report (measured)

> **Synthetic data.** Measurements were taken on generated data in a local PostgreSQL container.
> This report replaces an earlier version whose timings (an "average 32% improvement", 20-45 ms
> per query, "~80% planning-time reduction") could not be reproduced. Those numbers were not
> measured on this repository's data.

## Setup

| | |
|---|---|
| Database | PostgreSQL 16.14 (`postgres:16-alpine` in Docker, 1 GB memory limit), local laptop |
| Data | `schema/*.sql` + seed, then `python scripts/generate_data.py --customers 20000 --orders 100000` → **20,050 customers, 100,099 orders, 260,257 order items** |
| Method | `scripts/benchmark_optimizations.py`: `ANALYZE`, then per variant 2 warm-up runs and 15 timed `EXPLAIN (ANALYZE, BUFFERS)` runs; report the **median**. Each BEFORE/AFTER pair's result rows are compared with an order-insensitive checksum. |
| Raw results | `docs/benchmark_results_100k.json` (and `docs/benchmark_results_seed.json` for the 50-customer seed sample) |

Reproduce:

```bash
docker run -d --name rp -e POSTGRES_PASSWORD=pw -e POSTGRES_DB=retailpulse -p 127.0.0.1:5432:5432 postgres:16-alpine
for f in schema/0*.sql; do psql "postgresql://postgres:pw@127.0.0.1/retailpulse" -f $f; done
python scripts/generate_data.py --customers 20000 --orders 100000 --password pw --host 127.0.0.1
python scripts/benchmark_optimizations.py --password pw --out docs/benchmark_results_100k.json
```

## Results (100k orders)

| # | Change | Before (ms) | After (ms) | Change | Planning (ms) before → after | Same rows? |
|---|---|---|---|---|---|---|
| 1 | Customer revenue: 2 correlated subqueries per customer → one aggregation CTE | 443.5 | 230.3 | **-48.1%** | 0.29 → 0.28 | yes |
| 2 | Monthly revenue by category: same query, with vs without the covering index `idx_order_items_order_product` | 138.0 | 152.4 | +10.4% | 0.32 → 0.39 | yes |
| 3 | Product sales ranking: partial index on active products + pre-aggregating CTE | 77.2 | 83.9 | +8.7% | 0.36 → 0.29 | no |
| 4 | RFM: 3 correlated subqueries per customer → one aggregation pass + NTILE | 1,156.8 | 364.6 | **-68.5%** | 0.58 → 0.47 | yes |
| 5 | Cross-sell self-join: pre-filter to products in 3+ orders | 256.5 | 718.6 | +180.2% | 0.23 → 0.32 | no |

Run-to-run spread (min-max of the 15 runs) is in the JSON. **Between two complete runs** of the benchmark the
medians moved noticeably: #1 was -59.7% in the first run and -48.1% in this one, and #2
was -5.3% then +10.4%. #4 was stable (-68.1%, -68.5%). Treat
#1 as "roughly a 2x speedup", #4 as "about 3x", and #2 as "no measurable effect".

## What I learned

1. **Correlated subqueries were the real cost (#1, #4).** Each customer row re-scanned `orders` (and
   `order_items`) once per subquery. One `GROUP BY` pass replaces 20,050 × 2-3 lookups with a single hash
   aggregate. That is a 2-3x speedup with identical output.
2. **The covering index (#2) barely matters for this query.** It aggregates most of `order_items`, so the
   planner reads the bulk of the table either way. Covering indexes help selective lookups, not full-table
   aggregations.
3. **Two "optimizations" were not optimizations (#3, #5).** They change the result (dropping inactive
   products, or products with fewer than 3 orders), and on this data they are also slower. The pre-filter in
   #5 adds an extra aggregation pass that costs more than it saves.
4. **Planning time is not where the time goes.** It is 0.2-0.6 ms everywhere.
5. **Fair comparisons need equivalent queries.** The original #1 BEFORE ignored line discounts that AFTER
   applied, and the original #4 BEFORE computed only 50 arbitrary customers (`LIMIT 50` without
   `ORDER BY`) while AFTER scored everyone. Both BEFORE queries were rewritten to return exactly what AFTER
   returns before timing them.

On the 50-customer seed sample every query runs in under 5 ms (see `benchmark_results_seed.json`), which
is too small for timing comparisons to mean much.

## Index inventory

`schema/02_create_indexes.sql` creates 20 indexes (on top of the primary-key and unique-constraint indexes): B-tree foreign-key indexes, a composite
`(order_date, status, customer_id)` index, the covering index above, and partial indexes on active products
and low-stock inventory. Only the covering index was benchmarked in isolation (#2).
