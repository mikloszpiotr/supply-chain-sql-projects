-- 🎯 Objective: Classify products into A, B, C categories by sales value percentage

WITH sales_with_percent AS (
    -- Step 1: Calculate total sales and percentage contribution
    SELECT
        product_id,
        total_sales_value,
        ROUND(
            100.0 * total_sales_value / SUM(total_sales_value) OVER (),
            2
        ) AS percent_of_total_sales
    FROM
        sales_data
)

-- Step 2: Apply ABC classification using CASE
SELECT
    product_id,
    total_sales_value,
    percent_of_total_sales,

    CASE 
        WHEN percent_of_total_sales >= 70 THEN 'A'  -- Top 70% of sales value
        WHEN percent_of_total_sales >= 20 THEN 'B'  -- Next 20%
        ELSE 'C'                                    -- Remaining products
    END AS abc_class

FROM
    sales_with_percent
ORDER BY
    total_sales_value DESC;
