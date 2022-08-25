-------------------------
-- EG_01_Create Scripts
-- Product Sales 
-- March 2020
--------------------------

-- Create SalesChannel Table
DROP TABLE SalesChannel
CREATE TABLE SalesChannel 
( 
 	ChannelID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	ChannelName VARCHAR(10), 
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 


-- Insert  SalesChannel Data
INSERT INTO SalesChannel  
SELECT DISTINCT [SalesChannel],
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM SalesDW.[dbo].[ProductSales] 


-- Create Region Table
DROP TABLE Region
CREATE TABLE Region
( 
 	RegionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	RegionName VARCHAR(50), 
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 


-- Add new column for Region
ALTER TABLE ProductSales
ADD  RegionClean varchar(50)


-- Update statement
UPDATE ProductSales
SET RegionClean = CASE WHEN REGION = 'Central America and the C' THEN 'Central America and the Caribbean'
					 WHEN REGION = 'Middle East and North Afr' THEN 'Middle East and North Africa'
					ELSE REGION
					END 

--Checking update has worked
SELECT COUNT(*) AS COUNT,Region,RegionClean
FROM ProductSales
GROUP BY Region,RegionClean

-- Insert Region Data
TRUNCATE TABLE Region
INSERT INTO Region
SELECT DISTINCT RegionClean,
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM ProductSales

-- Create Customer Table
DROP TABLE Customer
CREATE TABLE Customer 
( 
 	CustID INT NOT NULL PRIMARY KEY, 
 	CustName VARCHAR(50),
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

--Insert Data
INSERT INTO Customer  
SELECT DISTINCT [CustID], 
[CustName],
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM SalesDW.[dbo].[ProductSales] 

-- Create Product Table
DROP TABLE Product
CREATE TABLE Product
(ProductID VARCHAR(8)  PRIMARY KEY,
ProductName VARCHAR(50),
StdCost NUMERIC(8,2),
StdPrice NUMERIC (8,2),
CreateTimestamp DATETIME,
UpdateTimestamp DATETIME
)

--Insert Data
INSERT INTO Product
SELECT DISTINCT ProductID,
ProductName,
StdCost,
StdPrice,
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM SalesDW.[dbo].[ProductSales] 

-- Create Country Table
DROP TABLE Country
CREATE TABLE Country 
( 
 	CountryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 	CountryName VARCHAR(50), 
   	RegionID INT FOREIGN KEY REFERENCES Region(RegionID),
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

--Insert Data
Truncate table Country
INSERT INTO Country  
SELECT DISTINCT [Country],  
 (
	    SELECT RegionID 
        FROM Region 
        WHERE RegionName = S.RegionClean
) ,
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM [SalesDW].[dbo].[ProductSales] AS S 

--Method 2 Insert
INSERT INTO Country 
SELECT DISTINCT S.Country, 
R.RegionID,
CURRENT_TIMESTAMP AS CreateTimestamp,
CURRENT_TIMESTAMP AS UpdateTimestamp
FROM Region AS R
INNER JOIN SalesDW.dbo.ProductSales AS S ON R.RegionName = S.RegionClean 


--Create Sale table
DROP TABLE Sale
CREATE TABLE Sale 
( 
    SaleID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    DateSold Date NOT NULL, 
 	ProductID VARCHAR(8) NOT NULL FOREIGN KEY REFERENCES
    Product(ProductID),
    CustID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustID), 
    CountryID INT NOT NULL FOREIGN KEY REFERENCES Country(CountryID), 
    ChannelID INT NOT NULL FOREIGN KEY REFERENCES SalesChannel(ChannelID), 
    UnitsSold INT NOT NULL,
	CreateTimestamp DATETIME,
	UpdateTimestamp DATETIME
) 

--Insert Data
INSERT INTO Sale  
SELECT         
 	S.dateSold,  
 	S.productID,  
 	S.custID,  
 	C.CountryID,  
 	SC.ChannelID,  
 	S.unitsSold,
	CURRENT_TIMESTAMP AS CreateTimestamp,
    CURRENT_TIMESTAMP AS UpdateTimestamp
FROM             
 	ProductSales AS S 
	INNER JOIN Country AS C ON S.Country = C.CountryName 
	INNER JOIN SalesChannel AS SC ON S.SalesChannel = SC.ChannelName 

---------------------------------------------------
-- Table Counts
---------------------------------------------------

SELECT COUNT(*) FROM Country
SELECT COUNT(*) FROM Region
SELECT COUNT(*) FROM SalesChannel
SELECT COUNT(*) FROM Customer
SELECT COUNT(*) FROM Product
SELECT COUNT(*) FROM Sale



---------------------------------------------------
-- Rename tables according to DW convention
---------------------------------------------------

EXEC sp_rename 'Product', 'dimProduct' 
EXEC sp_rename 'Customer', 'dimCustomer' 
EXEC sp_rename 'SalesChannel', 'dimSalesChannel' 
EXEC sp_rename 'Country', 'dimCountry' 
EXEC sp_rename 'Region', 'dimRegion' 
EXEC sp_rename 'Sale', 'factSale' 

----------End