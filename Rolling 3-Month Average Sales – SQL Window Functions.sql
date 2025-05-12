-- 🎯 Objective: Calculate rolling 3-month average sales per product
-- This helps to smooth demand variability and guide procurement decisions.

WITH monthly_sales AS (
    -- Step 1: Summarize sales at product + month level
    SELECT
        product_id,
        DATE_TRUNC('month', transaction_date) AS month,     -- Round dates to first of month
        SUM(quantity_sold) AS total_quantity_sold           -- Aggregate sales within the month
    FROM
        sales_transactions
    GROUP BY
        product_id,
        DATE_TRUNC('month', transaction_date)
)

-- Step 2: Apply window function to get rolling average of last 3 months
SELECT
    product_id,
    month,
    total_quantity_sold,
    
    -- Rolling 3-month average including current month + prior 2 months
    ROUND(
        AVG(total_quantity_sold) OVER (
            PARTITION BY product_id
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW   -- Look back 2 rows + current row = 3 months
        ),
        2
    ) AS rolling_3_month_avg
FROM
    monthly_sales
ORDER BY
    product_id,
    month;
