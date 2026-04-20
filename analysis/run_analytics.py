"""
run_analytics.py — End-to-end analytics pipeline for RetailPulse.

Generates a synthetic dataset in pandas, loads it into DuckDB (which accepts
most of the PostgreSQL SQL dialect the production queries are written in),
executes the core analytical queries, and produces the visualizations that
back the findings in analysis/findings.md.

Outputs land in analysis/outputs/ and are embedded in the repo README.

Run:
    pip install -r requirements.txt
    python analysis/run_analytics.py
"""

from __future__ import annotations

import os
import random
from datetime import datetime, timedelta

import duckdb
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np
import pandas as pd
import seaborn as sns

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(BASE, "analysis", "outputs")
os.makedirs(OUT, exist_ok=True)

RNG_SEED = 42
np.random.seed(RNG_SEED)
random.seed(RNG_SEED)

sns.set_theme(style="whitegrid", font_scale=1.05)
PALETTE = sns.color_palette("deep")


# ────────────────────────────────────────────────────────────────
#  1. Synthesize data
# ────────────────────────────────────────────────────────────────
def synthesize() -> dict[str, pd.DataFrame]:
    n_customers = 2000
    n_products = 250
    n_orders = 12000

    segments = np.random.choice(
        ["Regular", "Premium", "VIP"], size=n_customers, p=[0.70, 0.22, 0.08]
    )
    states = np.random.choice(
        ["GA", "FL", "NC", "SC", "TN", "AL", "VA", "KY", "AR", "MS", "LA", "TX"],
        size=n_customers,
        p=[0.20, 0.15, 0.10, 0.08, 0.08, 0.07, 0.08, 0.05, 0.05, 0.05, 0.04, 0.05],
    )
    reg_days = np.random.randint(0, 730, size=n_customers)
    registered = [datetime(2024, 1, 1) + timedelta(days=int(d)) for d in reg_days]

    customers = pd.DataFrame({
        "customer_id": np.arange(1, n_customers + 1),
        "customer_segment": segments,
        "state": states,
        "registered_at": registered,
    })

    parent_cats = ["Electronics", "Home & Kitchen", "Apparel", "Sports & Outdoors"]
    child_cats = {
        "Electronics":       ["Laptops", "Smartphones", "Audio"],
        "Home & Kitchen":    ["Cookware", "Small Appliances"],
        "Apparel":           ["Mens Clothing", "Womens Clothing"],
        "Sports & Outdoors": ["Fitness Equipment"],
    }
    cat_rows = []
    cid = 1
    parent_id = {}
    for p in parent_cats:
        parent_id[p] = cid
        cat_rows.append({"category_id": cid, "category_name": p, "parent_category_id": None})
        cid += 1
    for parent, kids in child_cats.items():
        for k in kids:
            cat_rows.append({"category_id": cid, "category_name": k, "parent_category_id": parent_id[parent]})
            cid += 1
    categories = pd.DataFrame(cat_rows)

    # price range per top-level category influences revenue mix
    cat_price = {
        "Laptops": (600, 1800), "Smartphones": (300, 1200), "Audio": (40, 400),
        "Cookware": (30, 220), "Small Appliances": (40, 350),
        "Mens Clothing": (20, 160), "Womens Clothing": (20, 180),
        "Fitness Equipment": (25, 500),
    }
    child_names = list(cat_price.keys())
    prod_cats = np.random.choice(child_names, size=n_products, p=[0.12, 0.10, 0.15, 0.14, 0.10, 0.13, 0.14, 0.12])
    prices = []
    for c in prod_cats:
        lo, hi = cat_price[c]
        prices.append(round(np.random.uniform(lo, hi), 2))
    name_to_id = {r["category_name"]: r["category_id"] for _, r in categories.iterrows()}
    products = pd.DataFrame({
        "product_id": np.arange(1, n_products + 1),
        "category_id": [name_to_id[c] for c in prod_cats],
        "unit_price": prices,
    })

    # Seasonal order distribution: stronger Q4, light Q1
    month_weights = np.array([0.055, 0.055, 0.065, 0.075, 0.080, 0.085,
                              0.080, 0.080, 0.085, 0.095, 0.115, 0.130])
    order_months = np.random.choice(np.arange(12), size=n_orders, p=month_weights)
    order_days = np.random.randint(1, 28, size=n_orders)
    order_years = np.random.choice([2024, 2025], size=n_orders, p=[0.45, 0.55])
    order_dates = [datetime(int(y), int(m) + 1, int(d))
                   for y, m, d in zip(order_years, order_months, order_days)]

    # Pareto-ish customer selection — 20% of customers take ~60% of orders
    pareto_weights = np.random.pareto(1.5, n_customers) + 1
    pareto_weights /= pareto_weights.sum()
    order_cust = np.random.choice(np.arange(1, n_customers + 1), size=n_orders, p=pareto_weights)

    orders = pd.DataFrame({
        "order_id": np.arange(1, n_orders + 1),
        "customer_id": order_cust,
        "order_date": order_dates,
        "status": np.random.choice(
            ["Delivered", "Shipped", "Cancelled", "Returned"],
            size=n_orders, p=[0.82, 0.10, 0.05, 0.03]
        ),
    })

    # order items: 1-5 items per order
    items_rows = []
    item_id = 1
    for oid in orders["order_id"]:
        n_items = np.random.choice([1, 2, 3, 4, 5], p=[0.40, 0.30, 0.18, 0.08, 0.04])
        picks = np.random.choice(products["product_id"].values, size=n_items, replace=False)
        for pid in picks:
            price = products.loc[products.product_id == pid, "unit_price"].iloc[0]
            items_rows.append({
                "order_item_id": item_id,
                "order_id": oid,
                "product_id": int(pid),
                "quantity": int(np.random.choice([1, 1, 1, 2, 2, 3], size=1)[0]),
                "unit_price": float(price),
                "discount_percent": float(np.random.choice([0, 0, 0, 5, 10, 15], size=1)[0]),
            })
            item_id += 1
    order_items = pd.DataFrame(items_rows)

    return {
        "customers": customers,
        "categories": categories,
        "products": products,
        "orders": orders,
        "order_items": order_items,
    }


