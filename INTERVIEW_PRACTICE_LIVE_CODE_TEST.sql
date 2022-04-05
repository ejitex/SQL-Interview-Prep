USE AdventureWorksDW2019;


SELECT TOP 10
product.EnglishProductName, 
sales.ProductKey, 
sales.SalesAmount
FROM [dbo].[FactInternetSales] AS sales
JOIN [dbo].[DimProduct] AS product
ON sales.ProductKey = product.ProductKey
ORDER BY SalesAmount DESC;



SELECT Title, ROUND(AVG(BaseRate),2) AS AVR
FROM [dbo].[DimEmployee]
GROUP BY Title
HAVING AVG(BaseRate) <= 15
ORDER BY Title;


SELECT FirstName +' '+ LastName AS Employee, Title,  BaseRate
FROM [dbo].[DimEmployee]
WHERE BaseRate <= (SELECT AVG(BaseRate)
		FROM [dbo].[DimEmployee]
		--GROUP BY Title
		--HAVING AVG(BaseRate) <= 15
		)

ORDER BY BaseRate DESC;

/* 

INTERVIEW PRACTICE QUESTION 



--1
SELECT TOP 3 a.author_name, SUM(b.sold_copies)
FROM authors a
JOIN books b
ON a.book_name = b.book_name
GROUP BY a.author_name
ORDER BY b.sold_copies desc;

--2 correct

SELECT COUNT(*) FROM
(SELECT user_id, COUNT(event_date_time) AS imageuploaduser 
FROM event_log
GROUP BY user_id) AS imageuploaduser
WHERE imageuploaduser > 1000 AND imageuploaduser < 2000

--2 correct

--3

SELECT  
e.department_name, 
AVG(s.salary)  
FROM
employees e
JOIN salaries s
ON e.employee_id = s.employee_id
GROUP BY e.department_name
HAVING AVG(s.salary) < 500



SELECT TOP 5 * FROM [dbo].[DatabaseLog];

SELECT DatabaseLog.DatabaseLogID, COUNT(DatabaseLog.PostTime) AS logs
FROM [dbo].[DatabaseLog]
GROUP BY DatabaseLog.DatabaseLogID
HAVING COUNT(DatabaseLog.PostTime) > 0 AND COUNT(DatabaseLog.PostTime) < 5
ORDER BY DatabaseLog.DatabaseLogID;

*/

SELECT TOP 5 * FROM [Sales].[Invoices] AS I, [Sales].[Orders] AS S
WHERE S.OrderID = I.OrderID;

/* 
THIRD DAY OF INTERVIEW PRACTICE


*/


-- list of customer which haven't made any transaction.
SELECT * FROM [Sales].[Customers] SC
WHERE SC.CustomerID NOT IN (SELECT TC.CustomerID FROM [Sales].[CustomerTransactions] AS TC
);

--- testing the solution above is correct. customer ID number 5 could not be found because the customer has not perform
--any transaction.
SELECT TOP 5 * FROM [Sales].[CustomerTransactions]
WHERE CustomerID = 5;

--  SQL query to find the 10th highest wage from an Employee table
--SELECT DISTINCT TOP 5 * FROM [dbo].[DimEmployee];

SELECT TOP 1 * FROM 
(SELECT DISTINCT TOP 10 BaseRate FROM
	[dbo].[DimEmployee] 
	ORDER BY BaseRate DESC)
AS Employee ORDER BY BaseRate;

-- 10 MOST EXPENSIVE PRODUCT
SELECT DISTINCT TOP 10 P.EnglishProductName,S.UnitPrice FROM [dbo].[FactInternetSales] S
INNER JOIN [dbo].[DimProduct] P
ON S.ProductKey = P.ProductKey
ORDER BY  S.UnitPrice DESC;

/* 
USE CASES OF SUBQUERY
*/
-- select CustomerKey and discounted price where salesamount greater than average salesamount
-- INclude alse Salesamount in the select statement
SELECT 
FS.CustomerKey, 
FS.DiscountAmount,
FS.SalesAmount,
	(SELECT AVG(SalesAmount) 
	FROM [dbo].[FactInternetSales]) AS [AVERAGE]

FROM [dbo].[FactInternetSales] AS FS

WHERE FS.SalesAmount >= 
	(SELECT AVG(SalesAmount) 
	FROM [dbo].[FactInternetSales]);




-- query variance between salesamount and average salesamount
-- include both salesamount and average salesamount in select statement
SELECT product.EnglishProductName, sales.SalesAmount, 
	(SELECT ROUND(AVG(SalesAmount),2) 
	FROM [dbo].[FactInternetSales]) AS AverageSalesAmount,
sales.SalesAmount - 
	(SELECT AVG(SalesAmount) 
	FROM [dbo].[FactInternetSales]) AS Variance
