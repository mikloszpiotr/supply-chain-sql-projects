/*
SQL Query for Slow-Moving and Obsolete Stock (SLOB) Analysis
*************************************************************
- Purpose: To identify and classify inventory based on sales velocity
           to find obsolete and slow-moving items.
- Dialect: T-SQL (SQL Server). See comments for MySQL/PostgreSQL.
*/

-- Define the key timeframes for your analysis
DECLARE @AnalysisDate DATE = GETDATE(); -- Use CURRENT_DATE for MySQL/PostgreSQL
DECLARE @ObsoleteThresholdDays INT = 365;
DECLARE @SlowMovingThresholdDays INT = 90;

-- 1. Common Table Expression (CTE) for Sales Summary
WITH SalesSummary AS (
    SELECT
        product_id,
        MAX(sale_date) AS last_sale_date,
        SUM(CASE
            -- For T-SQL:
            WHEN sale_date >= DATEADD(DAY, -@SlowMovingThresholdDays, @AnalysisDate) THEN quantity_sold
            -- For MySQL/PostgreSQL:
            -- WHEN sale_date >= (@AnalysisDate - INTERVAL @SlowMovingThresholdDays DAY) THEN quantity_sold
            ELSE 0
        END) AS quantity_sold_last_90_days
    FROM
        fact_Sales
    GROUP BY
        product_id
),

-- 2. CTE for Current Stock and Product Cost
ProductStock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.unit_cost,
        COALESCE(i.quantity_on_hand, 0) AS stock_on_hand,
        (p.unit_cost * COALESCE(i.quantity_on_hand, 0)) AS current_stock_value
    FROM
        dim_Product AS p
    LEFT JOIN
        fact_Inventory AS i ON p.product_id = i.product_id
    WHERE
        COALESCE(i.quantity_on_hand, 0) > 0 -- Only analyze products we currently have in stock
)

-- 3. Final Selection and Classification
SELECT
    ps.product_id,
    ps.product_name,
    ps.stock_on_hand,
    ps.unit_cost,
    ps.current_stock_value,
    ss.last_sale_date,
    COALESCE(ss.quantity_sold_last_90_days, 0) AS quantity_sold_last_90_days,

    -- Classification Logic
    CASE
        -- Rule 1: Obsolete Stock
        -- Has stock AND (has never sold OR last sale was > 365 days ago)
        WHEN ss.last_sale_date IS NULL
             OR ss.last_sale_date < DATEADD(DAY, -@ObsoleteThresholdDays, @AnalysisDate)
             -- MySQL/PostgreSQL: OR ss.last_sale_date < (@AnalysisDate - INTERVAL @ObsoleteThresholdDays DAY)
        THEN 'Obsolete'

        -- Rule 2: Slow-Moving Stock
        -- Is NOT obsolete (sold in last 365 days) BUT has 0 sales in the last 90 days
        WHEN COALESCE(ss.quantity_sold_last_90_days, 0) = 0
        THEN 'Slow-Moving'

        -- Rule 3: Healthy Stock
        -- Sells regularly
        ELSE 'Healthy'
    END AS stock_classification

FROM
    ProductStock AS ps
LEFT JOIN
    SalesSummary AS ss ON ps.product_id = ss.product_id
ORDER BY
    stock_classification,      -- Groups 'Obsolete' first, then 'Slow-Moving'
    current_stock_value DESC;  -- Shows the most costly items at the top