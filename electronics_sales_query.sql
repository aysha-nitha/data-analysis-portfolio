-- =========================================
-- 1. DATA CLEANING
-- =========================================

-- Check for NULL values
SELECT *
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
WHERE `Order Date` IS NULL 
  OR `Product Name` IS NULL
  OR Category = 'NULL'
  OR Region = 'NULL'
  OR Quantity = 0
  OR Sales = 0
  OR Profit = 0;


-- =========================================
-- 2. KPI METRICS
-- =========================================

-- Overall KPIs
SELECT 
  SUM(Sales) AS total_revenue,
  ROUND(SUM(Profit),2) AS total_profit,
  SUM(Quantity) AS total_units_sold,
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,3) AS profit_margin,
  ROUND(SAFE_DIVIDE(SUM(Sales), SUM(Quantity)),2) AS avg_price_per_item
FROM `trim-glazing-478812-b5.salesdata.officesupplies`;


-- =========================================
-- 3. BUSINESS INSIGHTS
-- =========================================

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


-- Top Selling Products (High revenue product)
SELECT DISTINCT(`Product Name`) AS Product_Name,
  Category,
  SUM(Sales) AS total_sales
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name, Category
ORDER BY total_sales DESC;


-- Most Profitable Products
SELECT DISTINCT(`Product Name`) AS Product_Name,
  Category,
  ROUND(SUM(Profit), 2) AS sum_profit
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name, Category
ORDER BY sum_profit DESC;


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


-- =========================================
-- 4. TREND ANALYSIS
-- =========================================

-- Yearly Sales Trend
SELECT
  Extract(Year from `Order Date`) AS Year,
  SUM(Sales) AS total_revenue,
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Year
ORDER BY total_revenue DESC;


-- Monthly trend
SELECT
  EXTRACT(MONTH FROM `Order Date`) AS month_num,
  FORMAT_DATE('%b', `Order Date`) AS Month,
  SUM(Sales) AS total_revenue
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY month_num, month
ORDER BY month_num;


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


-- =========================================
-- 5. ADVANCED ANALYSIS
-- =========================================

-- Pivot: Category Sales by Year
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


-- Pivot: Category Sales by Region
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


-- Profitability by Product
SELECT
  `Product Name` AS Product_Name,
  SUM(Sales) AS total_revenue,
  ROUND(SUM(Profit),2) AS total_profit,
  ROUND(SAFE_DIVIDE(SUM(Profit),SUM(Sales)) * 100, 2) AS profit_margin_percentage
FROM `trim-glazing-478812-b5.salesdata.officesupplies`
GROUP BY Product_Name
ORDER BY profit_margin_percentage DESC;