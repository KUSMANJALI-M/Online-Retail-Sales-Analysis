-- 1. Total revenue
SELECT ROUND(SUM(total_revenue), 2) AS total_revenue
FROM transactions;

-- 2. Total unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM transactions;

-- 3. Total orders (unique invoices)
SELECT COUNT(DISTINCT invoice) AS total_orders
FROM transactions;

-- 4. Revenue by country (Top 10)
SELECT
    country,
    ROUND(SUM(total_revenue), 2)  AS revenue,
    COUNT(DISTINCT invoice)        AS orders,
    COUNT(DISTINCT customer_id)    AS customers
FROM transactions
GROUP BY country
ORDER BY revenue DESC
LIMIT 10;

-- 5. Top 10 best-selling products by revenue
SELECT
    description,
    SUM(quantity)                  AS total_qty,
    ROUND(SUM(total_revenue), 2)  AS total_revenue
FROM transactions
GROUP BY description
ORDER BY total_revenue DESC
LIMIT 10;

-- 6. Monthly revenue trend
SELECT
    year_month,
    ROUND(SUM(total_revenue), 2)  AS monthly_revenue,
    COUNT(DISTINCT invoice)        AS monthly_orders
FROM transactions
GROUP BY year_month
ORDER BY year_month;
```

## SQL Queries — Intermediate Level

```sql
-- 7. Average Order Value (AOV)
SELECT
    ROUND(SUM(total_revenue) / COUNT(DISTINCT invoice), 2) AS avg_order_value
FROM transactions;

-- 8. Revenue by day of week
SELECT
    day_of_week,
    ROUND(SUM(total_revenue), 2)   AS revenue,
    COUNT(DISTINCT invoice)         AS orders,
    ROUND(AVG(total_revenue), 2)   AS avg_order_value
FROM transactions
GROUP BY day_of_week
ORDER BY revenue DESC;

-- 9. Customer purchase frequency distribution
SELECT
    purchase_count,
    COUNT(*) AS num_customers
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice) AS purchase_count
    FROM transactions
    GROUP BY customer_id
) sub
GROUP BY purchase_count
ORDER BY purchase_count;

-- 10. Month-over-Month revenue growth
WITH monthly AS (
    SELECT
        year_month,
        ROUND(SUM(total_revenue), 2) AS revenue
    FROM transactions
    GROUP BY year_month
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY year_month)   AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0),
    2) AS mom_growth_pct
FROM monthly
ORDER BY year_month;

-- 11. Top customers by lifetime value
SELECT
    customer_id,
    country,
    COUNT(DISTINCT invoice)        AS total_orders,
    ROUND(SUM(total_revenue), 2)  AS lifetime_value,
    ROUND(AVG(total_revenue), 2)  AS avg_order_value,
    MIN(invoicedate)               AS first_purchase,
    MAX(invoicedate)               AS last_purchase
FROM transactions
GROUP BY customer_id, country
ORDER BY lifetime_value DESC
LIMIT 20;

-- KPI Summary Card
SELECT
    ROUND(SUM(total_revenue), 2)                                    AS total_revenue,
    COUNT(DISTINCT invoice)                                          AS total_orders,
    COUNT(DISTINCT customer_id)                                      AS unique_customers,
    ROUND(SUM(total_revenue) / COUNT(DISTINCT invoice), 2)          AS avg_order_value,
    ROUND(SUM(total_revenue) / COUNT(DISTINCT customer_id), 2)      AS avg_revenue_per_customer,
    COUNT(DISTINCT stockcode)                                        AS unique_products,
    ROUND(1.0 * COUNT(DISTINCT invoice) / COUNT(DISTINCT customer_id), 2) AS avg_orders_per_customer
FROM transactions;