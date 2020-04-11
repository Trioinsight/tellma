﻿CREATE TYPE [dbo].[ResourceList] AS TABLE (
	[Index]							INT					PRIMARY KEY,
	[Id]							INT					NOT NULL DEFAULT 0,
	--[OperatingSegmentId]			INT,
	[AssetTypeId]					INT,
	[RevenueTypeId]					INT,
	[ExpenseTypeId]					INT,

	[Name]							NVARCHAR (255)		NOT NULL,
	[Name2]							NVARCHAR (255),
	[Name3]							NVARCHAR (255),
	[Identifier]					NVARCHAR (10),
	--[BatchCode]						NVARCHAR (10), -- when not null, measures need not be known per unit. 
	[Code]							NVARCHAR (255),

	[CurrencyId]					NCHAR (3),
	[MonetaryValue]					Decimal (19,4), -- such as when dealing with a check, or when the unit price is fixed (rare)

	[Description]					NVARCHAR (2048),
	[Description2]					NVARCHAR (2048),
	[Description3]					NVARCHAR (2048),
	-- For PPE
	[ExpenseEntryTypeId]			INT,
	[CenterId]						INT,
	[ResidualMonetaryValue]			Decimal (19,4) DEFAULT 0,
	[ResidualValue]					Decimal (19,4) DEFAULT 0,
	-- For inventory
	[ReorderLevel]					Decimal (19,4),
	[EconomicOrderQuantity]			Decimal (19,4),
	--[AttachmentsFolderURL]			NVARCHAR (255), 

	--[CustomsReference]				NVARCHAR (255), -- how it is referred to by Customs
	--[PreferredSupplierId]			INT,			-- FK, Table Agents, specially for purchasing

	[AvailableSince]				DATE,			
	[AvailableTill]					DATE,			

	--[UniqueReference1]				NVARCHAR(50), -- such as VIN, UPC, EPC, etc...
	--[UniqueReference2]				NVARCHAR(50), -- such as Engine number
	--[UniqueReference3]				NVARCHAR(50), -- such as Plate number
	
	--[AssetAccountId]				INT,			
	--[LiabilityAccountId]			INT,			
	--[EquityAccountId]				INT,			
	--[RevenueAccountId]				INT,			
	--[ExpensesAccountId]				INT,			

	--[Agent1Id]						INT,			
	--[Agent2Id]						INT,			
	--[Date1]							DATE,			
	--[Date2]							DATE,			
	[Decimal1]						DECIMAL,
	[Decimal2]						DECIMAL,
	[Int1]							INT,			-- Engine Capacity
	[Int2]							INT,

	[Lookup1Id]						INT,
	[Lookup2Id]						INT,
	[Lookup3Id]						INT,
	[Lookup4Id]						INT,
	--[Lookup5Id]						INT,			
	--[DECIMAL (19,4)1]						DECIMAL (19,4),
	--[DECIMAL (19,4)2]						DECIMAL (19,4),
	[Text1]							NVARCHAR (255), 
	[Text2]							NVARCHAR (255), 

	INDEX IX_ResourceList__Code ([Code])
);