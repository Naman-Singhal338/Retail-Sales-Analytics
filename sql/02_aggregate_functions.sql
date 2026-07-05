/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 02_aggregate_functions.sql
Covers: Aggregate Functions (SUM/AVG/COUNT), GROUP BY, HAVING
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 7: Overall headline KPIs
-- ============================================
-- Business Question: What are our overall headline numbers - total sales,
--                     total profit, total orders, and average order value?
-- Explanation: COUNT(DISTINCT Order_ID) counts unique orders, not line-items.
--              SUM/AVG operate across all rows (no WHERE/GROUP BY).
-- Business Insight: These are the dashboard's headline KPI cards.
-- ============================================
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    AVG(Sales) AS Avg_Sale_Per_LineItem
FROM orders;


-- ============================================
-- Query 8: Sales and profit by Category
-- ============================================
-- Business Question: What is the total sales and profit for each Category?
-- Explanation: GROUP BY Category buckets rows by category, then SUM
--              calculates totals within each bucket.
-- Business Insight: Reveals whether the highest-revenue category is also
--                    the highest-profit category (often they are not).
-- ============================================
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM orders
GROUP BY Category
ORDER BY Total_Sales DESC;


-- ============================================
-- Query 9: Sales and profit by Category + Sub-Category
-- ============================================
-- Business Question: How do sales and profit break down by Sub-Category?
-- Explanation: GROUP BY with two columns creates a bucket per unique
--              Category/Sub-Category combination.
-- Business Insight: Surfaces "problem child" sub-categories with high sales
--                    but low/negative profit.
-- ============================================
SELECT
    Category,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Order_Count
FROM orders
GROUP BY Category, Sub_Category
ORDER BY Category, Total_Profit DESC;


-- ============================================
-- Query 10: Loss-making Sub-Categories
-- ============================================
-- Business Question: Which Sub-Categories are losing money overall?
-- Explanation: WHERE cannot filter on aggregate results - HAVING filters
--              groups AFTER SUM(Profit) is calculated per group.
-- Business Insight: Directly identifies product lines needing pricing or
--                    discount strategy changes.
-- ============================================
SELECT
    Category,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM orders
GROUP BY Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- ============================================
-- Query 11: High-performing States (Sales > $50,000)
-- ============================================
-- Business Question: Which States generated more than $50,000 in total sales?
-- Explanation: Groups by State, then HAVING filters to high performers
--              after aggregation.
-- Business Insight: Identifies core "home market" states worth prioritizing
--                    for marketing/logistics investment.
-- ============================================
SELECT
    State,
    SUM(Sales) AS Total_Sales,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM orders
GROUP BY State
HAVING SUM(Sales) > 50000
ORDER BY Total_Sales DESC;
