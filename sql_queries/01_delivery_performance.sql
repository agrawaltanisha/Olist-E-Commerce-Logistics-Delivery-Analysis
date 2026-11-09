-- =======================================================================================
-- OLIST E-COMMERCE: DELIVERY PERFORMANCE & DELAY ANALYSIS
-- Business Question: What percentage of orders are delivered late, and what is the average delay?
-- =======================================================================================

-- 1. Identify Late Deliveries and Calculate Delay in Days
WITH DeliveryStats AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        -- Calculate actual delivery time (in days)
        JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp) AS actual_delivery_days,
        -- Calculate delay (if actual > estimated)
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date 
            THEN JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_estimated_delivery_date)
            ELSE 0 
        END AS delay_days,
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
            ELSE 0 
        END AS is_late
    FROM olist_orders_dataset
    WHERE order_status = 'delivered' 
      AND order_delivered_customer_date IS NOT NULL
)
SELECT 
    COUNT(order_id) AS total_delivered_orders,
    SUM(is_late) AS total_late_orders,
    ROUND((CAST(SUM(is_late) AS FLOAT) / COUNT(order_id)) * 100, 2) AS late_delivery_percentage,
    ROUND(AVG(actual_delivery_days), 2) AS avg_delivery_time_days,
    ROUND(AVG(CASE WHEN is_late = 1 THEN delay_days ELSE NULL END), 2) AS avg_delay_duration_days
FROM DeliveryStats;


-- 2. Rank States by Worst Delivery Performance (Using Window Functions)
WITH StateDelivery AS (
    SELECT 
        c.customer_state,
        COUNT(o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT 
    customer_state,
    total_orders,
    late_orders,
    ROUND((CAST(late_orders AS FLOAT) / total_orders) * 100, 2) AS late_percentage,
    DENSE_RANK() OVER (ORDER BY (CAST(late_orders AS FLOAT) / total_orders) DESC) AS worst_performance_rank
FROM StateDelivery
WHERE total_orders > 1000 -- Filter out states with very low order volumes
ORDER BY worst_performance_rank;
