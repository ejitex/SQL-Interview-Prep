USE WideWorldImporters
GO

SELECT TOP 10 * FROM [Purchasing].[PurchaseOrders]
ORDER BY ContactPersonID asc;

--CREATE UNIQUE CLUSTERED INDEX IND_IndexDetail
--ON [Purchasing].[PurchaseOrders](PurchaseOrderID, SupplierID, ContactPersonID);

CREATE VIEW Sales.CustomerBala

AS
-- Querying Bala's histortical order --

SELECT 
	SC.CustomerName, 
	SC.DeliveryAddressLine1, 
	SO.OrderDate,
	SoL.Quantity,
	SoL.UnitPrice, 
	SoL.Description
FROM Sales.Customers as SC
INNER JOIN Sales.Orders as SO
ON SC.CustomerID = SO.CustomerID
INNER JOIN Sales.OrderLines AS SoL
ON SoL.OrderID = SO.OrderID
WHERE SC.CustomerID = 803
---ORDER BY SO.OrderDate DESC;

GO

SELECT * FROM Sales.CustomerBala;

-- Querying the most recent order from Tailspin whose OrderID = 123

SELECT 
	SC.CustomerName, 
	SC.DeliveryAddressLine1, 
	SO.OrderDate,
	SoL.Quantity,
	SoL.UnitPrice, 
	SoL.Description
FROM Sales.Customers as SC
INNER JOIN Sales.Orders as SO
ON SC.CustomerID = SO.CustomerID
INNER JOIN Sales.OrderLines AS SoL
ON SoL.OrderID = SO.OrderID
WHERE SO.OrderID = (SELECT TOP 1 Sales.Orders.OrderID 
FROM Sales.Orders
WHERE OrderID = 123
ORDER BY OrderDate DESC)


ALTER FUNCTION Sales.LastOrder (@CustomerID AS INT)
RETURNS TABLE
AS RETURN
SELECT 
	SC.CustomerName,
	SC.CustomerID,
	SC.DeliveryAddressLine1, 
	SO.OrderDate,
	SO.OrderID,
	SoL.Quantity,
	SoL.UnitPrice, 
	SoL.Description
FROM Sales.Customers as SC
INNER JOIN Sales.Orders as SO
ON SC.CustomerID = SO.CustomerID
INNER JOIN Sales.OrderLines AS SoL
ON SoL.OrderID = SO.OrderID
WHERE SO.OrderID = (SELECT TOP 1 Sales.Orders.OrderID
FROM Sales.Orders
WHERE CustomerID = @CustomerID
ORDER BY OrderDate DESC)

SELECT * FROM Sales.LastOrder(426)

SELECT * FROM [Sales].[Customers];
GO


SELECT TOP 2 * FROM [Sales].[Customers];
SELECT TOP 2 * FROM [Sales].[Orders];
GO

CREATE OR ALTER PROC Sales.usp_getCustomerOrderbyID (@CustomerIDNumber AS INT)
AS
SELECT CustomerTable.CustomerName,
CustomerTable.CustomerID,
CustomerTable.PhoneNumber,
CustomerTable.PaymentDays 
FROM [Sales].[Customers] AS CustomerTable
WHERE CustomerTable.CustomerID = @CustomerIDNumber;

SELECT OrderTable.OrderID,
OrderTable.OrderDate, 
OrderTable.Comments
--OrderTable.CustomerID
FROM [Sales].[Orders] AS OrderTable
WHERE OrderTable.CustomerID = @CustomerIDNumber;

GO

EXEC Sales.usp_getCustomerOrderbyID 823;
EXEC Sales.usp_getCustomerOrderbyID 803;

SELECT TOP 1 * FROM [Sales].[Orders];
SELECT TOP 1 * FROM [Sales].[OrderLines];
SELECT TOP 1 * FROM [Purchasing].[PurchaseOrders];

SELECT TOP 200 
SO.OrderID,
SO.OrderDate,
SO.ExpectedDeliveryDate,
DATEDIFF(DD,SO.OrderDate, SO.ExpectedDeliveryDate) AS LeadTime
FROM [Sales].[Orders] AS SO

DECLARE @counter AS INT
SET @counter = 1

WHILE @counter < 10

BEGIN
	SET @counter = @counter + 1
END;

SELECT @counter
