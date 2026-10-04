-- 1) نضف الأول:
TRUNCATE TABLE olist_order_reviews_dataset;

-- 2) الوضع المتسامح:
SET SESSION sql_mode = '';

-- 3) أمر الـ LOAD (نفس الأمر بتاعك — انسخه زي ما هو)
LOAD DATA INFILE 'E:/MySql_env/server/data/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(review_id, order_id, review_score, @title, @msg, @cdate, @atime)
SET review_comment_title = NULLIF(@title, ''),
    review_comment_message = NULLIF(@msg, ''),
    review_creation_date = NULLIF(@cdate, ''),
    review_answer_timestamp = NULLIF(@atime, '');
    
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- import all datasets without the above beacause the error

LOAD DATA INFILE 'E:/MySql_env/server/data/Uploads/product_category_name_translation.csv'
INTO TABLE olist_product_category_name_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
UPDATE olist_products_dataset SET
  product_name_lenght = NULLIF(product_name_lenght, 0),
  product_description_lenght = NULLIF(product_description_lenght, 0),
  product_photos_qty = NULLIF(product_photos_qty, 0),
  product_weight_g = NULLIF(product_weight_g, 0),
  product_length_cm = NULLIF(product_length_cm, 0),
  product_height_cm = NULLIF(product_height_cm, 0),
  product_width_cm = NULLIF(product_width_cm, 0);
  
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
TRUNCATE TABLE olist_orders_dataset;
SET SESSION sql_mode = '';

LOAD DATA INFILE 'E:/MySql_env/server/data/Uploads/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(order_id, customer_id, order_status, @p, @a, @c, @d, @e)
SET order_purchase_timestamp = NULLIF(@p,''),
    order_approved_at = NULLIF(@a,''),
    order_delivered_carrier_date = NULLIF(@c,''),
    order_delivered_customer_date = NULLIF(@d,''),
    order_estimated_delivery_date = NULLIF(@e,'');
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
UPDATE olist_orders_dataset
SET order_delivered_carrier_date = NULL,
    order_delivered_customer_date = NULL
WHERE order_delivered_carrier_date = '0000-00-00 00:00:00'
   OR order_delivered_customer_date = '0000-00-00 00:00:00';

UPDATE olist_orders_dataset
SET order_approved_at = NULL
WHERE order_approved_at = '0000-00-00 00:00:00';
    
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2)
);
LOAD DATA INFILE 'E:/MySql_env/server/data/Uploads/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- finally count (validation)

SELECT 'customers' AS tbl, COUNT(*) AS cnt FROM olist_customers_dataset
UNION ALL SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset
UNION ALL SELECT 'translation', COUNT(*) FROM olist_product_category_name_translation
UNION ALL SELECT 'products', COUNT(*) FROM olist_products_dataset
UNION ALL SELECT 'payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL SELECT 'reviews', COUNT(*) FROM olist_order_reviews_dataset
UNION ALL SELECT 'orders', COUNT(*) FROM olist_orders_dataset
UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
UNION ALL SELECT 'geolocation', COUNT(*) FROM olist_geolocation_dataset;
    