-- =========================================================================================
-- WAREHOUSING KEY PERFORMANCE INDICATORS (KPIs)
-- This script uses standard SQL concepts (CTEs, aggregate functions) to calculate
-- five common warehousing KPIs based on mock data.
-- =========================================================================================

-- 1. MOCK DATA: Simulating the ORDERS table
WITH Orders_Data AS (
    SELECT 1 AS order_id, 1001 AS customer_id, 2 AS total_lines, TRUE AS is_backorder, 50 AS total_order_qty, 10 AS total_value, '2025-09-01' AS order_date
    UNION ALL SELECT 2, 1002, 1, FALSE, 20, 5, '2025-09-02'
    UNION ALL SELECT 3, 1003, 3, FALSE, 80, 25, '2025-09-02'
    UNION ALL SELECT 4, 1004, 1, FALSE, 15, 8, '2025-09-03'
    UNION ALL SELECT 5, 1005, 2, TRUE, 30, 12, '2025-09-03'
),

-- 2. MOCK DATA: Simulating the SHIPMENTS / FULFILLMENT table
Shipments_Data AS (
    -- Tracks individual shipments and their associated timeliness/completeness
    SELECT 101 AS shipment_id, 1 AS order_id, 2 AS items_shipped, TRUE AS is_complete_shipment, '2025-09-03' AS scheduled_ship_date, '2025-09-03' AS actual_ship_date, 120 AS pick_time_seconds -- On-time
    UNION ALL SELECT 102, 2, 1, TRUE, '2025-09-04', '2025-09-05', 80  -- Late
    UNION ALL SELECT 103, 3, 3, TRUE, '2025-09-04', '2025-09-04', 150 -- On-time
    UNION ALL SELECT 104, 4, 1, TRUE, '2025-09-05', '2025-09-05', 95  -- On-time
    UNION ALL SELECT 105, 5, 1, FALSE, '2025-09-05', '2025-09-05', 105 -- On-time, but incomplete (partial shipment)
),

-- 3. MOCK DATA: Simulating INVENTORY / STOCK COUNT table
Inventory_Data AS (
    -- Tracks inventory records and any discrepancies found during cycle counts
    SELECT 201 AS item_id, 'A-001' AS location_id, 100 AS system_qty, 100 AS actual_qty, FALSE AS has_discrepancy, 1.50 AS cost
    UNION ALL SELECT 202, 'B-002', 50, 48, TRUE, 2.00 -- Discrepancy (2 units)
    UNION ALL SELECT 203, 'C-003', 200, 200, FALSE, 0.75
    UNION ALL SELECT 204, 'A-002', 75, 75, FALSE, 3.00
    UNION ALL SELECT 205, 'D-001', 30, 31, TRUE, 1.00 -- Discrepancy (1 unit)
),

-- =========================================================================================
-- KPI CALCULATION CTEs
-- =========================================================================================

-- KPI 1 & 2: Order Fulfillment and On-Time Shipment Rate
Fulfillment_And_Shipping_KPIs AS (
    SELECT
        -- Order Fulfillment Rate (OFR): Percentage of orders shipped completely (no backorders/partial shipments).
        CAST(SUM(CASE WHEN S.is_complete_shipment = TRUE THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(S.order_id) AS Order_Fulfillment_Rate_PCT,

        -- On-Time Shipping Rate (OTS): Percentage of shipments that meet the scheduled ship date.
        CAST(SUM(CASE WHEN S.actual_ship_date <= S.scheduled_ship_date THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(S.shipment_id) AS On_Time_Shipping_Rate_PCT,

        -- Average Pick/Pack Cycle Time: Average time spent processing a shipment (in seconds).
        AVG(S.pick_time_seconds) AS Avg_Pick_Pack_Time_Seconds
    FROM
        Shipments_Data S
),

-- KPI 3 & 4: Inventory Metrics (Accuracy and Turnover)
Inventory_Metrics_KPIs AS (
    SELECT
        -- Inventory Accuracy (IA): Percentage of inventory records that match the actual physical count.
        -- Calculated by (Total Records - Records with Discrepancies) / Total Records
        CAST(SUM(CASE WHEN I.has_discrepancy = FALSE THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(I.item_id) AS Inventory_Accuracy_PCT,

        -- Inventory Turnover (IT): Measures how many times inventory is sold/used over a period.
        -- Formula: (Cost of Goods Sold) / (Average Inventory Value)
        -- Simplified here as (Total Shipped Quantity * Average Item Cost) / (Total Inventory Value)
        (
            (SELECT SUM(items_shipped) FROM Shipments_Data) * (SELECT AVG(cost) FROM Inventory_Data)
        ) / (
            (SELECT SUM(system_qty * cost) FROM Inventory_Data)
        ) AS Inventory_Turnover_Ratio,

        -- Total Inventory Discrepancy Value: Monetary value of missing or excess stock.
        SUM(ABS(I.system_qty - I.actual_qty) * I.cost) AS Total_Discrepancy_Value
    FROM
        Inventory_Data I
),

-- KPI 5: Backorder Rate
Backorder_KPIs AS (
    SELECT
        -- Backorder Rate: Percentage of orders that contained backordered items.
        CAST(SUM(CASE WHEN O.is_backorder = TRUE THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(O.order_id) AS Backorder_Rate_PCT
    FROM
        Orders_Data O
)

-- =========================================================================================
-- FINAL RESULT: Combining all KPIs into a single row for reporting
-- =========================================================================================
SELECT
    -- Order/Shipping KPIs
    F.Order_Fulfillment_Rate_PCT,
    F.On_Time_Shipping_Rate_PCT,
    B.Backorder_Rate_PCT,
    F.Avg_Pick_Pack_Time_Seconds,

    -- Inventory KPIs
    I.Inventory_Accuracy_PCT,
    I.Inventory_Turnover_Ratio,
    I.Total_Discrepancy_Value

FROM
    Fulfillment_And_Shipping_KPIs F
CROSS JOIN
    Inventory_Metrics_KPIs I
CROSS JOIN
    Backorder_KPIs B;

-- NOTE ON SQL DIALECT:
-- - The CAST(... AS REAL) conversion is used to ensure floating-point division for percentage calculations.
-- - Date comparison (actual_ship_date <= scheduled_ship_date) is standard for calculating On-Time metrics.
-- - For calculating time differences (like Avg_Pick_Pack_Time_Seconds), actual systems would use DATEDIFF (T-SQL/MySQL), DATE_PART (PostgreSQL), or similar functions on timestamp columns.
