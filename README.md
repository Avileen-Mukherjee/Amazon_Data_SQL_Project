---

# **Amazon USA Sales Analysis Project - SQL **
---

## **Project Overview**
I have worked on analyzing a dataset of over 20,000 sales records from an Amazon-like e-commerce platform using PostgreSQL. This project involved extensive querying to understand customer behavior, product performance, and sales trends. Through it, I tackled various SQL challenges, including revenue analysis, customer segmentation, and inventory management.

The project also emphasized data cleaning, managing null values, and applying structured queries to solve real-world business problems.

An ERD diagram was created to provide a clear visual representation of the database schema and table relationships.


---
## **Objective**

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations
--
## ** SQL Concepts Used **
Joins , case statements , window functions - Rank , Dense Rank , Lag , Group By , Having , Subqueries.
## ** Key Insights **
High-Value Customers: The top 10 customers contribute significantly to the overall revenue, indicating the importance of customer retention strategies.

Payment Efficiency: The payment success rate provides insights into the reliability of the payment processing system.

Product Performance: Identifying top-selling products helps in inventory management and marketing focus.

Return Rates: Products with high return rates may require quality assessment or better customer education.

Seller Contributions: Understanding which sellers generate the most revenue can inform partnership and commission strategies.

## **Database Setup & Design**

### **Schema Structure**

```sql
CREATE TABLE category
(
  category_id	INT PRIMARY KEY,
  category_name VARCHAR(20)
);

-- customers TABLE
CREATE TABLE customers
(
  customer_id INT PRIMARY KEY,	
  first_name	VARCHAR(20),
  last_name	VARCHAR(20),
  state VARCHAR(20),
  address VARCHAR(5) DEFAULT ('xxxx')
);

-- sellers TABLE
CREATE TABLE sellers
(
  seller_id INT PRIMARY KEY,
  seller_name	VARCHAR(25),
  origin VARCHAR(15)
);

-- products table
  CREATE TABLE products
  (
  product_id INT PRIMARY KEY,	
  product_name VARCHAR(50),	
  price	FLOAT,
  cogs	FLOAT,
  category_id INT, -- FK 
  CONSTRAINT product_fk_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

-- orders
CREATE TABLE orders
(
  order_id INT PRIMARY KEY, 	
  order_date	DATE,
  customer_id	INT, -- FK
  seller_id INT, -- FK 
  order_status VARCHAR(15),
  CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT orders_fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_items
(
  order_item_id INT PRIMARY KEY,
  order_id INT,	-- FK 
  product_id INT, -- FK
  quantity INT,	
  price_per_unit FLOAT,
  CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- payment TABLE
CREATE TABLE payments
(
  payment_id	
  INT PRIMARY KEY,
  order_id INT, -- FK 	
  payment_date DATE,
  payment_status VARCHAR(20),
  CONSTRAINT payments_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shippings
(
  shipping_id	INT PRIMARY KEY,
  order_id	INT, -- FK
  shipping_date DATE,	
  return_date	 DATE,
  shipping_providers	VARCHAR(15),
  delivery_status VARCHAR(15),
  CONSTRAINT shippings_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory
(
  inventory_id INT PRIMARY KEY,
  product_id INT, -- FK
  stock INT,
  warehouse_id INT,
  last_stock_date DATE,
  CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
  );
```

---

## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---
--- Business Problems -
--- Advance Analysis
-----------------------------------------------------------------
--- Problem 1
-- Top Selling Products
-- Query the top 10 products by total sales value.
-- Challenge: Include product name, total quantity sold, and total sales value.

select * from order_items;

-- Creating the Column Total Sales

Alter table order_items
Add column total_sales Float;

-- updating TOTAL SALES COLUMN AS price qty * price per unit 

update order_items
set total_sales = quantity * price_per_unit;
select * from order_items;
-- Applying Inner Join ( simple Join )
Select
oi.product_id, -- Table 1
p.product_name, -- Table 2
sum(oi.total_sales) as Total_sales,
count(o.order_id) as total_unit_orders
from orders as o -- Table 3
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN
products as P
ON p.product_id= oi.product_id
Group By 1,2
Order by 3 desc
limit 10;

--------------------------------------------------------------------
--- Problem 2 
-- Revenue by Category
-- Calculate total revenue generated by each product category.
-- Challenge: Include the percentage contribution of each category to total revenue.

Select p.category_id,
c.category_name,
sum(oi.total_sales) as total_sales,
sum(oi.total_sales)/(select sum(total_sales) From order_items) * 100 as percentage_contribution -- subquery
FROM order_items as oi
JOIN
products as p
ON p.product_id = oi.product_id
LEFT JOIN category as c --Left Join to ensure selection of all the product category that has done some sales. ( Inner Join Could work here as well)
ON c.category_id = p.category_id
Group by 1,2
order by 3 Desc;
-------------------------------------------------------------------------------
-- Problem 3
-- Average Order Value (AOV)
-- Compute the average order value for each customer.
-- Challenge: Include only customers with more than 5 orders.

