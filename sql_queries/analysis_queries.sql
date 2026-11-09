-- Placeholder for Olist E-commerce Analysis Queries

-- 1. Total Revenue and Order Count
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset;

-- 2. Average Delivery Time (Actual vs Estimated)
-- (Add your CTEs or Joins here)

-- 3. Top 5 Product Categories with highest freight costs
-- (Add your queries here)

-- 4. Impact of late deliveries on Customer Review Scores
-- (Add your queries here)
