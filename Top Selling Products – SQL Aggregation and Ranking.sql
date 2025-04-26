-- 🎯 Objective: Find the top-selling products based on total quantity sold

SELECT
    p.product_id,                  -- Unique identifier of each product
    p.product_name,                -- Descriptive name for clarity
    SUM(st.quantity_sold) AS total_quantity_sold -- Total units sold (aggregated across all transactions)
FROM
    products p
JOIN
    sales_transactions st          -- Join products with their sales data
    ON p.product_id = st.product_id
GROUP BY
    p.product_id,
    p.product_name                 -- Group by product so we can sum the sales properly
ORDER BY
    total_quantity_sold DESC;      -- Sort so that the best-selling products come first
