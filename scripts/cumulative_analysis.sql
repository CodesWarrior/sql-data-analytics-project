-- CUMULATIVE ANALYSIS
-- Calculate total sales over time and track the running total
-- Helps identify overall growth and accumulated business performance


-- RUNNING TOTAL RESET EVERY YEAR
-- Running total starts again at the beginning of each year
-- Useful for comparing sales progression within each year

select 
order_date,
total_sales,
sum(total_sales) over(partition by year(order_date) order by order_date) as running_total from ( -- windowssss function
SELECT
DATETRUNC(month,Order_date) as order_date,
sum(Sales) as total_sales
from gold.fact_sales 
where order_date is not null
group by DATETRUNC(month,Order_date)
) t


-- RUNNING TOTAL ACROSS ALL YEARS
-- Tracks cumulative sales continuously throughout the entire period
-- Also calculates the running average selling price

select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total, -- windowssss function
avg(avg_price) over(order by order_date) as running_avg_price from ( -- windowssss function
SELECT
DATETRUNC(year,Order_date) as order_date,
sum(Sales) as total_sales,
avg(Price) as avg_price
from gold.fact_sales 
where order_date is not null
group by DATETRUNC(year,Order_date)
) t
