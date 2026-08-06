import os
import pandas as pd
from urllib.parse import quote_plus
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()
PASSWORD = quote_plus(os.getenv("PGPASSWORD"))
engine = create_engine(f"postgresql+psycopg2://postgres:{PASSWORD}@localhost:5432/olist")

files = {
    "customers":            "data/olist_customers_dataset.csv",
    "geolocation":          "data/olist_geolocation_dataset.csv",
    "order_items":          "data/olist_order_items_dataset.csv",
    "order_payments":       "data/olist_order_payments_dataset.csv",
    "order_reviews":        "data/olist_order_reviews_dataset.csv",
    "orders":               "data/olist_orders_dataset.csv",
    "products":             "data/olist_products_dataset.csv",
    "sellers":              "data/olist_sellers_dataset.csv",
    "category_translation": "data/product_category_name_translation.csv",
}

date_cols = {
    "orders": ["order_purchase_timestamp", "order_approved_at",
               "order_delivered_carrier_date", "order_delivered_customer_date",
               "order_estimated_delivery_date"],
    "order_items": ["shipping_limit_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
}

for table, path in files.items():
    df = pd.read_csv(path, parse_dates=date_cols.get(table))
    df.to_sql(table, engine, if_exists="replace", index=False,
              chunksize=10000, method="multi")
    print(f"{table:22} {len(df):>9,} rows")
