/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 09_advanced_business_queries.sql
Covers: ABC Analysis, RFM-style Segmentation, Discount Impact Analysis,
        Region x Category Matrix, CLV Approximation, Executive Summary
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 33: ABC Analysis (product profit classification)
-- ============================================
-- Business Question: Which products fall into A (top 70% cumulative profit),
--                     B (next 20%), or C (remaining 10%) classes?
-- Explanation: ROWS UNBOUNDED PRECEDING accumulates a running total from
--              the highest-profit product downward. SUM(...) OVER () with
--              empty parentheses gives the grand total across all rows.
-- Business Insight: "A" products are the vital few driving most profit -
--                    protect/prioritize inventory. "C" products are
--                    candidates for discontinuation review.
-- ============================================
WITH Product_Profit AS (
    SELECT
        Product_Name,
        SUM(Profit) AS Total_Profit
    FROM orders
    GROUP BY Product_Name
),
Ranked AS (
    SELECT
        Product_Name,
        Total_Profit,
        SUM(Total_Profit) OVER (ORDER BY Total_Profit DESC ROWS UNBOUNDED PRECEDING) AS Running_Profit,
        SUM(Total_Profit) OVER () AS Grand_Total_Profit
    FROM Product_Profit
)
SELECT
    Product_Name,
    Total_Profit,
    ROUND(Running_Profit / Grand_Total_Profit * 100, 2) AS Cumulative_Percent,
    CASE
        WHEN Running_Profit / Grand_Total_Profit <= 0.70 THEN 'A'
        WHEN Running_Profit / Grand_Total_Profit <= 0.90 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM Ranked
ORDER BY Total_Profit DESC;


-- ============================================
-- Query 34: RFM-style customer segmentation
-- ============================================
-- Business Question: How can we segment customers by Recency and Frequency
--                     into actionable groups?
-- Explanation: DATEDIFF calculates recency relative to the dataset's last
--              date. CASE buckets customers using recency + frequency
--              thresholds.
-- Business Insight: "Champions" deserve retention investment; "At Risk"
--                    customers need win-back campaigns before being lost.
-- ============================================
WITH Customer_RF AS (
    SELECT
        Customer_Name,
        DATEDIFF(DAY, MAX(Order_Date), '2017-12-31') AS Recency_Days,
        COUNT(DISTINCT Order_ID) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders
    GROUP BY Customer_Name
)
SELECT
    Customer_Name,
    Recency_Days,
    Frequency,
    Monetary,
    CASE
        WHEN Recency_Days <= 90 AND Frequency >= 5 THEN 'Champion'
        WHEN Recency_Days <= 180 AND Frequency >= 3 THEN 'Loyal'
        WHEN Recency_Days > 365 THEN 'At Risk'
        ELSE 'Regular'
    END AS Customer_Segment
FROM Customer_RF
ORDER BY Monetary DESC;


-- ============================================
-- Query 35: Discount band impact on profit margin
-- ============================================
-- Business Question: At what discount levels does average profit margin
--                     turn negative?
-- Explanation: Buckets every transaction into a discount band, then
--              calculates average profit margin within each band.
-- Business Insight: Provides a concrete, data-backed discount threshold
--                    recommendation (margin likely turns negative ~30-40%+).
-- ============================================
SELECT
    CASE
        WHEN Discount = 0 THEN '0% (No Discount)'
        WHEN Discount <= 0.2 THEN '1-20%'
        WHEN Discount <= 0.4 THEN '21-40%'
        WHEN Discount <= 0.6 THEN '41-60%'
        ELSE '60%+'
    END AS Discount_Band,
    COUNT(*) AS Transaction_Count,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(AVG(Profit / NULLIF(Sales, 0)) * 100, 2) AS Avg_Profit_Margin_Percent
FROM orders
GROUP BY
    CASE
        WHEN Discount = 0 THEN '0% (No Discount)'
        WHEN Discount <= 0.2 THEN '1-20%'
        WHEN Discount <= 0.4 THEN '21-40%'
        WHEN Discount <= 0.6 THEN '41-60%'
        ELSE '60%+'
    END
ORDER BY MIN(Discount);


-- ============================================
-- Query 36: Region x Category performance matrix
-- ============================================
-- Business Question: How does each Category rank within its own Region,
--                     and what is the profit margin for each combination?
-- Explanation: Combines GROUP BY on two dimensions with a PARTITION BY
--              rank, showing each category's relative standing within
--              its own region.
-- Business Insight: Surfaces region-specific problems that a flat
--                    national-level view would hide.
-- ============================================
SELECT
    Region,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2) AS Profit_Margin_Percent,
    RANK() OVER (PARTITION BY Region ORDER BY SUM(Profit) DESC) AS Category_Rank_In_Region
FROM orders
GROUP BY Region, Category
ORDER BY Region, Category_Rank_In_Region;


-- ============================================
-- Query 37: Approximate Customer Lifetime Value (CLV)
-- ============================================
-- Business Question: Which customers generate the most value per active
--                     month (a simplified CLV proxy)?
-- Explanation: +1 on the month difference avoids divide-by-zero for
--              customers whose first and last order fall in the same month.
-- Business Insight: Identifies customers generating consistent value over
--                    time versus one-time big spenders - useful for
--                    prioritizing retention budget.
-- ============================================
WITH Customer_Activity AS (
    SELECT
        Customer_Name,
        MIN(Order_Date) AS First_Order,
        MAX(Order_Date) AS Last_Order,
        SUM(Profit) AS Total_Profit,
        COUNT(DISTINCT Order_ID) AS Total_Orders
    FROM orders
    GROUP BY Customer_Name
)
SELECT
    Customer_Name,
    Total_Profit,
    Total_Orders,
    DATEDIFF(MONTH, First_Order, Last_Order) + 1 AS Active_Months,
    ROUND(Total_Profit / (DATEDIFF(MONTH, First_Order, Last_Order) + 1), 2) AS Avg_Monthly_Profit_Value
FROM Customer_Activity
ORDER BY Total_Profit DESC;


-- ============================================
-- Query 38: Executive summary (YoY KPI dashboard feed)
-- ============================================
-- Business Question: What does a single, board-ready summary of yearly
--                     KPIs and YoY growth look like?
-- Explanation: Combines CTE, aggregates, LAG, and safe division into one
--              polished summary table mirroring a Tableau KPI row.
-- Business Insight: One query telling the full growth-and-profitability
--                    story across all 4 years - a strong report headline.
-- ============================================
WITH Yearly AS (
    SELECT
        YEAR(Order_Date) AS Order_Year,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        COUNT(DISTINCT Order_ID) AS Total_Orders
    FROM orders
    GROUP BY YEAR(Order_Date)
)
SELECT
    Order_Year,
    Total_Sales,
    Total_Profit,
    Total_Orders,
    ROUND(Total_Profit / NULLIF(Total_Sales, 0) * 100, 2) AS Profit_Margin_Percent,
    ROUND(Total_Sales / NULLIF(Total_Orders, 0), 2) AS Avg_Order_Value,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Order_Year))
        / NULLIF(LAG(Total_Sales) OVER (ORDER BY Order_Year), 0) * 100, 2
    ) AS YoY_Sales_Growth_Percent
FROM Yearly
ORDER BY Order_Year;