# ────────────────────────────────────────────────────────────────
#  2. Load into DuckDB
# ────────────────────────────────────────────────────────────────
def load_db(frames: dict[str, pd.DataFrame]) -> duckdb.DuckDBPyConnection:
    con = duckdb.connect(":memory:")
    for name, df in frames.items():
        con.register(name, df)
        con.execute(f"CREATE TABLE {name} AS SELECT * FROM {name}_df" if False else
                    f"CREATE TABLE {name} AS SELECT * FROM {name}")
    return con


# ────────────────────────────────────────────────────────────────
#  3. Queries & charts
# ────────────────────────────────────────────────────────────────
def chart_pareto(con, out):
    """Top 10% of customers drive X% of revenue (findings.md claim)."""
    df = con.execute("""
        WITH cust_rev AS (
          SELECT c.customer_id,
                 SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS revenue
          FROM customers c
          JOIN orders o ON o.customer_id = c.customer_id
                      AND o.status NOT IN ('Cancelled', 'Returned')
          JOIN order_items oi ON oi.order_id = o.order_id
          GROUP BY c.customer_id
        )
        SELECT revenue FROM cust_rev ORDER BY revenue DESC
    """).fetchdf()
    df["cum_pct"] = df["revenue"].cumsum() / df["revenue"].sum() * 100
    df["cust_pct"] = (np.arange(len(df)) + 1) / len(df) * 100

    fig, ax = plt.subplots(figsize=(8.5, 5))
    ax.plot(df["cust_pct"], df["cum_pct"], color=PALETTE[0], lw=2.2)
    ax.axvline(10, color="#888", ls="--", lw=1)
    ax.axhline(df.loc[df["cust_pct"] <= 10, "cum_pct"].iloc[-1], color="#888", ls="--", lw=1)
    top10_share = df.loc[df["cust_pct"] <= 10, "cum_pct"].iloc[-1]
    ax.set_title(f"Revenue Concentration (Pareto): Top 10% of customers → {top10_share:.1f}% of revenue",
                 fontsize=13, fontweight="bold")
    ax.set_xlabel("Cumulative % of Customers (sorted by revenue, descending)")
    ax.set_ylabel("Cumulative % of Revenue")
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    plt.tight_layout()
    plt.savefig(os.path.join(out, "01_pareto_revenue.png"), dpi=150)
    plt.close()
    return top10_share


