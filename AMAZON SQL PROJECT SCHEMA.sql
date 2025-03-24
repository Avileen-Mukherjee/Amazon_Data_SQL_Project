-- Amazon Project- Advanced SQL
-- First Create The Parent Tables. Table 1, 2, 3 are the parent tables.
-- category TABLE ( Table 1)

Create Table Category 
(
category_id INT Primary Key,
category_name Varchar (30 )
);

-- Customers Table ( Table 2)

create Table customers 
( 
customer_id INT primary key,
first_name varchar (20),
last_name  varchar (20),
state varchar (20),
address varchar (5) default ( 'xxxx')
);

-- Sellers Table ( Table 3)

Create Table sellers (
seller_id INT Primary Key,
seller_name varchar(25),
origin Varchar (10)
);

-- Products table ( Table 4)
Create table products 
(
product_id INT primary key,
product_name Varchar (100),
price FLOAT,
cogs  FLOAT,
category_id  INT, -- FK
constraint product_fk_Category Foreign Key (category_id) references category (category_id)
);

-- Orders Table ( Table 5)

create table orders
(
order_id INT Primary Key , 
order_date date,
customer_id INT, -- FK
seller_id INT, -- FK
order_status Varchar (50),
constraint orders_fk_customers foreign key (customer_id) references customers  ( customer_id),
Constraint orders_fk_sellers foreign key (seller_id) references sellers ( seller_id)
);


-- Order Items Table ( Table 6)

Create Table order_items 
( 
 order_item_id int Primary Key,
order_id INT, -- FK
product_id INT, -- FK
quantity int,
price_per_unit FLOAT,
constraint order_items_fk_orders Foreign Key (order_id) references orders (order_id),
constraint order_items_fk_products Foreign Key (product_id) references products ( product_id)
);




-- Payment Table ( table 7)
Create Table payments
(
payment_id INT Primary Key,
order_id INT, --FK
payment_date Date,
payment_status Varchar (100),
Constraint payments_fk_orders Foreign Key (order_id) references orders (order_id)
);

-- Shipping Table ( table 8)

Create Table shippings 
(
shipping_id INT Primary Key,
order_id INT , -- FK
shipping_date DATE,
return_date DATE,
shipping_providers Varchar (15),
delivery_status Varchar (15),
Constraint shipping_fk_orders Foreign Key (order_id) references orders (order_id)
);

-- Inventory Table ( table 9)

Create Table inventory
(
inventory_id  int Primary KEY,
product_id INT, --FK
stock INT,
warehouse_id INT,
last_stock_date DATE,
CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- END OF SCHEMAS



