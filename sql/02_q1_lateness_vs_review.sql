-- Q1: Does lateness kill reviews?
-- RESULT (run 2026-08-06):
--   5+ days early   81,555 orders   avg 4.31   6.5% one-star
--   0-4 days early   7,888 orders   avg 4.12   7.9% one-star
--   1-3 days late    1,852 orders   avg 3.29  25.2% one-star
--   4-7 days late    1,748 orders   avg 2.11  58.5% one-star
--   8+ days late     2,781 orders   avg 1.70  69.7% one-star
-- Finding: satisfaction is graded against the PROMISE, not absolute speed.
-- Crossing the promised date costs 0.83 review points immediately.

SELECT
    CASE
        WHEN days_vs_promise <= -5 THEN 'a. 5+ days early'
        WHEN days_vs_promise <   1 THEN 'b. 0-4 days early'
        WHEN days_vs_promise <= 3  THEN 'c. 1-3 days late'
        WHEN days_vs_promise <= 7  THEN 'd. 4-7 days late'
        ELSE                            'e. 8+ days late'
    END AS bucket,
    COUNT(*)                        AS orders,
    ROUND(AVG(review_score), 2)     AS avg_review,
    ROUND(100.0 * COUNT(*) FILTER (WHERE review_score = 1) / COUNT(review_score), 1) AS pct_one_star
FROM v_order_delivery
WHERE review_score IS NOT NULL
GROUP BY bucket
ORDER BY bucket;
