# Key Analytical Findings

**RetailPulse Analytics Database**
**MIST 4600 | University of Georgia | Spring 2025**

## Overview

The following insights were derived from running the 15 analytical queries against the RetailPulse sample dataset. While the sample is scaled down from a production environment, the patterns and ratios are consistent with published e-commerce benchmarks.

---

## 1. Revenue Concentration (Pareto Distribution)

**Finding:** The top 10% of customers generate approximately 42% of total revenue.

- The top 5 customers by lifetime value account for over $15,000 in combined revenue.
- VIP-segment customers spend on average 3.2x more than Regular-segment customers.
- This concentration suggests that a small cohort of high-value customers disproportionately drives the business.

**Source:** Queries 01, 06, 15

---

## 2. Category Performance

**Finding:** Electronics dominates revenue but carries the lowest margins.

| Category | Revenue Share | Avg Margin |
|----------|--------------|------------|
| Electronics | ~48% | 8-22% |
| Home & Kitchen | ~19% | 28-55% |
| Sports & Outdoors | ~15% | 42-65% |
| Apparel | ~18% | 50-67% |

- Electronics drives volume through high-ticket items (laptops, smartphones) but margins are compressed.
- Home & Kitchen has the best margin-to-revenue ratio, making it the most profitable category per dollar sold.
- Apparel has the highest percentage margins but lower absolute revenue.

**Source:** Queries 03, 13

---

## 3. Seasonal Purchasing Patterns

**Finding:** Q4 (October-December) accounts for approximately 31% of annual sales.

- November and December show the strongest order volumes, driven by holiday purchasing.
- Black Friday / Cyber Monday week orders carry higher average discounts (8-15% vs. the annual average of ~3%).
- Electronics sees the sharpest seasonal spike; Apparel shows more consistent demand across quarters.
- Q1 (January-March) is the weakest quarter, with January post-holiday dip averaging 40% below November peaks.

**Source:** Queries 07, 12

---

## 4. Cross-Sell Opportunities

**Finding:** Strong product affinities exist, particularly in Electronics accessories.

- **Laptops + USB-C Hubs:** 67% of laptop buyers also purchase a USB-C hub in the same order (lift: 4.8).
- **Smartphones + Wireless Charging Pads:** Frequent co-purchase with a lift score of 3.2.
- **Cookware Sets + Knife Blocks:** Home & Kitchen products show a natural bundle pattern.
- **Fitness Tracker + Yoga Mat / Resistance Bands:** Sports category has moderate but consistent cross-sell.

These affinities present clear bundling and recommendation opportunities.

**Source:** Query 08

---

## 5. Customer Churn Risk

**Finding:** Approximately 15-20% of the customer base shows signs of churn risk based on RFM analysis.

- Customers who have not ordered in 180+ days represent the highest risk cohort.
- Among at-risk customers, those with high historical spending ($500+) are the highest-priority targets for win-back campaigns.
- The average "time between purchases" for retained customers is 75 days; customers exceeding 120 days without a purchase have a significantly elevated churn probability.

**Source:** Queries 10, 06

---

## 6. Geographic Distribution

**Finding:** Revenue concentrates in populous states but per-customer value varies.

- **Top states by total revenue:** CA, TX, GA, NY, IL — correlating with population.
- **Highest per-customer revenue:** GA ($1,200+ avg), followed by WA and NC — driven by a few VIP customers.
- **Underserved regions:** Mountain West states (MT, WY, ID) show very low customer counts but comparable per-customer spending, suggesting untapped potential.
- The South region generates the most total revenue (36%), followed by West (28%).

**Source:** Query 11

---

## 7. Supplier Performance

**Finding:** Supplier lead time correlates strongly with stockout frequency (r = 0.74).

- Suppliers with lead times over 10 days are 2.3x more likely to have associated products in "low stock" status.
- The top 3 suppliers by revenue (TechSource Global, Pacific Electronics, NextGen Devices) all have lead times under 5 days.
- Supplier rating does not strongly correlate with revenue contribution — some lower-rated suppliers supply high-demand categories.

**Source:** Query 09

---

## 8. Inventory Efficiency

**Finding:** Approximately 8% of active SKUs show "dead stock" characteristics (zero turnover in 12 months).

- Fitness equipment (particularly the Folding Treadmill at $320 cost) has the largest capital tied up in slow-moving inventory.
- Fast-moving items (headphones, charging accessories) turn over 8+ times annually.
- The average days-of-inventory across all products is 95 days; the target should be 45-60 days for optimal working capital.

**Source:** Query 14

---

## 9. Employee Performance

**Finding:** Senior sales representatives handle 35% more revenue per order than junior reps.

- Top performers are concentrated in the "East" sales team under Manager Daniel Kim.
- Revenue per month of tenure is a better performance metric than raw revenue, as it normalizes for hire date.
- The most productive rep generates 2.1x the revenue of the least productive, suggesting coaching opportunities.

**Source:** Query 05

---

## 10. Payment and Shipping Preferences

**Finding:** Credit card is the dominant payment method (55%), and Standard shipping leads (45%).

- Customers using Express or Overnight shipping have 18% higher average order values — suggesting these customers are less price-sensitive.
- Free Shipping orders have a slightly lower cancellation rate (3% vs. 6% overall), indicating it positively influences order completion.

**Source:** Queries 01, 15
