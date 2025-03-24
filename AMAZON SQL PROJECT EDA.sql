-- EDA
-- This is only fot training purpose data , not actual Amazon Data
select * from category ;
select * from customers ;
select * from Inventory;
select * from order_items;
select * from orders;
select * from payments;

-- distinct payment status
select Distinct 
payment_status from payments;

select * from products ;
select * from sellers;
select * from shippings;

-- Products that have been Returned
select * from shippings
where  return_date is not null ;

-- EDS ends Here.