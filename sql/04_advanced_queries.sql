-- 12. RFM Score Calculation
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(invoicedate)                           AS last_purchase_date,
        COUNT(DISTINCT invoice)                    AS frequency,
        ROUND(SUM(total_revenue), 2)              AS monetary,
        JULIANDAY('2011-12-31') - JULIANDAY(MAX(invoicedate)) AS recency_days
    FROM transactions
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score, 
        NTILE(5) OVER (ORDER BY frequency ASC)       AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)        AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                   THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                   THEN 'New Customers'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3  THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 3                   THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3  THEN 'Cant Lose Them'
        WHEN r_score <= 1                                     THEN 'Lost'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

-- 13. Customer Cohort Retention Analysis
WITH first_purchase AS (
    SELECT customer_id, MIN(year_month) AS cohort_month
    FROM transactions
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        t.customer_id,
        f.cohort_month,
        t.year_month AS purchase_month
    FROM transactions t
    JOIN first_purchase f ON t.customer_id = f.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
),
retention AS (
    SELECT
        cd.cohort_month,
        cd.purchase_month,
        COUNT(DISTINCT cd.customer_id) AS active_customers
    FROM cohort_data cd
    GROUP BY cd.cohort_month, cd.purchase_month
)
SELECT
    r.cohort_month,
    r.purchase_month,
    cs.cohort_customers,
    r.active_customers,
    ROUND(100.0 * r.active_customers / cs.cohort_customers, 1) AS retention_rate_pct
FROM retention r
JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.purchase_month;

-- 14. Product Basket Analysis 
WITH invoice_products AS (
    SELECT invoice, description
    FROM transactions
),
product_pairs AS (
    SELECT
        a.invoice,
        a.description AS product_a,
        b.description AS product_b
    FROM invoice_products a
    JOIN invoice_products b
        ON a.invoice = b.invoice AND a.description < b.description
)
SELECT
    product_a,
    product_b,
    COUNT(*) AS co_purchase_count
FROM product_pairs
GROUP BY product_a, product_b
ORDER BY co_purchase_count DESC
LIMIT 20;