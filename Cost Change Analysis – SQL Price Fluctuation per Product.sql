-- 🎯 Objective: Analyze unit cost trends over time and calculate monthly percentage changes

WITH monthly_avg_cost AS (
    -- Step 1: Calculate average unit cost per product for each month
    SELECT
        product_id,
        DATE_TRUNC('month', order_date) AS month,       -- Normalize to month level
        ROUND(AVG(unit_cost), 2) AS avg_unit_cost        -- Average cost that month (rounded to 2 decimals)
    FROM
        purchase_orders
    GROUP BY
        product_id,
        DATE_TRUNC('month', order_date)
),

cost_with_change AS (
    -- Step 2: Use LAG() to get previous month's cost to compute change
    SELECT
        product_id,
        month,
        avg_unit_cost,
        LAG(avg_unit_cost) OVER (
            PARTITION BY product_id 
            ORDER BY month
        ) AS prev_month_cost
    FROM
        monthly_avg_cost
)

-- Step 3: Calculate % change from previous month using math operations
SELECT
    product_id,
    month,
    avg_unit_cost,
    prev_month_cost,
    
    -- Step 4: Compute percentage change: ((new - old) / old) * 100
    CASE 
        WHEN prev_month_cost IS NULL THEN NULL             -- No previous month to compare
        WHEN prev_month_cost = 0 THEN NULL                 -- Avoid division by zero
        ELSE ROUND(100.0 * (avg_unit_cost - prev_month_cost) / prev_month_cost, 2)
    END AS cost_change_percent
FROM
    cost_with_change
ORDER BY
    product_id,
    month;
