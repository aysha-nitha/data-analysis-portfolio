-- Check for NULL values
SELECT *
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
WHERE `Order Date` IS NULL 
  OR `Product Name` = 'NULL'
  OR Category = 'NULL'
  OR Region = 'NULL'
  OR Quantity = 0
  OR Sales = 0
  OR Profit = 0;


-- Total Revenue
SELECT
  SUM(Sales) AS total_revenue
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;


-- Total Profit
SELECT
  ROUND(SUM(Profit),2) AS total_profit
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;


-- Total Units Sold
SELECT
  SUM(Quantity) AS total_units_sold
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;



-- High Profit Products
SELECT DISTINCT(`Product Name`) AS Product_Name,
  Category,
  ROUND(SUM(Profit), 2) AS sum_profit
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name, Category
ORDER BY sum_profit DESC;


-- Top Selling Products (High revenue product)
SELECT DISTINCT(`Product Name`) AS Product_Name,
  Category,
  SUM(Sales) AS total_sales
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name, Category
ORDER BY total_sales DESC;


-- Top Product in each region
SELECT Region, Product_Name, total_sales
FROM(
  SELECT Region,
  `Product Name` as Product_Name,
  SUM(Sales) as total_sales,
  RANK() OVER (PARTITION BY Region ORDER BY SUM(Sales) DESC) as ranking
  FROM `trim-glazing-478812-b5.salesdata.officesupplies`
  GROUP BY Region, Product_Name
)
WHERE ranking = 1;


-- Total Revenue over the years
SELECT
  Extract(Year from `Order Date`) AS Year,
  SUM(Sales) AS total_revenue,
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Year
ORDER BY total_revenue DESC;


-- Year over year Revenue growth
SELECT 
  Year, 
  total_revenue, 
  LAG(total_revenue) OVER (ORDER BY Year) AS pre_revenue,
  SAFE_DIVIDE(total_revenue - LAG(total_revenue) OVER (ORDER BY Year), LAG (total_revenue) OVER (ORDER BY Year)) * 100 AS percent_growth

FROM
  (SELECT
    Extract(Year from `Order Date`) AS Year,
    SUM(Sales) AS total_revenue,
  FROM `trim-glazing-478812-b5.salesdata.officesupplies`
  GROUP BY Year); 


-- Pivot table with year, category, total_revenue to understand the category performance over the years
SELECT *
FROM
(SELECT
  EXTRACT(Year from `Order Date`) AS Year,
  Category,
  Sales,
FROM `trim-glazing-478812-b5.salesdata.officesupplies`)
PIVOT (
  SUM(Sales)
  FOR Category IN ('Electronics', 'Accessories', 'Office') 
)
ORDER BY Year;


-- Total Revenue for different categories in each region
SELECT *
FROM(
  SELECT
    Region,
    Category,
    Sales
  FROM `trim-glazing-478812-b5.salesdata.officesupplies`
)

PIVOT(
  SUM(Sales)
  For Category IN ('Electronics', 'Accessories', 'Office')
)
ORDER BY Region;



-- Profit Margin (%)
SELECT
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,3) AS profit_margin
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;


-- Monthly trend
SELECT
  FORMAT_DATE('%b', `Order Date`) AS Month,
  SUM(Sales) AS total_revenue
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Month
ORDER BY total_revenue DESC;


-- Sales by Region
SELECT Region,
  SUM(Sales) AS total_revenue
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Region
ORDER BY total_revenue DESC; 

-- Category Performance
SELECT
  Category,
  Sum(Sales) AS total_revenue,
  ROUND(Sum(Profit),2) AS total_profit
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Category
ORDER BY total_profit DESC; 


-- Average Price per Item
SELECT 
  ROUND(SAFE_DIVIDE(SUM(Sales), SUM(Quantity)),2) AS avg_price_per_item
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;



-- Profitability by Product
SELECT
  `Product Name` AS Product_Name,
  SUM(Sales) AS total_revenue,
  ROUND(SUM(Profit),2) AS total_profit,
  ROUND(SAFE_DIVIDE(SUM(Profit),SUM(Sales)) * 100, 2) AS profit_margin_percentage
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name
ORDER BY profit_margin_percentage DESC;
