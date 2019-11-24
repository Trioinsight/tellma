﻿	INSERT INTO dbo.ResourceDefinitions (
	[Id],					[TitlePlural],		[TitleSingular],	[ResourceTypeParentList]) VALUES
	( N'received-checks',	N'Received Checks',	N'Received Check',	N'CashEquivalents');

DECLARE @ReceivedChecks [dbo].ResourceList;

-- Bydefining the monetary amount
INSERT INTO @ReceivedChecks ([Index],
		[ResourceTypeId],	[Name],							[CountUnitId]) VALUES
	(0,	N'CashEquivalents', N'Walia Steel Oct 2019 Check',	dbo.fn_UnitName__Id(N'ea'), 69000),
	(1,	N'CashEquivalents', N'Best Plastic Oct 2019 Check',	dbo.fn_UnitName__Id(N'ea'), 15700),
	(2,	N'CashEquivalents', N'Best Paint Oct 2019 Check',	dbo.fn_UnitName__Id(N'ea'), 6900);

	EXEC [api].[Resources__Save] -- N'received-checks'
	@DefinitionId =  N'received-checks',
	@Entities = @ReceivedChecks,
	@ValidationErrorsJson = @ValidationErrorsJson OUTPUT;
	IF @ValidationErrorsJson IS NOT NULL 
	BEGIN
		Print 'Inserting received checks'
		GOTO Err_Label;
	END;

	IF @DebugResources = 1 
BEGIN
	SELECT  N'received-checks' AS [Resource Definition]
	DECLARE @ReceivedChecksIds dbo.IdList;
	INSERT INTO @ReceivedChecksIds SELECT [Id] FROM dbo.Resources WHERE [ResourceDefinitionId] = N'received-checks';
	
	SELECT ResourceTypeId, [Name] AS 'Received Check', Money1 AS [Amount]
	FROM rpt.Resources(@ReceivedChecksIds);
END