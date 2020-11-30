/****************************************************************************************************************
	TASK #3 - Optimization script.
	
	This script optimize the execution of the stored procedure dbo.StatisticalSummary_SuburbByCalendarYear

	It basically prevent ths use of TABLE SCAN and enforce the use of INDEX SEEK instead.

*****************************************************************************************************************/
USE working
GO

DROP INDEX IF EXISTS NCI_1 ON dbo.PropertySale_Task2_Task3;

CREATE NONCLUSTERED INDEX NCI_1 ON dbo.PropertySale_Task2_Task3 (PostCode, [State]) INCLUDE(Suburb, SalePrice,SaleDate);
