﻿CREATE PROCEDURE [dal].[Resources__Save]
	@DefinitionId INT,
	@Entities [dbo].[ResourceList] READONLY,
	@ResourceUnits [dbo].[ResourceUnitList] READONLY,
	@Attachments [dbo].[ResourceAttachmentList] READONLY,
	@ReturnIds BIT = 0,
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IndexedIds [dbo].[IndexedIdList], @DeletedImageIds [dbo].[StringList], @DeletedAttachmentIds [dbo].[StringList];
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
	
	-- Entities whose ImageIds will be updated: capture their old ImageIds first (if any) so C# can delete them from blob storage
	INSERT INTO @DeletedImageIds ([Id])
	SELECT [ImageId] FROM [dbo].[Resources] E
	WHERE E.[ImageId] IS NOT NULL 
		AND E.[Id] IN (SELECT [Id] FROM @Entities WHERE [ImageId] IS NULL OR [ImageId] <> N'(Unchanged)');

	-- Save entities
	INSERT INTO @IndexedIds([Index], [Id])
	SELECT x.[Index], x.[Id]
	FROM
	(
		MERGE INTO [dbo].[Resources] AS t
		USING (
			SELECT 
				[Index], [Id],
				@DefinitionId AS [DefinitionId],
				[Name], 
				[Name2], 
				[Name3],
				[Code],
				[CurrencyId],
				[CenterId],
				[Description],
				[Description2],
				[Description3],
				geography::STGeomFromWKB([LocationWkb], 4326) AS [Location], -- 4326 = World Geodetic System, used by Google Maps
				[LocationJson],
				[FromDate],
				[ToDate],
				[Date1],
				[Date2],
				[Date3],
				[Date4],
				[Decimal1],
				[Decimal2],
				[Decimal3],
				[Decimal4],
				[Int1],
				[Int2],
				[Lookup1Id],
				[Lookup2Id],
				[Lookup3Id],
				[Lookup4Id],
				[Text1],					
				[Text2],
-- Specific to resources
				[Identifier],
				[VatRate],
				[ReorderLevel],
				[EconomicOrderQuantity],	
				[UnitId],
				[UnitMass],
				[UnitMassUnitId],
				[MonetaryValue],
				[Agent1Id],
				[Agent2Id],
				[Resource1Id],
				[Resource2Id],
				[ImageId]
			FROM @Entities 
		) AS s ON (t.[Id] = s.[Id])
		WHEN MATCHED 
		THEN
			UPDATE SET
				t.[DefinitionId]			= s.[DefinitionId],
				t.[Name]					= s.[Name],
				t.[Name2]					= s.[Name2],
				t.[Name3]					= s.[Name3],
				
				t.[Code]					= s.[Code],
				t.[CurrencyId]				= s.[CurrencyId],
				t.[CenterId]				= s.[CenterId],
				t.[Description]				= s.[Description],
				t.[Description2]			= s.[Description2],
				t.[Description3]			= s.[Description3],
				t.[Location]				= s.[Location],
				t.[LocationJson]			= s.[LocationJson],
				t.[FromDate]				= s.[FromDate],
				t.[ToDate]					= s.[ToDate],
				t.[Date1]					= s.[Date1],
				t.[Date2]					= s.[Date2],
				t.[Date3]					= s.[Date3],
				t.[Date4]					= s.[Date4],
				t.[Decimal1]				= s.[Decimal1],
				t.[Decimal2]				= s.[Decimal2],
				t.[Decimal3]				= s.[Decimal3],
				t.[Decimal4]				= s.[Decimal4],
				t.[Int1]					= s.[Int1],
				t.[Int2]					= s.[Int2],
				t.[Lookup1Id]				= s.[Lookup1Id],
				t.[Lookup2Id]				= s.[Lookup2Id],
				t.[Lookup3Id]				= s.[Lookup3Id],
				t.[Lookup4Id]				= s.[Lookup4Id],
				t.[Text1]					= s.[Text1],	
				t.[Text2]					= s.[Text2],

				t.[Identifier]				= s.[Identifier],
				t.[VatRate]					= s.[VatRate],
				t.[ReorderLevel]			= s.[ReorderLevel],
				t.[EconomicOrderQuantity]	= s.[EconomicOrderQuantity],
				t.[UnitId]					= s.[UnitId],
				t.[UnitMass]				= s.[UnitMass],
				t.[UnitMassUnitId]			= s.[UnitMassUnitId],
				t.[MonetaryValue]			= s.[MonetaryValue],
				t.[Agent1Id]				= s.[Agent1Id],
				t.[Agent2Id]				= s.[Agent2Id],
				t.[Resource1Id]				= s.[Resource1Id],
				t.[Resource2Id]				= s.[Resource2Id],
				t.[ImageId]					= IIF(s.[ImageId] = N'(Unchanged)', t.[ImageId], s.[ImageId]),
				t.[ModifiedAt]				= @Now,
				t.[ModifiedById]			= @UserId
		WHEN NOT MATCHED THEN
			INSERT (
				[DefinitionId],
				[Name], 
				[Name2], 
				[Name3],
				[Code],
				[CurrencyId],
				[CenterId],
				[Description],
				[Description2],
				[Description3],
				[Location], -- 4326 = World Geodetic System, used by Google Maps
				[LocationJson],
				[FromDate],
				[ToDate],
				[Date1],
				[Date2],
				[Date3],
				[Date4],
				[Decimal1],
				[Decimal2],
				[Decimal3],
				[Decimal4],
				[Int1],
				[Int2],
				[Lookup1Id],
				[Lookup2Id],
				[Lookup3Id],
				[Lookup4Id],
				[Text1],					
				[Text2],
-- Specific to resources
				[Identifier],
				[VatRate],
				[ReorderLevel],
				[EconomicOrderQuantity],
				[UnitId],
				[UnitMass],
				[UnitMassUnitId],
				[MonetaryValue],
				[Agent1Id],
				[Agent2Id],
				[Resource1Id],
				[Resource2Id],
				[ImageId],
				[CreatedById], 
				[CreatedAt], 
				[ModifiedById], 
				[ModifiedAt]
				)
			VALUES (
				s.[DefinitionId],
				s.[Name], 
				s.[Name2], 
				s.[Name3],
				s.[Code],
				s.[CurrencyId],
				s.[CenterId],
				s.[Description],
				s.[Description2],
				s.[Description3],
				s.[Location], -- 4326 = World Geodetic System, used by Google Maps
				s.[LocationJson],
				s.[FromDate],
				s.[ToDate],
				s.[Date1],
				s.[Date2],
				s.[Date3],
				s.[Date4],
				s.[Decimal1],
				s.[Decimal2],
				s.[Decimal3],
				s.[Decimal4],
				s.[Int1],
				s.[Int2],
				s.[Lookup1Id],
				s.[Lookup2Id],
				s.[Lookup3Id],
				s.[Lookup4Id],
				s.[Text1],					
				s.[Text2],
-- Specific to resources
				s.[Identifier],
				s.[VatRate],
				s.[ReorderLevel],
				s.[EconomicOrderQuantity],
				s.[UnitId],
				s.[UnitMass],
				s.[UnitMassUnitId],
				s.[MonetaryValue],
				s.[Agent1Id],
				s.[Agent2Id],
				s.[Resource1Id],
				s.[Resource2Id],
				IIF(s.[ImageId] = N'(Unchanged)', NULL, s.[ImageId]),
				@UserId,
				@Now,
				@UserId,
				@Now
				)
			OUTPUT s.[Index], inserted.[Id]
	) AS x;

	-- The following code is needed for bulk import, when the reliance is on Resource1Index
	MERGE [dbo].[Resources] As t
	USING (
		SELECT II.[Id], IIResource1.[Id] As Resource1Id
		FROM @Entities O
		JOIN @IndexedIds IIResource1 ON IIResource1.[Index] = O.Resource1Index
		JOIN @IndexedIds II ON II.[Index] = O.[Index]
	) As s
	ON (t.[Id] = s.[Id])
	WHEN MATCHED THEN UPDATE SET t.[Resource1Id] = s.[Resource1Id];

	-- MA: copy/paste of previous after adding Resource2Id to table resources
	MERGE [dbo].[Resources] As t
	USING (
		SELECT II.[Id], IIResource2.[Id] As Resource2Id
		FROM @Entities O
		JOIN @IndexedIds IIResource2 ON IIResource2.[Index] = O.Resource2Index
		JOIN @IndexedIds II ON II.[Index] = O.[Index]
	) As s
	ON (t.[Id] = s.[Id])
	WHEN MATCHED THEN UPDATE SET t.[Resource2Id] = s.[Resource2Id];

	-- Resource Units
	WITH BU AS (
		SELECT * FROM [dbo].[ResourceUnits] RU
		WHERE RU.ResourceId IN (SELECT [Id] FROM @IndexedIds)
	)
	MERGE INTO BU AS t
	USING (
		SELECT
			RU.[Id],
			I.[Id] AS [ResourceId],
			RU.[UnitId]
		FROM @ResourceUnits RU
		JOIN @IndexedIds I ON RU.[HeaderIndex] = I.[Index]
	) AS s ON (t.[Id] = s.[Id])
	WHEN MATCHED AND (t.[UnitId] <> s.[UnitId])
	THEN
		UPDATE SET
			t.[UnitId]					= s.[UnitId],
			t.[ModifiedAt]				= @Now,
			t.[ModifiedById]			= @UserId
	WHEN NOT MATCHED THEN
		INSERT (
			[ResourceId],
			[UnitId],
			[CreatedById], 
			[CreatedAt], 
			[ModifiedById], 
			[ModifiedAt]
		) VALUES (
			s.[ResourceId],
			s.[UnitId],
			@UserId,
			@Now,
			@UserId,
			@Now
		)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;		
		
	-- Attachments
	WITH BA AS (
		SELECT * FROM dbo.[ResourceAttachments]
		WHERE [ResourceId] IN (
			SELECT II.[Id] FROM @IndexedIds II 
			JOIN @Entities E ON II.[Index] = E.[Index]
			WHERE E.[UpdateAttachments] = 1 -- Is this correct ?
		)
	)
	INSERT INTO @DeletedAttachmentIds([Id])
	SELECT x.[DeletedFileId]
	FROM
	(
		MERGE INTO BA AS t
		USING (
			SELECT
				A.[Id],
				DI.[Id] AS [ResourceId],
				A.[CategoryId],
				A.[FileName],
				A.[FileExtension],
				A.[FileId],
				A.[Size]
			FROM @Attachments A 
			JOIN @IndexedIds DI ON A.[HeaderIndex] = DI.[Index]
		) AS s ON (t.[Id] = s.[Id])
		WHEN MATCHED THEN
			UPDATE SET
				t.[FileName]		= s.[FileName],
				t.[CategoryId]		= s.[CategoryId],
				t.[ModifiedAt]		= @Now,
				t.[ModifiedById]	= @UserId
		WHEN NOT MATCHED THEN
			INSERT ([ResourceId], [CategoryId], [FileName], [FileExtension], [FileId], [Size], [CreatedById], [CreatedAt], [ModifiedById], [ModifiedAt])
			VALUES (s.[ResourceId], s.[CategoryId], s.[FileName], s.[FileExtension], s.[FileId], s.[Size], @UserId, @Now, @UserId, @Now)
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE
		OUTPUT INSERTED.[FileId] AS [InsertedFileId], DELETED.[FileId] AS [DeletedFileId]
	) AS x
	WHERE x.[InsertedFileId] IS NULL


	-- Return overwritten Image Ids, so C# can delete them from Blob Storage
	SELECT [Id] FROM @DeletedImageIds;

	IF @ReturnIds = 1
		SELECT * FROM @IndexedIds;

	-- Return deleted Attachment Ids, so C# can delete them from Blob Storage
	SELECT [Id] FROM @DeletedAttachmentIds;
END;