/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 03_case_and_string_functions.sql
Covers: CASE WHEN, String Functions (UPPER, CONCAT, LEFT)
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 12: Sales tier classification
-- ============================================
-- Business Question: Classify each transaction as High/Medium/Low Value
--                     based on Sales amount.
-- Explanation: CASE WHEN checks conditions top-to-bottom per row and
--              assigns the label of the first TRUE condition.
-- Business Insight: Segments transactions into business-friendly buckets
--                    for reports/dashboards.
-- ============================================
SELECT
    Order_ID,
    Customer_Name,
    Sales,
    CASE
        WHEN Sales >= 1000 THEN 'High Value'
        WHEN Sales >= 300 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Sales_Tier
FROM orders
ORDER BY Sales DESC;


-- ============================================
-- Query 13: Profitable vs Loss transaction summary
-- ============================================
-- Business Question: How many transactions are profitable vs. a loss,
--                     and what is their total value?
-- Explanation: GROUP BY can operate directly on a CASE WHEN expression.
-- Business Insight: Shows frequency vs. severity of loss-making sales,
--                    not just the total loss amount.
-- ============================================
SELECT
    CASE
        WHEN Profit >= 0 THEN 'Profitable'
        ELSE 'Loss'
    END AS Profit_Status,
    COUNT(*) AS Transaction_Count,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM orders
GROUP BY
    CASE
        WHEN Profit >= 0 THEN 'Profitable'
        ELSE 'Loss'
    END;


-- ============================================
-- Query 14: Standardized customer display label
-- ============================================
-- Business Question: Create a clean display label combining Customer Name
--                     and Segment (e.g., "DARRIN VAN HUFF (Corporate)").
-- Explanation: UPPER() converts text to all caps; CONCAT() joins multiple
--              text pieces together.
-- Business Insight: Data presentation skill for readable reports/dashboards.
-- ============================================
SELECT
    Customer_Name,
    Segment,
    CONCAT(UPPER(Customer_Name), ' (', Segment, ')') AS Display_Label
FROM orders;


-- ============================================
-- Query 15: Order ID prefix vs Region check
-- ============================================
-- Business Question: Does the first 2 letters of Order ID correspond to
--                     a specific Region?
-- Explanation: LEFT(Order_ID, 2) extracts the first 2 characters; combined
--              with DISTINCT to check prefix-to-region mapping.
-- Business Insight: Reinforces not assuming an ID's structure encodes
--                    business meaning without verifying first.
-- ============================================
SELECT DISTINCT
    LEFT(Order_ID, 2) AS Order_Prefix,
    Region
FROM orders
ORDER BY Order_Prefix;
