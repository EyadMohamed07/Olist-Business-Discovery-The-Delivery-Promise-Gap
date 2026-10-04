# MySQL Data Import Challenges & Solutions Log
## Olist Brazilian E-Commerce Dataset — Environment Setup

**Author:** Eyad Mohamed
**Project:** HVIA Task 01 — Olist Business Discovery
**Environment:** MySQL 8.x + MySQL Workbench on Windows
**Dataset:** 9 CSV tables (~1.4M total rows) from Kaggle

---

## Overview

Importing 9 CSV files (~1.4M rows) into MySQL 8 involved a chain of 
real-world data engineering problems: security restrictions, path 
formatting, malformed source data, silent type coercion, and a 
duplicate import. This log documents each problem, its root cause, 
and the applied fix.

---

## Challenges & Solutions

### 1. Import Wizard was slow and guessed wrong data types
**Problem:** The Table Data Import Wizard took very long for large 
files and auto-inferred column types, causing silent data loss 
(leading zeros in zip codes, misread dates).

**Solution:** Switched to LOAD DATA INFILE with explicit CREATE TABLE 
definitions — full control over types:
- Hash IDs → VARCHAR(50) (not INT — they are hex strings)
- Zip codes → VARCHAR(10) (protects leading zero: 01151)
- Money → DECIMAL(10,2) (never FLOAT for financial values)
- Timestamps → DATETIME, dates → DATE
- Nullable business fields → allowed NULL

---

### 2. Error 2068 — LOAD DATA LOCAL INFILE rejected
**Problem:** Even after enabling local_infile on the server 
(SET GLOBAL local_infile = 1), the client connection was still 
rejected because the connection itself was opened before the 
setting was applied.

**Root cause:** Server setting AND connection-level setting must 
both agree. The connection reads its options only at open time.

**Attempted fix:** Added local_infile=1 in connection Advanced 
settings and reopened the connection — still rejected in this 
environment.

