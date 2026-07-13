/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 08_views.sql
Covers: CREATE VIEW (reusable summary tables for Category/Region and Customer)
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 31: View - Category x Region summary
-- ============================================
-- Business Question: Create a reusable summary of sales/profit by Category
--                     and Region for reports/Tableau to query directly.
-- Explanation: CREATE VIEW saves the query definition as a virtual table.
--              Querying it re-runs the underlying GROUP BY logic live,
--              always reflecting current data.
-- Business Insight: Reusable analytical asset feeding a Tableau "Category
--                    by Region" chart without duplicating logic.
-- ============================================
CREATE VIEW vw_Category_Region_Summary AS
SELECT
    Category,
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM orders
GROUP BY Category, Region;
GO

-- Test the view
SELECT * FROM vw_Category_Region_Summary
ORDER BY Total_Sales DESC;


-- ============================================
-- Query 32: View - Customer-level summary
-- ============================================
-- Business Question: Create a reusable view of customer-level metrics
--                     (orders, sales, profit, profit margin).
-- Explanation: Bundles customer-level aggregation logic (from Query 27's
--              CTE) into a reusable view.
-- Business Insight: Single source of truth for any customer-level question
--                    going forward, in SQL, Tableau, or Python.
-- ============================================
CREATE VIEW vw_Customer_Summary AS
SELECT
    Customer_Name,
    Segment,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS Profit_Margin_Percent
FROM orders
GROUP BY Customer_Name, Segment;
GO

-- Test the view
SELECT TOP 10 * FROM vw_Customer_Summary
ORDER BY Total_Profit DESC;
