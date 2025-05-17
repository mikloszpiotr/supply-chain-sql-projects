-- 🎯 Objective: Calculate cost to fulfill demand = quantity * unit cost (using two tables)

WITH demand_monthly AS (
    -- Step 1: Round demand data to month and aggregate by product
    SELECT
        product_id,
        DATE_TRUNC('month', demand_date) AS month,
        SUM(quantity_demanded) AS total_quantity_demanded
    FROM demand_data
    GROUP BY product_id, DATE_TRUNC('month', demand_date)
),

price_monthly AS (
    -- Step 2: Get monthly cost per product (most recent price for the month)
    SELECT
        product_id,
        DATE_TRUNC('month', effective_date) AS month,
        MAX(unit_cost) AS unit_cost -- Assume latest price per month
    FROM product_prices
    GROUP BY product_id, DATE_TRUNC('month', effective_date)
)

-- Step 3: Join demand and cost data, and calculate total cost
SELECT
    d.product_id,
    d.month,
    d.total_quantity_demanded,
    p.unit_cost,
    
    -- 💰 Math: Total Cost = Quantity × Cost
    ROUND(d.total_quantity_demanded * p.unit_cost, 2) AS total_fulfillment_cost

FROM 
    demand_monthly d
JOIN 
    price_monthly p ON d.product_id = p.product_id AND d.month = p.month
ORDER BY 
    d.product_id, d.month;
