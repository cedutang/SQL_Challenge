/****************************************************************************************************************
	TASK #3 - Statistical Information:
	
	This script creates a stored procedure to generate statistical information.
	
*****************************************************************************************************************/
USE working
GO

DROP PROC IF EXISTS dbo.StatisticalSummary_SuburbByCalendarYear
GO

/********************************************************************************************
	Author			= Cesar Tang
	Creation Date	= 30/11/2020
	Purpose			= Generate statistical information for websites based on sale data contained
					  in PropertySale_Task2_Task3 table.
---------------------------------------------------------------------------------------------
History of changes:
	-
*********************************************************************************************/
CREATE PROC dbo.StatisticalSummary_SuburbByCalendarYear
(
	@p_Postcode	VARCHAR(4),
	@p_State	VARCHAR(20)
)
AS
BEGIN
	
	;
	WITH CTE
	AS
	(
	SELECT  DISTINCT
			suburb,postcode,[state],YEAR(saledate) DateYear,
			AVG(SalePrice) OVER(PARTITION BY Suburb,Postcode,[State],YEAR(SaleDate)) AS SalePriceAverage,		
			PERCENTILE_DISC(0.05) WITHIN GROUP (ORDER BY Saleprice) OVER(PARTITION BY Suburb,Postcode,[State],YEAR(SaleDate))  Percentile05SalePrice,
			PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY Saleprice) OVER(PARTITION BY Suburb,Postcode,[State],YEAR(SaleDate))  Percentile95SalePrice,
			COUNT(IIF(saleprice > 700000, 1,null)) OVER(PARTITION BY Suburb,Postcode,[State],YEAR(SaleDate)) AS NumberSalesInHighEnd,
			COUNT(*) OVER(PARTITION BY Suburb,Postcode,[State],YEAR(SaleDate)) AS TotalNumberSalesCombination
	FROM	dbo.PropertySale_Task2_Task3
	WHERE	Postcode = @p_Postcode and [state] = @p_State
	)
	SELECT	Suburb,
			Postcode,
			[State],
			DateYear,
			SalePriceAverage,
			(NumberSalesInHighEnd*1.0 / TotalNumberSalesCombination)*100 as PercentageOfSalesInHighEnd,
			Percentile05SalePrice,
			Percentile95SalePrice,
			TotalNumberSalesCombination as TotalNumberOfSales
	FROM	CTE
	ORDER BY suburb,postcode,[state],DateYear

END
GO

exec dbo.StatisticalSummary_SuburbByCalendarYear '2216','NSW'
GO
