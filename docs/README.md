# 📊 Olist Business Discovery — The Delivery Promise Gap

**HVIA Data & AI Solutions — Task 01 | Data Analysis Internship**

> A full business discovery on Olist (Brazil's largest e-commerce enabler) using 100K+ real orders (2016–2018). SQL-driven analysis that uncovered an inflated delivery promise system, quantified its customer-satisfaction cost, traced delays to two measurable root causes — and proposed a data-driven solution.

---

## 🎯 The Story in 30 Seconds

| Finding | Number | What it means |
|---|---|---|
| Orders arrive a WEEK+ before promise | **78.9%** | Promise is inflated — real speed is hidden |
| Orders that arrive late | **8.1%** | And when they do — trust collapses |
| Avg review when late vs on-time | **2.57★ vs 4.31★** | Timing — not price — drives satisfaction |
| Customer lateness when seller hands over late | **×5** | The delay is traceable, not random |

**Proposed solution:** A *Smart Delivery Promise Engine* — predicting realistic delivery dates per order using seller punctuality profiles + route intelligence. Built on HVIA's capabilities: Forecasting, Logistics Intelligence, Analytics.

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.x
- **Tooling:** MySQL Workbench, LOAD DATA INFILE pipeline
- **Analysis:** Advanced SQL — CASE segmentation, conditional aggregation, multi-table JOINs across 9 relational tables
- **Validation:** Row-count reconciliation, data-quality findings registry

---

## 🔍 Key Insights

### I1 — The Over-Promised Delivery
78.9% of delivered orders arrive **7+ days before** the promised date. Only 8.1% arrive late. The promise system is not failing — it is **massively inflated**, hiding Olist's real delivery speed from its own customers.

### I3 — Late Delivery Destroys Satisfaction
Orders that arrive late average **2.57★** vs **4.31★** for early arrivals — a **1.74-point collapse**. Delivery timing is a primary satisfaction driver.

### I4 — The Delay Has Two Faces
- **Slow sellers:** late handover to carrier → customer lateness jumps **×5** (from 4% to 22%). Verified per state (MA: 33% → 24%).
- **Slow routes:** some lanes delay orders despite punctual sellers (ES: 5.5% seller lateness → 7.7% customer lateness).

**Implication:** Two different problems require two different fixes — and both are predictable from existing data. Today, nobody predicts them.

---

## 📈 Methodology

1. **Data ingestion** — 9 CSV tables (~1.4M rows) imported into MySQL with explicit type-safe schemas
2. **Validation** — every table reconciled against source reference counts
3. **Segmentation** — orders classified vs. promise, joined with reviews, sellers, and geography
4. **Root-cause decomposition** — seller handover punctuality vs. customer lateness, per state
5. **Business translation** — every number mapped to a meaning, every finding to an action

---

## 🧪 Data Quality Findings

| ID | Finding | Handling |
|---|---|---|
| FQ1 | 8 "delivered" orders with no delivery timestamp | Documented; excluded from timing analysis |
| FQ2 | 394 orders with multiple review rows | `COUNT(DISTINCT order_id)` applied |

Full import challenges documented in [MySQL_Import_Challenges](/MySQL_Import_Challenges_Log.md).

---

## 💡 What This Project Demonstrates

- ✅ End-to-end pipeline: raw CSV → validated MySQL DB → business insights
- ✅ Real problem-solving: 10+ import errors diagnosed and resolved (documented)
- ✅ Analytical rigor: reconciliation after every JOIN — no orphan numbers
- ✅ Business thinking: insights translated into actions, not just charts
- ✅ Executive communication: 100K rows → 5 numbers → one story

---

## 👤 Author

**[Eyad Mohamed]**
- LinkedIn: [[EyadMohamed](http://www.linkedin.com/in/eyad-mohamed-098401289)]
- Email: [eymohamed2310@gmail.com]

*Data Analyst | SQL • Power BI • Business Discovery*

---

## 📜 License

MIT License — see [LICENSE](LICENSE)
