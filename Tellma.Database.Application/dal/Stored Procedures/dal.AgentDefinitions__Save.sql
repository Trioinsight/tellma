﻿CREATE PROCEDURE [dal].[AgentDefinitions__Save]
	@Entities [AgentDefinitionList] READONLY,
	@ReportDefinitions [AgentDefinitionReportDefinitionList] READONLY,
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
		MERGE INTO [dbo].[AgentDefinitions] AS t
		USING (
			SELECT [Index], [Id], 
				[Code],
				[TitleSingular],
				[TitleSingular2],
				[TitleSingular3],
				[TitlePlural],
				[TitlePlural2],
				[TitlePlural3],
				-----Agent properties common with resources
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

				[DateOfBirthVisibility],
				[ContactEmailVisibility],
				[ContactMobileVisibility],
				[ContactAddressVisibility],

				[Date1Label],
				[Date1Label2],
				[Date1Label3],
				[Date1Visibility],

				[Date2Label],
				[Date2Label2],
				[Date2Label3],	
				[Date2Visibility],

				[Date3Label],
				[Date3Label2],
				[Date3Label3],		
				[Date3Visibility],

				[Date4Label],
				[Date4Label2],
				[Date4Label3],	
				[Date4Visibility],

				[Decimal1Label],
				[Decimal1Label2],
				[Decimal1Label3],	
				[Decimal1Visibility],

				[Decimal2Label],
				[Decimal2Label2],
				[Decimal2Label3],		
				[Decimal2Visibility],

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

				[Lookup5Label],
				[Lookup5Label2],
				[Lookup5Label3],
				[Lookup5Visibility],
				[Lookup5DefinitionId],
				[Lookup6Label],
				[Lookup6Label2],
				[Lookup6Label3],
				[Lookup6Visibility],
				[Lookup6DefinitionId],
				[Lookup7Label],
				[Lookup7Label2],
				[Lookup7Label3],
				[Lookup7Visibility],
				[Lookup7DefinitionId],
				[Lookup8Label],
				[Lookup8Label2],
				[Lookup8Label3],
				[Lookup8Visibility],
				[Lookup8DefinitionId],

				[Text1Label],
				[Text1Label2],
				[Text1Label3],	
				[Text1Visibility],

				[Text2Label],
				[Text2Label2],
				[Text2Label3],	
				[Text2Visibility],

				[Text3Label],
				[Text3Label2],
				[Text3Label3],	
				[Text3Visibility],

				[Text4Label],
				[Text4Label2],
				[Text4Label3],	
				[Text4Visibility],

				[HasAddress],

				[PreprocessScript],
				[ValidateScript],
				-----Properties applicable to Agent only
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

				[TaxIdentificationNumberVisibility],

				[BankAccountNumberVisibility],
				[ExternalReferenceVisibility],
				[ExternalReferenceLabel],
				[ExternalReferenceLabel2],
				[ExternalReferenceLabel3],

				[UserCardinality],				
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

				t.[CurrencyVisibility]		= s.[CurrencyVisibility],
				t.[CenterVisibility]		= s.[CenterVisibility],
				t.[ImageVisibility]			= s.[ImageVisibility],
				t.[DescriptionVisibility]	= s.[DescriptionVisibility],
				t.[LocationVisibility]		= s.[LocationVisibility],

				t.[FromDateLabel]			= s.[FromDateLabel],
				t.[FromDateLabel2]			= s.[FromDateLabel2],
				t.[FromDateLabel3]			= s.[FromDateLabel3],	
				t.[FromDateVisibility]		= s.[FromDateVisibility],
				t.[ToDateLabel]				= s.[ToDateLabel],
				t.[ToDateLabel2]			= s.[ToDateLabel2],
				t.[ToDateLabel3]			= s.[ToDateLabel3],
				t.[ToDateVisibility]		= s.[ToDateVisibility],

				t.[DateOfBirthVisibility]	= s.[DateOfBirthVisibility],
				t.[ContactEmailVisibility]	= s.[ContactEmailVisibility],
				t.[ContactMobileVisibility]	= s.[ContactMobileVisibility],
				t.[ContactAddressVisibility]= s.[ContactAddressVisibility],

				t.[Date1Label]				= s.[Date1Label],
				t.[Date1Label2]				= s.[Date1Label2],
				t.[Date1Label3]				=  s.[Date1Label3],
				t.[Date1Visibility]			= s.[Date1Visibility],

				t.[Date2Label]				= s.[Date2Label],
				t.[Date2Label2]				= s.[Date2Label2],
				t.[Date2Label3]				= s.[Date2Label3],	
				t.[Date2Visibility]			= s.[Date2Visibility],

				t.[Date3Label]				= s.[Date3Label],
				t.[Date3Label2]				= s.[Date3Label2],
				t.[Date3Label3]				= s.[Date3Label3],		
				t.[Date3Visibility]			= s.[Date3Visibility],

				t.[Date4Label]				= s.[Date4Label],
				t.[Date4Label2]				= s.[Date4Label2],
				t.[Date4Label3]				= s.[Date4Label3],	
				t.[Date4Visibility]			= s.[Date4Visibility],

				t.[Decimal1Label]			= s.[Decimal1Label],
				t.[Decimal1Label2]			= s.[Decimal1Label2],
				t.[Decimal1Label3]			= s.[Decimal1Label3],	
				t.[Decimal1Visibility]		= s.[Decimal1Visibility],

				t.[Decimal2Label]			= s.[Decimal2Label],
				t.[Decimal2Label2]			= s.[Decimal2Label2],
				t.[Decimal2Label3]			= s.[Decimal2Label3],		
				t.[Decimal2Visibility]		= s.[Decimal2Visibility],

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

				t.[Lookup5Label]			= s.[Lookup5Label],
				t.[Lookup5Label2]			= s.[Lookup5Label2],
				t.[Lookup5Label3]			= s.[Lookup5Label3],
				t.[Lookup5Visibility]		= s.[Lookup5Visibility],
				t.[Lookup5DefinitionId]		= s.[Lookup5DefinitionId],
				t.[Lookup6Label]			= s.[Lookup6Label],
				t.[Lookup6Label2]			= s.[Lookup6Label2],
				t.[Lookup6Label3]			= s.[Lookup6Label3],
				t.[Lookup6Visibility]		= s.[Lookup6Visibility],
				t.[Lookup6DefinitionId]		= s.[Lookup6DefinitionId],
				t.[Lookup7Label]			= s.[Lookup7Label],
				t.[Lookup7Label2]			= s.[Lookup7Label2],
				t.[Lookup7Label3]			= s.[Lookup7Label3],
				t.[Lookup7Visibility]		= s.[Lookup7Visibility],
				t.[Lookup7DefinitionId]		= s.[Lookup7DefinitionId],
				t.[Lookup8Label]			= s.[Lookup8Label],
				t.[Lookup8Label2]			= s.[Lookup8Label2],
				t.[Lookup8Label3]			= s.[Lookup8Label3],
				t.[Lookup8Visibility]		= s.[Lookup8Visibility],
				t.[Lookup8DefinitionId]		= s.[Lookup8DefinitionId],

				t.[Text1Label]				= s.[Text1Label],
				t.[Text1Label2]				= s.[Text1Label2],
				t.[Text1Label3]				= s.[Text1Label3],
				t.[Text1Visibility]			= s.[Text1Visibility],

				t.[Text2Label]				= s.[Text2Label],
				t.[Text2Label2]				= s.[Text2Label2],
				t.[Text2Label3]				= s.[Text2Label3],
				t.[Text2Visibility]			= s.[Text2Visibility],

				t.[Text3Label]				= s.[Text3Label],
				t.[Text3Label2]				= s.[Text3Label2],
				t.[Text3Label3]				= s.[Text3Label3],
				t.[Text3Visibility]			= s.[Text3Visibility],

				t.[Text4Label]				= s.[Text4Label],
				t.[Text4Label2]				= s.[Text4Label2],
				t.[Text4Label3]				= s.[Text4Label3],
				t.[Text4Visibility]			= s.[Text4Visibility],

				t.[HasAddress]				= s.[HasAddress],

				t.[PreprocessScript]		= s.[PreprocessScript],
				t.[ValidateScript]			= s.[ValidateScript],
				-----Properties applicable to Agents only

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

				t.[TaxIdentificationNumberVisibility]
											= s.[TaxIdentificationNumberVisibility],
				t.[BankAccountNumberVisibility]
											= s.[BankAccountNumberVisibility],
				t.[ExternalReferenceVisibility]
											= s.[ExternalReferenceVisibility],
				t.[ExternalReferenceLabel]	= s.[ExternalReferenceLabel],
				t.[ExternalReferenceLabel2] = s.[ExternalReferenceLabel2],
				t.[ExternalReferenceLabel3] = s.[ExternalReferenceLabel3],
				t.[UserCardinality]			= s.[UserCardinality],
				t.[HasAttachments]			= s.[HasAttachments],
				t.[AttachmentsCategoryDefinitionId]
											= s.[AttachmentsCategoryDefinitionId],
		
				t.[MainMenuIcon]			= s.[MainMenuIcon],
				t.[MainMenuSection]			= s.[MainMenuSection],
				t.[MainMenuSortKey]			= s.[MainMenuSortKey],
				t.[SavedById]				= @UserId
		WHEN NOT MATCHED THEN
			INSERT ([Code],	[TitleSingular],	[TitleSingular2], [TitleSingular3],		[TitlePlural],	[TitlePlural2],		[TitlePlural3],
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

				[DateOfBirthVisibility],
				[ContactEmailVisibility],
				[ContactMobileVisibility],
				[ContactAddressVisibility],

				[Date1Label],
				[Date1Label2],
				[Date1Label3],
				[Date1Visibility],

				[Date2Label],
				[Date2Label2],
				[Date2Label3],	
				[Date2Visibility],

				[Date3Label],
				[Date3Label2],
				[Date3Label3],		
				[Date3Visibility],

				[Date4Label],
				[Date4Label2],
				[Date4Label3],	
				[Date4Visibility],

				[Decimal1Label],
				[Decimal1Label2],
				[Decimal1Label3],	
				[Decimal1Visibility],

				[Decimal2Label],
				[Decimal2Label2],
				[Decimal2Label3],		
				[Decimal2Visibility],

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
				[Lookup5Label],
				[Lookup5Label2],
				[Lookup5Label3],
				[Lookup5Visibility],
				[Lookup5DefinitionId],
				[Lookup6Label],
				[Lookup6Label2],
				[Lookup6Label3],
				[Lookup6Visibility],
				[Lookup6DefinitionId],
				[Lookup7Label],
				[Lookup7Label2],
				[Lookup7Label3],
				[Lookup7Visibility],
				[Lookup7DefinitionId],
				[Lookup8Label],
				[Lookup8Label2],
				[Lookup8Label3],
				[Lookup8Visibility],
				[Lookup8DefinitionId],

				[Text1Label],
				[Text1Label2],
				[Text1Label3],	
				[Text1Visibility],

				[Text2Label],
				[Text2Label2],
				[Text2Label3],	
				[Text2Visibility],

				[Text3Label],
				[Text3Label2],
				[Text3Label3],	
				[Text3Visibility],

				[Text4Label],
				[Text4Label2],
				[Text4Label3],	
				[Text4Visibility],

				[HasAddress],

				[PreprocessScript],
				[ValidateScript],
				-----Properties applicable to Agents only
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

				[TaxIdentificationNumberVisibility],

				[BankAccountNumberVisibility],
				[ExternalReferenceVisibility],
				[ExternalReferenceLabel],
				[ExternalReferenceLabel2],
				[ExternalReferenceLabel3],

				[UserCardinality],
				[HasAttachments],
				[AttachmentsCategoryDefinitionId],

				[MainMenuIcon],		[MainMenuSection], [MainMenuSortKey], [SavedById])
			VALUES (s.[Code], s.[TitleSingular], s.[TitleSingular2], s.[TitleSingular3], s.[TitlePlural], s.[TitlePlural2], s.[TitlePlural3],
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

				s.[DateOfBirthVisibility],
				s.[ContactEmailVisibility],
				s.[ContactMobileVisibility],
				s.[ContactAddressVisibility],

				s.[Date1Label],
				s.[Date1Label2],
				s.[Date1Label3],
				s.[Date1Visibility],

				s.[Date2Label],
				s.[Date2Label2],
				s.[Date2Label3],	
				s.[Date2Visibility],

				s.[Date3Label],
				s.[Date3Label2],
				s.[Date3Label3],		
				s.[Date3Visibility],

				s.[Date4Label],
				s.[Date4Label2],
				s.[Date4Label3],	
				s.[Date4Visibility],

				s.[Decimal1Label],
				s.[Decimal1Label2],
				s.[Decimal1Label3],	
				s.[Decimal1Visibility],

				s.[Decimal2Label],
				s.[Decimal2Label2],
				s.[Decimal2Label3],		
				s.[Decimal2Visibility],

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
				s.[Lookup5Label],
				s.[Lookup5Label2],
				s.[Lookup5Label3],
				s.[Lookup5Visibility],
				s.[Lookup5DefinitionId],
				s.[Lookup6Label],
				s.[Lookup6Label2],
				s.[Lookup6Label3],
				s.[Lookup6Visibility],
				s.[Lookup6DefinitionId],
				s.[Lookup7Label],
				s.[Lookup7Label2],
				s.[Lookup7Label3],
				s.[Lookup7Visibility],
				s.[Lookup7DefinitionId],
				s.[Lookup8Label],
				s.[Lookup8Label2],
				s.[Lookup8Label3],
				s.[Lookup8Visibility],
				s.[Lookup8DefinitionId],

				s.[Text1Label],
				s.[Text1Label2],
				s.[Text1Label3],	
				s.[Text1Visibility],

				s.[Text2Label],
				s.[Text2Label2],
				s.[Text2Label3],	
				s.[Text2Visibility],

				s.[Text3Label],
				s.[Text3Label2],
				s.[Text3Label3],	
				s.[Text3Visibility],

				s.[Text4Label],
				s.[Text4Label2],
				s.[Text4Label3],	
				s.[Text4Visibility],

				s.[HasAddress],

				s.[PreprocessScript],
				s.[ValidateScript],
				-----Properties applicable to Agents only
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

				s.[TaxIdentificationNumberVisibility],

				s.[BankAccountNumberVisibility],
				s.[ExternalReferenceVisibility],
				s.[ExternalReferenceLabel],
				s.[ExternalReferenceLabel2],
				s.[ExternalReferenceLabel3],

				s.[UserCardinality],
				s.[HasAttachments],
				s.[AttachmentsCategoryDefinitionId],

				s.[MainMenuIcon], s.[MainMenuSection], s.[MainMenuSortKey], @UserId)
		OUTPUT s.[Index], inserted.[Id]
	) AS x;
	
	-- The following code is needed for bulk import, when the reliance is on Agent1DefinitionIndex
	MERGE [dbo].[AgentDefinitions] As t
	USING (
		SELECT II.[Id], IIAgent1Definition.[Id] As Agent1DefinitionId
		FROM @Entities O
		JOIN @IndexedIds IIAgent1Definition ON IIAgent1Definition.[Index] = O.[Agent1DefinitionIndex]
		JOIN @IndexedIds II ON II.[Index] = O.[Index]
	) As s
	ON (t.[Id] = s.[Id])
	WHEN MATCHED THEN UPDATE SET t.[Agent1DefinitionId] = s.[Agent1DefinitionId];
	
	-- Reports
	WITH CurrentDefinitionReportDefinitions AS (
		SELECT *
		FROM [dbo].[AgentDefinitionReportDefinitions]
		WHERE [AgentDefinitionId] IN (SELECT [Id] FROM @Entities)
	)
	MERGE CurrentDefinitionReportDefinitions AS t
	USING (
		SELECT
			RDRD.[Index],
			RDRD.[Id],
			II.[Id] AS [AgentDefinitionId],
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
			[Index], [AgentDefinitionId],	[ReportDefinitionId], [Name], [Name2], [Name3], [SavedById]
		) VALUES (
			[Index], s.[AgentDefinitionId], s.[ReportDefinitionId], s.[Name], s.[Name2], s.[Name3], @UserId
		);
	
	-- Signal clients to refresh their cache
	IF EXISTS (SELECT * FROM @IndexedIds I JOIN [dbo].[AgentDefinitions] D ON I.[Id] = D.[Id] WHERE D.[State] <> N'Hidden')
		UPDATE [dbo].[Settings] SET [DefinitionsVersion] = NEWID();

	IF @ReturnIds = 1
		SELECT * FROM @IndexedIds;
END;