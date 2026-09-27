-- Student:Muhammad Talha
--ASSIGNEMENT : QUIZ TEST
-- Scenario-Based SQL Assignment — BikeStores

-------------------------------------------------
--Task 1 -- Build the Sales Detail Dataset (6 marks)
Q1)  (Management needs a detailed sales dataset for analysis. Return one row per order item containing:
order_id and order_date
customer full name
store name
staff full name
product name
category name
brand name
quantity, list_price, discount
calculated net_line_revenue)?

solve

SELECT 
    o.order_id,
    o.order_date,
    c.first_name + ' ' + c.last_name AS customer_name,
    s.store_name,
    st.first_name + ' ' + st.last_name AS staff_name,
    p.product_name,
    cat.category_name,
    b.brand_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS net_line_revenue
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN sales.stores s ON o.store_id = s.store_id
JOIN sales.staffs st ON o.staff_id = st.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.categories cat ON p.category_id = cat.category_id
JOIN production.brands b ON p.brand_id = b.brand_id
WHERE o.order_status = 4
ORDER BY o.order_date DESC;

-------------------------------------------------
-- TASK 2: Store Performance Summary
Create a store-level performance report for completed orders showing:
store name
number of distinct orders
total units sold
total net revenue
average order value?
------------------------------------------------------------------
SELECT 
    s.store_name,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM sales.orders o
JOIN sales.stores s ON o.store_id = s.store_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_name
ORDER BY total_net_revenue DESC;

-------------------------------------------------
-- TASK 3: High-Value Customers
Management wants to identify high-value customers. Return customers whose total completed-order spending is greater than the average total spending of customers who have completed orders.?
-------------------------------------------------
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name + ' ' + c.last_name AS customer_name,
        COUNT(DISTINCT o.order_id) AS completed_order_count,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.orders o
    JOIN sales.customers c ON o.customer_id = c.customer_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM customer_spending
WHERE total_spending > (SELECT AVG(total_spending) FROM customer_spending)
ORDER BY total_spending DESC;

-------------------------------------------------
-- TASK 4: Inventory Risk Report
Operations wants to identify inventory risk. Return products where the stock quantity is below 5 in at least one store.
Show product name, store name, current quantity, category name, and brand name. Products with zero stock should appear first, followed by the lowest remaining quantities.
-------------------------------------------------
SELECT 
    p.product_name,
    s.store_name,
    st.quantity AS current_quantity,
    c.category_name,
    b.brand_name
FROM production.stocks st
JOIN production.products p ON st.product_id = p.product_id
JOIN sales.stores s ON st.store_id = s.store_id
JOIN production.categories c ON p.category_id = c.category_id
JOIN production.brands b ON p.brand_id = b.brand_id
WHERE st.quantity < 5
ORDER BY st.quantity ASC;

-------------------------------------------------
-- TASK 5: Top Products Within Each Category
For each product category, identify the top 3 products by total net revenue from completed orders.

Return category name, product name, total units sold, total net revenue, and the product's position within its category. Tied products must receive the same position and the next position should not contain gaps?
-----------------------------------------------------------------------------------

WITH product_revenue AS (
    SELECT 
        c.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE o.order_status = 4
    GROUP BY c.category_name, p.product_name
),
ranked_products AS (
    SELECT *,
           RANK() OVER (PARTITION BY category_name ORDER BY total_net_revenue DESC) AS position
    FROM product_revenue
)
SELECT category_name, product_name, total_units_sold, total_net_revenue, position
FROM ranked_products
WHERE position <= 3;

-------------------------------------------------
-- --TASK 6: Monthly Sales Trend
Create a monthly sales trend for completed orders.

----NOT PRACTICE THIS QUESTION----


-------------------------------------------------
-- TASK 7: Reusable Reporting View

-------------------------------------------------
---NOT PRACTICE THIS QUESTION

-------------------------------------------------
-- TASK 8: Safe Data Modification
A customer with customer_id = 1 has requested that their phone number be changed to '(999) 555-0101'.

Write SQL that performs this update inside an explicit transaction. Include a validation query after the UPDATE and show how the change can be rolled back during testing so the assessment database is not permanently changed.

-------------------------------------------------------
BEGIN TRANSACTION;

UPDATE sales.customers
SET phone = '(999) 555-0101'
WHERE customer_id = 1;

-- Validation
SELECT customer_id, first_name, last_name, phone
FROM sales.customers
WHERE customer_id = 1;

-- Rollback for testing
ROLLBACK;

-------------------------------------------------
-- TASK 9: Store Sales Procedure
------------------------------------------------
---NOT PRACTICE THIS QUESTION---

----------------------------------------------
-- TASK 10: Management Insight Query
Write one additional SQL query that you believe would provide useful insight to BikeStores management using at least three tables.

Below the query, add a SQL comment of no more than three lines explaining:
1. the business question,
2. what the result measures, and
3. why management should care about it.

--------------------------------------------------
SELECT 
    b.brand_name,
    c.category_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS brand_category_revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories c ON p.category_id = c.category_id
WHERE o.order_status = 4
GROUP BY b.brand_name, c.category_name
ORDER BY brand_category_revenue DESC;
