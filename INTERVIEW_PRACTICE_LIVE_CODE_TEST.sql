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
ORDER BY AVR desc;


SELECT FirstName +' '+ LastName AS Employee, Title,  BaseRate
FROM [dbo].[DimEmployee]
WHERE BaseRate in (SELECT AVG(BaseRate) as AverageWages
		FROM [dbo].[DimEmployee]
		GROUP BY Title
		HAVING AVG(BaseRate) <= 15
		)

ORDER BY BaseRate DESC;

/* 

INTERVIEW PRACTICE QUESTION - section copied from data36.com


-- Create an SQL query that shows the TOP 3 authors who sold the most books in total!

SELECT  TOP 3 a.author_name, Sum(b.sold_copies) as totalCopiesSold 
FROM authors as a
inner join books as b
on a.book_name = b.book_name
group by a.author_name
order by totalCopiesSold desc;


--Write an SQL query to find out how many users inserted more than 1000 but less than 2000 images in their presentations!

select count(*) from (select user_id,count(event_date_time) 
                        from event_log
                        group by user_id) as x
                        
where x > 1000 and x < 2000;


--Print every department where the average salary per employee is lower than $500!

select e.department_name,AVG(s.salary) as averageSalary from employees as e
inner join salaries as s
on e.employee_id = s.employee_id
group by e.department_name
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


-- query customer first,last name,occupation where the customer purchase greater or equal 30 purchases in 
--factinternet sales table

with ctetable(Customer, numberofPurchase) AS
(select fs.CustomerKey ,count(*) as countvalue from [dbo].[FactInternetSales] as fs
group by fs.CustomerKey)

select a.FirstName,a.LastName,a.EnglishOccupation,b.numberofPurchase from [dbo].[DimCustomer] as a
join ctetable as b
on a.CustomerKey = b.Customer
where b.numberofPurchase >= 30
order by b.numberofPurchase desc;

/* 
USE CASES OF SUBQUERY
-- SUBQUERY IN FROM CLAUSE - the most commonly asked in interview and a good example of subquery use case
*/

---subquery in from clause example
-- How many customer made 30 or more purchases in our factinternetsales table 
select count(*) from (select fsales.CustomerKey, count(fsales.CustomerKey) as NumberofPurchasebyCus from [dbo].[FactInternetSales] as fsales
						group by fsales.CustomerKey) as x
where x.NumberofPurchasebyCus >= 30;


-- query all department name where average wage greater than $19
-- Remember using alias is required when using SUBquery in FROM Clause

SELECT * FROM 
	(SELECT DepartmentName, AVG(BaseRate) AS deptAVGWage 
	FROM [dbo].[DimEmployee]
	GROUP BY DepartmentName)
AS deptAVGWage
WHERE deptAVGWage >= 19
ORDER BY deptAVGWage DESC;



SELECT TOP 1 * FROM 
(SELECT DISTINCT TOP 10 BaseRate FROM
	[dbo].[DimEmployee]
	ORDER BY BaseRate DESC)
AS Employee ORDER BY BaseRate;


-- 10 MOST EXPENSIVE PRODUCTs
SELECT DISTINCT TOP 10 P.EnglishProductName,S.UnitPrice FROM [dbo].[FactInternetSales] S
INNER JOIN [dbo].[DimProduct] P
ON S.ProductKey = P.ProductKey
ORDER BY  S.UnitPrice DESC;


-- subquery in select clause
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

--Subquery in Where Clause
--- use subquery to query product names where sales made between Jan to March 2014
SELECT 
DISTINCT(product.EnglishProductName),
product.ProductKey
FROM [dbo].[DimProduct] product
WHERE product.ProductKey IN(
						SELECT Fsales.ProductKey 
						FROM [dbo].[FactInternetSales] AS Fsales
						WHERE Fsales.OrderDate >= '2014-01-01' AND Fsales.OrderDate <= '2014-03-31');


---make a few changes to the above query to return how many department with avg wage greater than $19

