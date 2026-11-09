import os
from urllib.parse import quote_plus
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
PASSWORD = quote_plus(os.getenv("PGPASSWORD"))
engine = create_engine(f"postgresql+psycopg2://postgres:{PASSWORD}@localhost:5432/olist")

os.makedirs("tableau", exist_ok=True)

queries = {}

queries["orders_fact"] = """
SELECT order_id, customer_unique_id, customer_state,
       order_purchase_timestamp, days_vs_promise,
       actual_lead_time, promised_lead_time, review_score,
       CASE
           WHEN days_vs_promise <= -5 THEN 'a. 5+ days early'
           WHEN days_vs_promise <   1 THEN 'b. 0-4 days early'
           WHEN days_vs_promise <= 3  THEN 'c. 1-3 days late'
           WHEN days_vs_promise <= 7  THEN 'd. 4-7 days late'
           ELSE                            'e. 8+ days late'
       END AS lateness_bucket,
       (days_vs_promise > 0) AS is_late
FROM v_order_delivery
"""

queries["q1_lateness_vs_review"] = """
SELECT CASE
           WHEN days_vs_promise <= -5 THEN 'a. 5+ days early'
           WHEN days_vs_promise <   1 THEN 'b. 0-4 days early'
           WHEN days_vs_promise <= 3  THEN 'c. 1-3 days late'
           WHEN days_vs_promise <= 7  THEN 'd. 4-7 days late'
           ELSE                            'e. 8+ days late'
       END AS bucket,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * COUNT(*) FILTER (WHERE review_score = 1) / COUNT(review_score), 1) AS pct_one_star
FROM v_order_delivery
WHERE review_score IS NOT NULL
GROUP BY bucket ORDER BY bucket
"""

queries["state_performance"] = """
SELECT customer_state,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE days_vs_promise > 0) / COUNT(*), 1) AS pct_late,
       ROUND(AVG(actual_lead_time), 1)   AS avg_actual_days,
       ROUND(AVG(promised_lead_time), 1) AS avg_promised_days,
       ROUND(AVG(days_vs_promise), 1)    AS avg_buffer_used,
       ROUND(AVG(review_score), 2)       AS avg_review
FROM v_order_delivery
GROUP BY customer_state ORDER BY avg_actual_days DESC
"""

queries["seller_performance"] = """
WITH order_seller AS (SELECT DISTINCT order_id, seller_id FROM order_items)
SELECT os.seller_id,
       COUNT(*) AS orders,
       COUNT(*) FILTER (WHERE v.days_vs_promise > 0) AS late_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE v.days_vs_promise > 0) / COUNT(*), 1) AS pct_late,
       ROUND(AVG(v.actual_lead_time), 1) AS avg_lead_time,
       ROUND(AVG(v.review_score), 2)     AS avg_review
FROM v_order_delivery v
JOIN order_seller os ON v.order_id = os.order_id
GROUP BY os.seller_id
HAVING COUNT(*) >= 20
ORDER BY orders DESC
"""

queries["monthly_trend"] = """
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE days_vs_promise > 0) / COUNT(*), 1) AS pct_late,
       ROUND(AVG(actual_lead_time), 1) AS avg_lead_time,
       ROUND(AVG(review_score), 2)     AS avg_review
FROM v_order_delivery
GROUP BY month ORDER BY month
"""

for name, q in queries.items():
    df = pd.read_sql(text(q), engine)
    path = f"tableau/{name}.csv"
    df.to_csv(path, index=False)
    print(f"{name:28} {len(df):>7,} rows -> {path}")
