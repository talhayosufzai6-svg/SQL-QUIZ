USE BikeStores;

 ---sales.customers (customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
select
    first_name,
    last_name,
    city,
    customer_id,
    phone,
    email,
    state,
    zip_code
FROM sales.customers;


--sales.orders (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)


SELECT 
    o.order_id,  
    o.order_date,
    customer_id,
    order_status,
    required_date,
    shipped_date,
    st.staff_id
FROM sales.orders o
JOIN sales.stores s 
ON o.store_id = s.store_id
JOIN sales.staffs st 
ON o.staff_id = st.staff_id;

---sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)


SELECT 
    oi.order_id,
    oi.item_id,
    oi.product_id,
    oi.quantity,
    oi.list_price,
    oi.discount
FROM sales.order_items AS oi;

          
    

-- 5. ORDERS + ORDER_ITEMS + CUSTOMER FULL DETAIL
SELECT 
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS line_total,
    o.order_date
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN production.products p ON oi.product_id = p.product_id;

-- 6. SAB SE ZYADA BIKNE WALA PRODUCT
SELECT TOP 5
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM sales.order_items oi
JOIN production.products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC;


--  HAR PRODUCT KI TOTAL QUANTITY AUR REVENUE
SELECT 
    product_id,
    SUM(quantity) AS total_qty,
    SUM(quantity * list_price * (1 - discount)) AS total_revenue
FROM sales.order_items
GROUP BY product_id
ORDER BY total_revenue DESC;

SELECT * FROM sales.order_items
WHERE discount > 0;

---sales.stores (store_id, store_name, phone, email, street, city, state, zip_code)

select  store_id, 
        store_name, phone, email, street, city, state, zip_code
from sales.stores as s;

--sales.staffs (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)

select staff_id,
       first_name, last_name, 
       email,
       phone,
       active,
       store_id,
       manager_id
from sales.staffs;

--production.products (product_id, product_name, brand_id, category_id, model_year,

select product_id, product_name, brand_id, category_id, model_year, list_price
from production.products;
---production.categories (category_id, category_name
select category_id, 
       category_name
from production.categories;

--production.brands (brand_id, brand_name
select  brand_id, brand_name
from production.brands;

--production.stocks (store_id, product_id, quantity
select  store_id, product_id, quantity
from production.stocks;

----(LIKE, IN, ORDER BY with multiple columns) Return the first_name, last_name and city of customers
--who live in the state NY or CA, whose email ends in .com 
----and whose last_name starts with the letter M. Sort by city ascending, then last_name ascending.

SELECT first_name, last_name, city
FROM sales.customers
WHERE state IN ('NY', 'CA')
  AND email LIKE '%.com'
  AND last_name LIKE 'M%'
ORDER BY city ASC, last_name ASC;

--Q2. (Aliases, calculated column, ORDER BY, pagination) Show product_name, list_price and a calculated column called discounted_price (
--10% off) for products with a list_price above 500. Skip the 10 most expensive products 
--and return the next 10 (the 11th to 20th most expensive).

SELECT product_name, list_price, list_price * 0.90 AS discounted_price
FROM production.products AS p
WHERE list_price > 500
ORDER BY list_price DESC, product_id ASC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;


-- Q3. (NULL, BETWEEN, AND/OR precedence) Find all orders that are either Pending or Processing, have not shipped yet,
-- and were placed between 2018-01-01 and 2018-06-30.
-- Return order_id, order_date, required_date and order_status. Group the AND/OR logic explicitly.


SELECT order_id, order_date, required_date, order_status
FROM sales.orders
WHERE (order_status = 1 OR order_status = 2)
    AND shipped_date IS NULL
    AND order_date BETWEEN '2018-01-01' AND '2018-06-30';


