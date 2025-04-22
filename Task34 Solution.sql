-- Q 1 .Find out top 10 countries' which have maximum A and D values.
SELECT A.Country,A,D FROM (SELECT Country,A FROM freedom_rank.country_ab
ORDER BY A DESC LIMIT 10) A
LEFT JOIN
(SELECT Country,D FROM freedom_rank.country_cd
ORDER BY D DESC LIMIT 10) B
ON A.Country = B.Country
UNION
SELECT B.Country,A,D FROM (SELECT Country,A FROM freedom_rank.country_ab
ORDER BY A DESC LIMIT 10) A 
RIGHT JOIN
(SELECT Country,D FROM freedom_rank.country_cd
ORDER BY D DESC  LIMIT 10) B
ON A.Country = B.Country
ORDER BY Country;

-- Q-2 Find out highest CL value for 2020 for every region. Also sort the result in descending order. 
-- Also display the CL values in descending order.
SELECT Region,MAX(CL) FROM country_cl t1
JOIN country_ab t2
ON t1.country = t2.country
WHERE t1.Edition = 2020
GROUP BY Region 
ORDER BY MAX(CL) DESC;

-- Q-3 Find top-5 most sold products.
SELECT t2.Name,SUM(Quantity) AS 'product_sold' FROM salesdb.sales t1
INNER JOIN salesdb.products t2
ON t1.ProductID = t2.ProductID
GROUP BY t1.ProductID,t2.Name
ORDER BY product_sold DESC LIMIT 5;

-- Q-4: Find sales man who sold most no of products.
SELECT EmployeeID,FIRSTName,SUM(Quantity) AS 'total_sales' FROM salesdb.employees t1
INNER JOIN salesdb.sales t2
ON t1.EmployeeID = t2.SalesPersonID 
GROUP BY t1.EmployeeID,FIRSTName
ORDER BY total_sales DESC LIMIT 5;

-- Q-5: Sales man name who has most no of unique customer.
SELECT t1.SalesPersonID,FirstName,LastName,COUNT(DISTINCT CustomerID) AS 'unique_cust'
FROM sales t1
JOIN employees t2
ON t1.SalesPersonID = t2.EmployeeID
GROUP BY t1.SalesPersonID,FirstName,LastName
ORDER BY unique_cust DESC LIMIT 5;

-- Q-6: Sales man who has generated most revenue. Show top 5.
SELECT t1.SalesPersonID,t3.FirstName,t3.LastName,ROUND(SUM(t2.Price*t1.Quantity),2) AS 'Revenue'
FROM sales t1
JOIN products t2
ON t1.ProductID = t2.ProductID
INNER JOIN employees t3
ON t1.SalesPersonID = t3.EmployeeID
GROUP BY t1.SalesPersonID,t3.FirstName,t3.LastName
ORDER BY Revenue DESC LIMIT 5;

-- Q-7: List all customers who have made more than 10 purchases.
SELECT t1.CustomerID,FirstName,LastName,COUNT(DISTINCT SalesID) AS 'total_purchase' 
FROM salesdb.sales t1
INNER JOIN salesdb.customers t2
ON t1.CustomerID = t2.CustomerID
GROUP BY t1.CustomerID,FirstName,LastName HAVING total_purchase > 10;

-- Q-8 : List all salespeople who have made sales to more than 5 customers.
SELECT SalesPersonID,FirstName,LastName,COUNT(DISTINCT CustomerID) AS 'num_customer' FROM sales t1
JOIN employees t2
ON t1.SalesPersonID = t2.EmployeeID
GROUP BY SalesPersonID,FirstName,LastName HAVING num_customer > 5;

-- Q-9: List all pairs of customers who have made purchases with the same salesperson.
-- Not able to solve this question
SELECT CONCAT(t2.FirstName," ",t2.LastName) AS 'cust_name', 
CONCAT(t3.FirstName," ",t3.LastName) AS 'Sales Person' ,
COUNT(CONCAT(t2.FirstName," ",t2.LastName)) AS 'num_time_buy'
FROM sales t1
JOIN customers t2 
ON t1.CustomerID = t2.CustomerID
JOIN employees t3
ON t1.SalesPersonID = t3.EmployeeID
GROUP BY t2.CustomerID,CONCAT(t2.FirstName," ",t2.LastName),t3.EmployeeID,CONCAT(t3.FirstName," ",t3.LastName)