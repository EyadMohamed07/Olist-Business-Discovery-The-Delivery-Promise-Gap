# 📒 Olist Analysis — Insights Register

**HVIA Data & AI Solutions — Task 01**

Every analytical insight discovered during this project, with its 
question, method, result, and business meaning. Full SQL queries 
available in the SQL files of this repository.

---

## I1 — The Over-Promised Delivery

- **Question:** How accurate are Olist's delivery promises?
- **Method:** Percentage segmentation of delivered orders vs. 
  estimated delivery date
- **Results:**
  - Orders delivered **late** (after promise): **8.1%**
  - Orders delivered **7+ days before** the promise: **78.9%**
- **Business Meaning:** Olist is not failing its promises — it is 
  massively over-promising. Nearly 4 in 5 orders arrive a full week 
  or more early. This means: (1) the real delivery speed is hidden 
  from customers, (2) long promises ("20 days") may discourage 
  purchases, (3) satisfaction can improve **without any logistics 
  investment** — just by fixing the promise.
- **Slides:** #3 — "A Blind Promise System"

---

## I2 — Order Status Distribution

- **Question:** What happens to all orders? How many actually deliver?
- **Method:** GROUP BY order_status
- **Results:**

| Status | Count | Share |
|---|---|---|
| delivered | 96,478 | 97.0% |
| shipped | 1,107 | 1.1% |
| canceled | 625 | 0.6% |
| unavailable | 609 | 0.6% |
| invoiced | 314 | 0.3% |
| processing | 301 | 0.3% |
| created | 5 | ~0% |
| approved | 2 | ~0% |

- **Business Meaning:** 97% delivered = I1's numbers are computed on 
  a solid base. Actual fulfillment failure (canceled + unavailable) 
  ≈ 1.2% — healthy for the platform. In-flight orders (~1,722) show 
  the over-promising pattern is live in real time, not just history.
- **Slides:** #2 — context layer

---

## I3 — Late Delivery Destroys Satisfaction

- **Question:** Does delivery timing affect customer review scores?
- **Method:** Orders segmented vs. promise (5 windows) → JOIN reviews 
  → AVG per segment. Deduplicated via COUNT(DISTINCT order_id) — 
  see FQ2.
- **Results:**

| Segment | Orders | Avg Review |
|---|---|---|
| Late | 7,662 | **2.57** |
| Early 1–6 days | 12,419 | 4.18 |
| Early 7–13 days | 33,882 | 4.30 |
| Early 14+ days | 41,866 | 4.32 |

Total analyzed: 95,829 (reconciled — see validation notes)
- **Business Meaning:** Late delivery costs **1.74 rating points** 
  (2.57 vs 4.31). Timing — not price, not product — is a primary 
  satisfaction driver. Combined with I1: Olist's inflated promise 
  hides real speed, and its rare failures crush trust.
- **Slides:** #4 — "Late Delivery Kills Trust"

---

## I4 — The Delay Has Two Faces

- **Question:** Where is the delay born — with the seller, or in 
  the shipping path?
- **Method:** Per-state decomposition: seller handover punctuality 
  (carrier date vs. shipping limit) cross-referenced with customer 
  lateness
- **Results (by seller state):**

| Pattern | Example | Reading |
|---|---|---|
| Seller-driven | MA: 32.6% seller-late → 24.4% customer-late | Slow sellers cause downstream lateness |
| Route-driven | ES: 5.5% seller-late → 7.7% customer-late | Carrier delays despite punctual sellers |
| Reliable | PE, GO, RS | Minor issue |

- **Business Meaning:** If the seller hands over late, customer 
  lateness jumps **×5** (4% → 22%). But in some states, delays 
  happen **even with punctual sellers** — a pure logistics-path 
  issue. Two different problems → two different fixes → both 
  predictable from existing data.
- **Slides:** #5, #6 — Root Causes

---

## 🧪 Data Quality Findings

### FQ1 — Delivered orders without delivery timestamp
- **8 orders** marked delivered with no order_delivered_customer_date
- Verified: all 8 have reviews (7× score 5, 1× score 1) — a database 
  inconsistency: "completed" deliveries with no completion time
- **Handling:** Excluded from timing analysis; documented

### FQ2 — Orders with multiple review rows
- **394 orders** have 2+ review rows (4 have 3) — review edit history 
  preserved as separate rows
- **Handling:** COUNT(DISTINCT order_id) for all order counts; AVG 
  computed over review rows (~0.4% duplication — negligible, 
  documented)

---

## ✅ Validation Rules Applied Throughout

1. Orders with delivery date → timing analysis only
2. Delivered without delivery date → Data Quality Findings only
3. All totals computed with NO filters (source of truth)
4. After every JOIN → segment sums reconciled against source totals
5. Every query documented with result and business meaning

---

*Part of the Olist Business Discovery project — HVIA Task 01*
