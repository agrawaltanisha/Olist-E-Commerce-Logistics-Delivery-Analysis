# Olist E-Commerce Logistics & Delivery Analysis 📦🚚

## Project Overview
This project analyzes a massive real-world e-commerce dataset (100,000+ orders) from Olist, a Brazilian e-commerce platform. Using advanced SQL and Tableau, this project investigates supply chain logistics, focusing on delivery delays, freight costs, and their impact on customer satisfaction.

## Business Problem
Late deliveries and high shipping costs are major pain points for e-commerce logistics. The objective is to perform a Root Cause Analysis (RCA) on last-mile delivery delays and visualize the performance of various shipping routes and product categories.

## Tech Stack Used
- **Database:** PostgreSQL / MySQL / SQLite (Choose the one you used)
- **Query Language:** Advanced SQL (CTEs, Window Functions, Joins, Aggregations)
- **Data Cleansing:** Python (Pandas)
- **Data Visualization:** Tableau

## Repository Structure
- `data/` : Raw CSV files downloaded from the Kaggle Olist Dataset.
- `sql_queries/` : Contains `.sql` scripts used for data analysis and metric extraction.
- `dashboards/` : Contains the `.twbx` Tableau workbook files.
- `README.md` : Project documentation.

## Key SQL Concepts Demonstrated
- Complex `JOIN` operations across 5+ tables (Orders, Customers, Products, Reviews, Sellers).
- Using **CTEs (Common Table Expressions)** to calculate average delivery times by state.
- **Window Functions** (`RANK()`, `DENSE_RANK()`) to find the top worst-performing shipping routes.
- Date/Time functions (`DATEDIFF()`, `EXTRACT()`) to measure actual vs. estimated delivery times.

## Key Insights
*(To be filled out after analysis. Examples:)*
1. **Delivery Delays:** 8% of all orders were delivered after the estimated delivery date, severely dropping average review scores from 4.2 to 2.1.
2. **Freight Costs:** The Northern regions experienced freight costs 40% higher than the national average, correlating with a higher cart abandonment rate.
3. **Product Impact:** "Office Furniture" had the highest variance in delivery times due to size constraints in last-mile logistics.

---
*Dataset sourced from [Kaggle: Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).*
