# Q-1: Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank
SELECT t3.FirstName,t.total_revenue,t.rank FROM(WITH filtered_data AS(SELECT t1.OrderID,EmployeeID,UnitPrice*Quantity AS 'total_price' FROM orders t1
JOIN order_details t2
ON t1.OrderID = t2.OrderID)
SELECT EmployeeID,
ROUND(SUM(total_price),2) AS 'total_revenue',
RANK() OVER(ORDER BY SUM(total_price) DESC) AS 'rank'
FROM filtered_data 
GROUP BY EmployeeID) t
JOIN employees t3
ON t.EmployeeID = t3.EmployeeID
ORDER BY t.rank;

SELECT t3.FirstName,ROUND(SUM(UnitPrice*Quantity),2) AS 'total_revenue',
RANK() OVER(ORDER BY SUM(UnitPrice*Quantity) DESC) AS 'rank'
FROM orders t1
JOIN order_details t2
ON t1.OrderID = t2.OrderID
JOIN employees t3
ON t1.EmployeeID = t3.EmployeeID
GROUP BY t1.EmployeeID, t3.FirstName;

# Q-2: Show All products cumulative sum of units sold each month.
SELECT *,
SUM(total_quantity) OVER(PARTITION BY ProductID ORDER BY 'month' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
FROM(SELECT ProductID,MONTHNAME(OrderDate) AS 'month',SUM(Quantity) AS 'total_quantity' FROM orders t1
JOIN order_details t2
ON t1.OrderID = t2.OrderID
GROUP BY ProductID,MONTHNAME(OrderDate),MONTH(OrderDate)
ORDER BY ProductID,MONTH(OrderDate))t;

# Q-3: Show Percentage of total revenue by each suppliers
WITH filter_data AS(SELECT t2.SupplierID,t2.CompanyName,ROUND(SUM(t3.UnitPrice*t3.Quantity),2) AS 'total_revenue' FROM products t1
JOIN suppliers t2
ON t1.SupplierID = t2.SupplierID
JOIN order_details t3
ON t1.ProductID = t3.ProductID
GROUP BY SupplierID,CompanyName
ORDER BY t2.SupplierID)
SELECT *,
ROUND((total_revenue/SUM(total_revenue) OVER())*100,2) AS '%revenue'
FROM filter_data
ORDER BY `%revenue` DESC;

# Q-4: Show Percentage of total orders by each suppliers
WITH filter_data AS(SELECT t2.SupplierID,t2.CompanyName, COUNT(DISTINCT t3.OrderID) AS 'num_orders' FROM products t1
JOIN suppliers t2
ON t1.SupplierID = t2.SupplierID
JOIN order_details t3
ON t1.ProductID = t3.ProductID
GROUP BY SupplierID,CompanyName
ORDER BY t2.SupplierID)
SELECT *,
ROUND((num_orders/SUM(num_orders) OVER())*100,2) AS '%orders'
FROM filter_data;

# Q-5:Show All Products Year Wise report of total Quantity sold, percentage change from last year.
SELECT *,
((Quantity - LAG(Quantity) OVER(PARTITION BY ProductID ORDER BY YEAR))/LAG(Quantity) OVER(PARTITION BY ProductID ORDER BY YEAR))*100 AS '% change'
FROM(SELECT YEAR(OrderDate) AS 'Year',ProductID,SUM(Quantity) AS 'Quantity'
FROM order_details t1
JOIN orders t2
ON t1.OrderID = t2.OrderID
GROUP BY YEAR(OrderDate),ProductID
ORDER BY ProductID) t;

# Problem-6: For each condition, what is the average satisfaction level of drugs that are 
# "On Label" vs "Off Label"?

SELECT `Condition`,Indication,ROUND(AVG(Satisfaction),2)
FROM drug.drugs
GROUP BY `Condition`,Indication;

WITH temp_df AS (SELECT `Condition`,Indication, Satisfaction,
ROUND(AVG(Satisfaction) OVER(PARTITION BY `Condition`,Indication ORDER BY Satisfaction
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) AS 'avg_satisfaction',
DENSE_RANK() OVER( PARTITION BY `Condition`, Indication ORDER BY drugs.Satisfaction) AS rank_num
FROM drug.drugs)
SELECT temp_df.`Condition`,temp_df.Indication,temp_df.avg_satisfaction
FROM temp_df
where rank_num = 1;

WITH temp AS(SELECT `CONDITION`,Indication,
ROUND(AVG(Satisfaction) OVER(PARTITION BY `CONDITION`,Indication),2) AS 'avg_satisfaction'
FROM drugs)
SELECT DISTINCT * FROM temp;

# Problem-7: For each drug type (RX, OTC, RX/OTC), what is the average ease of use and satisfaction
# level of drugs with a price above the median for their type?
WITH temp AS (SELECT Type,
AVG(EaseOfUse) OVER(PARTITION BY Type) AS 'avg_easeofuse',
AVG(Satisfaction) OVER(PARTITION BY Type) AS 'avg_satisfaction'
FROM (SELECT Type,EaseOfUse,Satisfaction,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Price) OVER(PARTITION BY Type) AS 'median_price',price
FROM drugs
WHERE Type IN ('RX', 'OTC', 'RX/OTC')) t 
WHERE price >= median_price)
SELECT * FROM temp
GROUP BY type;

# Problem 8: What is the cumulative distribution of EaseOfUse ratings for each drug type 
#(RX, OTC, RX/OTC)? Show the results in descending order by drug type and cumulative distribution. 
#(Use the built-in method and the manual method by calculating on your own. For the manual method, 
#use the "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW" and see if you get the same results as 
#the built-in method.)
SELECT Type,EaseOfUse,
CUME_DIST() OVER(PARTITION BY Type ORDER BY EaseOfUse) AS 'cumulative_dist_builtin',
COUNT(*) OVER (
    PARTITION BY Type
    ORDER BY EaseOfUse
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)*1.0/COUNT(*) OVER (PARTITION BY Type) AS 'cumulative_dist_manual'
FROM drugs
WHERE Type IN ('RX', 'OTC', 'RX/OTC')
ORDER BY Type,cumulative_dist_builtin DESC;

#Problem 9: What is the median satisfaction level for each medical condition? Show the results in 
# descending order by median satisfaction level. (Don't repeat the same rows of your result.)
WITH temp AS (SELECT `Condition`,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Satisfaction) OVER(PARTITION BY `Condition`) AS 'median'
FROM drugs)
SELECT  DISTINCT * FROM temp
ORDER BY median DESC;

