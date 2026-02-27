#!/usr/bin/env python3
"""
RetailPulse — Realistic Sample Data Generator
MIST 4600 | University of Georgia | Spring 2025

Generates realistic e-commerce data and inserts it into a PostgreSQL database.
Uses the Faker library for realistic names, addresses, and dates.

Usage:
    python generate_data.py --customers 5000 --orders 20000 --db retailpulse
    python generate_data.py --help
"""

import argparse
import random
import sys
from datetime import datetime, timedelta
from decimal import Decimal

try:
    import psycopg2
    from psycopg2.extras import execute_values
except ImportError:
    print("Error: psycopg2 is required. Install with: pip install psycopg2-binary")
    sys.exit(1)

try:
    from faker import Faker
except ImportError:
    print("Error: faker is required. Install with: pip install faker")
    sys.exit(1)

fake = Faker()
Faker.seed(42)
random.seed(42)

# Configuration constants
CUSTOMER_SEGMENTS = ["Regular", "Premium", "VIP"]
SEGMENT_WEIGHTS = [0.70, 0.20, 0.10]

ORDER_STATUSES = ["Pending", "Processing", "Shipped", "Delivered", "Cancelled", "Returned"]
STATUS_WEIGHTS = [0.05, 0.05, 0.08, 0.72, 0.06, 0.04]

SHIPPING_METHODS = ["Standard", "Express", "Overnight", "Free Shipping"]
SHIPPING_COSTS = {"Standard": 7.99, "Express": 12.99, "Overnight": 24.99, "Free Shipping": 0.00}
SHIPPING_WEIGHTS = [0.45, 0.25, 0.10, 0.20]

PAYMENT_METHODS = ["Credit Card", "PayPal", "Bank Transfer", "Gift Card"]
PAYMENT_WEIGHTS = [0.55, 0.25, 0.10, 0.10]

US_STATES = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
]

# Weighted state distribution (more customers in populous states)
STATE_WEIGHTS = {
    "CA": 12, "TX": 10, "FL": 8, "NY": 8, "IL": 5, "PA": 5,
    "OH": 4, "GA": 4, "NC": 4, "MI": 3, "NJ": 3, "VA": 3,
    "WA": 3, "AZ": 3, "MA": 3, "TN": 2, "IN": 2, "MO": 2,
    "MD": 2, "WI": 2, "CO": 2, "MN": 2, "SC": 2, "AL": 1,
    "LA": 1, "KY": 1, "OR": 1, "OK": 1, "CT": 1, "UT": 1,
    "IA": 1, "NV": 1, "AR": 1, "MS": 1, "KS": 1, "NM": 1,
    "NE": 1, "ID": 1, "WV": 1, "HI": 1, "NH": 1, "ME": 1,
    "MT": 1, "RI": 1, "DE": 1, "SD": 1, "ND": 1, "AK": 1,
    "VT": 1, "WY": 1,
}


def weighted_state():
    """Pick a US state weighted by population."""
    states = list(STATE_WEIGHTS.keys())
    weights = list(STATE_WEIGHTS.values())
    return random.choices(states, weights=weights, k=1)[0]


def generate_customers(cursor, count):
    """Generate and insert customer records."""
    print(f"Generating {count} customers...")
    customers = []
    emails_seen = set()

    for i in range(count):
        first = fake.first_name()
        last = fake.last_name()
        email = f"{first.lower()}.{last.lower()}{random.randint(1, 9999)}@{fake.free_email_domain()}"

        # Ensure unique email
        while email in emails_seen:
            email = f"{first.lower()}.{last.lower()}{random.randint(1, 99999)}@{fake.free_email_domain()}"
        emails_seen.add(email)

        state = weighted_state()
        segment = random.choices(CUSTOMER_SEGMENTS, weights=SEGMENT_WEIGHTS, k=1)[0]
        registered = fake.date_time_between(start_date="-2y", end_date="now")
        dob = fake.date_of_birth(minimum_age=18, maximum_age=75)

        customers.append((
            first, last, email, fake.phone_number()[:15],
            fake.street_address(), None, fake.city(), state,
            fake.zipcode_in_state(state), "US", dob, registered, segment
        ))

    sql = """
        INSERT INTO customers
            (first_name, last_name, email, phone, address_line1, address_line2,
             city, state, zip_code, country, date_of_birth, registered_at, customer_segment)
        VALUES %s
    """
    execute_values(cursor, sql, customers, page_size=500)
    print(f"  Inserted {count} customers.")


