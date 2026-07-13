/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 05_window_functions.sql
Covers: RANK, DENSE_RANK, PARTITION BY, Running Totals, LAG (YoY Growth)
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 21: Rank products by profit within each Category
-- ============================================
-- Business Question: Which products rank #1 by profit within each Category?
-- Explanation: PARTITION BY Category restarts the ranking for each category
--              separately. RANK() assigns equal rank to ties and skips the
--              next number after a tie.
-- Business Insight: Identifies category champions worth featuring/promoting.
-- ============================================
SELECT
    Category,
    Product_Name,
    SUM(Profit) AS Total_Profit,
    RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS Profit_Rank
FROM orders
GROUP BY Category, Product_Name
ORDER BY Category, Profit_Rank;


-- ============================================
-- Query 22: Top 3 most profitable products overall
-- ============================================
-- Business Question: What are the top 3 most profitable products company-wide?
-- Explanation: DENSE_RANK() does not skip numbers after ties. Window function
--              results must be filtered via a subquery (cannot use WHERE on
--              a window function directly in the same SELECT).
-- Business Insight: These are "hero products" worth highlighting in marketing
--                    and ensuring inventory availability.
-- ============================================
SELECT *
FROM (
    SELECT
        Product_Name,
        Category,
        SUM(Profit) AS Total_Profit,
        DENSE_RANK() OVER (ORDER BY SUM(Profit) DESC) AS Profit_Rank
    FROM orders
    GROUP BY Product_Name, Category
) AS Ranked_Products
WHERE Profit_Rank <= 3;


-- ============================================
-- Query 23: Running (cumulative) total of monthly sales
-- ============================================
-- Business Question: What does our cumulative sales growth look like
--                     month-by-month?
-- Explanation: SUM(SUM(Sales)) OVER (ORDER BY ...) with no PARTITION BY
--              treats the entire result as one window, adding each row's
--              value to a running total.
-- Business Insight: Powers a "cumulative revenue" chart - a classic
--                    executive dashboard visual showing growth trajectory.
-- ============================================
SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    SUM(Sales) AS Monthly_Sales,
    SUM(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date)) AS Running_Total_Sales
FROM orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Order_Year, Order_Month;


-- ============================================
-- Query 24: Year-over-Year sales growth percentage
-- ============================================
-- Business Question: What was our YoY sales growth percentage each year?
-- Explanation: LAG(Total_Sales) OVER (ORDER BY Order_Year) looks at the
--              previous row's value while staying on the current row,
--              enabling (this year - last year) / last year * 100.
-- Business Insight: A headline, board-level growth KPI for the business
--                    insights report.
-- ============================================
SELECT
    Order_Year,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Order_Year) AS Previous_Year_Sales,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Order_Year))
        / LAG(Total_Sales) OVER (ORDER BY Order_Year) * 100, 2
    ) AS YoY_Growth_Percent
FROM (
    SELECT
        YEAR(Order_Date) AS Order_Year,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY YEAR(Order_Date)
) AS Yearly_Sales;
