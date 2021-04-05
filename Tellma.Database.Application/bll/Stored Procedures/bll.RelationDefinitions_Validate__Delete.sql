﻿CREATE PROCEDURE [bll].[RelationDefinitions_Validate__Delete]
	@Ids [dbo].[IndexedIdList] READONLY,
	@Top INT = 10
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];	

	-- Check that Definition is not used
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT DISTINCT TOP (@Top)
		 '[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		N'Error_Definition0AlreadyContainsData',
		dbo.fn_Localize(D.[TitlePlural], D.[TitlePlural2], D.[TitlePlural3]) AS [Relation]
	FROM @Ids FE
	JOIN dbo.[RelationDefinitions] D ON D.[Id] = FE.[Id]
	JOIN dbo.[Relations] R ON R.[DefinitionId] = FE.[Id]

	-- Check that Definition is not used in Account Definition Filters
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1])
	SELECT DISTINCT TOP (@Top)
		 '[' + CAST(FE.[Index] AS NVARCHAR (255)) + ']',
		N'Error_TheRelationDefinition0IsUsedInAccountType1',
		dbo.fn_Localize(RLD.[TitleSingular], RLD.[TitleSingular2], RLD.[TitleSingular3]) AS [Definition],
		dbo.fn_Localize(AD.[Name], AD.[Name2], AD.[Name3]) AS [AccountType]
	FROM @Ids FE
	JOIN dbo.[RelationDefinitions] RLD ON RLD.[Id] = FE.[Id]
	JOIN dbo.[AccountTypes] AD ON AD.[RelationDefinitionId] = RLD.[Id]

	SELECT TOP(@Top) * FROM @ValidationErrors;