WITH temp_df AS (
    SELECT drugs.Condition,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY drugs.Satisfaction) OVER (PARTITION BY drugs.Condition) AS median_satisfaction
    FROM drugs
)
SELECT temp_df.Condition, temp_df.median_satisfaction
FROM temp_df
GROUP BY temp_df.Condition
ORDER BY temp_df.median_satisfaction DESC;

# Problem 10: What is the running average of the price of drugs for each medical condition? Show 
# the results in ascending order by medical condition and drug name.
SELECT `Condition`,drug,ROUND(Price,2) AS 'price',
ROUND(AVG(price) OVER(PARTITION BY `Condition`),2) AS 'avg',
ROUND(AVG(price) OVER(PARTITION BY `Condition` ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS 'rolling_avg'
FROM drugs
ORDER BY `Condition`,drug;

SELECT drugs.Condition, drugs.Drug, ROUND(drugs.Price, 2),
    ROUND(AVG(drugs.Price) OVER (
        PARTITION BY drugs.Condition
        ORDER BY drugs.Drug
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_avg_price
FROM drugs
ORDER BY drugs.Condition ASC, drugs.Drug ASC;

# Problem 11: What is the percentage change in the number of reviews for each drug between the 
# previous row and the current row? Show the results in descending order by percentage change.
SELECT `Condition`, Drug, Reviews,
(Reviews - LAG(Reviews) OVER (PARTITION BY `Condition`, Drug ORDER BY Reviews DESC))*100.0 / LAG(drugs.Reviews) OVER(PARTITION BY `Condition`,Drug ORDER BY Reviews DESC) AS pct_change
FROM drugs
ORDER BY pct_change DESC;

SELECT `Condition`, Drug, Reviews,
(Reviews - LAG(Reviews) OVER(PARTITION BY `Condition`,Drug ORDER BY Reviews DESC))*100.0/LAG(Reviews) OVER(PARTITION BY `Condition`,Drug ORDER BY Reviews DESC) AS 'pct_change'
FROM drugs
ORDER BY pct_change DESC;

# Problem 12: What is the percentage of total satisfaction level for each drug type 
#(RX, OTC, RX/OTC)? Show the results in descending order by drug type and percentage of total 
# satisfaction.
SELECT Type,pct_total_satisfaction FROM(SELECT Type,Satisfaction,
ROUND((SUM(Satisfaction) OVER(PARTITION BY Type))*100 /SUM(Satisfaction) OVER(),2) AS 'pct_total_satisfaction'
FROM drugs
WHERE Type IN ('RX', 'OTC', 'RX/OTC'))t
GROUP BY Type;

WITH temp_df AS (
    SELECT Type, Satisfaction,
        ROUND(SUM(Satisfaction) OVER (PARTITION BY Type) * 100.0 / SUM(Satisfaction) OVER (),2) AS pct_total_satisfaction
    FROM drugs
    WHERE Type IN ('RX', 'OTC', 'RX/OTC')
    ORDER BY Type ASC, pct_total_satisfaction DESC
)

SELECT Type, pct_total_satisfaction FROM temp_df
GROUP BY Type;

# Problem 13: What is the cumulative sum of effective ratings for each medical condition and drug 
# form combination? Show the results in ascending order by medical condition, drug form and the 
# name of the drug.
SELECT `Condition`,Drug,Form,Effective, 
#SUM(Effective) OVER(PARTITION BY `Condition`,Drug),
SUM(Effective) OVER(PARTITION BY `Condition`,Form ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as 'cumsum'
FROM drugs
ORDER BY `condition`,Form,Drug;

SELECT drugs.Condition, drugs.Form, drugs.Drug,
    drugs.Effective,
    SUM(drugs.Effective) OVER (
        PARTITION BY drugs.Condition, drugs.Form
        ORDER BY drugs.Drug
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum_effective
FROM drugs
ORDER BY
    drugs.Condition ASC,
    drugs.Form ASC,
    drugs.Drug ASC;
    
# Problem-14: What is the rank of the average ease of use for each drug type (RX, OTC, RX/OTC)? 
# Show the results in descending order by rank and drug type.
WITH temp AS(SELECT Type,
AVG(EaseOfUse) OVER(PARTITION BY Type) AS 'avg_easeofuse'
FROM drugs
WHERE Type IN ('RX', 'OTC', 'RX/OTC'))
SELECT DISTINCT *,
DENSE_RANK() OVER(ORDER BY avg_easeofuse DESC)
FROM temp;

SELECT
  Type,
  AVG(EaseOfUse) AS average_ease_of_use,
  RANK() OVER (ORDER BY AVG(EaseOfUse) DESC) AS 'rank'
FROM drugs
WHERE Type IN ('RX', 'OTC', 'RX/OTC')
GROUP BY Type;

# Problem-15: For each condition, what is the average effectiveness of the top 3 most reviewed drugs?
SELECT `Condition`,Drug,ROUND(Reviews,2) AS 'Reviews',
ROUND(AVG(Effective) OVER(PARTITION BY `Condition`,Drug ORDER BY Reviews DESC
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) AS 'avg_effectiveness',
`rank`
FROM(SELECT *,
RANK() OVER(PARTITION BY `Condition` ORDER BY Reviews DESC) AS 'rank'
FROM drugs)t
WHERE t.`rank` < 4;

SELECT * FROM (
    SELECT drugs.Condition, drugs.Drug, ROUND(drugs.Reviews, 2) AS 'Reviews',
ROUND(AVG(drugs.Effective) OVER (
            PARTITION BY drugs.Condition, drugs.Drug
            ORDER BY drugs.Reviews DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ), 2) AS avg_effectiveness,
    RANK() OVER (
        PARTITION BY drugs.Condition
        ORDER BY drugs.Reviews DESC
    ) AS rank_num
    FROM drugs
) t
WHERE rank_num <= 3;