def chart_category_revenue(con, out):
    df = con.execute("""
        SELECT COALESCE(pc.category_name, cat.category_name) AS top_category,
               SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS revenue
        FROM order_items oi
        JOIN orders o ON o.order_id = oi.order_id AND o.status NOT IN ('Cancelled', 'Returned')
        JOIN products p ON p.product_id = oi.product_id
        JOIN categories cat ON cat.category_id = p.category_id
        LEFT JOIN categories pc ON pc.category_id = cat.parent_category_id
        GROUP BY top_category
        ORDER BY revenue DESC
    """).fetchdf()
    df["pct"] = df["revenue"] / df["revenue"].sum() * 100

    fig, ax = plt.subplots(figsize=(8.5, 5))
    bars = ax.barh(df["top_category"][::-1], df["pct"][::-1],
                   color=[PALETTE[i] for i in range(len(df))][::-1], edgecolor="white")
    for bar, v in zip(bars, df["pct"][::-1]):
        ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2,
                f"{v:.1f}%", va="center", fontsize=11)
    ax.set_title("Revenue Share by Top-Level Category", fontsize=13, fontweight="bold")
    ax.set_xlabel("% of Total Revenue")
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    plt.tight_layout()
    plt.savefig(os.path.join(out, "02_category_revenue.png"), dpi=150)
    plt.close()


def chart_seasonality(con, out):
    df = con.execute("""
        SELECT date_trunc('month', o.order_date) AS month,
               SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS revenue
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.status NOT IN ('Cancelled','Returned')
        GROUP BY month
        ORDER BY month
    """).fetchdf()

    fig, ax = plt.subplots(figsize=(9.5, 5))
    ax.plot(df["month"], df["revenue"], marker="o", color=PALETTE[3], lw=2)
    q4_rev = df[df["month"].dt.month.isin([10, 11, 12])]["revenue"].sum()
    total_rev = df["revenue"].sum()
    q4_share = q4_rev / total_rev * 100
    ax.set_title(f"Monthly Revenue — Q4 accounts for {q4_share:.1f}% of annual sales",
                 fontsize=13, fontweight="bold")
    ax.set_xlabel("")
    ax.set_ylabel("Revenue (USD)")
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
    plt.xticks(rotation=30)
    plt.tight_layout()
    plt.savefig(os.path.join(out, "03_monthly_seasonality.png"), dpi=150)
    plt.close()
    return q4_share


def chart_rfm_segments(con, out):
    df = con.execute("""
        WITH rfm AS (
          SELECT c.customer_id,
                 DATE_DIFF('day', MAX(o.order_date), DATE '2025-12-31') AS recency_days,
                 COUNT(DISTINCT o.order_id) AS frequency,
                 SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS monetary
          FROM customers c
          JOIN orders o ON o.customer_id = c.customer_id
                      AND o.status NOT IN ('Cancelled','Returned')
          JOIN order_items oi ON oi.order_id = o.order_id
          GROUP BY c.customer_id
        ),
        scored AS (
          SELECT *,
                 NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
                 NTILE(5) OVER (ORDER BY frequency  DESC) AS f_score,
                 NTILE(5) OVER (ORDER BY monetary   DESC) AS m_score
          FROM rfm
        )
        SELECT
          CASE
            WHEN r_score<=1 AND f_score<=2 THEN 'Lost'
            WHEN r_score<=2 AND f_score<=2 THEN 'Hibernating'
            WHEN r_score<=2 AND f_score>=3 THEN 'At Risk — Need Attention'
            WHEN r_score<=3 AND m_score>=4 THEN 'At Risk — High Value Cooling'
            WHEN r_score>=4 AND f_score>=4 THEN 'Loyal / Champion'
            WHEN r_score>=4 AND f_score<=2 THEN 'New — Promising'
            ELSE 'Monitor'
          END AS segment,
          COUNT(*) AS n
        FROM scored
        GROUP BY segment
        ORDER BY n DESC
    """).fetchdf()

    fig, ax = plt.subplots(figsize=(9, 5))
    colors = sns.color_palette("RdYlGn_r", len(df))
    bars = ax.barh(df["segment"][::-1], df["n"][::-1], color=colors[::-1], edgecolor="white")
    for bar, v in zip(bars, df["n"][::-1]):
        ax.text(bar.get_width() + max(df["n"])*0.01, bar.get_y() + bar.get_height()/2,
                f"{v:,}", va="center", fontsize=10)
    ax.set_title("Customer RFM Segments", fontsize=13, fontweight="bold")
    ax.set_xlabel("Customers")
    plt.tight_layout()
    plt.savefig(os.path.join(out, "04_rfm_segments.png"), dpi=150)
    plt.close()


