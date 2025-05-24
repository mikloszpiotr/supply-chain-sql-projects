-- 🎯 Objective: Join forecast with actual demand and compute error metrics

WITH combined AS (
    SELECT
        f.product_id,
        f.forecast_month,
        f.forecast_qty,
        a.actual_qty,
        
        -- 🔢 1. Absolute Error
        ABS(f.forecast_qty - a.actual_qty) AS absolute_error,

        -- 🔢 2. Percentage Error (rounded)
        ROUND(
            100.0 * (f.forecast_qty - a.actual_qty) / NULLIF(a.actual_qty, 0), 
            2
        ) AS percentage_error

    FROM
        demand_forecast f
    JOIN 
        demand_actual a 
        ON f.product_id = a.product_id 
        AND f.forecast_month = a.actual_month
)

-- Final step: show per-row errors + overall accuracy metrics
SELECT
    product_id,
    forecast_month,
    forecast_qty,
    actual_qty,
    absolute_error,
    percentage_error,

    -- 📊 3. Running mean absolute error (MAE)
    ROUND(AVG(absolute_error) OVER (), 2) AS mean_absolute_error,

    -- 📊 4. Running mean absolute percentage error (MAPE)
    ROUND(AVG(ABS(percentage_error)) OVER (), 2) AS mean_absolute_percentage_error

FROM
    combined
ORDER BY
    product_id,
    forecast_month;
