#!/usr/bin/env python3
"""
RetailPulse — Report Exporter
MIST 4600 | University of Georgia | Spring 2025

Runs analytical queries and exports results to CSV files for use in
presentations, dashboards, or further analysis in Python/R/Excel.

Usage:
    python export_reports.py --db retailpulse --output exports/
    python export_reports.py --query queries/basic/01_customer_orders.sql --output results.csv
"""

import argparse
import csv
import os
import sys
from datetime import datetime
from pathlib import Path

try:
    import psycopg2
    from psycopg2.extras import RealDictCursor
except ImportError:
    print("Error: psycopg2 is required. Install with: pip install psycopg2-binary")
    sys.exit(1)


# Reports to export (query file -> output filename)
REPORT_QUERIES = {
    "queries/basic/01_customer_orders.sql": "customer_orders.csv",
    "queries/basic/02_product_sales.sql": "product_sales.csv",
    "queries/basic/03_revenue_by_category.sql": "revenue_by_category.csv",
    "queries/basic/04_inventory_status.sql": "inventory_status.csv",
    "queries/basic/05_employee_performance.sql": "employee_performance.csv",
    "queries/advanced/06_customer_lifetime_value.sql": "customer_lifetime_value.csv",
    "queries/advanced/07_sales_trends.sql": "sales_trends.csv",
    "queries/advanced/08_cross_sell_analysis.sql": "cross_sell_analysis.csv",
    "queries/advanced/09_supplier_performance.sql": "supplier_scorecard.csv",
    "queries/advanced/10_churn_prediction.sql": "churn_risk.csv",
    "queries/advanced/11_geographic_analysis.sql": "geographic_analysis.csv",
    "queries/advanced/13_profit_margins.sql": "profit_margins.csv",
    "queries/advanced/14_inventory_turnover.sql": "inventory_turnover.csv",
    "queries/advanced/15_customer_segmentation.sql": "customer_segments.csv",
}


def find_project_root():
    """Walk up from script location to find the project root."""
    current = Path(__file__).resolve().parent.parent
    if (current / "schema").exists():
        return current
    return Path.cwd()


def clean_sql(sql_text):
    """Remove EXPLAIN ANALYZE and clean up query for execution."""
    import re
    sql = re.sub(r"^\s*EXPLAIN\s+(ANALYZE\s+)?", "", sql_text,
                 flags=re.IGNORECASE | re.MULTILINE)
    return sql.strip().rstrip(";")


def export_query_to_csv(cursor, sql, output_path):
    """Execute a query and write results to a CSV file."""
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()

        if not rows:
            print(f"    No results returned.")
            return 0

        # Get column names from cursor description
        columns = [desc[0] for desc in cursor.description]

        os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)

        with open(output_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(columns)
            for row in rows:
                writer.writerow([
                    str(val) if val is not None else ""
                    for val in row
                ])

        return len(rows)

    except psycopg2.Error as e:
        print(f"    Query error: {e}")
        cursor.connection.rollback()
        return -1


def main():
    parser = argparse.ArgumentParser(description="Export RetailPulse query results to CSV")
    parser.add_argument("--db", type=str, default="retailpulse", help="Database name")
    parser.add_argument("--host", type=str, default="localhost", help="Database host")
    parser.add_argument("--port", type=int, default=5432, help="Database port")
    parser.add_argument("--user", type=str, default="postgres", help="Database user")
    parser.add_argument("--password", type=str, default="", help="Database password")
    parser.add_argument("--output", type=str, default="exports", help="Output directory or file")
    parser.add_argument("--query", type=str, help="Export a single query file")
    args = parser.parse_args()

    project_root = find_project_root()
    output_base = Path(args.output)

    print("=" * 60)
    print("RetailPulse Report Exporter")
    print(f"Database: {args.db}")
    print(f"Output: {output_base}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
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

    if args.query:
        # Single query mode
        query_path = project_root / args.query
        if not query_path.exists():
            print(f"Error: Query file not found: {query_path}")
            sys.exit(1)

        sql = clean_sql(query_path.read_text())
        output_file = str(output_base) if output_base.suffix == ".csv" else \
            str(output_base / f"{query_path.stem}.csv")

        print(f"  Exporting: {args.query}")
        rows = export_query_to_csv(cursor, sql, output_file)
        if rows >= 0:
            print(f"    -> {output_file} ({rows} rows)")
    else:
        # Batch mode: export all reports
        total_rows = 0
        exported = 0

        for query_file, output_name in REPORT_QUERIES.items():
            filepath = project_root / query_file
            if not filepath.exists():
                print(f"  SKIP: {query_file} (not found)")
                continue

            sql = clean_sql(filepath.read_text())
            output_file = str(output_base / output_name)

            print(f"  Exporting: {os.path.basename(query_file)}")
            rows = export_query_to_csv(cursor, sql, output_file)
            if rows >= 0:
                print(f"    -> {output_file} ({rows} rows)")
                total_rows += rows
                exported += 1

        print()
        print(f"Export complete: {exported} files, {total_rows:,} total rows")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
