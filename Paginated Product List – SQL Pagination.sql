-- 🎯 Objective: Fetch a paginated list of products
-- This example shows how to retrieve "Page 2" (products 11–20) assuming 10 products per page

SELECT
    product_id,       -- Unique product identifier
    product_name,     -- Human-readable product name
    category          -- Product category (used for grouping or filtering)
FROM
    products
ORDER BY
    product_name ASC  -- Always use ORDER BY to ensure consistent pagination order
LIMIT 10              -- Return only 10 products per page
OFFSET 10;            -- Skip the first 10 products (i.e., show page 2)
