/***************************************************************************************************

	Ensure base data files are copied to the folder C:\BaseDataFile\

	This script uploads the following files:
			- PropertySale_BaseData_Task1.csv
			- PropertySale_BaseData_Task2_Task3.csv

	into staging tables and then into the main tables (PropertySale_Task1,  PropertySale_Task2_Task3)

	Straight import by using of BULKL INSERT was not possible so the use of staging tables
	were require to proceed with the trasnformation.
	
****************************************************************************************************/
USE Working
GO

/*----------------------------------------------------
	Load base data into PropertySale_Task1_Staging
-----------------------------------------------------*/
TRUNCATE TABLE dbo.PropertySale_Task1_Staging;
TRUNCATE TABLE PropertySale_Task1;

BULK INSERT dbo.PropertySale_Task1_Staging
FROM 'C:\BaseDataFile\PropertySale_BaseData_Task1.csv'
WITH (FORMAT = 'CSV' , FIRSTROW=2 , FIELDTERMINATOR = ',' , ROWTERMINATOR = '\n' );

INSERT INTO dbo.PropertySale_Task1
( SaleID,AddressLine,Suburb,Postcode,State,SalePrice,SaleDate,PhoneNumber,CreateDate,ModifyDate )
SELECT	SaleID,
		AddressLine,
		Suburb,
		Postcode,
		State,
		SalePrice,
		CONVERT(DATETIME,SaleDate,103) as SaleDate,
		PhoneNumber,
		CONVERT(DATETIME,CreateDate,103) as CreateDate,
		CONVERT(DATETIME,ModifyDate,103) as ModifyDate
FROM	PropertySale_Task1_Staging;

--select * from PropertySale_Task1

/*--------------------------------------------------------
	Load base data into PropertySale_Task2_Task3_Staging
---------------------------------------------------------*/
TRUNCATE TABLE dbo.PropertySale_Task2_Task3_Staging;
TRUNCATE TABLE dbo.PropertySale_Task2_Task3;

BULK INSERT dbo.PropertySale_Task2_Task3_Staging
FROM 'C:\BaseDataFile\PropertySale_BaseData_Task2_Task3.csv'
WITH (FORMAT = 'CSV' , FIRSTROW=2 , FIELDTERMINATOR = ',' , ROWTERMINATOR = '\n');

INSERT INTO dbo.PropertySale_Task2_Task3
( SaleID,	AddressLine,Suburb,Postcode,State,SalePrice,SaleDate,PhoneNumber,CreateDate,ModifyDate )
SELECT	SaleID,
		AddressLine,
		Suburb,
		Postcode,
		State,
		SalePrice,
		CONVERT(DATETIME,SaleDate,103) as SaleDate,
		PhoneNumber,
		CreateDate,
		ModifyDate
FROM	PropertySale_Task2_Task3_Staging;

