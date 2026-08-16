/* Analyze the yearly performance of products by comparing their sales
   to both the previous year's sales and the product's average sales performance.

   This analysis helps identify:
   - Year-over-year sales changes
   - Whether sales increased or decreased
   - Whether the product had sales in the previous year
   - Whether current sales are above, below, or equal to the product's average
*/


-- PREPARE YEARLY SALES DATA
-- Calculate total sales for each product per year

   WITH current_yearly_sales as(
   select
   year(f.Order_date) as order_year,
   p.Product_name as Product_name,
   sum(f.Sales) as current_sales
   from gold.fact_sales f
   left join gold.dim_products p
   on f.Product_Key = p.Product_Key
   where  year(f.Order_date) IS NOT NULL
   group by   year(f.Order_date),p.Product_name
  )


-- YOY ANALYSIS
-- Compare current year's sales with the previous year's sales
-- Helps identify yearly growth or decline

  select
  order_year,
  Product_name,
  current_sales,

  -- YOY ANALYSIS--
  Lag(current_sales) over(Partition by Product_name order by order_year) as prev_sales,
  current_sales - Lag(current_sales) over(Partition by Product_name order by order_year) as sales_dif,

  -- CLASSIFY SALES CHANGE
  -- Labels whether sales increased, decreased, or remained unchanged
  CASE WHEN current_sales - Lag(current_sales) over(Partition by Product_name order by order_year) > 0 THEN 'Increased'
  when current_sales - Lag(current_sales) over(Partition by Product_name order by order_year) < 0 THEN 'Decreased'
  else 'NO CHANGE'
  END diff_sales,

  -- CHECK IF THE PRODUCT HAD SALES IN THE PREVIOUS YEAR
  -- Identifies whether a previous-year sales value exists
  CASE WHEN Lag(current_sales) over(Partition by Product_name order by order_year) is NUll Then 'No sales prev year'
     else 'Has sales prev year'
     end as prev_year_sales_stats,

  -- AVERAGE SALES ANALYSIS
  -- Compare yearly sales against the product's average sales

  avg(current_sales) over(Partition by Product_name) as avg_sales,
  current_sales - avg(current_sales) over(Partition by Product_name)  as diff_avg_sales,

  -- CLASSIFY PERFORMANCE AGAINST AVERAGE
  -- Identifies whether current sales are above, below, or equal to average
  CASE WHEN
  current_sales - avg(current_sales) over(Partition by Product_name) > 0 then 'Above avg'
  WHEN current_sales - avg(current_sales) over(Partition by Product_name) < 0 then 'Below avg'
  else 'Average'
  end as diff_avg

  FROM current_yearly_sales
  order by  Product_name,order_year;
