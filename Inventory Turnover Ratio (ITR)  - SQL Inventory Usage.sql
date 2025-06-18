-- 🎯 Objective: Calculate monthly Inventory Turnover Ratio per product

SELECT
    i.product_id,
    i.month,
    i.avg_inventory_value,
    s.cost_of_goods_sold,

    -- 🔢 ITR = COGS / Average Inventory
    CASE 
        WHEN i.avg_inventory_value = 0 THEN NULL      -- Prevent division by zero
        ELSE ROUND(s.cost_of_goods_sold * 1.0 / i.avg_inventory_value, 2)
    END AS inventory_turnover_ratio

FROM
    inventory_balances i
JOIN
    sales_data s ON i.product_id = s.product_id AND i.month = s.month
ORDER BY
    i.product_id,
    i.month;
