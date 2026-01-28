CREATE DATABASE mydatabase;
use mydatabase;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);


select * from orders;


-- find top 10 highest reveue generating products
select product_id,sum(sale_price) as sales
from orders
group by product_id
order by sales DESC
limit 10;

-- find top 5 highest selling products in each region 
select distinct region from orders; 

with cte as(
select region,product_id,sum(sale_price) as sales
from orders
group by region,product_id)
select *,
row_number() over(partition by region order by sales desc)as rn
from cte;

-- for top 5
with cte as(
select region,product_id,sum(sale_price) as sales
from orders
group by region,product_id)
select * from (
select *,
row_number() over(partition by region order by sales desc)as rn
from cte)A
where rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
select distinct year(order_date) from orders;

select year(order_date) as order_year,
month(order_date) as order_month,
sum(sale_price) as sales
from orders
group by year(order_date),month(order_date)
order by year(order_date),month(order_date)

with cte as (
select year(order_date) as order_year,
month(order_date) as order_month,
sum(sale_price) as sales
from orders
group by year(order_date),month(order_date)
-- order by year(order_date),month(order_date)
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

-- for each category which month had highest sales

select category,
DATE_FORMAT(order_date, '%Y %m')  as order_year_month,
sum(sale_price) as sales
from orders
group by category,DATE_FORMAT(order_date, '%Y %m')
order by category,DATE_FORMAT(order_date, '%Y %m')

with cte as(
select category,
DATE_FORMAT(order_date, '%Y %m')  as order_year_month,
sum(sale_price) as sales
from orders
group by category,DATE_FORMAT(order_date, '%Y %m')
-- order by category,DATE_FORMAT(order_date, '%Y %m')
)
select * from(
select *,
row_number() over(partition by category order by sales desc)as rn
from cte) a
where rn = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,
year(order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category,year(order_date)
)
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category

-- growth
with cte as (
select sub_category,
year(order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category,year(order_date)
),
cte2 as(
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select * ,
(sales_2023 - sales_2022)*100 / sales_2022
from cte2
order by (sales_2023 - sales_2022)*100 / sales_2022 desc
limit 1