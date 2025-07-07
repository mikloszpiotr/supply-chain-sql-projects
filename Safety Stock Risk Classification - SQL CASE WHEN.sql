-- 🎯 Objective: Classify products by safety stock coverage vs average demand

SELECT
    product_id,
    avg_monthly_demand,
    safety_stock,

    -- 🔢 Safety stock coverage ratio
    ROUND(100.0 * safety_stock / NULLIF(avg_monthly_demand, 0), 2) AS coverage_percent,

    -- 🎨 Risk classification
    CASE
        WHEN safety_stock / NULLIF(avg_monthly_demand, 0) < 0.5 THEN 'High Risk'    -- Less than 50% coverage
        WHEN safety_stock / NULLIF(avg_monthly_demand, 0) BETWEEN 0.5 AND 0.8 THEN 'Medium Risk'
        WHEN safety_stock / NULLIF(avg_monthly_demand, 0) > 0.8 THEN 'Low Risk'
        ELSE 'Check Data'
    END AS risk_category

FROM
    product_inventory
ORDER BY
    product_id;
