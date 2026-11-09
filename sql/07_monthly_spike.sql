-- Monthly trend: when did lateness spike?
-- RESULT (run 2026-08-06):
--   2017-10  4,478 orders   4.2% late  11.7d lead time
--   2017-11  7,288 orders  12.4% late  15.1d   <- Black Friday, volume +63%
--   2017-12  5,513 orders   7.5% late  15.3d
--   2018-01  7,069 orders   5.7% late  14.0d
--   2018-02  6,555 orders  14.1% late  16.9d
--   2018-03  7,003 orders  19.0% late  16.2d   <- worst month in dataset
--   2018-04  6,798 orders   4.5% late  11.4d   <- full recovery, volume flat
-- Finding: lead time rose only ~40% (11.7 -> 16.2d) while late rate quadrupled.
-- A modest slowdown blows through a fixed promised date (see Q1).
-- April recovery at unchanged volume => operational failure, not a capacity ceiling.

SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date                        AS month,
    COUNT(*)                                                                   AS orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE days_vs_promise > 0) / COUNT(*), 1)   AS pct_late,
    ROUND(AVG(actual_lead_time), 1)                                            AS avg_lead_time,
    ROUND(AVG(review_score), 2)                                                AS avg_review
FROM v_order_delivery
GROUP BY month
ORDER BY month;
