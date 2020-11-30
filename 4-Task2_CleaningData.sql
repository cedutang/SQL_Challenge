/****************************************************************************************************************
	TASK #2 - Cleaning Data
	
	This script remove duplicate records from PropertySale_Task2_Task3 table.
	
*****************************************************************************************************************/

/*------------------------------------------------------------------------------------------
	If there are more than two records with the same values for Address and SalePrice, 
	then we wish to retain two of the records, the one with the earliest SaleDate and the 
	one with the latest SaleDate
--------------------------------------------------------------------------------------------*/
USE Working
GO

BEGIN TRAN
;
WITH CTE_MoreThan2RecordsWithSameValues
AS
(
	SELECT	AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR) as ID
	FROM	PropertySale_Task2_Task3
	GROUP BY AddressLine,Suburb,Postcode,State,SalePrice
	HAVING COUNT(*) > 2
),
CTE_MaxMin
AS
(
	SELECT	(AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR)) as ID
			,MIN(SaleDate) as Min_Saledate 
			,MAX(SaleDate) as Max_Saledate
	FROM	[dbo].[PropertySale_Task2_Task3] 
	WHERE	(AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))
			IN	(
					SELECT	ID
					FROM	CTE_MoreThan2RecordsWithSameValues
				)
	GROUP BY AddressLine,Suburb,Postcode,State,SalePrice
)
DELETE	p
FROM	PropertySale_Task2_Task3 p
		INNER JOIN CTE_MaxMin c ON c.ID = (AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))
WHERE	p.SaleDate > Min_Saledate AND p.SaleDate < Max_Saledate;

IF @@ERROR != 0
	BEGIN
		RAISERROR('Cannot delete #1 on PropertySale_Task2_Task3 table',16,1)
		ROLLBACK TRAN
		RETURN
	END
COMMIT TRAN

PRINT 'Successfull deletion #1 on PropertySale_Task2_Task3 table.'


/*---------------------------------------------------------------------------------------------
	If there is more than 1 record with the sale values for Address, SalePrice and SaleDate, 
	then we wish to retain the one with the largest SaleID
----------------------------------------------------------------------------------------------*/
BEGIN TRAN
;
WITH CTE_MoreThan1RecordWithSameAddressSalePriceSaleDate
AS
(
	SELECT	(AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))+CONVERT(VARCHAR,SaleDate,112) as ID
	FROM	PropertySale_Task2_Task3
	GROUP BY AddressLine,Suburb,Postcode,State,SalePrice,SaleDate
	HAVING COUNT(*) > 1
),
CTE_LargestSaleID
AS
(
	SELECT	(AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))+CONVERT(VARCHAR,SaleDate,112) as ID
			,MAX(SaleID) as Max_SaleID
	FROM	[dbo].[PropertySale_Task2_Task3] 
	WHERE	(AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))+CONVERT(VARCHAR,SaleDate,112)
			IN	(
					SELECT	ID
					FROM	CTE_MoreThan1RecordWithSameAddressSalePriceSaleDate
				)
	GROUP BY AddressLine,Suburb,Postcode,State,SalePrice,SaleDate
)
DELETE	p
FROM	PropertySale_Task2_Task3 p
		INNER JOIN CTE_LargestSaleID c ON c.ID = (AddressLine+Suburb+Postcode+State+CAST(SalePrice as VARCHAR))+CONVERT(VARCHAR,SaleDate,112)
WHERE	p.SaleID < c.Max_SaleID

IF @@ERROR != 0
	BEGIN
		RAISERROR('Cannot delete #2 on PropertySale_Task2_Task3 table',16,1)
		ROLLBACK TRAN
		RETURN
	END
COMMIT TRAN

PRINT 'Successfull deletion #2 on PropertySale_Task2_Task3 table.'