**Final fix:** Abandoned the LOCAL approach entirely (see #3).

---

### 3. Error 1290 — secure-file-priv restriction
**Problem:** LOAD DATA INFILE was blocked: "The MySQL server is 
running with the --secure-file-priv option so it cannot execute 
this statement."

**Root cause:** MySQL servers restrict file reading to a single 
whitelisted directory for security. Discovered via:

    SHOW VARIABLES LIKE 'secure_file_priv';

**Solution:** Copied source CSVs manually into the whitelisted 
Uploads directory, then imported from there — no security settings 
needed to change:

    LOAD DATA INFILE 'E:/MySql_env/server/data/Uploads/file.csv' ...

**Lesson:** Before blaming configuration, always inspect server-side 
security variables first.

---

### 4. Error 1290 (again) — Windows backslash paths
**Problem:** Same 1290 error persisted despite correct directory.

**Root cause:** Windows-style paths use backslashes which MySQL 
treats as escape characters (E:\MySql_env becomes E:MySql_env). 
The path no longer matched the whitelisted directory.

**Solution:** Convert all path separators to forward slashes:

    'E:/MySql_env/server/data/Uploads/olist_orders_dataset.csv'

**Rule:** MySQL file paths always use forward slashes, except \n 
in LINES TERMINATED BY.

---

### 5. Error 1265 — wrong file loaded into wrong table
**Problem:** "Incorrect date value: f63f9a76... for column 
payment_sequential" — a customers file (hash strings) was loaded 
into the payments table (integer column). Field values shifted 
across columns.

**Solution:** Match file name to table name one-to-one; never 
bulk-paste commands without checking the file/table pair.

---

### 6. Error 1292 — malformed rows in reviews file
**Problem:** Import stopped at row 77,917: a review hash appeared 
in a date column. Root cause: comment fields containing embedded 
quotes/commas broke the row structure — the source file itself 
has corrupted rows.

**Solution (two parts):**
1. Cleaned partial import: TRUNCATE TABLE before re-import.
2. Enabled tolerant mode + explicit column mapping with NULL handling:

    SET SESSION sql_mode = '';
    LOAD DATA INFILE '...' INTO TABLE ...
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n' IGNORE 1 ROWS
    (review_id, order_id, review_score, @title, @msg, @cdate, @atime)
    SET review_comment_title = NULLIF(@title, ''),
        review_comment_message = NULLIF(@msg, ''),
        review_creation_date = NULLIF(@cdate, ''),
        review_answer_timestamp = NULLIF(@atime, '');

**Result:** 99,223 of ~100,000 rows imported; remaining 0.8% are 
structurally corrupted rows in the source file — documented as a 
Data Quality finding, not an import failure.

---

### 7. Silent zero-fill instead of NULL (products)
**Problem:** Warnings like "Incorrect integer value: ''" — empty 
numeric fields were coerced to 0 (e.g., product weight = 0g is 
impossible).

**Solution:** Post-import cleanup converting fake zeros to real NULLs:

    UPDATE olist_products_dataset SET
      product_weight_g = NULLIF(product_weight_g, 0), ...

**Lesson:** A zero and a missing value are different business facts; 
leaving fake zeros would distort averages and aggregations later.

---

### 8. Zero dates instead of NULL (orders)
**Problem:** Orders without delivery (cancelled / in transit) had 
empty date fields coerced to 0000-00-00 00:00:00.

**Solution:**

    UPDATE olist_orders_dataset
    SET order_delivered_customer_date = NULL
    WHERE order_delivered_customer_date = '0000-00-00 00:00:00';

**Lesson:** Zero dates would poison any DATEDIFF-based 
delivery-delay analysis — must be NULL before computing lateness.

---

### 9. Precision loss in geolocation (DECIMAL too narrow)
**Problem:** Warnings on every row: "Data truncated for column 
geolocation_lat" — DECIMAL(10,8) could not hold the source precision.

**Solution:** Redefined lat/lng as DOUBLE (full float precision), 
dropped and re-imported the 1M-row table in seconds.

---

### 10. Duplicated table (caught by validation)
**Problem:** After a failed-then-retried import, orders contained 
198,882 rows instead of 99,441 — two overlapping imports stacked.

**Detection:** The validation query below flagged the anomaly 
immediately.

**Solution:** TRUNCATE + single clean re-import → 99,441.

**Lesson:** Never trust "it worked" — validate row counts against 
the source after every import.

---

## Final Validation Query

    SELECT 'customers' AS tbl, COUNT(*) AS cnt FROM olist_customers_dataset
    UNION ALL SELECT 'sellers',     COUNT(*) FROM olist_sellers_dataset
    UNION ALL SELECT 'translation', COUNT(*) FROM olist_product_category_name_translation
    UNION ALL SELECT 'products',    COUNT(*) FROM olist_products_dataset
    UNION ALL SELECT 'payments',    COUNT(*) FROM olist_order_payments_dataset
    UNION ALL SELECT 'reviews',     COUNT(*) FROM olist_order_reviews_dataset
    UNION ALL SELECT 'orders',      COUNT(*) FROM olist_orders_dataset
    UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
    UNION ALL SELECT 'geolocation', COUNT(*) FROM olist_geolocation_dataset;

**Result vs. Kaggle reference:**

| Table | Expected | Imported | Status |
|---|---|---|---|
| customers | 99,441 | 99,441 | OK |
| sellers | 3,095 | 3,095 | OK |
| translation | 71 | 71 | OK |
| products | 32,951 | 32,951 | OK |
| payments | 103,886 | 103,886 | OK |
| reviews | ~100,000 | 99,223 | Source-corrupted rows (documented) |
| orders | 99,441 | 99,441 | OK (after dedup fix) |
| order_items | 112,650 | 112,650 | OK |
| geolocation | ~1,000,000 | 1,000,163 | OK |

---

## Key Takeaways

1. Understand server security before fighting it — secure_file_priv 
   and local_infile are features, not bugs.
2. Explicit schema beats auto-guessing — the Wizard's type inference 
   silently corrupts data; define types yourself.
3. Validate after every load — COUNT(*) against source references 
   catches duplication and truncation instantly.
4. Warnings are not errors — but both matter: warnings mean silent 
   data transformation (zeros, truncation) that must be cleaned.
5. Data quality issues in source files are findings, not failures — 
   corrupted review rows and missing product attributes are documented 
   as part of the analysis story.
