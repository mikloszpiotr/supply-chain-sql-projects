-- INVENTORY TYPES ANALYSIS

-- Example table structure
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id VARCHAR(10),
    warehouse_id VARCHAR(10),
    inventory_type VARCHAR(30),  -- 'Raw Material', 'WIP', 'Finished Good', 'MRO'
    quantity INT,
    last_update DATE
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE warehouses (
    warehouse_id VARCHAR(10) PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(50)
);

-- 1. Total inventory quantities by type, with breakdown per warehouse
SELECT
    i.inventory_type,
    w.warehouse_name,
    SUM(i.quantity) AS total_quantity
FROM inventory i
INNER JOIN warehouses w ON i.warehouse_id = w.warehouse_id
GROUP BY i.inventory_type, w.warehouse_name
ORDER BY i.inventory_type, total_quantity DESC;

-- 2. Inventory composition per type across all warehouses
SELECT
    i.inventory_type,
    COUNT(DISTINCT i.product_id) AS distinct_products,
    SUM(i.quantity) AS total_qty
FROM inventory i
GROUP BY i.inventory_type;

-- 3. Flag inventory types with low stock (threshold example: <100 units)
SELECT
    i.inventory_type,
    p.product_name,
    w.warehouse_name,
    i.quantity,
    CASE
        WHEN i.quantity < 100 THEN 'Low Stock'
        ELSE 'OK'
    END AS status
FROM inventory i
INNER JOIN products p ON i.product_id = p.product_id
INNER JOIN warehouses w ON i.warehouse_id = w.warehouse_id
ORDER BY i.inventory_type, i.quantity;

-- 4. Advanced: % composition of each inventory type, organization-wide
SELECT
    i.inventory_type,
    ROUND(100.0 * SUM(i.quantity) / (SELECT SUM(quantity) FROM inventory), 1) AS percent_of_total
FROM inventory i
GROUP BY i.inventory_type
ORDER BY percent_of_total DESC;

-- End of Project
/*
Features included:
- Type-based inventory calculation (Raw Material, WIP, Finished Good, MRO)
- Low-stock flagging across types & warehouses
- Percent composition for strategic analytics
- Can be visualized via dashboards, used in ABC inventory, FIFO, or OTIF reporting
*/