FROM [dbo].[FactInternetSales] AS sales
INNER JOIN [dbo].[DimProduct] product
ON sales.ProductKey = product.ProductKey;

--- use subquery to query product names where sales made between Jan to March 2014
SELECT 
DISTINCT(product.EnglishProductName),
product.ProductKey
FROM [dbo].[DimProduct] product
WHERE product.ProductKey IN(
						SELECT Fsales.ProductKey 
						FROM [dbo].[FactInternetSales] AS Fsales
						WHERE Fsales.OrderDate >= '2014-01-01' AND Fsales.OrderDate <= '2014-03-31')

-- SUBQUERY IN FROM CLAUSE - the most commonly asked in interview and a good example of subquery use case

-- query all department name where average wage greater than $19
-- Remember using alias is required when using SUBquery in FROM Clause

SELECT * FROM 
	(SELECT DepartmentName, AVG(BaseRate) AS deptAVGWage 
	FROM [dbo].[DimEmployee]
	GROUP BY DepartmentName)
AS deptAVGWage
WHERE deptAVGWage >= 19
ORDER BY deptAVGWage DESC;

---make a few changes to the above query to return how many department with avg wage greater than $19

SELECT COUNT(*) AS howMany FROM 
	(SELECT DepartmentName, AVG(BaseRate) AS deptAVGWage 
	FROM [dbo].[DimEmployee]
	GROUP BY DepartmentName)
AS deptAVGWage
WHERE deptAVGWage >= 19
--ORDER BY deptAVGWage DESC;

/*
--- QUERY MEDIAN VALUE OF A ROWSET

-- syNtax 
PERCENTILE_DISC ( numeric_literal ) WITHIN GROUP ( ORDER BY order_by_expression [ ASC | DESC ] )  
    OVER ( [ <partition_by_clause> ] )
	*/


SELECT DISTINCT PERCENTILE_DISC(0.5) 
WITHIN GROUP (ORDER BY CurrencyKey)
OVER (PARTITION BY 1) AS Median
FROM [dbo].[DimCurrency];

SELECT * FROM [dbo].[DimDate] AS D, [dbo].[FactInternetSales] AS S
WHERE D.DateKey = S.DueDateKey; 

SELECT sales.DueDateKey FROM [dbo].[FactInternetSales] AS sales

select * from [dbo].[DimProductCategory] as cat
inner join [dbo].[DimProductSubcategory] as subcat
on cat.ProductCategoryKey = subcat.ProductCategoryKey
inner join [dbo].[DimProduct] as product
on subcat.ProductSubcategoryKey = product.ProductSubcategoryKey


-- total productcategory sales by year

SELECT distinct 
cat.EnglishProductCategoryName,
salesdate.FiscalYear,
SUM(sales.SalesAmount)
OVER (PARTITION BY salesdate.FiscalYear) AS YearlySales
FROM [dbo].[DimDate] AS salesdate
inner join [dbo].[FactInternetSales] as sales
on salesdate.DateKey = sales.DueDateKey
inner join [dbo].[DimProduct] as product
on sales.ProductKey = product.ProductKey
inner join [dbo].[DimProductSubcategory] as subcat
on product.ProductSubcategoryKey = subcat.ProductSubcategoryKey
inner join [dbo].[DimProductCategory] as cat
on subcat.ProductCategoryKey = cat.ProductCategoryKey
order by salesdate.FiscalYear;

--- AGGREGRATE FUNCTION WITH GROUPING BY MULTIPLE COLNS

SELECT DISTINCT productTable.EnglishProductName ,OrderDate, Sum(SalesAmount) AS dailySales 
FROM [dbo].[FactInternetSales] AS salestable
INNER JOIN [dbo].[DimProduct] AS productTable
ON salestable.ProductKey = productTable.ProductKey
GROUP BY productTable.EnglishProductName, OrderDate
HAVING productTable.EnglishProductName LIKE '%Bike%'
ORDER BY OrderDate DESC;



SELECT salesTable.CustomerKey, customerTable.LastName, salesTable.SalesAmount,
row_number()
OVER(PARTITION BY salesTable.CustomerKey ORDER BY customerTable.LastName ASC) AS OrdersbyCustomer
FROM [dbo].[DimCustomer] AS customerTable
INNER JOIN [dbo].[FactInternetSales] AS salesTable
ON customerTable.CustomerKey = salesTable.CustomerKey
--where customerTable.LastName = 'Adams';
;
---testing solution if the below query returns 252 then the query above is correct (Adams should have made 252 orders)
SELECT count(*) AS orderbycustomer
FROM [dbo].[FactInternetSales] AS salesTable
INNER JOIN [dbo].[DimCustomer] AS customerTable
ON customerTable.CustomerKey = salesTable.CustomerKey
where customerTable.LastName = 'Adams';



