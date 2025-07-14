-- 🎯 Objective: Calculate ROI for each project using SQL math logic

SELECT
    i.project_id,
    i.project_name,
    i.investment_amount,
    r.return_value,

    -- 🔢 ROI = ((Return - Investment) / Investment) * 100
    CASE 
        WHEN i.investment_amount = 0 THEN NULL  -- avoid division by zero
        ELSE ROUND(
            100.0 * (r.return_value - i.investment_amount) / i.investment_amount,
            2
        )
    END AS roi_percent

FROM
    project_investments i
JOIN
    project_returns r ON i.project_id = r.project_id
ORDER BY
    roi_percent DESC;
