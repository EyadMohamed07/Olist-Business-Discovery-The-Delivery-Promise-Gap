-- =====================================================
-- percentage of orders delivered

SELECT
    ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS late_pct,
    ROUND(SUM(CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= -7 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS early_by_week_pct
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL ;
-- =====================================================
-- orders status

SELECT order_status, COUNT(*) AS cnt
FROM olist_orders_dataset 
GROUP BY order_status
ORDER BY cnt DESC;
-- =====================================================
-- Delivery VS Review

SELECT 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN '1_Late'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) = 0 THEN '2_On_time'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) BETWEEN -6 AND -1 THEN '3_Early_1-6d'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) BETWEEN -13 AND -7 THEN '4_Early_7-13d'
        ELSE '5_Early_14d+'
    END AS delivery_vs_promise,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(AVG(r.review_score), 2) AS avg_review
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_vs_promise
ORDER BY delivery_vs_promise;

-- =====================================================

-- Verification: Delivered orders without delivery date — do they have reviews?
SELECT 
    o.order_id,
    r.review_score,
    r.review_creation_date
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NULL;
  -- =====================================================
  
  -- Verification: Do some orders have multiple review rows? because the difference between num of orders
SELECT order_id, COUNT(*) AS review_count
FROM olist_order_reviews_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC;
-- =====================================================

-- Causition of latency
-- I4 v2: Seller states — handover lateness % vs customer lateness % (side by side)
SELECT
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    -- % of orders where seller handed over LATE to carrier:
    ROUND(SUM(CASE 
        WHEN o.order_delivered_carrier_date > i.shipping_limit_date THEN 1 ELSE 0 
    END) * 100.0 / COUNT(DISTINCT o.order_id), 1) AS seller_late_pct,
    -- % of orders that arrived LATE to customer:
    ROUND(SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 
    END) * 100.0 / COUNT(DISTINCT o.order_id), 1) AS customer_late_pct
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_sellers_dataset s ON i.seller_id = s.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_carrier_date IS NOT NULL
  AND i.shipping_limit_date IS NOT NULL
GROUP BY s.seller_state
ORDER BY customer_late_pct DESC;
