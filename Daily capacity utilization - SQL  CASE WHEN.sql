SELECT
    wc.work_center_id,
    wc.work_date,
    SUM(wc.available_hours)                         AS available_hours,
    COALESCE(SUM(wo.run_hours), 0)                  AS actual_hours,
    CASE 
        WHEN SUM(wc.available_hours) = 0 THEN 0
        ELSE ROUND(
            COALESCE(SUM(wo.run_hours), 0) 
            / SUM(wc.available_hours) * 100.0, 2
        )
    END                                             AS capacity_utilization_pct
FROM work_center_calendar wc
LEFT JOIN work_orders wo
    ON  wc.work_center_id = wo.work_center_id
    AND wc.work_date      = wo.work_date
-- optional: filter period
-- WHERE wc.work_date BETWEEN DATE '2025-01-01' AND DATE '2025-01-31'
GROUP BY
    wc.work_center_id,
    wc.work_date
ORDER BY
    wc.work_center_id,
    wc.work_date;
