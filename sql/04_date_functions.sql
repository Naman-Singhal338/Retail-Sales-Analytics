/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 04_date_functions.sql
Covers: DATEDIFF, YEAR, MONTH, DATENAME
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 16: Shipping delay per order
-- ============================================
-- Business Question: How many days does it typically take to ship an order,
--                     and are any shipments unusually slow?
-- Explanation: DATEDIFF(DAY, Order_Date, Ship_Date) calculates days between
--              the two dates.
-- Business Insight: Identifies operational bottlenecks in fulfillment.
-- ============================================
SELECT
    Order_ID,
    Order_Date,
    Ship_Date,
    DATEDIFF(DAY, Order_Date, Ship_Date) AS Shipping_Delay_Days
FROM orders
ORDER BY Shipping_Delay_Days DESC;


-- ============================================
-- Query 17: Average shipping delay by Ship Mode
-- ============================================
-- Business Question: What is the average shipping delay for each Ship Mode?
-- Explanation: Combines DATEDIFF with AVG and GROUP BY.
-- Business Insight: Validates whether shipping tiers deliver on their promise.
-- ============================================
SELECT
    Ship_Mode,
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Avg_Shipping_Delay,
    COUNT(*) AS Total_Orders
FROM orders
GROUP BY Ship_Mode
ORDER BY Avg_Shipping_Delay ASC;


-- ============================================
-- Query 18: Monthly sales trend across all years
-- ============================================
-- Business Question: What is our monthly sales trend across all 4 years -
--                     do we see the classic Q4 retail spike?
-- Explanation: YEAR() and MONTH() extract date parts; GROUP BY both creates
--              one bucket per calendar month per year.
-- Business Insight: Foundation of seasonality analysis for Phase 5/Tableau.
-- ============================================
SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Order_Year, Order_Month;


-- ============================================
-- Query 19: Orders by day of week
-- ============================================
-- Business Question: Which day of the week gets the most orders?
-- Explanation: DATENAME(WEEKDAY, Order_Date) converts date to a readable
--              day name for grouping.
-- Business Insight: Weekday-heavy ordering supports B2B-like (Corporate/
--                    Home Office) buying behavior.
-- ============================================
SELECT
    DATENAME(WEEKDAY, Order_Date) AS Order_Day,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Sales
FROM orders
GROUP BY DATENAME(WEEKDAY, Order_Date)
ORDER BY Total_Orders DESC;


-- ============================================
-- Query 20: Yearly sales totals (baseline for YoY growth)
-- ============================================
-- Business Question: What were our total sales each year (2014-2017)?
-- Explanation: Groups by YEAR(Order_Date) only. True YoY growth % requires
--              LAG() (a window function) - revisited in Milestone 3.5.
-- Business Insight: Sets baseline numbers for the growth-rate KPI next.
-- ============================================
SELECT
    YEAR(Order_Date) AS Order_Year,
    SUM(Sales) AS Total_Sales
FROM orders
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year;
