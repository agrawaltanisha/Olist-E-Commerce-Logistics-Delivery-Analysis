-- Q2: Better logistics, or more honest estimates?
-- RESULT (run 2026-08-06):
--   avg actual lead time    12.5 days   (median 10, p90 23)
--   avg promised lead time  24.4 days   (median 24)
--   avg variance           -11.9 days  -> Olist ALREADY pads heavily
--   late now: 6,534 | with +3d buffer: 4,664 | with +7d buffer: 2,862
-- Finding: buffer does NOT fix this. +3 days rescues only 29% of late orders;
-- 44% are >7 days late against an already-doubled promise.
-- This is a TAIL problem (a few catastrophic orders), not a calibration problem.
-- Padding further would degrade the offer for the 90% who get orders in ~10 days.

-- TAIL CONFIRMATION:
--   p95 = 29 days, p99 = 46 days, max = 210 days
--   on-time orders avg 10.9 days (n=89,936)
--   late orders    avg 33.9 days (n=6,534)  -> 3.1x longer
-- Late orders are structurally different, not marginally slower.

-- 1. Promise vs reality: how much does Olist already pad?
SELECT
    ROUND(AVG(actual_lead_time), 1)                                       AS avg_actual_days,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY actual_lead_time)         AS median_actual_days,
    PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY actual_lead_time)         AS p90_actual_days,
    ROUND(AVG(promised_lead_time), 1)                                     AS avg_promised_days,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY promised_lead_time)       AS median_promised_days,
    ROUND(AVG(days_vs_promise), 1)                                        AS avg_variance_days
FROM v_order_delivery;

-- 2. Buffer simulation: how many late orders would a longer promise rescue?
WITH late_counts AS (
    SELECT
        COUNT(*) FILTER (WHERE days_vs_promise > 0) AS late_now,
        COUNT(*) FILTER (WHERE days_vs_promise > 3) AS late_with_3d_buffer,
        COUNT(*) FILTER (WHERE days_vs_promise > 7) AS late_with_7d_buffer
    FROM v_order_delivery
)
SELECT
    late_now,
    late_with_3d_buffer,
    late_with_7d_buffer,
    ROUND(100.0 * (late_now - late_with_3d_buffer) / late_now, 1) AS pct_rescued_by_3d,
    ROUND(100.0 * late_with_7d_buffer / late_now, 1)               AS pct_more_than_7d_late
FROM late_counts;

-- 3. Tail confirmation: are late orders marginally slower or structurally different?
SELECT
    PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY actual_lead_time) AS p95_days,
    PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY actual_lead_time) AS p99_days,
    MAX(actual_lead_time)                                          AS max_days
FROM v_order_delivery;

SELECT
    CASE WHEN days_vs_promise > 0 THEN 'late' ELSE 'on time' END AS status,
    COUNT(*)                                                     AS orders,
    ROUND(AVG(actual_lead_time), 1)                              AS avg_actual_days
FROM v_order_delivery
GROUP BY status
ORDER BY status;
