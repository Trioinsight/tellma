﻿CREATE PROCEDURE [dal].[ResourceDefinitions__Save]
	@Entities [dbo].[ResourceDefinitionList] READONLY,
	@ReportDefinitions [dbo].[ResourceDefinitionReportDefinitionList] READONLY,
	@ReturnIds BIT = 0,
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IndexedIds [dbo].[IndexedIdList];
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();

	INSERT INTO @IndexedIds([Index], [Id])
	SELECT x.[Index], x.[Id]
	FROM
	(
		MERGE INTO [dbo].[ResourceDefinitions] AS t
		USING (
			SELECT 
				[Index], [Id],
				[Code],
				[TitleSingular],
				[TitleSingular2],
				[TitleSingular3],
				[TitlePlural],
				[TitlePlural2],
				[TitlePlural3],
				[ResourceDefinitionType],
				-----Contract properties common with resources
				[CurrencyVisibility],
				[CenterVisibility],
				[ImageVisibility],
				[DescriptionVisibility],
				[LocationVisibility],

				[FromDateLabel],
				[FromDateLabel2],
				[FromDateLabel3],	
				[FromDateVisibility],
				[ToDateLabel],
				[ToDateLabel2],
				[ToDateLabel3],
				[ToDateVisibility],

				[Date1Visibility],
				[Date1Label],
				[Date1Label2],
				[Date1Label3],

				[Date2Visibility],
				[Date2Label],
				[Date2Label2],
				[Date2Label3],

				[Date3Visibility],
				[Date3Label],
				[Date3Label2],
				[Date3Label3],

				[Date4Visibility],
				[Date4Label],
				[Date4Label2],
				[Date4Label3],

				[Decimal1Label],
				[Decimal1Label2],
				[Decimal1Label3],	
				[Decimal1Visibility],

				[Decimal2Label],
				[Decimal2Label2],
				[Decimal2Label3],		
				[Decimal2Visibility],

				[Decimal3Label],
				[Decimal3Label2],
				[Decimal3Label3],	
				[Decimal3Visibility],

				[Decimal4Label],
				[Decimal4Label2],
				[Decimal4Label3],		
				[Decimal4Visibility],

				[Int1Label],
				[Int1Label2],
				[Int1Label3],	
				[Int1Visibility],

				[Int2Label],
				[Int2Label2],
				[Int2Label3],		
				[Int2Visibility],

				[Lookup1Label],
				[Lookup1Label2],
				[Lookup1Label3],
				[Lookup1Visibility],
				[Lookup1DefinitionId],
				[Lookup2Label],
				[Lookup2Label2],
				[Lookup2Label3],
				[Lookup2Visibility],
				[Lookup2DefinitionId],
				[Lookup3Label],
				[Lookup3Label2],
				[Lookup3Label3],
				[Lookup3Visibility],
				[Lookup3DefinitionId],
				[Lookup4Label],
				[Lookup4Label2],
				[Lookup4Label3],
				[Lookup4Visibility],
				[Lookup4DefinitionId],

				[Text1Label],
				[Text1Label2],
				[Text1Label3],	
				[Text1Visibility],

				[Text2Label],
				[Text2Label2],
				[Text2Label3],	
				[Text2Visibility],

				[PreprocessScript],
				[ValidateScript],
				-----Properties applicable to resources only
				[IdentifierLabel],
				[IdentifierLabel2],
				[IdentifierLabel3],
				[IdentifierVisibility],
				[VatRateVisibility],
				[DefaultVatRate],
				-- Inventory
				[ReorderLevelVisibility],
				[EconomicOrderQuantityVisibility],
				[UnitCardinality],
				[DefaultUnitId],
				[UnitMassVisibility],
				[DefaultUnitMassUnitId],
				-- financial instruments
				[MonetaryValueVisibility],

				[Agent1Label],
				[Agent1Label2],
				[Agent1Label3],
				[Agent1Visibility],
				[Agent1DefinitionId],
				
				[Agent2Label],
				[Agent2Label2],
				[Agent2Label3],
				[Agent2Visibility],
				[Agent2DefinitionId],

				[Resource1Label],
				[Resource1Label2],
				[Resource1Label3],
				[Resource1Visibility],
				[Resource1DefinitionId],

				[Resource2Label],
				[Resource2Label2],
				[Resource2Label3],
				[Resource2Visibility],
				[Resource2DefinitionId],

				[HasAttachments],
				[AttachmentsCategoryDefinitionId],

				[MainMenuIcon],
				[MainMenuSection],
				[MainMenuSortKey]
			FROM @Entities 
		) AS s ON (t.[Id] = s.[Id])
		WHEN MATCHED 
		THEN
			UPDATE SET
				t.[Code]					= s.[Code],
				t.[TitleSingular]			= s.[TitleSingular],
				t.[TitleSingular2]			= s.[TitleSingular2],
				t.[TitleSingular3]			= s.[TitleSingular3],
				t.[TitlePlural]				= s.[TitlePlural],
				t.[TitlePlural2]			= s.[TitlePlural2],
				t.[TitlePlural3]			= s.[TitlePlural3],
				t.[ResourceDefinitionType]	= s.[ResourceDefinitionType],
				t.[CurrencyVisibility]		= s.[CurrencyVisibility],
				t.[CenterVisibility]		= s.[CenterVisibility],
				t.[ImageVisibility]			= s.[ImageVisibility],
				t.[DescriptionVisibility]	= s.[DescriptionVisibility],
				t.[LocationVisibility]		= s.[LocationVisibility],

				t.[FromDateLabel]			= s.[FromDateLabel],
				t.[FromDateLabel2]			= s.[FromDateLabel2],
				t.[FromDateLabel3]			= s.[FromDateLabel3],	
				t.[FromDateVisibility]		= s.[FromDateVisibility],

				t.[Date1Visibility]			= s.[Date1Visibility],
				t.[Date1Label]				= s.[Date1Label],
				t.[Date1Label2]				= s.[Date1Label2],
				t.[Date1Label3]				= s.[Date1Label3],

				t.[Date2Visibility]			= s.[Date2Visibility],
				t.[Date2Label]				= s.[Date2Label],
				t.[Date2Label2]				= s.[Date2Label2],
				t.[Date2Label3]				= s.[Date2Label3],

				t.[Date3Visibility]			= s.[Date3Visibility],
				t.[Date3Label]				= s.[Date3Label],
				t.[Date3Label2]				= s.[Date3Label2],
				t.[Date3Label3]				= s.[Date3Label3],

				t.[Date4Visibility]			= s.[Date4Visibility],
				t.[Date4Label]				= s.[Date4Label],
				t.[Date4Label2]				= s.[Date4Label2],
				t.[Date4Label3]				= s.[Date4Label3],

				t.[ToDateLabel]				= s.[ToDateLabel],
				t.[ToDateLabel2]			= s.[ToDateLabel2],
				t.[ToDateLabel3]			= s.[ToDateLabel3],
				t.[ToDateVisibility]		= s.[ToDateVisibility],

				t.[Decimal1Label]			= s.[Decimal1Label],
				t.[Decimal1Label2]			= s.[Decimal1Label2],
				t.[Decimal1Label3]			= s.[Decimal1Label3],	
				t.[Decimal1Visibility]		= s.[Decimal1Visibility],

				t.[Decimal2Label]			= s.[Decimal2Label],
				t.[Decimal2Label2]			= s.[Decimal2Label2],
				t.[Decimal2Label3]			= s.[Decimal2Label3],		
				t.[Decimal2Visibility]		= s.[Decimal2Visibility],

				t.[Decimal3Label]			= s.[Decimal3Label],
				t.[Decimal3Label2]			= s.[Decimal3Label2],
				t.[Decimal3Label3]			= s.[Decimal3Label3],	
				t.[Decimal3Visibility]		= s.[Decimal3Visibility],

				t.[Decimal4Label]			= s.[Decimal4Label],
				t.[Decimal4Label2]			= s.[Decimal4Label2],
				t.[Decimal4Label3]			= s.[Decimal4Label3],		
				t.[Decimal4Visibility]		= s.[Decimal4Visibility],

				t.[Int1Label]				= s.[Int1Label],
				t.[Int1Label2]				= s.[Int1Label2],
				t.[Int1Label3]				= s.[Int1Label3],	
				t.[Int1Visibility]			= s.[Int1Visibility],

				t.[Int2Label]				= s.[Int2Label],
				t.[Int2Label2]				= s.[Int2Label2],
				t.[Int2Label3]				= s.[Int2Label3],		
				t.[Int2Visibility]			= s.[Int2Visibility],

				t.[Lookup1Label]			= s.[Lookup1Label],
				t.[Lookup1Label2]			= s.[Lookup1Label2],
				t.[Lookup1Label3]			= s.[Lookup1Label3],
				t.[Lookup1Visibility]		= s.[Lookup1Visibility],
				t.[Lookup1DefinitionId]		= s.[Lookup1DefinitionId],
				t.[Lookup2Label]			= s.[Lookup2Label],
				t.[Lookup2Label2]			= s.[Lookup2Label2],
				t.[Lookup2Label3]			= s.[Lookup2Label3],
				t.[Lookup2Visibility]		= s.[Lookup2Visibility],
				t.[Lookup2DefinitionId]		= s.[Lookup2DefinitionId],
				t.[Lookup3Label]			= s.[Lookup3Label],
				t.[Lookup3Label2]			= s.[Lookup3Label2],
				t.[Lookup3Label3]			= s.[Lookup3Label3],
				t.[Lookup3Visibility]		= s.[Lookup3Visibility],
				t.[Lookup3DefinitionId]		= s.[Lookup3DefinitionId],
				t.[Lookup4Label]			= s.[Lookup4Label],
				t.[Lookup4Label2]			= s.[Lookup4Label2],
				t.[Lookup4Label3]			= s.[Lookup4Label3],
				t.[Lookup4Visibility]		= s.[Lookup4Visibility],
				t.[Lookup4DefinitionId]		= s.[Lookup4DefinitionId],

				t.[Text1Label]				= s.[Text1Label],
				t.[Text1Label2]				= s.[Text1Label2],
				t.[Text1Label3]				= s.[Text1Label3],
				t.[Text1Visibility]			= s.[Text1Visibility],

				t.[Text2Label]				= s.[Text2Label],
				t.[Text2Label2]				= s.[Text2Label2],
				t.[Text2Label3]				= s.[Text2Label3],
				t.[Text2Visibility]			= s.[Text2Visibility],

				t.[PreprocessScript]		= s.[PreprocessScript],
				t.[ValidateScript]			= s.[ValidateScript],
				-----Properties applicable to resources only
				t.[IdentifierLabel]			= s.[IdentifierLabel],
				t.[IdentifierLabel2]		= s.[IdentifierLabel2],
				t.[IdentifierLabel3]		= s.[IdentifierLabel3],
				t.[IdentifierVisibility]	= s.[IdentifierVisibility],
				t.[VatRateVisibility]		= s.[VatRateVisibility],
				t.[DefaultVatRate]			= s.[DefaultVatRate],
				-- Inventory
				t.[ReorderLevelVisibility] = s.[ReorderLevelVisibility],
				t.[EconomicOrderQuantityVisibility]
											= s.[EconomicOrderQuantityVisibility],
				t.[UnitCardinality]			= s.[UnitCardinality],
				t.[DefaultUnitId]			= s.[DefaultUnitId],
				t.[UnitMassVisibility]		= s.[UnitMassVisibility],
				t.[DefaultUnitMassUnitId]	= s.[DefaultUnitMassUnitId],
				t.[MonetaryValueVisibility]	= s.[MonetaryValueVisibility],

				t.[Agent1Label]				= s.[Agent1Label],
				t.[Agent1Label2]			= s.[Agent1Label2],
				t.[Agent1Label3]			= s.[Agent1Label3],
				t.[Agent1Visibility]		= s.[Agent1Visibility],
				t.[Agent1DefinitionId]		= s.[Agent1DefinitionId],
				
				t.[Agent2Label]				= s.[Agent2Label],
				t.[Agent2Label2]			= s.[Agent2Label2],
				t.[Agent2Label3]			= s.[Agent2Label3],
				t.[Agent2Visibility]		= s.[Agent2Visibility],
				t.[Agent2DefinitionId]		= s.[Agent2DefinitionId],

				t.[Resource1Label]			= s.[Resource1Label],
				t.[Resource1Label2]			= s.[Resource1Label2],
				t.[Resource1Label3]			= s.[Resource1Label3],
				t.[Resource1Visibility]		= s.[Resource1Visibility],
				t.[Resource1DefinitionId]	= s.[Resource1DefinitionId],
				t.[Resource2Label]			= s.[Resource2Label],
				t.[Resource2Label2]			= s.[Resource2Label2],
				t.[Resource2Label3]			= s.[Resource2Label3],
				t.[Resource2Visibility]		= s.[Resource2Visibility],
				t.[Resource2DefinitionId]	= s.[Resource2DefinitionId],
				t.[HasAttachments]			= s.[HasAttachments],
				t.[AttachmentsCategoryDefinitionId] = s.[AttachmentsCategoryDefinitionId],
				t.[MainMenuIcon]			= s.[MainMenuIcon],
				t.[MainMenuSection]			= s.[MainMenuSection],
				t.[MainMenuSortKey]			= s.[MainMenuSortKey],
				t.[SavedById]				= @UserId
		WHEN NOT MATCHED THEN
		INSERT ([Code],	[TitleSingular],	[TitleSingular2], [TitleSingular3],		[TitlePlural],	[TitlePlural2],		[TitlePlural3],
				[ResourceDefinitionType],
				[CurrencyVisibility],
				[CenterVisibility],
				[ImageVisibility],
				[DescriptionVisibility],
				[LocationVisibility],

				[FromDateLabel],
				[FromDateLabel2],
				[FromDateLabel3],	
				[FromDateVisibility],
				[ToDateLabel],
				[ToDateLabel2],
				[ToDateLabel3],
				[ToDateVisibility],

				[Date1Visibility],
				[Date1Label],
				[Date1Label2],
				[Date1Label3],

				[Date2Visibility],
				[Date2Label],
				[Date2Label2],
				[Date2Label3],

				[Date3Visibility],
				[Date3Label],
				[Date3Label2],
				[Date3Label3],

				[Date4Visibility],
				[Date4Label],
				[Date4Label2],
				[Date4Label3],

				[Decimal1Label],
				[Decimal1Label2],
				[Decimal1Label3],	
				[Decimal1Visibility],

				[Decimal2Label],
				[Decimal2Label2],
				[Decimal2Label3],		
				[Decimal2Visibility],

				[Decimal3Label],
				[Decimal3Label2],
				[Decimal3Label3],	
				[Decimal3Visibility],

				[Decimal4Label],
				[Decimal4Label2],
				[Decimal4Label3],		
				[Decimal4Visibility],

				[Int1Label],
				[Int1Label2],
				[Int1Label3],	
				[Int1Visibility],

				[Int2Label],
				[Int2Label2],
				[Int2Label3],		
				[Int2Visibility],

				[Lookup1Label],
				[Lookup1Label2],
				[Lookup1Label3],
				[Lookup1Visibility],
				[Lookup1DefinitionId],
				[Lookup2Label],
				[Lookup2Label2],
				[Lookup2Label3],
				[Lookup2Visibility],
				[Lookup2DefinitionId],
				[Lookup3Label],
				[Lookup3Label2],
				[Lookup3Label3],
				[Lookup3Visibility],
				[Lookup3DefinitionId],
				[Lookup4Label],
				[Lookup4Label2],
				[Lookup4Label3],
				[Lookup4Visibility],
				[Lookup4DefinitionId],

				[Text1Label],
				[Text1Label2],
				[Text1Label3],	
				[Text1Visibility],

				[Text2Label],
				[Text2Label2],
				[Text2Label3],	
				[Text2Visibility],

				[PreprocessScript],
				[ValidateScript],

				[IdentifierLabel],
				[IdentifierLabel2],
				[IdentifierLabel3],
				[IdentifierVisibility],
				[VatRateVisibility],
				[DefaultVatRate],
				-- Inventory
				[ReorderLevelVisibility],
				[EconomicOrderQuantityVisibility],
				[UnitCardinality],
				[DefaultUnitId],
				[UnitMassVisibility],
				[DefaultUnitMassUnitId],
				[MonetaryValueVisibility],
				
				[Agent1Label],
				[Agent1Label2],
				[Agent1Label3],
				[Agent1Visibility],
				[Agent1DefinitionId],
				
				[Agent2Label],
				[Agent2Label2],
				[Agent2Label3],
				[Agent2Visibility],
				[Agent2DefinitionId],

				[Resource1Label],
				[Resource1Label2],
				[Resource1Label3],
				[Resource1Visibility],
				[Resource1DefinitionId],
				[Resource2Label],
				[Resource2Label2],
				[Resource2Label3],
				[Resource2Visibility],
				[Resource2DefinitionId],
				[HasAttachments],
				[AttachmentsCategoryDefinitionId],
				[MainMenuIcon],
				[MainMenuSection],
				[MainMenuSortKey],
				[SavedById]
				)
			VALUES (s.[Code],	s.[TitleSingular],	s.[TitleSingular2], s.[TitleSingular3],		s.[TitlePlural],	s.[TitlePlural2],		s.[TitlePlural3],
				s.[ResourceDefinitionType],
				s.[CurrencyVisibility],
				s.[CenterVisibility],
				s.[ImageVisibility],
				s.[DescriptionVisibility],
				s.[LocationVisibility],

				s.[FromDateLabel],
				s.[FromDateLabel2],
				s.[FromDateLabel3],	
				s.[FromDateVisibility],
				s.[ToDateLabel],
				s.[ToDateLabel2],
				s.[ToDateLabel3],
				s.[ToDateVisibility],

				s.[Date1Visibility],
				s.[Date1Label],
				s.[Date1Label2],
				s.[Date1Label3],

				s.[Date2Visibility],
				s.[Date2Label],
				s.[Date2Label2],
				s.[Date2Label3],

				s.[Date3Visibility],
				s.[Date3Label],
				s.[Date3Label2],
				s.[Date3Label3],

				s.[Date4Visibility],
				s.[Date4Label],
				s.[Date4Label2],
				s.[Date4Label3],

				s.[Decimal1Label],
				s.[Decimal1Label2],
				s.[Decimal1Label3],	
				s.[Decimal1Visibility],

				s.[Decimal2Label],
				s.[Decimal2Label2],
				s.[Decimal2Label3],		
				s.[Decimal2Visibility],

				s.[Decimal3Label],
				s.[Decimal3Label2],
				s.[Decimal3Label3],	
				s.[Decimal3Visibility],

				s.[Decimal4Label],
				s.[Decimal4Label2],
				s.[Decimal4Label3],		
				s.[Decimal4Visibility],

				s.[Int1Label],
				s.[Int1Label2],
				s.[Int1Label3],	
				s.[Int1Visibility],

				s.[Int2Label],
				s.[Int2Label2],
				s.[Int2Label3],		
				s.[Int2Visibility],

				s.[Lookup1Label],
				s.[Lookup1Label2],
				s.[Lookup1Label3],
				s.[Lookup1Visibility],
				s.[Lookup1DefinitionId],
				s.[Lookup2Label],
				s.[Lookup2Label2],
				s.[Lookup2Label3],
				s.[Lookup2Visibility],
				s.[Lookup2DefinitionId],
				s.[Lookup3Label],
				s.[Lookup3Label2],
				s.[Lookup3Label3],
				s.[Lookup3Visibility],
				s.[Lookup3DefinitionId],
				s.[Lookup4Label],
				s.[Lookup4Label2],
				s.[Lookup4Label3],
				s.[Lookup4Visibility],
				s.[Lookup4DefinitionId],

				s.[Text1Label],
				s.[Text1Label2],
				s.[Text1Label3],	
				s.[Text1Visibility],

				s.[Text2Label],
				s.[Text2Label2],
				s.[Text2Label3],	
				s.[Text2Visibility],
				
				s.[PreprocessScript],
				s.[ValidateScript],

				s.[IdentifierLabel],
				s.[IdentifierLabel2],
				s.[IdentifierLabel3],
				s.[IdentifierVisibility],
				s.[VatRateVisibility],
				s.[DefaultVatRate],
				-- Inventory
				s.[ReorderLevelVisibility],
				s.[EconomicOrderQuantityVisibility],
				s.[UnitCardinality],
				s.[DefaultUnitId],
				s.[UnitMassVisibility],
				s.[DefaultUnitMassUnitId],
				-- Financial
				s.[MonetaryValueVisibility],

				s.[Agent1Label],
				s.[Agent1Label2],
				s.[Agent1Label3],
				s.[Agent1Visibility],
				s.[Agent1DefinitionId],

				s.[Agent2Label],
				s.[Agent2Label2],
				s.[Agent2Label3],
				s.[Agent2Visibility],
				s.[Agent2DefinitionId],

				s.[Resource1Label],
				s.[Resource1Label2],
				s.[Resource1Label3],
				s.[Resource1Visibility],
				s.[Resource1DefinitionId],
				s.[Resource2Label],
				s.[Resource2Label2],
				s.[Resource2Label3],
				s.[Resource2Visibility],
				s.[Resource2DefinitionId],
				s.[HasAttachments],
				s.[AttachmentsCategoryDefinitionId],
				s.[MainMenuIcon],
				s.[MainMenuSection],
				s.[MainMenuSortKey],
				@UserId)		
		OUTPUT s.[Index], inserted.[Id]
	) AS x;

	WITH CurrentDefinitionReportDefinitions AS (
		SELECT *
		FROM [dbo].[ResourceDefinitionReportDefinitions]
		WHERE [ResourceDefinitionId] IN (SELECT [Id] FROM @Entities)
	)
	MERGE CurrentDefinitionReportDefinitions AS t
	USING (
		SELECT
			RDRD.[Index],
			RDRD.[Id],
			II.[Id] AS [ResourceDefinitionId],
			RDRD.[ReportDefinitionId],
			RDRD.[Name],
			RDRD.[Name2],
			RDRD.[Name3]
		FROM @Entities DD
		JOIN @IndexedIds II ON DD.[Index] = II.[Index]
		JOIN @ReportDefinitions RDRD ON DD.[Index] = RDRD.[HeaderIndex]
	) AS s
	ON s.Id = t.Id
	WHEN MATCHED THEN
		UPDATE SET
			t.[Index]				= s.[Index],
			t.[ReportDefinitionId]	= s.[ReportDefinitionId],
			t.[Name]				= s.[Name],
			t.[Name2]				= s.[Name2],
			t.[Name3]				= s.[Name3],
			t.[SavedById]			= @UserId
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[Index], [ResourceDefinitionId],	[ReportDefinitionId], [Name], [Name2], [Name3], [SavedById]
		) VALUES (
			[Index], s.[ResourceDefinitionId], s.[ReportDefinitionId], s.[Name], s.[Name2], s.[Name3], @UserId
		);
	
	-- Signal clients to refresh their cache
	IF EXISTS (SELECT * FROM @IndexedIds I JOIN [dbo].[ResourceDefinitions] D ON I.[Id] = D.[Id] WHERE D.[State] <> N'Hidden')
		UPDATE [dbo].[Settings] SET [DefinitionsVersion] = NEWID();

	IF @ReturnIds = 1
		SELECT * FROM @IndexedIds;
END;