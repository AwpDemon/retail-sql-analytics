"""Guards against README/findings drifting from computed results.

- README numbers must match analysis/outputs/metrics.json and docs/benchmark_results_100k.json
- analysis/findings.md must be exactly what analysis/write_findings.py generates
- RFM scoring direction: higher scores must mean more recent / more frequent / higher spend
"""
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "analysis"))

METRICS = json.loads((ROOT / "analysis" / "outputs" / "metrics.json").read_text(encoding="utf-8"))
BENCH = {r["num"]: r for r in json.loads(
    (ROOT / "docs" / "benchmark_results_100k.json").read_text(encoding="utf-8"))["results"]}
README = (ROOT / "README.md").read_text(encoding="utf-8")


def test_readme_pipeline_numbers_match_metrics():
    assert f"{METRICS['top10pct_revenue_share_pct']}% of net revenue" in README
    assert f"Q4 = {METRICS['q4_revenue_share_pct']}%" in README
    assert f"{METRICS['category_revenue_share_pct']['Electronics']}% of net revenue" in README
    assert f"${METRICS['aov_mean']:,.2f}" in README and f"${METRICS['aov_median']:,.2f}" in README
    assert f"{METRICS['customers_with_revenue']:,} customers with revenue" in README


def test_readme_benchmark_numbers_match_json():
    for n in (1, 4):
        r = BENCH[n]
        assert f"{r['before']['execution_ms_median']:,.0f} → {r['after']['execution_ms_median']:,.0f} ms" in README
        assert f"({r['execution_change_pct']:.0f}%)" in README
        assert r["same_result"], f"optimization {n} must return identical rows"


def test_no_retracted_claims_in_readme():
    for stale in ("4.8 lift", "~80%", "~42%", "31% of annual", "CA and NY"):
        assert stale not in README


def test_findings_md_is_generated(tmp_path):
    committed = (ROOT / "analysis" / "findings.md").read_text(encoding="utf-8")
    subprocess.run([sys.executable, str(ROOT / "analysis" / "write_findings.py")], check=True)
    assert (ROOT / "analysis" / "findings.md").read_text(encoding="utf-8") == committed


def test_rfm_scores_point_the_right_way(tmp_path):
    """A recent, frequent, big spender must not be labeled 'Lost'."""
    import run_analytics

    cust = pd.DataFrame({"customer_id": range(1, 11), "customer_segment": "Regular", "state": "GA",
                         "registered_at": datetime(2024, 1, 1)})
    orders, items = [], []
    oid = 1
    for c in range(1, 11):
        # customer 10: 10 recent big orders; customer 1: one old small order
        for k in range(c):
            orders.append({"order_id": oid, "customer_id": c, "status": "Delivered",
                           "order_date": datetime(2025, 1 + c, 1 + k)})
            items.append({"order_item_id": oid, "order_id": oid, "product_id": 1,
                          "quantity": 1, "unit_price": 10.0 * c, "discount_percent": 0.0})
            oid += 1
    con = duckdb.connect(":memory:")
    for name, df in {"customers": cust, "orders": pd.DataFrame(orders), "order_items": pd.DataFrame(items)}.items():
        con.register(name + "_df", df)
        con.execute(f"CREATE TABLE {name} AS SELECT * FROM {name}_df")

    scores = con.execute("""
        WITH rfm AS (
          SELECT c.customer_id,
                 DATE_DIFF('day', MAX(o.order_date), DATE '2025-12-31') AS recency_days,
                 COUNT(DISTINCT o.order_id) AS frequency,
                 SUM(oi.quantity * oi.unit_price) AS monetary
          FROM customers c JOIN orders o USING (customer_id) JOIN order_items oi USING (order_id)
          GROUP BY 1)
        SELECT customer_id,
               NTILE(5) OVER (ORDER BY recency_days DESC) r,
               NTILE(5) OVER (ORDER BY frequency ASC) f,
               NTILE(5) OVER (ORDER BY monetary ASC) m
        FROM rfm ORDER BY customer_id""").fetchdf().set_index("customer_id")
    assert tuple(scores.loc[10]) == (5, 5, 5)
    assert tuple(scores.loc[1]) == (1, 1, 1)

    # The pipeline's own query must use the same directions.
    src = (ROOT / "analysis" / "run_analytics.py").read_text(encoding="utf-8")
    assert "ORDER BY recency_days DESC) AS r_score" in src
    churn = (ROOT / "queries" / "advanced" / "10_churn_prediction.sql").read_text(encoding="utf-8")
    assert "ORDER BY days_since_last_order DESC" in churn
    counts = run_analytics.chart_rfm_segments(con, str(tmp_path))
    assert "Loyal / Champion" in counts
