-- Q3: Which sellers cause the lateness?
-- RESULT (run 2026-08-06): NULL FINDING — lateness is NOT concentrated.
--   Worst seller (n>=50 orders) is only 30.1% late; baseline is 6.8%.
--   Cumulative share of all 6,547 late orders:
--     top 10 sellers -> 15.7% | top 50 -> 38.1% | top 100 -> 50.5% | top 500 -> 84.7%
--   Need 100 of ~3,000 sellers to reach half of late orders. No Pareto concentration.
-- The original hypothesis (a few bad sellers own the problem) is REJECTED.
-- Worst-rate sellers avg 13-26 day lead times, but late orders overall avg 33.9 —
-- so these sellers are mildly slow, not the source of the extreme tail.
-- Next hypothesis: geography.

-- One row per (order, seller): an order with items from two sellers counts once for each.
CREATE OR REPLACE TEMP VIEW seller_late AS
WITH order_seller AS (
    SELECT DISTINCT order_id, seller_id
    FROM order_items
)
SELECT
    os.seller_id,
    COUNT(*)                                     AS orders,
    COUNT(*) FILTER (WHERE v.days_vs_promise > 0) AS late_orders
FROM v_order_delivery v
JOIN order_seller os ON v.order_id = os.order_id
GROUP BY os.seller_id;

-- 1. Baseline late rate and number of sellers
SELECT
    COUNT(*)                                          AS sellers,
    SUM(late_orders)                                  AS late_orders,
    ROUND(100.0 * SUM(late_orders) / SUM(orders), 1)  AS baseline_pct_late
FROM seller_late;

-- 2. Worst sellers by late rate (minimum 50 orders, so small sellers don't dominate)
SELECT
    seller_id,
    orders,
    late_orders,
    ROUND(100.0 * late_orders / orders, 1) AS pct_late
FROM seller_late
WHERE orders >= 50
ORDER BY pct_late DESC
LIMIT 10;

-- 3. Concentration: what share of all late orders do the top N sellers hold?
WITH ranked AS (
    SELECT
        seller_id,
        late_orders,
        ROW_NUMBER() OVER (ORDER BY late_orders DESC, seller_id)                          AS seller_rank,
        SUM(late_orders) OVER (ORDER BY late_orders DESC, seller_id
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)          AS cumulative_late,
        SUM(late_orders) OVER ()                                                          AS total_late
    FROM seller_late
)
SELECT
    seller_rank                                         AS top_n_sellers,
    cumulative_late,
    ROUND(100.0 * cumulative_late / total_late, 1)      AS pct_of_all_late_orders
FROM ranked
WHERE seller_rank IN (10, 50, 100, 500)
ORDER BY seller_rank;