def chart_state_heatmap(con, out):
    df = con.execute("""
        SELECT c.state,
               COALESCE(pc.category_name, cat.category_name) AS category,
               SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS revenue
        FROM customers c
        JOIN orders o       ON o.customer_id = c.customer_id AND o.status NOT IN ('Cancelled','Returned')
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p     ON p.product_id = oi.product_id
        JOIN categories cat ON cat.category_id = p.category_id
        LEFT JOIN categories pc ON pc.category_id = cat.parent_category_id
        GROUP BY c.state, category
    """).fetchdf()
    pivot = df.pivot_table(index="state", columns="category", values="revenue", aggfunc="sum", fill_value=0)
    pivot = pivot.loc[pivot.sum(axis=1).sort_values(ascending=False).index]

    fig, ax = plt.subplots(figsize=(8.5, 6))
    sns.heatmap(pivot / 1000, annot=True, fmt=".0f", cmap="YlOrRd",
                cbar_kws={"label": "Revenue ($K)"}, ax=ax)
    ax.set_title("Revenue by State × Category (USD, thousands)", fontsize=13, fontweight="bold")
    ax.set_xlabel("")
    ax.set_ylabel("")
    plt.tight_layout()
    plt.savefig(os.path.join(out, "05_state_category_heatmap.png"), dpi=150)
    plt.close()


def chart_aov_distribution(con, out):
    df = con.execute("""
        SELECT o.order_id,
               SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100.0)) AS order_value
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.status NOT IN ('Cancelled','Returned')
        GROUP BY o.order_id
    """).fetchdf()

    fig, ax = plt.subplots(figsize=(8.5, 5))
    sns.histplot(df["order_value"].clip(upper=df["order_value"].quantile(0.99)),
                 bins=50, color=PALETTE[2], edgecolor="white", ax=ax)
    ax.axvline(df["order_value"].mean(), color="#e74c3c", ls="--", lw=2,
               label=f"Mean: ${df['order_value'].mean():.0f}")
    ax.axvline(df["order_value"].median(), color="#2c3e50", ls="--", lw=2,
               label=f"Median: ${df['order_value'].median():.0f}")
    ax.legend()
    ax.set_title("Order Value Distribution (capped at 99th percentile)", fontsize=13, fontweight="bold")
    ax.set_xlabel("Order Value (USD)")
    ax.set_ylabel("Orders")
    plt.tight_layout()
    plt.savefig(os.path.join(out, "06_order_value_distribution.png"), dpi=150)
    plt.close()


# ────────────────────────────────────────────────────────────────
#  Main
# ────────────────────────────────────────────────────────────────
def main():
    print("[1/3] Synthesizing data …")
    frames = synthesize()
    print(f"      customers={len(frames['customers']):,}  orders={len(frames['orders']):,}  "
          f"order_items={len(frames['order_items']):,}")

    print("[2/3] Loading DuckDB …")
    con = load_db(frames)

    print("[3/3] Running queries + rendering charts …")
    top10 = chart_pareto(con, OUT)
    chart_category_revenue(con, OUT)
    q4 = chart_seasonality(con, OUT)
    chart_rfm_segments(con, OUT)
    chart_state_heatmap(con, OUT)
    chart_aov_distribution(con, OUT)

    print()
    print(f"  Top 10% of customers → {top10:.1f}% of revenue")
    print(f"  Q4 share of annual revenue: {q4:.1f}%")
    print(f"  Outputs written to {OUT}")


if __name__ == "__main__":
    main()
