/*
================================================================================
Retail Sales Analytics — SQL Analysis
File: 07_subqueries.sql
Covers: Scalar Subqueries, Subqueries with NOT IN, Correlated Subqueries
Database: RetailSalesDB | Table: orders
================================================================================
*/

-- ============================================
-- Query 28: Orders above the company-wide average Sales
-- ============================================
-- Business Question: Which orders had a Sales value above the company-wide
--                     average?
-- Explanation: Scalar subquery (SELECT AVG(Sales) FROM orders) runs first,
--              returning a single number the outer query compares against.
-- Business Insight: Isolates "above-average" transactions dynamically,
--                    staying accurate even as data changes.
-- ============================================
SELECT
    Order_ID,
    Customer_Name,
    Sales
FROM orders
WHERE Sales > (SELECT AVG(Sales) FROM orders)
ORDER BY Sales DESC;


-- ============================================
-- Query 29: Customers who have never bought Technology
-- ============================================
-- Business Question: Which customers have never purchased anything from
--                     the Technology category?
-- Explanation: Inner subquery returns every customer who bought Technology
--              at least once; outer query finds customers NOT IN that list.
-- Business Insight: A direct cross-sell target list for Technology-focused
--                    marketing campaigns.
-- ============================================
SELECT DISTINCT Customer_Name
FROM orders
WHERE Customer_Name NOT IN (
    SELECT DISTINCT Customer_Name
    FROM orders
    WHERE Category = 'Technology'
)
ORDER BY Customer_Name;


-- ============================================
-- Query 30: Sales vs. own-category average (correlated subquery)
-- ============================================
-- Business Question: How does each order's Sales compare to the average
--                     Sales for its own Category?
-- Explanation: Correlated subquery references o1.Category from the outer
--              query, so it re-runs separately for every outer row using
--              that row's own category.
-- Business Insight: Fairer comparison than a flat company-wide average -
--                    shows performance relative to peers in the same category.
-- ============================================
SELECT
    Order_ID,
    Category,
    Sales,
    (SELECT AVG(Sales) FROM orders o2 WHERE o2.Category = o1.Category) AS Category_Avg_Sales,
    CASE
        WHEN Sales > (SELECT AVG(Sales) FROM orders o2 WHERE o2.Category = o1.Category)
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS Comparison
FROM orders o1
ORDER BY Category, Sales DESC;
