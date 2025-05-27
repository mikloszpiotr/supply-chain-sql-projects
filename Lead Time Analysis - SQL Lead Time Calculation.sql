-- 🎯 Objective: Calculate lead time (days between order and delivery)

SELECT
    supplier_id,
    product_id,
    order_id,
    order_date,
    delivery_date,

    -- 📅 Lead Time in Days
    DATEDIFF(DAY, order_date, delivery_date) AS lead_time_days

FROM
    purchase_orders
ORDER BY
    supplier_id, product_id, order_date;
