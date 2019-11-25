﻿CREATE TABLE [dbo].[ResourceDefinitions]
(
	[Id]								NVARCHAR (50)	NOT NULL PRIMARY KEY,
	[TitleSingular]						NVARCHAR (255),
	[TitleSingular2]					NVARCHAR (255),
	[TitleSingular3]					NVARCHAR (255),
	[TitlePlural]						NVARCHAR (255),
	[TitlePlural2]						NVARCHAR (255),
	[TitlePlural3]						NVARCHAR (255),
	-- If null, no restriction. Otherwise, it restricts the types to those stemming from one of the nodes in the parent list
	-- TODO: This design is not normalized. To normalize, move it to a separate table ResourceDefinitionResourceTypes([ResourceDefinitionId], [ResourceTypeParentId])
	[ResourceTypeParentList]			NVARCHAR (1024), --			CONSTRAINT [FK_ResourceDefinitions__ResourceTypeId] FOREIGN KEY ([ResourceTypeList]) REFERENCES dbo.ResourceTypes([Id]),
	-- One method to auto generate codes/names
	[CodeRegEx]							NVARCHAR (255), -- Null means manually defined
	[NameRegEx]							NVARCHAR (255), -- Null means manually defined
	-- Resource properties
	[ResourceClassificationVisibility]	NVARCHAR (50) DEFAULT N'None' CHECK ([ResourceClassificationVisibility] IN (N'None', N'Required', N'Optional')),
	[CountUnitVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([CountUnitVisibility] IN (N'None', N'Required', N'Optional')),
	[MassUnitVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([MassUnitVisibility] IN (N'None', N'Required', N'Optional')),
	[VolumeUnitVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([VolumeUnitVisibility] IN (N'None', N'Required', N'Optional')),
	[TimeUnitVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([TimeUnitVisibility] IN (N'None', N'Required', N'Optional')),
	[CurrencyVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([CurrencyVisibility] IN (N'None', N'Required', N'Optional')),
	[CustomsReferenceVisibility]		NVARCHAR (50) DEFAULT N'None' CHECK ([CustomsReferenceVisibility] IN (N'None', N'Required', N'Optional')),
	[PreferredSupplierVisibility]		NVARCHAR (50) DEFAULT N'None' CHECK ([PreferredSupplierVisibility] IN (N'None', N'Required', N'Optional')),

	[Lookup1Visibility]					NVARCHAR (50) DEFAULT N'None' CHECK ([Lookup1Visibility] IN (N'None', N'Required', N'Optional')),
	[Lookup1DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup1DefinitionId] FOREIGN KEY (Lookup1DefinitionId) REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup1Label]						NVARCHAR (50),
	[Lookup2Visibility]					NVARCHAR (50) DEFAULT N'None' CHECK ([Lookup2Visibility] IN (N'None', N'Required', N'Optional')),
	[Lookup2DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup2DefinitionId] FOREIGN KEY (Lookup2DefinitionId) REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup2Label]						NVARCHAR (50),
	[Lookup3Visibility]					NVARCHAR (50) DEFAULT N'None' CHECK ([Lookup3Visibility] IN (N'None', N'Required', N'Optional')),
	[Lookup3DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup3DefinitionId] FOREIGN KEY (Lookup3DefinitionId) REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup3Label]						NVARCHAR (50),
	[Lookup4Visibility]					NVARCHAR (50) DEFAULT N'None' CHECK ([Lookup4Visibility] IN (N'None', N'Required', N'Optional')),
	[Lookup4DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup4DefinitionId] FOREIGN KEY (Lookup4DefinitionId) REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup4Label]						NVARCHAR (50),

	-- TODO: Production Date has been moved from Resources to Accounts/Entries... Delete from definition.
	[ProductionDateVisibility]			NVARCHAR (50) DEFAULT N'None' CHECK ([ProductionDateVisibility] IN (N'None', N'Required', N'Optional')),
	[ProductionDateLabel]				NVARCHAR (50),
	[ProductionDateLabel2]				NVARCHAR (50),
	[ProductionDateLabel3]				NVARCHAR (50),

	[ExpiryDateVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([ExpiryDateVisibility] IN (N'None', N'Required', N'Optional')),
	[ExpiryDateLabel]					NVARCHAR (50),
	[ExpiryDateLabel2]					NVARCHAR (50),
	[ExpiryDateLabel3]					NVARCHAR (50),
	-- more properties from Resource Instances to come..

	[State]							NVARCHAR (50)				DEFAULT N'Draft',	-- Deployed, Archived (Phased Out)
	[MainMenuIcon]					NVARCHAR (50),
	[MainMenuSection]				NVARCHAR (50),			-- IF Null, it does not show on the main menu
	[MainMenuSortKey]				DECIMAL (9,4)
);