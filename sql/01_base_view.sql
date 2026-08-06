-- Base view: one row per delivered order.
-- Reviews deduplicated to the EARLIEST review per order:
-- the question is about reaction to delivery, and later reviews
-- reflect service recovery rather than the delivery itself.
-- 547 orders (0.55%) had multiple reviews; 202 of those conflicted.
-- 8 orders are status='delivered' but have no delivery date; excluded.
-- Result: 96,470 rows.

CREATE OR REPLACE VIEW v_order_delivery AS
WITH first_review AS (
    SELECT DISTINCT ON (order_id)
           order_id,
           review_score
    FROM order_reviews
    ORDER BY order_id, review_creation_date, review_answer_timestamp
)
SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_state,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) AS days_vs_promise,
    (o.order_delivered_customer_date::date - o.order_purchase_timestamp::date)      AS actual_lead_time,
    (o.order_estimated_delivery_date::date - o.order_purchase_timestamp::date)      AS promised_lead_time,
    r.review_score
FROM orders o
JOIN customers c        ON o.customer_id = c.customer_id
LEFT JOIN first_review r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;
