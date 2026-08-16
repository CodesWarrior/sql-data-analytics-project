/* PRODUCT SEGMENTATION
   Segment products into different cost ranges and count how many products
   fall into each segment.

   This helps understand the distribution of products across different
   pricing/cost levels.
*/


-- CREATE PRODUCT COST SEGMENTS
-- Categorize products based on their cost range

with segments_data as(
SELECT Product_Key,Product_name, 
Cost,
CASE WHEN Cost < 100 then 'Below 100'
WHEN Cost BETWEEN 100 AND 500 THEN '100-500'
WHEN Cost Between 500 and 1000 then '500-1000'
else 'Above 1000'
end cost_range
 from gold.dim_products) 

-- COUNT PRODUCTS IN EACH COST SEGMENT
-- Shows how products are distributed across the different cost ranges

 SELECT 
 cost_range,
 count(Product_Key) total_products
 from segments_data
 group by cost_range
 order by total_products desc;


/* CUSTOMER SEGMENTATION
   Group customers into three segments based on their spending behavior
   and relationship duration:

   VIP     → At least 12 months of history and spending more than 5,000
   Regular → At least 12 months of history and spending 5,000 or less
   New     → Less than 12 months of history

   This segmentation helps identify valuable customers and understand
   the overall customer base.
*/


-- CALCULATE CUSTOMER SPENDING AND LIFESPAN
-- Determine each customer's total spending, order history, and lifespan

with customer_spending as (
SELECT c.Customer_key,
Sum(Sales) as total_sales,
Min(Order_date) as first_order,
Max(Order_date) as Last_order,
DATEDIFF(Month,Min(Order_date),Max(Order_date)) as life_span
from gold.fact_sales f
left join gold.dim_customer c
on f.Customer_key = c.Customer_key
group by c.Customer_key)

-- CLASSIFY CUSTOMERS INTO SEGMENTS
-- Assign each customer to VIP, Regular, or New based on spending and lifespan

-- subquery , this is the finalllll resultttttttttttttttttttttttt
select
customer_segs,
count(Customer_key) as total_customers
from(
select
Customer_key,
CASE WHEN life_span > 12 and total_sales >5000 then 'VIP'
WHEN life_span >= 12 and total_sales <=5000 then 'Regular'
else 'New'
end as customer_segs
from customer_spending)t

-- COUNT CUSTOMERS BY SEGMENT
-- Shows the size of each customer segment
Group by customer_segs
Order by total_customers DESC;
