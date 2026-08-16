/*
===============================================================================
CUSTOMER REPORT
===============================================================================
Purpose:
    - Consolidate customer-level information, behavior, and key metrics.
    - Provide a single report for customer analysis and segmentation.

Highlights:
    1. Retrieves customer and transaction details.
    2. Calculates customer age and groups customers by age.
    3. Segments customers into VIP, Regular, and New.
    4. Aggregates customer-level metrics:
        - Total orders
        - Total sales
        - Total quantity purchased
        - Total products purchased
        - Customer lifespan
    5. Calculates additional KPIs:
        - Recency
        - Average order value
        - Average monthly spend
===============================================================================
*/


-- 1. BASE QUERY
-- Combines customer and sales information into a single dataset
-- Serves as the foundation for the customer-level analysis

--create view gold.report_customers as
with Base_query  AS(
 SELECT
  f.Order_number,
  f.Product_Key,
  f.Order_date,
  f.Sales,
  f.Quantity,
  c.Customer_key,
  c.Customer_number,
  CONCAT(c.Firstname, ' ', c.Lastname) as Customer_name,
  DATEDIFF(year,c.Birthday, GETDATE()) AS age -- Calculate customer age
  FROM gold.fact_sales f
  Left join gold.dim_customer c
  ON c.Customer_key = f.Customer_key
  Where Order_date IS NOT NULL)


-- 2. CUSTOMER AGGREGATION
-- Aggregates transaction-level data into customer-level metrics
-- Provides a summary of each customer's purchasing behavior

  ,customer_aggreation AS( 
  -- Aggregates customer-level metrics
  SELECT
  Customer_key,
  Customer_number,
  Customer_name,
  age,
  COUNT(DISTINCT Order_number) as total_order,
  SUM(Sales) as total_sales,
  SUM(Quantity) as total_quantity,
  count(Distinct Product_Key) as total_products,
  MAX(Order_date) as recent_order,
  DATEDIFF(Month,Min(Order_date),Max(Order_date)) as life_span
  from Base_query
  Group by   Customer_key,
  Customer_number,
  Customer_name, age)


-- 3. CUSTOMER SEGMENTATION AND KPI CALCULATION
-- Classifies customers by age and spending behavior
-- Calculates additional customer performance metrics

  SELECT
  Customer_key,
  Customer_number,
  Customer_name,
  age,

  -- AGE SEGMENTATION
  -- Groups customers into age-based categories

  case when age >=60 then 'Senior Citizen'
       when age >=18  then 'Adults'
       when age >=12 then  'teen ager'
       else 'Kids'
       end as age_group,

  -- CUSTOMER SEGMENTATION
  -- Classifies customers based on lifespan and total spending

  CASE WHEN life_span > 12 and total_sales >5000 then 'VIP'
       WHEN life_span >= 12 and total_sales <=5000 then 'Regular'
       else 'New'
       end as customer_segs,

  recent_order,

  -- RECENCY
  -- Calculates the number of months since the customer's most recent order

  DATEDIFF(MONTH,recent_order,GETDATE()) as recent_orders,

  total_order,
  total_sales,
  total_quantity,
  total_products,
  life_span,


  -- AVERAGE ORDER VALUE
  -- Calculates the average amount spent per order
  -- Prevents division by zero when there are no orders

  case when total_order = 0 then 0
  else
  total_sales / total_order
  end as average_order_value,


  -- AVERAGE MONTHLY SPEND
  -- Calculates the customer's average spending per month
  -- Uses total sales when lifespan is zero

  case when life_span = 0 then total_sales
  else 
  total_sales / life_span 
  end as monthy_average_spend

 from customer_aggreation;
