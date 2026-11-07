-- ============================================
-- SQL Server — Class 4 Homework
-- BikeStores Sample Database
-- Topics: SELECT · Filtering · JOIN · GROUP BY
-- ============================================

-- Q1: Show product name, model year, and list price for all products
-- from model year 2017 or 2018 whose name contains the word 'Electra'.
-- Sort by product name.
SELECT 
    product_name,
    model_year,
    list_price
FROM [production].[products]
WHERE (model_year = 2017 OR model_year = 2018)
  AND product_name LIKE '%Electra%'
ORDER BY product_name ASC;

-- Q2: Find customers who have a phone number on file AND an email
-- ending in '@yahoo.com'. Show full name, email, and city.
-- Sort by city, then by last name.
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    city
FROM sales.customers
WHERE phone IS NOT NULL 
  AND email LIKE '%@yahoo.com'
ORDER BY 
    city ASC, 
    last_name ASC;

-- Q3: For orders placed in 2017 that have already shipped, show order ID,
-- order date, shipped date, and a computed column "Days To Ship"
-- (days between order date and shipped date).
-- Show only the 10 slowest shipments.
SELECT TOP 10
    order_id,
    order_date,
    shipped_date,
    DATEDIFF(day, order_date, shipped_date) AS [Days To Ship]
FROM sales.orders
WHERE order_date >= '2017-01-01' 
  AND order_date <= '2017-12-31'
  AND shipped_date IS NOT NULL
ORDER BY [Days To Ship] DESC;

-- Q4: List all products that are OUT OF STOCK (quantity = 0) at the
-- store "Baldwin Bikes". Show product name, brand name, and quantity.
-- Sort by product name.
SELECT 
    P.product_name,
    B.brand_name,
    S.quantity
FROM production.products AS P
INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id
INNER JOIN production.stocks AS S
    ON P.product_id = S.product_id
INNER JOIN sales.stores AS ST
    ON S.store_id = ST.store_id
WHERE ST.store_name = 'Baldwin Bikes'
  AND S.quantity = 0
ORDER BY P.product_name ASC;

-- Q5: For orders placed in 2018, show order ID, customer full name,
-- product name, and the discounted line total
-- (quantity × list_price × (1 – discount)) for every order item with
-- a discount of 20% or more. Sort by line total descending.
SELECT 
    O.order_id,
    CONCAT(C.first_name, ' ', C.last_name) AS customer_full_name,
    P.product_name,
    (OI.quantity * OI.list_price * (1 - OI.discount)) AS line_total
FROM sales.orders AS O
INNER JOIN sales.customers AS C
    ON O.customer_id = C.customer_id
INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id
INNER JOIN production.products AS P
    ON OI.product_id = P.product_id
WHERE YEAR(O.order_date) = 2018
  AND OI.discount >= 0.20
ORDER BY line_total DESC;

-- Q6: Find all staff members who have NEVER handled an order.
-- Show staff full name and the name of their store.
SELECT 
    CONCAT(S.first_name, ' ', S.last_name) AS staff_full_name,
    ST.store_name
FROM sales.staffs AS S
INNER JOIN sales.stores AS ST
    ON S.store_id = ST.store_id
LEFT JOIN sales.orders AS O
    ON S.staff_id = O.staff_id
WHERE O.order_id IS NULL;

-- Q7: Find all customers who have bought at least one product from
-- the brand "Trek". Show each customer's full name and city once only.
-- Sort by full name.
SELECT DISTINCT
    CONCAT(C.first_name, ' ', C.last_name) AS customer_full_name,
    C.city
FROM sales.customers AS C
INNER JOIN sales.orders AS O
    ON C.customer_id = O.customer_id
INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id
INNER JOIN production.products AS P
    ON OI.product_id = P.product_id
INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id
WHERE B.brand_name = 'Trek'
ORDER BY customer_full_name ASC;

-- Q8: Using CROSS JOIN, generate every possible combination of
-- store name and category name. Sort by store name, then category name.
SELECT 
    ST.store_name,
    C.category_name
FROM sales.stores AS ST
CROSS JOIN production.categories AS C
ORDER BY 
    ST.store_name ASC, 
    C.category_name ASC;

