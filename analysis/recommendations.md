# Data-Driven Recommendations

**RetailPulse Analytics Database**
**MIST 4600 | University of Georgia | Spring 2025**

Based on the analytical findings from our 15 SQL queries, we present the following actionable recommendations organized by business area.

---

## Marketing & Customer Retention

### 1. Implement Tiered Loyalty Program
**Based on:** Finding 1 (Revenue Concentration), Query 06 (CLV)

The top 10% of customers generate 42% of revenue. A formal tiered loyalty program would help retain these high-value customers while incentivizing mid-tier customers to increase spending.

- **VIP tier (top 10%):** Free express shipping, early access to sales, dedicated support
- **Premium tier (next 20%):** Free standard shipping on orders over $50, birthday discounts
- **Regular tier:** Points accumulation toward future discounts

**Expected impact:** 5-8% increase in retention among high-value customers, based on industry benchmarks for loyalty programs.

### 2. Launch Win-Back Campaign for At-Risk Customers
**Based on:** Finding 5 (Churn Risk), Query 10

15-20% of the customer base shows churn risk. Target these customers with a three-touch email sequence:

1. **Day 0:** Personalized "We miss you" email with a 15% discount code
2. **Day 7:** Product recommendation based on past purchase history
3. **Day 14:** Final reminder with 20% discount or free shipping offer

Prioritize high-value at-risk customers (historical spending > $500) for personal outreach from sales representatives.

### 3. Deploy Product Recommendation Engine
**Based on:** Finding 4 (Cross-Sell), Query 08

Implement "Frequently Bought Together" recommendations on product pages using the co-purchase affinity data:

- Laptop pages should suggest USB-C hubs and headphones
- Smartphone pages should suggest wireless charging pads and power banks
- Cookware sets should suggest knife blocks and cutting boards

**Expected impact:** 10-15% increase in average order value through accessory attach rates.

---

## Inventory & Supply Chain

### 4. Consolidate Suppliers with Long Lead Times
**Based on:** Finding 7 (Supplier Performance), Query 09

Suppliers with lead times exceeding 10 days correlate with 2.3x higher stockout frequency. We recommend:

- Shift volume from suppliers with 12+ day lead times to preferred suppliers (lead time < 5 days) where product overlap exists
- Negotiate safety stock agreements with high-lead-time suppliers for critical products
- Establish dual-sourcing for top 20 SKUs by revenue to mitigate supply risk

**Expected impact:** 18% reduction in stockout frequency, based on the observed lead-time/stockout correlation.

### 5. Liquidate Dead Stock
**Based on:** Finding 8 (Inventory Efficiency), Query 14

8% of SKUs are dead or very slow-moving stock, tying up working capital. Recommended actions:

- Run clearance pricing (40-60% off) on products with zero turnover in 12 months
- Bundle slow-moving accessories with popular products (e.g., include exercise ball with treadmill purchase)
- Reduce reorder quantities for slow-movers to minimize future capital lock-up

### 6. Adjust Reorder Levels by Seasonality
**Based on:** Finding 3 (Seasonal Patterns), Query 12

Q4 accounts for 31% of annual sales. Inventory planning should reflect this:

- Increase reorder quantities by 40% for Electronics in September/October to prepare for holiday demand
- Maintain steady reorder levels for Apparel (less seasonal variation)
- Reduce reorder quantities by 25% in January to avoid post-holiday overstocking

---

## Pricing & Promotions

### 7. Restructure Discounting Strategy by Category
**Based on:** Finding 2 (Category Performance), Query 13

Electronics has the lowest margins (8-22%). Discount policy should vary by category margin profile:

| Category | Max Discount | Rationale |
|----------|-------------|-----------|
| Electronics | 8% | Already low margin; deep discounts erode profitability |
| Home & Kitchen | 15% | Healthy margins can absorb moderate discounts |
| Apparel | 20% | High margins support seasonal clearance |
| Sports & Outdoors | 15% | Good margins; discounts drive trial |

### 8. Introduce Free Shipping Threshold
**Based on:** Finding 10 (Payment/Shipping Preferences)

Free Shipping orders have lower cancellation rates (3% vs. 6%). Implement a dynamic free shipping threshold:

- Standard free shipping on orders over $75
- Free express shipping for VIP loyalty members on orders over $100
- During Q4 holiday period, lower threshold to $50 to drive conversion

**Expected impact:** 5-10% reduction in cart abandonment rate.

---

## Sales & Operations

### 9. Implement Sales Rep Coaching Program
**Based on:** Finding 9 (Employee Performance), Query 05

There is a 2.1x gap between the highest and lowest performing sales reps. Recommended actions:

- Pair top performers with junior reps for mentorship
- Use "revenue per month of tenure" as the primary performance metric to normalize for experience
- Set quarterly targets based on individual baselines with progressive improvement goals
- Share cross-sell data (Query 08) with reps to improve attachment rates

### 10. Expand Marketing in Underserved Regions
**Based on:** Finding 6 (Geographic Distribution), Query 11

Mountain West states show low customer counts but comparable per-customer spending. This suggests latent demand with insufficient awareness.

- Target digital advertising in MT, WY, ID, UT with geo-fenced campaigns
- Evaluate shipping cost optimization for Mountain West via regional carrier partnerships
- Monitor new customer acquisition rates by state quarterly to measure campaign effectiveness

---

## Technical / Database

### 11. Scale the Database for Production
Based on our performance optimization work (32% average improvement documented in the optimization report), the following should be implemented before scaling to production data volumes:

- **Partition the orders table** by month (range partitioning on `order_date`) for efficient date-range pruning
- **Schedule materialized view refreshes** for `mv_daily_sales` every 15 minutes during business hours
- **Set up read replicas** to separate analytical queries from transactional workload
- **Automate VACUUM ANALYZE** to keep planner statistics current as data grows

---

## Summary of Expected Outcomes

| Initiative | Expected Impact | Timeline |
|-----------|----------------|----------|
| Loyalty program | +5-8% VIP retention | 3 months |
| Win-back campaign | Recover 10-15% of at-risk customers | 1 month |
| Product recommendations | +10-15% avg order value | 2 months |
| Supplier consolidation | -18% stockout rate | 6 months |
| Dead stock clearance | Release ~$5K working capital | 1 month |
| Seasonal reorder tuning | -12% overstock cost in Q1 | Ongoing |
| Free shipping threshold | -5-10% cart abandonment | 1 month |
| Sales coaching | +15% junior rep productivity | 6 months |
| Regional marketing expansion | +8% customer acquisition in target states | 3 months |
