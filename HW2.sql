--question answering
--1. A result set is a set of requested rows from a database, as well as metadata about the query such as the column names, and the types and sizes of each column under user-defined conditions.

--2. UNION extracts the rows that are being specified in the query while UNION ALL extracts all the rows including the duplicates (repeated values) from both the queries.

--3. INTERSECT (takes the results of two queries and returns only rows that appear in both result sets) and EXCEPT (takes the distinct rows of one query and returns the rows that do not appear in a second result set).

--4. JOIN is used to combine columns from different tables, while UNION is used to combine rows. The number of columns must be the same for both select statements of UNION.

--5. INNER JOIN only produces results appearing in both tables while FULL JOIN produces results appearing in either tables, even the first table and the second table have NULL results.

--6. LEFT JOIN returns all records from left table, matched from right, returning null while RIGHT JOIN returns all records from right table, matched from left, returning null.

--7. The CROSS JOIN is the Cartesian product of the two tables, meaning a paired combination of each row of the first table with each row of the second table.

--8. The are basically 7 differences:
--a. WHERE is used to filter the records from the table while HAVING is used to filter records from the group;
--b. WHERE can be used without GROUP BY while HAVING is not;
--c. WHERE is used before GROUP BY while HAVING is after;
--d. WHERE implements in row operations while HAVING in column operation;
--e. WHERE cannot contain aggregate function while HAVING can;
--f. WHERE can be used with SELECT, UPDATE, and DELETE while HAVING only SELECT;
--g. WHERE is used with single row function while HAVING is used with multiple row function like SUM, COUNT etc.

--9.There can be multiple group by columns and all fields other than aggregation functions appeared in SELECT should be included in GROUP BY.

--queries writing
USE AdventureWorks2019
GO

--1
SELECT COUNT(*) as TotalNumOfProducts
FROM Production.Product

--2
SELECT COUNT(ProductSubcategoryID) as NumOfSubcategoryID
FROM Production.Product

--3
SELECT ProductSubcategoryID, COUNT(*) as CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID
HAVING ProductSubcategoryID IS NOT NULL

--4
SELECT ProductSubcategoryID, COUNT(*) as CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID
HAVING ProductSubcategoryID IS NULL

--5
SELECT SUM(Quantity) 
FROM Production.ProductInventory
GROUP BY ProductID

--6
SELECT ProductID, SUM(Quantity) as TheSum
FROM Production.ProductInventory
WHERE LocationID = 4
GROUP BY ProductID
HAVING SUM(Quantity) < 100

--7
SELECT Shelf, ProductID, SUM(Quantity) as TheSum
FROM Production.ProductInventory
WHERE LocationID = 4
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100

--8
SELECT AVG(Quantity) as AverageQuantity
FROM Production.ProductInventory
WHERE LocationID = 10

--9
SELECT ProductID, Shelf, AVG(Quantity) as TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

--10
SELECT ProductID, Shelf, AVG(Quantity) as TheAvg
FROM Production.ProductInventory
WHERE Shelf IS NOT NULL
GROUP BY ProductID, Shelf

--11
SELECT Color, Class, COUNT(*) as TheCount, AVG(ListPrice) as AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12
SELECT c.Name as Country, s.Name as Province
FROM Person.CountryRegion c JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode

--13
SELECT c.Name as Country, s.Name as Province
FROM Person.CountryRegion c JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')

USE Northwind
GO
--14
SELECT DISTINCT od.ProductID
FROM Orders o JOIN [Order Details] od on o.OrderID = od.OrderID
WHERE year(getDate()) - year(o.OrderDate) < 25

--15
SELECT TOP 5 ShipPostalCode
FROM Orders
WHERE ShipPostalCode IS NOT NULL
GROUP BY ShipPostalCode
ORDER BY COUNT(*) DESC

--16
SELECT TOP 5 o.ShipPostalCode
FROM Orders o JOIN [Order Details] od on o.OrderID = od.OrderID
WHERE year(getDate()) - year(o.OrderDate) < 25
GROUP BY o.ShipPostalCode
ORDER BY COUNT(o.OrderID) DESC

--17
SELECT City, COUNT(DISTINCT CustomerID) as CustomerNumber
FROM Customers
GROUP BY City

--18
SELECT City, COUNT(DISTINCT CustomerID) as CustomerNumber
FROM Customers
GROUP BY City
HAVING COUNT(DISTINCT CustomerID) > 2

--19
SELECT DISTINCT c.ContactName as CustomerName
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1998-01-01'

--20
SELECT c.CompanyName as CustomerName, MAX(o.OrderDate) as MostRecentOrderDates
FROM (Customers c JOIN Orders o ON c.CustomerID = o.CustomerID)
GROUP BY c.CompanyName

--21
SELECT c.CompanyName as CustomerName, SUM(od.Quantity) as CountOfProduct
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CompanyName

--22
SELECT c.CustomerID
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.ContactName
HAVING SUM(od.Quantity) > 100

--23
SELECT su.CompanyName as [Supplier Company Name], sh.CompanyName as [Shipping Company Name]
FROM Suppliers su JOIN Products p on su.SupplierID = p.SupplierID JOIN [Order Details] od ON p.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID JOIN Shippers sh ON o.ShipVia = sh.ShipperID
GROUP BY su.CompanyName, sh.CompanyName

--24
SELECT o.OrderDate as OrderDate, p.ProductName as ProductName
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON p.ProductID = od.ProductID
GROUP BY o.OrderDate, od.ProductID

--25
SELECT e1.FirstName + ' ' + e1.LastName as FirstEmpolyeeName, e2.FirstName + ' ' + e2.LastName as SecondEmpolyeeName, e1.title
FROM Employees e1 JOIN Employees e2 on e1.Title = e2.Title
WHERE e1.EmployeeID > e2.EmployeeID

--26
SELECT m.FirstName + ' ' + m.LastName as FirstEmpolyeeName
FROM Employees m JOIN Employees e ON m.EmployeeID = e.ReportsTo
GROUP BY m.FirstName, m.LastName
HAVING COUNT(e.ReportsTo) > 2

--27
SELECT CompanyName as Name, City, 'Customers' as Type
FROM Customers

UNION

SELECT CompanyName as Name, City, 'Suppier' as Type
FROM Suppliers

--28
CREATE TABLE T1(F1 int primary key)
INSERT INTO T1 VALUES (1), (2), (3)

CREATE TABLE T2(F2 int primary key)
INSERT INTO T2 VALUES (2), (3), (4)

SELECT T1.F1
FROM T1 JOIN T2 ON T1.F1 = T2.F2

/*
result:
T1.F1 | T2.F2
--------------
  2   |   2
  3   |   3
*/

--29
SELECT T1.F1
FROM T1 LEFT JOIN T2 ON T1.F1 = T2.F2

/*
result:
T1.F1 | T2.F2
---------------
  1   |  NULL
  2   |  2
  3   |  3
*/