-- Q9: Show the total number of units sold for each product category.
-- Display category name and total units. Sort by total units descending.
SELECT 
    C.category_name,
    SUM(OI.quantity) AS total_units
FROM production.categories AS C
INNER JOIN production.products AS P
    ON C.category_id = P.category_id
INNER JOIN sales.order_items AS OI
    ON P.product_id = OI.product_id
GROUP BY C.category_name
ORDER BY total_units DESC;

-- Q10: Show the number of orders placed per store per year.
-- Display store name, order year, and order count.
-- Sort by store name, then year.
SELECT 
    ST.store_name,
    YEAR(O.order_date) AS order_year,
    COUNT(O.order_id) AS order_count
FROM sales.stores AS ST
INNER JOIN sales.orders AS O
    ON ST.store_id = O.store_id
GROUP BY 
    ST.store_name,
    YEAR(O.order_date)
ORDER BY 
    ST.store_name ASC, 
    order_year ASC;

-- Q11: For each staff member, count the orders they handled.
-- Show staff full name and order count, but only for staff who handled
-- MORE THAN 100 orders. Sort by order count descending.
SELECT 
    CONCAT(S.first_name, ' ', S.last_name) AS staff_full_name,
    COUNT(O.order_id) AS order_count
FROM sales.staffs AS S
INNER JOIN sales.orders AS O
    ON S.staff_id = O.staff_id
GROUP BY 
    S.first_name, 
    S.last_name
HAVING COUNT(O.order_id) > 100
ORDER BY order_count DESC;

-- Q12: Find customers whose total spending
-- (SUM of quantity × list_price × (1 – discount)) is above $10,000.
-- Show customer full name and total spent (rounded to 2 decimals).
-- Sort by total spent descending.
SELECT 
    CONCAT(C.first_name, ' ', C.last_name) AS customer_full_name,
    ROUND(SUM(OI.quantity * OI.list_price * (1 - OI.discount)), 2) AS total_spent
FROM sales.customers AS C
INNER JOIN sales.orders AS O
    ON C.customer_id = O.customer_id
INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id
GROUP BY 
    C.customer_id,
    C.first_name, 
    C.last_name
HAVING SUM(OI.quantity * OI.list_price * (1 - OI.discount)) > 10000
ORDER BY total_spent DESC;

-- Q13: For each brand, show the average and maximum list price.
-- Keep only brands whose average price is above $1,000.
-- Show brand name, average price (2 decimals), and max price.
-- Sort by average price descending.
SELECT 
    B.brand_name,
    ROUND(AVG(P.list_price), 2) AS avg_price,
    MAX(P.list_price) AS max_price
FROM production.brands AS B
INNER JOIN production.products AS P
    ON B.brand_id = P.brand_id
GROUP BY B.brand_name
HAVING AVG(P.list_price) > 1000
ORDER BY avg_price DESC;

-- Q14: Show the total quantity in stock for each store and category
-- combination. Display store name, category name, and total quantity.
-- Sort by store name, then by total quantity descending.
SELECT 
    ST.store_name,
    C.category_name,
    SUM(S.quantity) AS total_quantity
FROM sales.stores AS ST
INNER JOIN production.stocks AS S
    ON ST.store_id = S.store_id
INNER JOIN production.products AS P
    ON S.product_id = P.product_id
INNER JOIN production.categories AS C
    ON P.category_id = C.category_id
GROUP BY 
    ST.store_name, 
    C.category_name
ORDER BY 
    ST.store_name ASC, 
    total_quantity DESC;

-- Q15 (BONUS): For the year 2017, show for each month:
-- month number, number of orders, and total revenue
-- (quantity × list_price × (1 – discount), rounded to 2 decimals).
-- Sort by month number.
SELECT 
    MONTH(O.order_date) AS month_number,
    COUNT(DISTINCT O.order_id) AS total_orders,
    ROUND(SUM(OI.quantity * OI.list_price * (1 - OI.discount)), 2) AS total_revenue
FROM sales.orders AS O
INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id
WHERE YEAR(O.order_date) = 2017
GROUP BY MONTH(O.order_date)
ORDER BY month_number ASC;