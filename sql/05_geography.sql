-- Follow-up to Q3 null finding: WHERE does lateness live?
-- RESULT (run 2026-08-06): geography, not sellers.
--   SP: 40,494 orders,  8.7d lead time,  4.5% late, 4.25 review
--   AL:    397 orders, 24.5d lead time, 21.4% late, 3.86 review
--   Slow tail = North/Northeast (AL, PA, MA, SE, CE, PB, PI)
--   Fast head = Southeast/South (SP, MG, PR, DF, SC) — where sellers cluster
--   2.8x spread in lead time, ~5x spread in lateness rate.
-- Explains why Q3 found no seller concentration: cause is the ROUTE, not the merchant.
-- NOTE: review gap across states is only 0.39 pts vs 2.6 pts in Q1 —
-- consistent with Q1: customers grade vs the PROMISE, and promises already
-- stretch for distant states. Slow-but-expected does not anger customers.

-- PROMISE CALIBRATION BY STATE:
--   promised lead time scales with distance: SP 19.8d -> RO 39.4d
--   BUT avg_buffer_used is ~constant across all 23 states (-8.7 to -20.1, most ~-12)
--   => Olist's estimator already accounts for distance AND adds a flat ~12-day cushion.
-- CONCLUSION: the estimate is well-calibrated. The 6,534 late orders are not
-- explained by the estimate, the seller, or the destination. They are operational
-- exceptions (avg 33.9d vs 10.9d norm). Recommendation: exception detection —
-- flag orders that go silent past day ~20 and intervene before the review lands.

-- Delivery performance and promise calibration by customer state.
-- avg_buffer_used = actual minus promised days (negative = arrived early).
SELECT
    customer_state,
    COUNT(*)                                                                   AS orders,
    ROUND(AVG(actual_lead_time), 1)                                            AS avg_actual_days,
    ROUND(AVG(promised_lead_time), 1)                                          AS avg_promised_days,
    ROUND(AVG(days_vs_promise), 1)                                             AS avg_buffer_used,
    ROUND(100.0 * COUNT(*) FILTER (WHERE days_vs_promise > 0) / COUNT(*), 1)   AS pct_late,
    ROUND(AVG(review_score), 2)                                                AS avg_review
FROM v_order_delivery
GROUP BY customer_state
ORDER BY avg_actual_days DESC;
