-- 🎯 Objective: Rank products by monthly sales using RANK, DENSE_RANK, and ROW_NUMBER

WITH monthly_sales AS (
    -- Step 1: Sum sales by product and month
    SELECT
        product_id,
        DATE_TRUNC('month', transaction_date) AS sales_month,
        SUM(quantity_sold) AS total_sales
    FROM
        sales_transactions
    GROUP BY
        product_id, DATE_TRUNC('month', transaction_date)
)

SELECT
    product_id,
    sales_month,
    total_sales,

    -- 🎖️ RANK(): Same rank for ties, skips next rank
    RANK() OVER (
        PARTITION BY sales_month 
        ORDER BY total_sales DESC
    ) AS rank_standard,

    -- 🎖️ DENSE_RANK(): Same rank for ties, no skips
    DENSE_RANK() OVER (
        PARTITION BY sales_month 
        ORDER BY total_sales DESC
    ) AS rank_dense,

    -- 🔢 ROW_NUMBER(): Always unique, even if values tie
    ROW_NUMBER() OVER (
        PARTITION BY sales_month 
        ORDER BY total_sales DESC
    ) AS row_number

FROM 
    monthly_sales
ORDER BY 
    sales_month, rank_standard;
