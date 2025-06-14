-- 🎯 Objective: Calculate cumulative (YTD) sales per product over time

WITH monthly_sales AS (
    -- Step 1: Summarize monthly sales per product
    SELECT
        product_id,
        DATE_TRUNC('month', transaction_date) AS sales_month,
        SUM(quantity_sold) AS monthly_sales
    FROM
        sales_transactions
    GROUP BY
        product_id, DATE_TRUNC('month', transaction_date)
)

-- Step 2: Use SUM() OVER() to calculate cumulative total
SELECT
    product_id,
    sales_month,
    monthly_sales,

    -- 📈 YTD cumulative sales up to current month
    SUM(monthly_sales) OVER (
        PARTITION BY product_id
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_cumulative_sales

FROM 
    monthly_sales
ORDER BY 
    product_id, sales_month;
