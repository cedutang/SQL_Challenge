/****************************************************************************************************************
	TASK #1 - Import New Data File and Matching

	Ensure the weekly imput dataset is copied to the folder C:\Weeekly_NewDataFile\

	This script imports the weekly data from a spreadsheet copied in the folder mentioned above.

	It is using a staging table as a prior step before copying the data into a table with an IDENTITY column. 

	This IDENTITY column makes easy the manipulation of the new imported data since there is no PK or numeric
	column that can be used as a KEY.

*****************************************************************************************************************/
USE Working
GO

DROP TABLE IF EXISTS dbo.NewDataFile_Staging;
DROP TABLE IF EXISTS dbo.NewDataFile;
DROP TABLE IF EXISTS dbo.#TMP_SameData;
DROP TABLE IF EXISTS dbo.#TMP_RecordsToUpdate

CREATE TABLE dbo.NewDataFile_Staging
(
	[Address]	VARCHAR(100) NULL,
	[Date]		VARCHAR(500) NULL,
	Phone		VARCHAR(500) NULL,
	Price		VARCHAR(500) NULL
);

CREATE TABLE dbo.NewDataFile
(
	SaleID		INT IDENTITY(1,1),
	[Address]	VARCHAR(100) NULL,
	[Date]		VARCHAR(500) NULL,
	Phone		VARCHAR(500) NULL,
	Price		VARCHAR(500) NULL
);


BULK INSERT dbo.NewDataFile_Staging
FROM 'C:\Weeekly_NewDataFile\NewInputDataset_SampleData.csv'
WITH (FORMAT = 'CSV' , FIRSTROW=2 , FIELDTERMINATOR = ',' , ROWTERMINATOR = '\n' );

-- Populate NewDataFile table from staging data. This will generate IDENTITY values for the new data.
INSERT INTO dbo.NewDataFile
SELECT	* FROM	dbo.NewDataFile_Staging

/*-----------------------------------------------------------------------
	Returns records with same address, price, date, and phone number.
	Records are dumped into #TMP_SameData table to be used later.
-------------------------------------------------------------------------*/
SELECT	--p.SaleID as Existing_SaleID,
		DISTINCT
		t.SaleID as NewDataFile_SaleID
INTO	#TMP_SameData
FROM	dbo.PropertySale_Task1 p
		INNER JOIN dbo.NewDataFile t
			ON REPLACE(t.Address,' ','') = REPLACE(p.AddressLine,' ','') + '|' + REPLACE(p.Postcode,' ','') + '|' + REPLACE(p.State,' ','') + '|' + REPLACE(p.Suburb,' ','')	--remove blanks from both sides
WHERE	ISNULL(p.SalePrice,0) = ISNULL(CAST(REPLACE(t.Price,'$','') AS real),0)
		AND CONVERT(VARCHAR,p.SaleDate,103) = CONVERT(VARCHAR,[Date],103)
		AND REPLACE(REPLACE(ISNULL(p.PhoneNumber,''),' ',''),'-','') = REPLACE(REPLACE(ISNULL(t.Phone,''),' ',''),'-','')


/*--------------------------------------------------------------------------------------------------------------------------------
	Returns records with same address, dates are within 60 days of each other, but price, date or phone number are different.
	Records are dumped into #TMP_RecordsToUpdate table to be used later.
---------------------------------------------------------------------------------------------------------------------------------*/
SELECT	p.SaleID as Existing_SaleID,
		t.SaleID as NewDataFile_SaleID,
		t.[Address],
		t.[Date],
		t.Phone,
		t.Price
INTO	#TMP_RecordsToUpdate
FROM	dbo.PropertySale_Task1 p
		INNER JOIN dbo.NewDataFile t
			ON REPLACE(t.Address,' ','') = REPLACE(p.AddressLine,' ','') + '|' + REPLACE(p.Postcode,' ','') + '|' + REPLACE(p.State,' ','') + '|' + REPLACE(p.Suburb,' ','')
WHERE	DATEDIFF(day,p.SaleDate,CONVERT(DATETIME,CONVERT(VARCHAR,[Date],103),103)) = 60
		AND	(
				p.SalePrice <> CAST(REPLACE(t.Price,'$','') AS real) OR
				CONVERT(VARCHAR,p.SaleDate,103) <> CONVERT(VARCHAR,[Date],103) OR
				REPLACE(REPLACE(ISNULL(p.PhoneNumber,''),' ',''),'-','') <> REPLACE(REPLACE(ISNULL(t.Phone,''),' ',''),'-','')
			)
		AND t.SaleID NOT IN (SELECT NewDataFile_SaleID FROM #TMP_SameData)	--exclude existing data


/*------------------------------------------------------------------------
	Update existing records based on the #TMP_RecordsToUpdate table.
-------------------------------------------------------------------------*/
BEGIN TRAN
UPDATE	p
SET		p.SaleDate = CONVERT(DATETIME,CONVERT(VARCHAR,t.[Date],103),103),
		p.PhoneNumber = t.Phone,
		p.SalePrice = CAST(REPLACE(t.Price,'$','') AS real)
FROM	PropertySale_Task1 p
		INNER JOIN #TMP_RecordsToUpdate t ON p.SaleID = t.Existing_SaleID
				
IF @@ERROR != 0
	BEGIN
		RAISERROR('Cannot update on PropertySale_Task1 table',16,1)
		ROLLBACK TRAN
		RETURN
	END
COMMIT TRAN

PRINT 'Successfull update on PropertySale_Task1 table.'

/*----------------------------
	Insert new records.
-----------------------------*/
BEGIN TRAN
INSERT INTO PropertySale_Task1 ( SaleID,AddressLine,Suburb,Postcode,State,SalePrice,SaleDate,PhoneNumber )
SELECT	(SELECT MAX(SaleID) FROM dbo.PropertySale_Task1) + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as SaleID,
		TRIM(PARSENAME(REPLACE(Address,'|','.'),4)) as AddressLine,		
		TRIM(PARSENAME(REPLACE(Address,'|','.'),1)) as Suburb,
		TRIM(PARSENAME(REPLACE(Address,'|','.'),3)) as Postcode,
		TRIM(PARSENAME(REPLACE(Address,'|','.'),2)) as [State],		
		CAST(REPLACE(Price,'$','') AS real) as SalePrice,
		CONVERT(DATETIME,CONVERT(VARCHAR,[Date],103),103) as SaleDate,
		Phone
FROM	NewDataFile
WHERE	SaleID NOT IN (SELECT NewDataFile_SaleID FROM #TMP_SameData)
		AND 
		SaleID NOT IN (SELECT NewDataFile_SaleID FROM #TMP_RecordsToUpdate)

IF @@ERROR != 0
	BEGIN
		RAISERROR('Cannot insert on PropertySale_Task1 table',16,1)
		ROLLBACK TRAN
		RETURN
	END
COMMIT TRAN

PRINT 'Successfull insert on PropertySale_Task1 table.'
