/*
===============================================================================
PRODUCT REPORT
===============================================================================
Purpose:
    - Consolidate product-level information, performance, and key metrics.
    - Provide a single report for product analysis and segmentation.

Highlights:
    1. Retrieves product details such as name, category, subcategory, and cost.
    2. Segments products based on total revenue performance.
    3. Aggregates product-level metrics:
        - Total orders
        - Total sales
        - Total quantity sold
        - Total unique customers
        - Product lifespan
    4. Calculates additional KPIs:
        - Recency
        - Average selling price
        - Average order revenue
        - Average monthly revenue
===============================================================================
*/


-- 1. BASE QUERY
-- Combines product information with sales transactions
-- Serves as the foundation for product-level analysis

create view gold.report_products as
With base_query as (
SELECT
p.Product_Key,
p. Product_name,
p.Category,
p.Subcategory,
p.Cost,
f.Sales,
f.Quantity,
f.Customer_key,
f.Order_date,
f.Order_number
 from
gold.fact_sales f
left join gold.dim_products p
on p.Product_Key = f.Product_Key
where Order_date is not null)


-- 2. PRODUCT AGGREGATION
-- Summarizes transaction-level data into product-level metrics
-- Provides an overview of each product's sales performance and activity

  ,product_aggregation as (
SELECT
Product_Key,
Product_name,
Category,
Subcategory,
Cost,
DATEDIFF(month, MIN(Order_date), MAX(Order_date)) as lifespan,
Max(Order_date) as last_sale_date,
Count(distinct Order_number) as total_order,
Count(distinct Customer_Key) as total_customer,
SUM(Sales) as total_sales,
Sum(Quantity) as total_quantity,
Round(avg(Cast(Sales as float) / nullif(Quantity, 0)), 1)as average_selling_price
from base_query
group by
Product_Key,
Product_name,
Category,
Subcategory,
Cost)


-- 3. FINAL PRODUCT REPORT
-- Combines product attributes, aggregated metrics, segmentation, and KPIs
-- Creates a complete product-level analytical report

select
Product_Key,
Product_name,
Category,
Subcategory,
Cost,
last_sale_date,

-- RECENCY
-- Calculates the number of months since the product was last sold

datediff(month,last_sale_date,GETDATE()) as recency_months,

total_sales,

-- PRODUCT SEGMENTATION
-- Classifies products based on their total revenue performance

case when total_sales >50000 then 'High Performer'
when total_sales >=10000 then 'Mid Range'
else 'Low Perfomer'
end as product_segment,

lifespan,
total_order,
total_customer,
total_quantity,
average_selling_price,


-- AVERAGE ORDER REVENUE (AOR)
-- Calculates the average revenue generated per order

case
 when total_order = 0 then 0
 else total_sales /total_order 
 end as avg_order_revenue,


-- AVERAGE MONTHLY REVENUE
-- Calculates the average revenue generated per month
-- Uses total sales when the product lifespan is zero

case 
 when lifespan = 0 then total_sales
else 
total_sales / lifespan 
end as avg_monthly_reveue

from product_aggregation