SELECT COUNT(*) AS howMany FROM 
	(SELECT DepartmentName, AVG(BaseRate) AS deptAVGWage 
	FROM [dbo].[DimEmployee]
	GROUP BY DepartmentName)
AS deptAVGWage
WHERE deptAVGWage >= 19


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



--- AGGREGRATE FUNCTION WITH GROUPING BY MULTIPLE COLNS

SELECT DISTINCT productTable.EnglishProductName ,OrderDate, Sum(SalesAmount) as sumSales
FROM [dbo].[FactInternetSales] AS salestable
INNER JOIN [dbo].[DimProduct] AS productTable
ON salestable.ProductKey = productTable.ProductKey
GROUP BY productTable.EnglishProductName, OrderDate
HAVING productTable.EnglishProductName LIKE '%Bike%'
ORDER BY OrderDate desc, sumSales DESC;

-- Window Function

SELECT customerTable.EnglishOccupation, salesTable.SalesAmount,
rank()
OVER(PARTITION BY customerTable.EnglishOccupation ORDER BY salesTable.SalesAmount DESC) AS Rankcol,
dense_rank()
OVER(PARTITION BY customerTable.EnglishOccupation ORDER BY salesTable.SalesAmount DESC) AS DenseRank,
row_number()
OVER(PARTITION BY customerTable.EnglishOccupation ORDER BY salesTable.SalesAmount DESC) AS rowNumber
FROM [dbo].[DimCustomer] AS customerTable
INNER JOIN [dbo].[FactInternetSales] AS salesTable
ON customerTable.CustomerKey = salesTable.CustomerKey

;

SELECT count(*) AS orderbycustomer
FROM [dbo].[FactInternetSales] AS salesTable
INNER JOIN [dbo].[DimCustomer] AS customerTable
ON customerTable.CustomerKey = salesTable.CustomerKey
where customerTable.LastName = 'Adams';

/*
-- Get top 3 most recent order for every customer
 
select top 3 * from [Sales].[Orders]
order by OrderDate desc;

SELECT COUNT(*) FROM [dbo].[FactInternetSales]
WHERE CustomerKey = 11016;
*/

--- get top 3 employees with highest wage in each department. dif btw rank and dense_rank?

SELECT * FROM(
SELECT e.FirstName, e.LastName, e.DepartmentName,e.BaseRate,
dense_rank() over(partition by DepartmentName ORDER BY BaseRate Desc) AS rnk
FROM [dbo].[DimEmployee] AS e) AS a
WHERE a.rnk <= 3;


--Compare wage difference base on employee hireDate

SELECT e.EmployeeKey,e.FirstName,e.LastName,e.StartDate, e.DepartmentName, e.BaseRate , 
LAG(e.BaseRate) OVER (PARTITION BY e.DepartmentName ORDER BY e.StartDate) as previous_BaseRate
FROM [dbo].[DimEmployee] AS e;


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


SELECT e.DepartmentName, sum(e.BaseRate) as sum_BaseWage FROM [dbo].[DimEmployee] as e
GROUP BY e.DepartmentName
HAVING sum(e.BaseRate) > 100  AND sum(e.BaseRate) < 200
ORDER BY sum_BaseWage desc;

select a.DepartmentName, 
AVG(a.BaseRate) 
OVER (PARTITION BY a.DepartmentName ORDER BY a.BaseRate ASC) AS AVG_BaseRateDept
from [dbo].[DimEmployee] a

--get last ID row without using aggregate function like MAX

select distinct top 1 * from [dbo].[FactInternetSales]
order by ProductKey desc;

--count how many salesamount was greater than average salesAmount of 486
select count(*) as CountofSalesAmountHigerAVG from [dbo].[FactInternetSales] as sales
where sales.SalesAmount >= (select AVG(SalesAmount) from [dbo].[FactInternetSales] );

--How would you print those sales and their details
--- CTE
--15205 salesamount was greater than average salesAmount of 486

WITH cteTable(average_salesAmount) AS
(Select cast(AVG(SalesAmount)as int) 
from [dbo].[FactInternetSales]
)
select * from [dbo].[FactInternetSales] a,
cteTable b
where a.SalesAmount >= b.average_salesAmount
order by a.SalesAmount ASC;



