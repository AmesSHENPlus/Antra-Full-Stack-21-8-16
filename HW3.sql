--Question
--1. JOINs should be chosen over subqueries since JOINs usually have a better performance.

--2. CTE stands for common table expression, which allows to define a temporary named result set that available temporarily in the execution scope of a statement such as SELECT, INSERT, UPDATE, DELETE, or MERGE. CTE can be used when subqueries are needed.

--3. The table variable is a special type of the local variable that helps to store data temporarily, similar to the temp table in SQL Server. The table variable scope is within the batch. Table variables are stored in the tempdb database.

--4. There are 11 distinctions:
--1) Delete command is useful to delete all or specific rows from a table specified using a Where clause. The truncate command removes all rows of a table. We cannot use a Where clause in this.
--2) DELETE is DML and TRUNCATE is DDL.
--3) SQL Delete command places lock on each row requires to delete from a table. SQL Truncate command places a table and page lock to remove all records.
--4) Delete command logs entry for each deleted row in the transaction log. The truncate command does not log entries for each deleted row in the transaction log.
--5) Delete command is slower than the Truncate command.
--6) DELETE removes rows one at a time. TRUNCATE removes all rows in a table by deallocating the pages that are used to store the table data.
--7) DELETE retains the identity and does not reset it to the seed value. TRUNCATE command reset the identity to its seed value.
--8) DELETE requires more transaction log space than the truncate command. TRUNCATE requires less transaction log space than the truncate command.
--9) You require delete permission on a table to use DELETE. You require Alter table permissions to truncate a table.
--10) You can use the DELETE statement with the indexed views. You cannot use the TRUNCATE command with the indexed views.
--11) DELETE command retains the object statistics and allocated space. TRUNCATE deallocates all data pages of a table. Therefore, it removes all statistics and allocated space as well.
--TRUNCATE TABLE is faster and uses fewer system resources than DELETE, because DELETE scans the table to generate a count of rows that were affected then delete the rows one by one and records an entry in the database log for each deleted row, while TRUNCATE TABLE just delete all the rows without providing any additional information.

--5. A DELETE statement preserves the IDENTITY value. A TRUNCATE statement resets the IDENTITY back to 0.

--6. Use TRUNCATE TABLE if you just want to delete all the rows and re-create the whole table. Use DELETE either if you want to delete limited number of rows based on specific condition or you don't want to reset the auto-increment value.

--Query
USE Northwind
GO
--1
SELECT DISTINCT c.City
FROM Customers c JOIN Employees e ON c.City = e.City

--2
--a
SELECT DISTINCT	City
FROM Customers
WHERE City NOT IN (
SELECT DISTINCT c.City
FROM Customers c JOIN Employees e ON c.City = e.City)

--3
SELECT DISTINCT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL

--4
SELECT c.City, p.ProductID
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID
ORDER BY 1

--5
--a
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 2

--b
SELECT c1.City
FROM Customers c1 JOIN
(SELECT City, CustomerID
FROM Customers) c2 ON c1.CustomerID = c2.CustomerID

--6
SELECT c.City
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.City
HAVING COUNT(p.ProductID) >= 2

--7
SELECT DISTINCT c.ContactName
FROM Customers c JOIN Orders O on c.CustomerID = o.CustomerID
WHERE c.City != o.ShipCity

--8
SELECT od.ProductID,  od.AvgPrice, oc.city
FROM (SELECT TOP 5 ProductID, SUM(Quantity) AS SumQuantity, SUM(Quantity*UnitPrice*(1-Discount))/SUM(Quantity) AS AvgPrice FROM [Order Details] GROUP BY ProductID ORDER BY 2 DESC) od JOIN 
(SELECT od.ProductID, c.City, SUM(od.Quantity) AS SumCityQuantity, RANK() OVER(PARTITION BY od.ProductID ORDER BY SUM(od.Quantity)) AS RNK FROM [Order Details] od JOIN Orders o ON od.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID GROUP BY od.ProductID, c.City) oc ON od.ProductID = oc.ProductID
WHERE oc.RNK = 1

--9
--a
SELECT City
FROM Employees
WHERE City NOT IN (SELECT ShipCity FROM Orders)

--b
SELECT City FROM Employees
EXCEPT
SELECT ShipCity FROM Orders

--10
SELECT RNK1.City
FROM (SELECT e.City, RANK() OVER (ORDER BY COUNT(o.OrderID) DESC) AS RNK FROM Employees e JOIN Orders o ON e.EmployeeID = o.EmployeeID GROUP BY e.city) RNK1 JOIN 
(SELECT c.city, RANK() OVER (ORDER BY SUM(od.Quantity) DESC) AS RNK FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID GROUP BY c.City) RNK2 ON RNK1.RNK = RNK2.RNK
WHERE RNK1.City = RNK2.City

--11
CREATE TABLE Employee(empid int primary key, mgrid integer, deptid integer, salary money)
INSERT INTO Employee

CREATE TABLE Dept(deptid int primary key, deptname varchar(20))
INSERT INTO Dept VALUES (2), (3), (4)

WITH cte AS (
    SELECT empid, mgrid, deptid, salary
        ROW_NUMBER() OVER (
            PARTITION BY mgrid, deptid, salary
            ORDER BY mgrid, deptid, salary
        ) row_num
     FROM Employee
)
DELETE FROM cte
WHERE row_num > 1;

--12
SELECT empid
FROM Employee
WHERE mgrid IS NULL

--13
SELECT d.deptname, COUNT(e.empid) AS CountOfEmployee
FROM Employee e JOIN Dept d on e.deptid = d.deptid 
WHERE COUNT(e.empid) = (SELECT TOP 1 COUNT(empid) FROM Employee GROUP BY deptid ORDER BY 1 DESC)
GROUP BY d.deptid

--14
SELECT d.deptname, e.empid, E.salary
FROM Employee e JOIN Dept d on e.deptid = d.deptid JOIN 
(SELECT empid, RANK() OVER(PARTITION BY deptid ORDER BY COUNT(salary) DESC) AS RNK FROM Employee GROUP BY deptid) RNK
ON e.empid = RNK.empid
WHERE RNK.RNK <= 3


