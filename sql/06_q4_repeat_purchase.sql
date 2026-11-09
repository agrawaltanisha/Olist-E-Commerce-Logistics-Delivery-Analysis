-- Q4: Does late delivery cost repeat business?
-- RESULT (run 2026-08-06): INCONCLUSIVE — directionally consistent, underpowered.
--   first order on time: 86,993 customers, 2,639 repeat -> 3.03%
--   first order late:     6,357 customers,   162 repeat -> 2.55%
--   gap = 0.48pp (16% relative), BUT:
--   95% CI half-widths: on-time +/-0.114pp, late +/-0.388pp -> intervals OVERLAP.
--   Dose-response FAILS (non-monotonic):
--     on time 3.04% | 1-7d late 2.35% | 8+d late 2.66%
--   Severely-late customers repeat MORE than mildly-late ones — not a causal shape.
-- Root cause: only ~3.4% of customers ever reorder (3,345 of 96,096) in a
-- 2016-2018 marketplace window. Cannot resolve an effect this small.
-- REPORTED AS: directional signal, not a finding.

-- Repeat = the customer placed any later order (any status) after their first delivered order.
CREATE OR REPLACE TEMP VIEW first_order_outcome AS
WITH all_orders AS (
    SELECT c.customer_unique_id, o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
),
first_delivered AS (
    SELECT DISTINCT ON (customer_unique_id)
           customer_unique_id,
           order_purchase_timestamp AS first_purchase,
           days_vs_promise
    FROM v_order_delivery
    ORDER BY customer_unique_id, order_purchase_timestamp
)
SELECT
    f.customer_unique_id,
    f.days_vs_promise,
    EXISTS (
        SELECT 1 FROM all_orders a
        WHERE a.customer_unique_id = f.customer_unique_id
          AND a.order_purchase_timestamp > f.first_purchase
    ) AS repeated
FROM first_delivered f;

-- 1. Base rate: how many customers ever reorder?
SELECT
    COUNT(*)                                AS customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*), 1) AS pct_repeat
FROM (
    SELECT c.customer_unique_id, COUNT(*) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) per_customer;

-- 2. Repeat rate by first-order outcome, with 95% confidence interval half-width
--    (normal approximation: 1.96 * sqrt(p * (1 - p) / n), shown in percentage points)
SELECT
    CASE WHEN days_vs_promise > 0 THEN 'late' ELSE 'on time' END          AS first_order,
    COUNT(*)                                                              AS customers,
    COUNT(*) FILTER (WHERE repeated)                                      AS repeaters,
    ROUND(100.0 * AVG(repeated::int), 2)                                  AS repeat_pct,
    ROUND(100 * 1.96 * SQRT(AVG(repeated::int) * (1 - AVG(repeated::int)) / COUNT(*)), 3) AS ci95_half_width_pp
FROM first_order_outcome
GROUP BY first_order
ORDER BY first_order DESC;

-- 3. Dose-response: does a later first order mean a lower repeat rate?
SELECT
    CASE
        WHEN days_vs_promise <= 0 THEN 'a. on time'
        WHEN days_vs_promise <= 7 THEN 'b. 1-7 days late'
        ELSE                           'c. 8+ days late'
    END                                    AS first_order,
    COUNT(*)                               AS customers,
    ROUND(100.0 * AVG(repeated::int), 2)   AS repeat_pct
FROM first_order_outcome
GROUP BY first_order
ORDER BY first_order;