-- find employees with wages higher than average wage
select * from [dbo].[DimEmployee]
where BaseRate > 18.5
ORDER BY BaseRate;

SELECT FirstName,LastName, BaseRate FROM [dbo].[DimEmployee]
WHERE BaseRate > (SELECT AVG(BaseRate) FROM [dbo].[DimEmployee])
ORDER BY BaseRate;

-- count number of employees with wages higher than average wage
-- how many employees earns wages higher than average wage
SELECT count(*) as aboveAverageWageEmp FROM [dbo].[DimEmployee]
WHERE BaseRate > (SELECT AVG(BaseRate) FROM [dbo].[DimEmployee]);


-- print employee with highest wage in every department

WITH ctetable(DepartmentName, maxWage)
AS
(Select DepartmentName, MAX(BaseRate) from [dbo].[DimEmployee]
group by DepartmentName)

select * from [dbo].[DimEmployee] a
join ctetable as b
on a.DepartmentName = b.DepartmentName
where a.BaseRate = b.maxWage;

-- print employees with wage greater than their department average wage
WITH cteAVGtable(DepartmentName, AverageWage) AS
(select emp.DepartmentName,AVG(emp.BaseRate) 
from [dbo].[DimEmployee] as emp
group by emp.DepartmentName)

select * from [dbo].[DimEmployee] as a
join cteAVGtable as b
on a.DepartmentName = b.DepartmentName
where a.BaseRate > b.AverageWage;

---could also be written as below using Correlated subquery
-- print employees with wage greater than their department average wage
Select * from [dbo].[DimEmployee] as e1
Where BaseRate > (select AVG(BaseRate) from [dbo].[DimEmployee] as e2
where e1.DepartmentName = e2.DepartmentName);



-- return shift with a highest total calls

select max(totals) from (select Shift, sum(Calls) as totals
from [dbo].[FactCallCenter]
group by Shift) as a;

-- best answer
select top 1 Shift, sum(Calls) as totals
from [dbo].[FactCallCenter]
group by Shift
order by totals desc;


-- return department with highest wage rate
SELECT TOP 1 a.DepartmentName,MAX(a.BaseRate) AS deptWithMaxWage  FROM [dbo].[DimEmployee] AS a
GROUP BY a.DepartmentName
ORDER BY deptWithMaxWage DESC;

--- count how many employees per department
SELECT a.DepartmentName,count(a.EmployeeKey) AS empCount  FROM [dbo].[DimEmployee] AS a
GROUP BY a.DepartmentName
ORDER BY empCount DESC;


--sales by product category
select d.EnglishProductCategoryName, c.EnglishProductSubcategoryName, round(SUM(a.SalesAmount),2) as TotalSales  from [dbo].[FactInternetSales] AS a
inner join [dbo].[DimProduct] AS b
on a.ProductKey = b.ProductKey
inner join [dbo].[DimProductSubcategory] as c
on b.ProductSubcategoryKey = c.ProductSubcategoryKey
inner join [dbo].[DimProductCategory] as d
on c.ProductCategoryKey = d.ProductCategoryKey
group by d.EnglishProductCategoryName,c.EnglishProductSubcategoryName
order by TotalSales desc;

-- Over Clause in agg function
-- total productcategory sales by year

SELECT distinct 
salesdate.FiscalYear,
SUM(sales.SalesAmount)
OVER (PARTITION BY salesdate.FiscalYear) AS YearlySales
FROM [dbo].[DimDate] AS salesdate
inner join [dbo].[FactInternetSales] as sales
on salesdate.DateKey = sales.DueDateKey
--inner join [dbo].[DimProduct] as product
--on sales.ProductKey = product.ProductKey
--inner join [dbo].[DimProductSubcategory] as subcat
--on product.ProductSubcategoryKey = subcat.ProductSubcategoryKey
--inner join [dbo].[DimProductCategory] as cat
--on subcat.ProductCategoryKey = cat.ProductCategoryKey
order by salesdate.FiscalYear asc;


