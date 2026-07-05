/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 01_basic_queries.sql
Covers: SELECT, TOP, ORDER BY, WHERE, AND/OR, DISTINCT, Aliases
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 1: Snapshot of transaction-level data
-- ============================================
-- Business Question: What do individual sales transactions look like?
-- Explanation: Pulls 10 sample rows with key business columns only.
-- Business Insight: Establishes transaction-level granularity (1 row = 1 product per order).
-- ============================================
SELECT TOP 10
    Order_ID,
    Order_Date,
    Customer_Name,
    Category,
    Sub_Category,
    Sales,
    Profit
FROM orders;


-- ============================================
-- Query 2: Top 10 highest-value transactions
-- ============================================
-- Business Question: What are our 10 highest-value single sales transactions?
-- Explanation: Sorts all rows by Sales descending, then takes the top 10.
-- Business Insight: Identifies "whale" transactions and whether they are also profitable.
-- ============================================
SELECT TOP 10
    Order_ID,
    Customer_Name,
    Product_Name,
    Sales,
    Profit
FROM orders
ORDER BY Sales DESC;


-- ============================================
-- Query 3: Loss-making transactions
-- ============================================
-- Business Question: Which transactions resulted in a financial loss?
-- Explanation: Filters to rows where Profit is negative, worst losses first.
-- Business Insight: First evidence linking heavy discounting to losses.
-- ============================================
SELECT
    Order_ID,
    Customer_Name,
    Category,
    Sub_Category,
    Sales,
    Discount,
    Profit
FROM orders
WHERE Profit < 0
ORDER BY Profit ASC;


-- ============================================
-- Query 4: High-value Technology sales in the West region
-- ============================================
-- Business Question: Which Technology sales in the West region exceeded $500?
-- Explanation: Combines three AND conditions in the WHERE clause.
-- Business Insight: Lets a regional manager drill into high-value Technology deals.
-- ============================================
SELECT
    Order_ID,
    Customer_Name,
    Region,
    Category,
    Sales,
    Profit
FROM orders
WHERE Category = 'Technology'
  AND Region = 'West'
  AND Sales > 500
ORDER BY Sales DESC;


-- ============================================
-- Query 5: Unique product taxonomy
-- ============================================
-- Business Question: What are all unique Category / Sub-Category combinations we sell?
-- Explanation: DISTINCT removes duplicate rows across the two columns.
-- Business Insight: Gives the full product "menu" structuring later analysis.
-- ============================================
SELECT DISTINCT
    Category,
    Sub_Category
FROM orders
ORDER BY Category, Sub_Category;


-- ============================================
-- Query 6: Transaction-level profit margin %
-- ============================================
-- Business Question: What is the profit margin percentage for each transaction?
-- Explanation: Calculates (Profit / Sales) * 100, aliased for readability.
--              NULLIF guards against divide-by-zero if Sales = 0.
-- Business Insight: Core KPI at transaction level; will be aggregated by
--                    category/region in later queries.
-- ============================================
SELECT
    Order_ID,
    Sales,
    Profit,
    (Profit / NULLIF(Sales, 0)) * 100 AS Profit_Margin_Percent
FROM orders
ORDER BY Profit_Margin_Percent DESC;
