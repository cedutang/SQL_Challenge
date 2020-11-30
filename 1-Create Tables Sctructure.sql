/***************************************************************************************************

	This script creates the tables structure that will be used as base for this challenge.
	The following are the main tables:
		- PropertySale_Task1
		- PropertySale_Task2_Task3

	The following are staging tables used to clean and transform data types.
		PropertySale_Task1_Staging
		PropertySale_Task2_Task3_Staging

****************************************************************************************************/
USE Working
GO

DROP TABLE IF EXISTS dbo.PropertySale_Task1;
DROP TABLE IF EXISTS dbo.PropertySale_Task2_Task3;
DROP TABLE IF EXISTS dbo.PropertySale_Task1_Staging;
DROP TABLE IF EXISTS dbo.PropertySale_Task2_Task3_Staging;
	
CREATE TABLE dbo.PropertySale_Task1 (
[SaleID] [int] NOT NULL,
[AddressLine] [varchar] (100) NULL,
[Suburb] [varchar] (50) NULL,
[Postcode] [varchar] (4) NULL,
[State] [varchar] (3) NULL,
[SalePrice] [real] NULL,
[SaleDate] [smalldatetime] NULL,
[PhoneNumber] [varchar] (30) NULL,
[CreateDate] [datetime] NULL,
[ModifyDate] [datetime] NULL
)
GO

CREATE TABLE dbo.PropertySale_Task2_Task3 (
[SaleID] [int] NOT NULL,
[AddressLine] [varchar] (100) NULL,
[Suburb] [varchar] (50) NULL,
[Postcode] [varchar] (4) NULL,
[State] [varchar] (3) NULL,
[SalePrice] [real] NULL,
[SaleDate] [smalldatetime] NULL,
[PhoneNumber] [varchar] (30) NULL,
[CreateDate] [datetime] NULL,
[ModifyDate] [datetime] NULL
)
GO

CREATE TABLE dbo.PropertySale_Task1_Staging (
[SaleID] [int] ,
[AddressLine] [varchar] (100) NULL,
[Suburb] [varchar] (50) NULL,
[Postcode] [varchar] (4) NULL,
[State] [varchar] (3) NULL,
[SalePrice] [real] NULL,
[SaleDate] VARCHAR(20) NULL,
[PhoneNumber] [varchar] (30) NULL,
[CreateDate] VARCHAR(20) NULL,
[ModifyDate] VARCHAR(20) NULL
)
GO

CREATE TABLE dbo.PropertySale_Task2_Task3_Staging (
[SaleID] [int] ,
[AddressLine] [varchar] (100) NULL,
[Suburb] [varchar] (50) NULL,
[Postcode] [varchar] (4) NULL,
[State] [varchar] (3) NULL,
[SalePrice] [real] NULL,
[SaleDate] VARCHAR(20) NULL,
[PhoneNumber] [varchar] (30) NULL,
[CreateDate] VARCHAR(20) NULL,
[ModifyDate] VARCHAR(20) NULL
)
GO
