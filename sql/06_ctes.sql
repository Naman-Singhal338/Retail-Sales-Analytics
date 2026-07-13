/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 06_ctes.sql
Covers: Common Table Expressions (CTEs), NTILE, CROSS JOIN with single-row CTE
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 25: Top 10% customers by total spend (VIP customers)
-- ============================================
-- Business Question: Which customers are in the top 10% by total spend?
-- Explanation: First CTE calculates per-customer total sales. Second CTE
--              splits customers into 10 equal groups (deciles) via NTILE(10).
--              Spend_Decile = 1 captures the top 10%.
-- Business Insight: This is the VIP customer list - prime candidates for
--                    loyalty programs or account management attention.
-- ============================================
WITH Customer_Sales AS (
    SELECT
        Customer_Name,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY Customer_Name
),
Ranked_Customers AS (
    SELECT
        Customer_Name,
        Total_Sales,
        NTILE(10) OVER (ORDER BY Total_Sales DESC) AS Spend_Decile
    FROM Customer_Sales
)
SELECT Customer_Name, Total_Sales
FROM Ranked_Customers
WHERE Spend_Decile = 1
ORDER BY Total_Sales DESC;


-- ============================================
-- Query 26: Category profit as % of total company profit
-- ============================================
-- Business Question: What percentage of total company profit does each
--                     Category represent?
-- Explanation: Two CTEs - one per-category total, one single-row company
--              total. CROSS JOIN is safe here since Company_Total has
--              exactly one row, attaching it to every category row.
-- Business Insight: Shows profit concentration - e.g. one category may
--                    drive the majority of all profit.
-- ============================================
WITH Category_Profit AS (
    SELECT
        Category,
        SUM(Profit) AS Category_Total_Profit
    FROM orders
    GROUP BY Category
),
Company_Total AS (
    SELECT SUM(Profit) AS Overall_Profit FROM orders
)
SELECT
    cp.Category,
    cp.Category_Total_Profit,
    ROUND(cp.Category_Total_Profit / ct.Overall_Profit * 100, 2) AS Percent_Of_Total_Profit
FROM Category_Profit cp
CROSS JOIN Company_Total ct
ORDER BY cp.Category_Total_Profit DESC;


-- ============================================
-- Query 27: Frequent but low-margin customers
-- ============================================
-- Business Question: Which customers order frequently (>5 orders) but
--                     have an average profit margin below 5%?
-- Explanation: CTE pre-calculates per-customer metrics once; outer query
--              filters and formats, avoiding repeated aggregation logic.
-- Business Insight: Flags high-maintenance, low-value customers - possibly
--                    due to heavy discount usage - worth a policy review.
-- ============================================
WITH Customer_Metrics AS (
    SELECT
        Customer_Name,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM orders
    GROUP BY Customer_Name
)
SELECT
    Customer_Name,
    Total_Orders,
    Total_Sales,
    Total_Profit,
    ROUND(Total_Profit / NULLIF(Total_Sales, 0) * 100, 2) AS Profit_Margin_Percent
FROM Customer_Metrics
WHERE Total_Orders > 5
  AND (Total_Profit / NULLIF(Total_Sales, 0) * 100) < 5
ORDER BY Profit_Margin_Percent ASC;