def generate_orders(cursor, count, num_customers, num_products, num_employees):
    """Generate orders and order items."""
    print(f"Generating {count} orders...")

    # Sales employee IDs (assume employees 8-19 are sales reps based on seed data)
    sales_employees = list(range(8, min(num_employees + 1, 20)))

    orders = []
    order_items_all = []
    order_id = 1

    # Get existing max order ID
    cursor.execute("SELECT COALESCE(MAX(order_id), 0) FROM orders")
    start_id = cursor.fetchone()[0] + 1

    for i in range(count):
        customer_id = random.randint(1, num_customers)
        employee_id = random.choice(sales_employees)

        # Order date: weighted toward more recent dates
        days_ago = int(random.triangular(0, 730, 30))
        order_date = datetime.now() - timedelta(days=days_ago)

        status = random.choices(ORDER_STATUSES, weights=STATUS_WEIGHTS, k=1)[0]
        shipping = random.choices(SHIPPING_METHODS, weights=SHIPPING_WEIGHTS, k=1)[0]
        payment = random.choices(PAYMENT_METHODS, weights=PAYMENT_WEIGHTS, k=1)[0]

        shipping_cost = SHIPPING_COSTS[shipping]
        discount = round(random.choice([0, 0, 0, 5, 10, 15, 20, 25, 30]), 2)

        shipped_date = None
        delivered_date = None
        if status in ("Shipped", "Delivered"):
            shipped_date = order_date + timedelta(days=random.randint(1, 3))
        if status == "Delivered":
            delivered_date = shipped_date + timedelta(days=random.randint(2, 7))

        orders.append((
            customer_id, employee_id, order_date, shipped_date, delivered_date,
            status, shipping, shipping_cost, payment, discount
        ))

        # Generate 1-5 line items per order
        num_items = random.choices([1, 2, 3, 4, 5], weights=[15, 35, 30, 15, 5], k=1)[0]
        products_in_order = random.sample(range(1, num_products + 1), min(num_items, num_products))

        for product_id in products_in_order:
            quantity = random.choices([1, 2, 3], weights=[70, 20, 10], k=1)[0]
            # Price variation: +/- 5% from base (simulated)
            base_price = round(random.uniform(19.99, 1799.99), 2)
            item_discount = random.choice([0, 0, 0, 0, 5, 8, 10, 15])

            order_items_all.append((
                start_id + i, product_id, quantity, base_price, item_discount
            ))

    # Insert orders
    order_sql = """
        INSERT INTO orders
            (customer_id, employee_id, order_date, shipped_date, delivered_date,
             status, shipping_method, shipping_cost, payment_method, discount_amount)
        VALUES %s
    """
    execute_values(cursor, order_sql, orders, page_size=500)

    # Insert order items
    items_sql = """
        INSERT INTO order_items
            (order_id, product_id, quantity, unit_price, discount_percent)
        VALUES %s
    """
    execute_values(cursor, items_sql, order_items_all, page_size=1000)
    print(f"  Inserted {count} orders with {len(order_items_all)} line items.")


def main():
    parser = argparse.ArgumentParser(description="Generate RetailPulse sample data")
    parser.add_argument("--customers", type=int, default=500, help="Number of customers (default: 500)")
    parser.add_argument("--orders", type=int, default=2000, help="Number of orders (default: 2000)")
    parser.add_argument("--db", type=str, default="retailpulse", help="Database name (default: retailpulse)")
    parser.add_argument("--host", type=str, default="localhost", help="Database host")
    parser.add_argument("--port", type=int, default=5432, help="Database port")
    parser.add_argument("--user", type=str, default="postgres", help="Database user")
    parser.add_argument("--password", type=str, default="", help="Database password")
    parser.add_argument("--seed-only", action="store_true", help="Only generate additional data (skip schema)")
    args = parser.parse_args()

    print(f"RetailPulse Data Generator")
    print(f"  Database: {args.db}")
    print(f"  Customers: {args.customers}")
    print(f"  Orders: {args.orders}")
    print()

    try:
        conn = psycopg2.connect(
            dbname=args.db,
            host=args.host,
            port=args.port,
            user=args.user,
            password=args.password
        )
        conn.autocommit = False
        cursor = conn.cursor()

        # Get product count (assumes schema + seed data already loaded)
        cursor.execute("SELECT COUNT(*) FROM products")
        num_products = cursor.fetchone()[0]
        if num_products == 0:
            print("Error: No products found. Run schema/04_seed_data.sql first.")
            sys.exit(1)

        cursor.execute("SELECT COUNT(*) FROM employees")
        num_employees = cursor.fetchone()[0]

        # Generate customers
        generate_customers(cursor, args.customers)

        # Get total customer count after insert
        cursor.execute("SELECT COUNT(*) FROM customers")
        total_customers = cursor.fetchone()[0]

        # Generate orders
        generate_orders(cursor, args.orders, total_customers, num_products, num_employees)

        conn.commit()
        print("\nData generation complete!")

        # Print summary
        for table in ["customers", "categories", "suppliers", "products",
                       "employees", "orders", "order_items", "inventory"]:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"  {table}: {count:,} rows")

    except psycopg2.OperationalError as e:
        print(f"Database connection error: {e}")
        print("Make sure the database exists and credentials are correct.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        if 'conn' in locals():
            conn.rollback()
        sys.exit(1)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()


if __name__ == "__main__":
    main()
