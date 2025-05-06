-- 🎯 Objective: Calculate On-Time Delivery % for each supplier

SELECT
    s.supplier_id,                          -- Unique ID of supplier
    s.supplier_name,                        -- Descriptive supplier name
    COUNT(so.order_id) AS total_orders,     -- Total number of orders placed with the supplier
    COUNT(
        CASE 
            WHEN so.delivery_date <= so.promised_date THEN 1 -- Count only orders delivered on-time
        END
    ) AS on_time_orders,
    
    ROUND(
        100.0 * COUNT(CASE WHEN so.delivery_date <= so.promised_date THEN 1 END) 
        / COUNT(so.order_id),
        2
    ) AS on_time_delivery_rate_percent     -- Final KPI: % of deliveries that were on or before promised date

FROM
    suppliers s
JOIN
    supplier_orders so ON s.supplier_id = so.supplier_id  -- Join suppliers to their delivery data

GROUP BY
    s.supplier_id, s.supplier_name
ORDER BY
    on_time_delivery_rate_percent DESC;  -- Rank suppliers from most reliable to least
