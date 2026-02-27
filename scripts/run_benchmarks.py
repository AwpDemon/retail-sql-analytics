#!/usr/bin/env python3
"""
RetailPulse — Query Performance Benchmarking Tool
MIST 4600 | University of Georgia | Spring 2025

Runs each analytical query multiple times with EXPLAIN ANALYZE and reports
median execution times, planning times, and row counts.

Usage:
    python run_benchmarks.py --db retailpulse --iterations 10
    python run_benchmarks.py --query queries/basic/01_customer_orders.sql
"""

import argparse
import os
import re
import statistics
import sys
import time
from pathlib import Path

try:
    import psycopg2
except ImportError:
    print("Error: psycopg2 is required. Install with: pip install psycopg2-binary")
    sys.exit(1)


# Query files to benchmark (relative to project root)
QUERY_FILES = [
    "queries/basic/01_customer_orders.sql",
    "queries/basic/02_product_sales.sql",
    "queries/basic/03_revenue_by_category.sql",
    "queries/basic/04_inventory_status.sql",
    "queries/basic/05_employee_performance.sql",
    "queries/advanced/06_customer_lifetime_value.sql",
    "queries/advanced/07_sales_trends.sql",
    "queries/advanced/08_cross_sell_analysis.sql",
    "queries/advanced/09_supplier_performance.sql",
    "queries/advanced/10_churn_prediction.sql",
    "queries/advanced/11_geographic_analysis.sql",
    "queries/advanced/12_seasonal_patterns.sql",
    "queries/advanced/13_profit_margins.sql",
    "queries/advanced/14_inventory_turnover.sql",
    "queries/advanced/15_customer_segmentation.sql",
]


def find_project_root():
    """Walk up from script location to find the project root."""
    current = Path(__file__).resolve().parent.parent
    if (current / "schema").exists():
        return current
    return Path.cwd()


def strip_explain(sql):
    """Remove any existing EXPLAIN ANALYZE from the query."""
    return re.sub(r"^\s*EXPLAIN\s+(ANALYZE\s+)?", "", sql, flags=re.IGNORECASE | re.MULTILINE)


def parse_explain_output(rows):
    """Extract planning and execution time from EXPLAIN ANALYZE output."""
    planning_time = None
    execution_time = None

    for row in rows:
        line = row[0] if isinstance(row, tuple) else row
        planning_match = re.search(r"Planning Time:\s+([\d.]+)\s*ms", line)
        execution_match = re.search(r"Execution Time:\s+([\d.]+)\s*ms", line)
        if planning_match:
            planning_time = float(planning_match.group(1))
        if execution_match:
            execution_time = float(execution_match.group(1))

    return planning_time, execution_time


def benchmark_query(cursor, sql, iterations=10):
    """Run a query multiple times and return timing statistics."""
    planning_times = []
    execution_times = []
    wall_times = []
    row_count = 0

    explain_sql = f"EXPLAIN (ANALYZE, BUFFERS) {sql}"

    for i in range(iterations):
        start = time.perf_counter()
        try:
            cursor.execute(explain_sql)
            rows = cursor.fetchall()
            wall_time = (time.perf_counter() - start) * 1000

            planning, execution = parse_explain_output(rows)
            if planning is not None:
                planning_times.append(planning)
            if execution is not None:
                execution_times.append(execution)
            wall_times.append(wall_time)

        except psycopg2.Error as e:
            # If EXPLAIN fails, try running the query directly for wall-clock timing
            cursor.connection.rollback()
            start = time.perf_counter()
            try:
                cursor.execute(sql)
                rows = cursor.fetchall()
                wall_time = (time.perf_counter() - start) * 1000
                wall_times.append(wall_time)
                row_count = len(rows)
            except psycopg2.Error:
                cursor.connection.rollback()
                return None

    # Also run the raw query once to get the row count
    try:
        cursor.execute(sql)
        result_rows = cursor.fetchall()
        row_count = len(result_rows)
    except psycopg2.Error:
        cursor.connection.rollback()

    return {
        "planning_median": statistics.median(planning_times) if planning_times else None,
        "execution_median": statistics.median(execution_times) if execution_times else None,
        "wall_median": statistics.median(wall_times) if wall_times else None,
        "wall_min": min(wall_times) if wall_times else None,
        "wall_max": max(wall_times) if wall_times else None,
        "iterations": iterations,
        "row_count": row_count,
    }


def main():
    parser = argparse.ArgumentParser(description="Benchmark RetailPulse SQL queries")
    parser.add_argument("--db", type=str, default="retailpulse", help="Database name")
    parser.add_argument("--host", type=str, default="localhost", help="Database host")
    parser.add_argument("--port", type=int, default=5432, help="Database port")
    parser.add_argument("--user", type=str, default="postgres", help="Database user")
    parser.add_argument("--password", type=str, default="", help="Database password")
    parser.add_argument("--iterations", type=int, default=10, help="Benchmark iterations per query")
    parser.add_argument("--query", type=str, help="Benchmark a single query file")
    args = parser.parse_args()

    project_root = find_project_root()
    query_files = [args.query] if args.query else QUERY_FILES

    print("=" * 80)
    print("RetailPulse Query Benchmark")
    print(f"Database: {args.db} | Iterations: {args.iterations}")
    print("=" * 80)
    print()

    try:
        conn = psycopg2.connect(
            dbname=args.db,
            host=args.host,
            port=args.port,
            user=args.user,
            password=args.password
        )
        conn.autocommit = True
        cursor = conn.cursor()
    except psycopg2.OperationalError as e:
        print(f"Database connection error: {e}")
        sys.exit(1)

    results = []

    for query_file in query_files:
        filepath = project_root / query_file
        if not filepath.exists():
            print(f"  SKIP: {query_file} (file not found)")
            continue

        sql = filepath.read_text()

        # Remove comments and empty lines, take the main query
        # (skip EXPLAIN if already present in the file)
        sql = strip_explain(sql)

        # Remove trailing semicolons (psycopg2 handles termination)
        sql = sql.strip().rstrip(";")

        if not sql:
            continue

        print(f"  Benchmarking: {query_file}")
        result = benchmark_query(cursor, sql, args.iterations)

        if result:
            results.append({"file": query_file, **result})
            exec_ms = result["execution_median"] or result["wall_median"] or 0
            print(f"    Rows: {result['row_count']:>6} | "
                  f"Exec: {exec_ms:>8.2f}ms | "
                  f"Plan: {result['planning_median'] or 0:>6.2f}ms | "
                  f"Wall: {result['wall_median'] or 0:>8.2f}ms")
        else:
            print(f"    ERROR: Query failed")

    # Print summary table
    print()
    print("=" * 80)
    print(f"{'Query File':<50} {'Exec (ms)':>10} {'Plan (ms)':>10} {'Rows':>8}")
    print("-" * 80)

    total_exec = 0
    for r in results:
        exec_ms = r["execution_median"] or r["wall_median"] or 0
        plan_ms = r["planning_median"] or 0
        total_exec += exec_ms
        name = os.path.basename(r["file"])
        print(f"  {name:<48} {exec_ms:>10.2f} {plan_ms:>10.2f} {r['row_count']:>8}")

    print("-" * 80)
    if results:
        avg_exec = total_exec / len(results)
        print(f"  {'AVERAGE':<48} {avg_exec:>10.2f}")
        print(f"  {'TOTAL':<48} {total_exec:>10.2f}")
    print("=" * 80)

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
