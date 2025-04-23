-- 💡 Objective: Get the current stock level for each product
-- We will join 'products' with 'inventory_transactions'
-- Then, we will calculate the net quantity by subtracting OUT from IN transactions

SELECT
    p.product_id,              -- Unique identifier of the product
    p.product_name,            -- Descriptive name of the product
    SUM(
        CASE 
            WHEN it.transaction_type = 'IN' THEN it.quantity   -- Add quantity when stock comes in
            WHEN it.transaction_type = 'OUT' THEN -it.quantity -- Subtract quantity when stock goes out
            ELSE 0                                             -- Handle unexpected types safely
        END
    ) AS current_stock         -- The resulting net stock level for each product
FROM
    products p                 -- Table with master data for products
LEFT JOIN
    inventory_transactions it  -- Table with daily inventory transactions
    ON p.product_id = it.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    current_stock ASC;         -- Optional: sort from lowest stock to highest (useful for spotting low stock)