-- Get top 3 most recent order for every customer
SELECT * FROM(
	SELECT S.CustomerKey, S.OrderDate,S.SalesAmount,
	row_number() 
	over (PARTITION BY S.CustomerKey ORDER by S.OrderDate desc ) as OrderbyUniqueCustomer
	--SUM(S.SalesAmount) OVER(PARTITION BY S.CustomerKey ORDER by S.OrderDate desc ) AS totalsales
	from [dbo].[FactInternetSales] AS S) 
AS a
WHERE a.OrderbyUniqueCustomer <= 3;

SELECT COUNT(*) FROM [dbo].[FactInternetSales]
WHERE CustomerKey = 11016;

--- get top 3 employees with highest wage in each department. dif btw rank and dense_rank?
SELECT TOP 5 * FROM [dbo].[DimEmployee];

SELECT * FROM(
SELECT e.FirstName, e.LastName, e.DepartmentName,e.BaseRate,
dense_rank() over(partition by DepartmentName ORDER BY BaseRate Desc) AS rnk
FROM [dbo].[DimEmployee] AS e) AS a
WHERE a.rnk <= 3;

--Compare wage difference base on employee hireDate

SELECT e.EmployeeKey,e.FirstName,e.LastName,e.StartDate, e.DepartmentName, e.BaseRate , 
LAG(e.BaseRate) OVER (PARTITION BY e.DepartmentName ORDER BY e.StartDate) as previous_BaseRate
FROM [dbo].[DimEmployee] AS e;

/*
WITH productMaxTable(productID, MAXsalesAmount)
AS
(SELECT ProductKey, MAX(SalesAmount)AS  MAXsalesAmount 
FROM [dbo].[FactInternetSales]
GROUP BY ProductKey)

SELECT e.EnglishProductCategoryName,d.EnglishProductSubcategoryName, c.EnglishProductName , MIN(a.SalesAmount) AS MINsalesAmount, b.MAXsalesAmount
FROM [dbo].[FactInternetSales] AS a
INNER JOIN productMaxTable AS b
ON  a.ProductKey = b.productID
INNER JOIN [dbo].[DimProduct] c
ON b.productID = c.ProductKey
INNER JOIN [dbo].[DimProductSubcategory] AS d
ON c.ProductSubcategoryKey = d.ProductSubcategoryKey
INNER JOIN [dbo].[DimProductCategory] e
ON d.ProductCategoryKey = e.ProductCategoryKey
GROUP BY e.EnglishProductCategoryName, d.EnglishProductSubcategoryName, c.EnglishProductName,b.MAXsalesAmount 
order by e.EnglishProductCategoryName;

*/

--Let's Group factsales table into Very low, Low, Medium and High bases on SalesAmount

SELECT product.EnglishProductName ,sales.ProductKey,
sales.OrderQuantity,
sales.Freight, 
sales.TaxAmt, 
sales.SalesAmount,
sales.UnitPrice,

CASE WHEN sales.UnitPrice < 10 THEN 'Very Low'
	WHEN sales.UnitPrice > 9 AND  sales.UnitPrice < 25 THEN 'Low'
	WHEN sales.UnitPrice > 24 AND  sales.UnitPrice < 100 THEN 'Medium'
	WHEN sales.UnitPrice > 99 AND  sales.UnitPrice < 300 THEN 'Above Average'
ELSE 'High'
END AS Product_Worth

FROM [dbo].[FactInternetSales] AS sales
INNER JOIN [dbo].[DimProduct] AS product
ON sales.ProductKey = product.ProductKey

SELECT * FROM [dbo].[DimEmployee];

SELECT e.EmployeeKey,e.DepartmentName,e.BaseRate, sum(e.BaseRate) as sum_BaseWage FROM [dbo].[DimEmployee] as e
GROUP BY e.EmployeeKey,e.DepartmentName,e.BaseRate
HAVING e.EmployeeKey > 100  AND e.EmployeeKey < 200
AND e.BaseRate > 19
ORDER BY e.DepartmentName;

select a.DepartmentName, 
AVG(a.BaseRate) 
OVER (PARTITION BY a.DepartmentName ORDER BY a.BaseRate ASC) AS AVG_BaseRateDept
from [dbo].[DimEmployee] a

--get last ID row without using aggregate function like MAX

select distinct top 1 * from [dbo].[FactInternetSales]
order by ProductKey desc;

--- CTE
--15205 sales was greater than average salesAmount of 486
WITH cteTable(average_salesAmount) AS
(Select cast(AVG(SalesAmount)as int) 
from [dbo].[FactInternetSales]
)
select * from [dbo].[FactInternetSales] a,
cteTable b
where a.SalesAmount > b.average_salesAmount
order by a.SalesAmount ASC;