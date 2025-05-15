-- 🎯 Step 1: Aggregate total monthly demand per product
WITH monthly_demand AS (
    SELECT
        product_id,
        DATE_TRUNC('month', demand_date) AS month,          -- Align all demand records to month level
        SUM(quantity_demanded) AS total_quantity_demanded  -- Total units demanded in that month
    FROM 
        demand_data
    GROUP BY 
        product_id, 
        DATE_TRUNC('month', demand_date)
)

-- 🎯 Step 2: Calculate demand trends and rolling averages
SELECT
    product_id,
    month,
    total_quantity_demanded,

    -- Previous month’s demand to track changes
    LAG(total_quantity_demanded) OVER (
        PARTITION BY product_id ORDER BY month
    ) AS previous_month_demand,

    -- Demand change = current month demand - previous month demand
    total_quantity_demanded 
    - LAG(total_quantity_demanded) OVER (
        PARTITION BY product_id ORDER BY month
    ) AS demand_change,

    -- Rolling 3-month average of demand
    ROUND(
        AVG(total_quantity_demanded) OVER (
            PARTITION BY product_id 
            ORDER BY month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 
        2
    ) AS rolling_3_month_avg_demand

FROM 
    monthly_demand
ORDER BY 
    product_id, 
    month;
