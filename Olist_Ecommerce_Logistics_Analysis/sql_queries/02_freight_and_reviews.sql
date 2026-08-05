-- =======================================================================================
-- OLIST E-COMMERCE: FREIGHT COST & CUSTOMER SATISFACTION (RCA)
-- Business Question: How do shipping delays and freight costs impact customer reviews?
-- =======================================================================================

-- 1. Correlation between Delivery Status (On-Time vs Late) and Review Scores
WITH OrderDeliveryStatus AS (
    SELECT 
        order_id,
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
            ELSE 'On-Time'
        END AS delivery_status
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
)
SELECT 
    ods.delivery_status,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(CASE WHEN r.review_score IN (1, 2) THEN 1 ELSE 0 END) AS negative_reviews,
    ROUND((CAST(SUM(CASE WHEN r.review_score IN (1, 2) THEN 1 ELSE 0 END) AS FLOAT) / COUNT(r.review_id)) * 100, 2) AS negative_review_percentage
FROM OrderDeliveryStatus ods
JOIN olist_order_reviews_dataset r ON ods.order_id = r.order_id
GROUP BY ods.delivery_status;


-- 2. Freight Cost Analysis by Product Category
SELECT 
    p.product_category_name,
    COUNT(oi.order_id) AS total_units_sold,
    ROUND(AVG(oi.price), 2) AS avg_product_price,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_cost,
    ROUND(AVG(oi.freight_value) / AVG(oi.price) * 100, 2) AS freight_to_price_ratio
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING total_units_sold > 500
ORDER BY freight_to_price_ratio DESC
LIMIT 10;