select 
c.customer_id,
concat (c.first_name , ' ', c.last_name) as Full_name,
Sum (total_sales) / Count(o.order_id) as Avg_Order_Value,
Count (o.order_id) as Total_orders -- filter
from orders as o
Join
customers as c
ON c.customer_id = o.order_id
JOIN
order_items as oi
ON oi.order_id = o.order_id
Group By 1, 2
having Count(o.order_id) > 5 ;

-----------------------------------------------------------------------------
-- Problem 4
-- Monthly Sales Trend
-- Query monthly total sales over the past year.
-- Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!
 
SELECT 
  month,
  year, 
  total_sales AS current_month_sales,
  LAG(total_sales, 1) OVER (ORDER BY year, month) AS last_month_sale
FROM (
  SELECT 
    EXTRACT(MONTH FROM o.order_date) AS month,
    EXTRACT(YEAR FROM o.order_date) AS year,
    ROUND(SUM(oi.total_sales::NUMERIC), 2) AS total_sales
  FROM orders AS o
  JOIN order_items AS oi
  ON oi.order_id = o.order_id
  WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
  GROUP BY 1, 2
) AS t1
ORDER BY year, month ASC;

-------------------------------------------------------------------------------------
-- Problem 5 Customers with No Purchases
-- Find customers who have registered but never placed an order.
-- Challenge: List customer details and the time since their registration.


-- Approach 1
SELECT *
	-- reg_date - CURRENT_DATE
FROM customers
WHERE customer_id NOT IN (SELECT 
					DISTINCT customer_id
				FROM orders
				);


-- Approach 2
SELECT *
FROM customers as c
LEFT JOIN
orders as o
ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL
-------------------------------------------------------------------------------------------------------

-- Problem 6 Least-Selling Categories by State
-- Identify the least-selling product category for each state.
-- Challenge: Include the total sales for that category within each state.

WITH ranking_table AS (
  SELECT 
    c.state,
    cat.category_name,
    SUM(oi.total_sales) AS total_sales,
    RANK() OVER (PARTITION BY c.state ORDER BY SUM(oi.total_sales) ASC) AS rank
  FROM orders AS o
  JOIN customers AS c ON o.customer_id = c.customer_id
  JOIN order_items AS oi ON o.order_id = oi.order_id
  JOIN products AS p ON oi.product_id = p.product_id
  JOIN category AS cat ON cat.category_id = p.category_id
  GROUP BY c.state, cat.category_name
)
SELECT *
FROM ranking_table
WHERE rank = 1;

----------------------------------------------------------------------------------------------------
-- Problem 7 Customer Lifetime Value (CLTV)
-- Calculate the total value of orders placed by each customer over their lifetime.
-- Challenge: Rank customers based on their CLTV

WITH customer_lifetime_value AS (
  SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.total_sales) AS lifetime_value
  FROM customers AS c
  JOIN orders AS o ON c.customer_id = o.customer_id
  JOIN order_items AS oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
  customer_id,
  customer_name,
  lifetime_value,
  RANK() OVER (ORDER BY lifetime_value DESC) AS rank
FROM customer_lifetime_value;
----------------------------------------------------------------------------------------------------------
-- Problem 8 Inventory Stock Alerts
-- Query products with stock levels below a certain threshold (e.g., less than 10 units).
-- Challenge: Include last restock date and warehouse information.

SELECT 
	i.inventory_id,
	p.product_name,
	i.stock as current_stock_left,
	i.last_stock_date,
	i.warehouse_id
FROM inventory as i
join 
products as p
ON p.product_id = i.product_id
WHERE stock < 10 ;
--------------------------------------------------------------------------------------------------------------

-- Problem 9 Payment Success Rate 
-- Calculate the percentage of successful payments across all orders.
-- Challenge: Include breakdowns by payment status (e.g., failed, pending).


SELECT 
	p.payment_status,
	COUNT(*) as total_cnt,
	COUNT(*)::numeric/(SELECT COUNT(*) FROM payments)::numeric * 100 as Percentage
FROM orders as o
JOIN
payments as p
ON o.order_id = p.order_id
GROUP BY 1

--------------------------------------------------------------------------------------------------------------
-- Problem 10 Most Returned Products
-- Query the top 10 products by the number of returns.

SELECT 
	p.product_id,
	p.product_name,
	COUNT(*) as total_unit_sold,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returned,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric/COUNT(*)::numeric * 100 as return_percentage
FROM order_items as oi
JOIN 
products as p
ON oi.product_id = p.product_id
JOIN orders as o
ON o.order_id = oi.order_id
GROUP BY 1, 2
ORDER BY 5 DESC ;

----------------------------------------------------------------------------------------------------------------------
/*
11. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
*/
select *, s.shipping_date - o.order_date as Shipped_After
from orders as o 
join customers c on c.customer_id = o.customer_id 
join shippings as S on o.order_id = s.order_id where (s.shipping_date - o.order_date) > 3 ;
----------------------------------------------------------------------------------------------------------------------
/*
12. Top Performing Sellers
Find the top 5 sellers based on total sales value.
*/


select se.seller_id ,se.seller_name, sum(oi.total_sales) as  Total_sales 
from order_items oi 

join orders o on oi.order_id = o.order_id 
join products p on oi.product_id = p.product_id 
join sellers se on o.seller_id = se.seller_id

group by 1, 2 order by 3 desc limit 5  ;

--------------------------------------------------------------------------------------------------------------------------
