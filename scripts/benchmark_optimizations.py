#!/usr/bin/env python3
"""
Measure the five before/after optimizations in
queries/optimized/optimization_before_after.sql with EXPLAIN (ANALYZE).

For each pair: 2 warm-up runs, then N timed runs of each variant; report the
median planning and execution time, and check that BEFORE and AFTER return
the same rows (order-insensitive checksum, LIMIT queries compared as sets of
their top rows). Optimization 2 is "same query, plus a covering index": its
BEFORE run drops idx_order_items_order_product inside a transaction that is
rolled back, so the index is restored afterwards.

Usage:
    python scripts/benchmark_optimizations.py --port 55433 --password ... \
        --iterations 15 --out docs/benchmark_results.json
"""
import argparse
import hashlib
import json
import re
import statistics
from pathlib import Path

import psycopg2

ROOT = Path(__file__).resolve().parents[1]
SQL_FILE = ROOT / "queries" / "optimized" / "optimization_before_after.sql"
COVERING_INDEX = "idx_order_items_order_product"


def parse_pairs(text: str) -> list[dict]:
    sections = re.split(r"^-- OPTIMIZATION (\d+): (.+)$", text, flags=re.MULTILINE)
    pairs = []
    # re.split with 2 groups yields [pre, num, title, body, num, title, body, ...]
    for i in range(1, len(sections) - 2, 3):
        num, title, body = int(sections[i]), sections[i + 1].strip(), sections[i + 2]
        body = body.split("-- SUMMARY OF OPTIMIZATIONS")[0]
        stmts = re.findall(r"EXPLAIN ANALYZE\s+(.+?);", body, flags=re.DOTALL)
        if len(stmts) == 2:
            pairs.append({"num": num, "title": title, "before": stmts[0], "after": stmts[1],
                          "drop_index_for_before": None})
        elif len(stmts) == 1:  # same query, before = without the covering index
            pairs.append({"num": num, "title": title, "before": stmts[0], "after": stmts[0],
                          "drop_index_for_before": COVERING_INDEX})
    return pairs


def explain(cur, sql: str) -> tuple[float, float]:
    cur.execute("EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) " + sql)
    plan = cur.fetchone()[0][0]
    return plan["Planning Time"], plan["Execution Time"]


def checksum(cur, sql: str) -> tuple[int, str]:
    cur.execute(sql)
    rows = sorted(repr(tuple(round(float(v), 2) if isinstance(v, (float,)) or type(v).__name__ == "Decimal"
                             else v for v in r)) for r in cur.fetchall())
    return len(rows), hashlib.sha256("\n".join(rows).encode()).hexdigest()[:16]


def measure(conn, sql: str, iterations: int, drop_index: str | None) -> dict:
    cur = conn.cursor()
    cur.execute("BEGIN")
    if drop_index:
        cur.execute(f"DROP INDEX {drop_index}")
    for _ in range(2):
        explain(cur, sql)
    plan_t, exec_t = [], []
    for _ in range(iterations):
        p, e = explain(cur, sql)
        plan_t.append(p)
        exec_t.append(e)
    rows, digest = checksum(cur, sql)
    cur.execute("ROLLBACK")  # also restores a dropped index
    return {"planning_ms_median": round(statistics.median(plan_t), 3),
            "execution_ms_median": round(statistics.median(exec_t), 3),
            "execution_ms_min": round(min(exec_t), 3),
            "execution_ms_max": round(max(exec_t), 3),
            "rows": rows, "result_checksum": digest}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=5432)
    ap.add_argument("--db", default="retailpulse")
    ap.add_argument("--user", default="postgres")
    ap.add_argument("--password", default="")
    ap.add_argument("--iterations", type=int, default=15)
    ap.add_argument("--out", default=str(ROOT / "docs" / "benchmark_results.json"))
    args = ap.parse_args()

    conn = psycopg2.connect(host=args.host, port=args.port, dbname=args.db,
                            user=args.user, password=args.password)
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("ANALYZE")
    cur.execute("SELECT version()")
    version = cur.fetchone()[0]
    sizes = {}
    for t in ("customers", "orders", "order_items", "products"):
        cur.execute(f"SELECT COUNT(*) FROM {t}")
        sizes[t] = cur.fetchone()[0]

    results = []
    for pair in parse_pairs(SQL_FILE.read_text(encoding="utf-8")):
        before = measure(conn, pair["before"], args.iterations, pair["drop_index_for_before"])
        after = measure(conn, pair["after"], args.iterations, None)
        change = (after["execution_ms_median"] - before["execution_ms_median"]) / before["execution_ms_median"] * 100
        results.append({
            "num": pair["num"], "title": pair["title"],
            "variant": "drop covering index for BEFORE" if pair["drop_index_for_before"] else "rewritten query",
            "before": before, "after": after,
            "execution_change_pct": round(change, 1),
            "same_result": before["result_checksum"] == after["result_checksum"],
        })
        print(f"#{pair['num']} {pair['title'][:40]:<40} exec {before['execution_ms_median']:8.2f} -> "
              f"{after['execution_ms_median']:8.2f} ms ({change:+.1f}%)  plan {before['planning_ms_median']:.2f} -> "
              f"{after['planning_ms_median']:.2f} ms  same_result={results[-1]['same_result']}")

    out = {"postgres": version, "table_rows": sizes, "iterations": args.iterations, "results": results}
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
