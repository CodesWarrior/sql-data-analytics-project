-- CHANGE OVER TIME
-- ANALYZE HOW A MEASURE EVOLVES OVER TIME
-- Helps identify trends, growth, decline, and seasonal patterns

-- ANALYZE SALES PERFORMANCE OVER TIME
-- Monthly analysis of sales, customers, and quantity sold
SELECT
year(Order_date) as order_year,
	Datetrunc(month, Order_date) as order_date,
sum(Sales) as total_Sales,
Count(Distinct Customer_key)  as total_customer,
Sum(Quantity) as total_quantity
from gold.fact_sales
Where Order_date is not Null
Group by 	Datetrunc(month, Order_date),year(Order_date)
order by 	Datetrunc(month, Order_date),year(Order_date) asc

-- CHANGES OVER YEARS A HIGH LEVEL OVERVIEW INSIGHTS THAT HELPS WITH STRATEGIC DECISION-MAKING

-- USING FORMAT
-- FORMAT() displays the date in a more readable Year-Month format

-- ANALYZE SALES PERFORMANCE OVER TIME
SELECT
year(Order_date) as order_year,
	FORMAT(Order_date, 'yyyy-MMM') as order_date,
sum(Sales) as total_Sales,
Count(Distinct Customer_key)  as total_customer,
Sum(Quantity) as total_quantity
from gold.fact_sales
Where Order_date is not Null
Group by FORMAT(Order_date,'yyyy-MMM') ,year(Order_date)
order by FORMAT(Order_date,'yyyy-MMM') ,year(Order_date) asc

