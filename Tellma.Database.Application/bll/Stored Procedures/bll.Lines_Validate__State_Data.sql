﻿CREATE PROCEDURE [bll].[Lines_Validate__State_Data]
-- @Lines and @Entries are read from the database just before calling.
	@Documents DocumentList READONLY,
	@DocumentLineDefinitionEntries DocumentLineDefinitionEntryList READONLY, -- TODO: Add to signature everywhere
	@Lines LineList READONLY,
	@Entries EntryList READONLY,
	@State SMALLINT,
	@Top INT = 200,
	@IsError BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ValidationErrors [dbo].[ValidationErrorList];
	DECLARE @ManualLineLD INT = (SELECT [Id] FROM dbo.LineDefinitions WHERE [Code] = N'ManualLine');

	-- The @Field is required if Line State >= RequiredState of line def column
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT DISTINCT TOP (@Top)
		CASE
			WHEN LDC.InheritsFromHeader >= 2 AND (
				FL.Id = N'CurrencyId' AND D.[CurrencyIsCommon] = 1 OR
				FL.Id = N'CenterId' AND D.[CenterIsCommon] = 1 OR
				FL.Id = N'AgentId' AND D.[AgentIsCommon] = 1 OR
				FL.Id = N'NotedAgentId' AND D.[NotedAgentIsCommon] = 1 OR
				FL.Id = N'ResourceId' AND D.[ResourceIsCommon] = 1 OR
				FL.Id = N'NotedResourceId' AND D.[NotedResourceIsCommon] = 1 OR
				FL.Id = N'Quantity' AND D.[QuantityIsCommon] = 1 OR
				FL.Id = N'UnitId' AND D.[UnitIsCommon] = 1 OR
				FL.Id = N'Time1' AND D.[Time1IsCommon] = 1 OR
				FL.Id = N'Time2' AND D.[Time2IsCommon] = 1 OR
				FL.Id = N'ExternalReference' AND D.[ExternalReferenceIsCommon] = 1 OR
				FL.Id = N'ReferenceSourceId' AND D.[ReferenceSourceIsCommon] = 1 OR
				FL.Id = N'InternalReference' AND D.[InternalReferenceIsCommon] = 1
			) THEN
				N'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + N'].' + FL.[Id]
			WHEN LDC.InheritsFromHeader >= 1 AND LD.ViewDefaultsToForm = 0 AND (
				FL.Id = N'CurrencyId' AND DLDE.[CurrencyIsCommon] = 1 OR
				FL.Id = N'CenterId' AND DLDE.[CenterIsCommon] = 1 OR
				FL.Id = N'AgentId' AND DLDE.[AgentIsCommon] = 1 OR
				FL.Id = N'NotedAgentId' AND DLDE.[NotedAgentIsCommon] = 1 OR
				FL.Id = N'ResourceId' AND DLDE.[ResourceIsCommon] = 1 OR
				FL.Id = N'NotedResourceId' AND DLDE.[NotedResourceIsCommon] = 1 OR
				FL.Id = N'Quantity' AND DLDE.[QuantityIsCommon] = 1 OR
				FL.Id = N'UnitId' AND DLDE.[UnitIsCommon] = 1 OR
				FL.Id = N'Time1' AND DLDE.[Time1IsCommon] = 1 OR
				FL.Id = N'Time2' AND DLDE.[Time2IsCommon] = 1 OR
				FL.Id = N'ExternalReference' AND DLDE.[ExternalReferenceIsCommon] = 1 OR
				FL.Id = N'ReferenceSourceId' AND DLDE.[ReferenceSourceIsCommon] = 1 OR
				FL.Id = N'InternalReference' AND DLDE.[InternalReferenceIsCommon] = 1
			) THEN
				N'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + N'].LineDefinitionEntries['  + CAST(DLDE.[Index] AS NVARCHAR (255)) + N'].' + FL.[Id]
			ELSE
				N'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + N'].Lines[' +
				CAST(E.[LineIndex] AS NVARCHAR (255)) + N'].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + N'].' + FL.[Id]
			END,
		N'Error_Field0IsRequired',
		[dbo].[fn_Localize](LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [FieldName]
	FROM @Entries E
	CROSS JOIN (VALUES
		(N'CurrencyId'),(N'AgentId'),(N'NotedAgentId'),(N'ResourceId'),(N'NotedResourceId'),(N'CenterId'),(N'EntryTypeId'),
		(N'MonetaryValue'),	(N'Quantity'),(N'UnitId'),(N'Time1'),(N'Time2'),(N'ExternalReference'),
		(N'ReferenceSourceId'),(N'InternalReference'),(N'NotedAgentName'),(N'NotedAmount'),(N'NotedDate')
	) FL([Id])
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN @Documents D ON D.[Index] = L.[DocumentIndex]
	JOIN dbo.LineDefinitions LD ON L.DefinitionId = LD.[Id]
	JOIN dbo.LineDefinitionColumns LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[EntryIndex] = E.[Index] AND LDC.[ColumnName] = FL.[Id]
	LEFT JOIN @DocumentLineDefinitionEntries DLDE ON D.[Index] = DLDE.[DocumentIndex] AND L.[DefinitionId] = DLDE.[LineDefinitionId] AND E.[Index] = DLDE.[EntryIndex]
	WHERE @State >= LDC.[RequiredState]
	AND L.[DefinitionId] <> @ManualLineLD
	AND	(
		FL.Id = N'CurrencyId'			AND E.[CurrencyId] IS NULL OR
		FL.Id = N'AgentId'				AND E.[AgentId] IS NULL OR
		FL.Id = N'NotedAgentId'			AND E.[NotedAgentId] IS NULL OR
		FL.Id = N'ResourceId'			AND E.[ResourceId] IS NULL OR
		FL.Id = N'NotedResourceId'		AND E.[NotedResourceId] IS NULL OR
		FL.Id = N'CenterId'				AND E.[CenterId] IS NULL OR
		FL.Id = N'EntryTypeId'			AND E.[EntryTypeId] IS NULL OR
		FL.Id = N'MonetaryValue'		AND E.[MonetaryValue] IS NULL OR
		FL.Id = N'Quantity'				AND E.[Quantity] IS NULL OR
		FL.Id = N'UnitId'				AND E.[UnitId] IS NULL OR
		FL.Id = N'Time1'				AND E.[Time1] IS NULL OR
		FL.Id = N'Time2'				AND E.[Time2] IS NULL OR
		FL.Id = N'ExternalReference'	AND E.[ExternalReference] IS NULL OR
		FL.Id = N'ReferenceSourceId'	AND E.[ReferenceSourceId] IS NULL OR
		FL.Id = N'InternalReference'	AND E.[InternalReference] IS NULL OR
		FL.Id = N'NotedAgentName'		AND E.[NotedAgentName] IS NULL OR
		FL.Id = N'NotedAmount'			AND E.[NotedAmount] IS NULL OR
		FL.Id = N'NotedDate'			AND E.[NotedDate] IS NULL
	);

	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT DISTINCT TOP (@Top)
		CASE
			WHEN LDC.InheritsFromHeader >= 2 AND (
				FL.Id = N'PostingDate' AND D.[PostingDateIsCommon] = 1 OR
				FL.Id = N'Memo' AND D.[MemoIsCommon] = 1
			) THEN
				N'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + N'].' + FL.[Id]
			WHEN LDC.InheritsFromHeader >= 1 AND LD.ViewDefaultsToForm = 0 AND (
				FL.Id = N'PostingDate' AND DLDE.[PostingDateIsCommon] = 1 OR
				FL.Id = N'Memo' AND DLDE.[MemoIsCommon] = 1
			) THEN
				N'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + N'].LineDefinitionEntries[0].' + FL.[Id]
			ELSE
				N'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + N'].Lines[' + CAST(L.[Index] AS NVARCHAR (255)) + N'].' + FL.[Id]
			END,
		N'Error_Field0IsRequired',
		[dbo].[fn_Localize](LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [FieldName]
	FROM @Lines L
	CROSS JOIN (VALUES
		(N'PostingDate'),(N'Memo')
	) FL([Id])
	JOIN @Documents D ON D.[Index] = L.[DocumentIndex]
	JOIN dbo.LineDefinitions LD ON L.DefinitionId = LD.[Id]
	JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[ColumnName] = FL.[Id]
	LEFT JOIN @DocumentLineDefinitionEntries DLDE ON D.[Index] = DLDE.[DocumentIndex] AND L.[DefinitionId] = DLDE.[LineDefinitionId] AND DLDE.[EntryIndex] = 0
	WHERE @State >= LDC.[RequiredState]
	AND L.[DefinitionId] IN (SELECT [Id] FROM map.LineDefinitions() WHERE [HasWorkflow] = 1)
	AND	(
		FL.Id = N'PostingDate'	AND L.[PostingDate] IS NULL OR
		FL.Id = N'Memo'			AND L.[Memo] IS NULL
	);
	-- No Null account when in state >= 2
	IF @State >= 2
	BEGIN
		DECLARE @ArchiveDate DATE;
		---- Posting Date not null, moved up
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
		CASE
			WHEN L.[DefinitionId] = @ManualLineLD THEN
				N'[' + CAST(D.[Index] AS NVARCHAR (255)) + N'].PostingDate'
			WHEN LDC.InheritsFromHeader >= 1 AND LD.ViewDefaultsToForm = 0 AND (
				DLDE.[PostingDateIsCommon] = 1
			) THEN
				N'[' + CAST(D.[Index] AS NVARCHAR (255)) + N'].LineDefinitionEntries[0].PostingDate'
			ELSE
				'[' + CAST(D.[Index] AS NVARCHAR (255)) + '].Lines[' + CAST(L.[Index] AS NVARCHAR (255)) + ']'
			END,
			N'Error_Field0IsRequired',		
			N'localize:Line_PostingDate'
		FROM @Lines L
		JOIN @Documents D ON D.[Index] = L.[DocumentIndex]
		JOIN dbo.LineDefinitions LD ON L.DefinitionId = LD.[Id]
		JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[ColumnName] = N'PostingDate'
		LEFT JOIN @DocumentLineDefinitionEntries DLDE ON D.[Index] = DLDE.[DocumentIndex] AND L.[DefinitionId] = DLDE.[LineDefinitionId] AND DLDE.[EntryIndex] = 0

		WHERE L.[PostingDate] IS NULL;

		-- Currency Exchange Rate must be defined for that date
		DECLARE @FunctionalCurrencyID NCHAR (3) = dal.fn_FunctionalCurrencyId();
		INSERT INTO @ValidationErrors([Key], [ErrorName])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ '].CurrencyId',
				N'Error_ExchangeRateIsRequired'
		FROM @Entries E
		JOIN @Lines L ON E.[LineIndex] = L.[Index] AND E.[DocumentIndex] = L.[DocumentIndex]
		WHERE L.[DefinitionId] <> @ManualLineLD
		AND L.[DefinitionId] IN (SELECT [Id] FROM [dbo].[LineDefinitions] WHERE [GenerateScript] IS NULL)
		AND E.[MonetaryValue] IS NOT NULL
		AND E.[CurrencyId] <> @FunctionalCurrencyID
		AND [bll].[fn_ConvertCurrencies](
							L.[PostingDate], E.[CurrencyId], @FunctionalCurrencyID, E.[MonetaryValue]
						) IS NULL

		-- Null Values are not allowed
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST([DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST([LineIndex] AS NVARCHAR (255)) + '].Entries[' +
				CAST([Index]  AS NVARCHAR (255))+ '].Value',
			N'Error_Field0IsRequired',
			N'localize:Entry_Value'
		FROM @Entries
		WHERE [Value] IS NULL;

		-- Lines must be balanced
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + ']',
			N'Error_TransactionHasDebitCreditDifference0',
			FORMAT(SUM(E.[Direction] * E.[Value]), 'N', 'en-us') AS NetDifference
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		GROUP BY L.[DocumentIndex], L.[Index]
		HAVING SUM(E.[Direction] * E.[Value]) <> 0;

		-- account/currency/center/ must not be null
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ '].' + FL.[Id],
			N'Error_Field0IsRequired',
			N'localize:Entry_' + LEFT(FL.[Id], LEN(FL.[Id]) - 2)
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		CROSS JOIN (VALUES
			(N'AccountId'),(N'CurrencyId'),(N'CenterId')
		) FL([Id])
		WHERE	(
			FL.Id = N'AccountId'		AND E.[AccountId] IS NULL OR
			FL.Id = N'CurrencyId'		AND E.[CurrencyId] IS NULL OR
			FL.Id = N'CenterId'			AND E.[CenterId] IS NULL
		)

		-- Depending on account, agent and/or resource and/or entry type might be required
		-- NOTE: the conformance with resource definition and account definition is in [bll].[Documents_Validate__Save]
		-- TODO: Check if I can add a filter that this applies to JVs only
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + '].AgentId',
			N'Error_Field0IsRequired',
			N'localize:Entry_Agent'
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.[AccountId] = A.[Id]
		WHERE (A.[AgentDefinitionId] IS NOT NULL) AND (E.[AgentId] IS NULL);

		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + '].ResourceId',
			N'Error_Field0IsRequired',
			N'localize:Entry_Resource'
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.[AccountId] = A.[Id]
		WHERE (A.[ResourceDefinitionId] IS NOT NULL) AND (E.[ResourceId] IS NULL);
	
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + '].NotedAgentId',
			N'Error_Field0IsRequired',
			N'localize:Entry_NotedAgent'
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.[AccountId] = A.[Id]
		WHERE (A.[NotedAgentDefinitionId] IS NOT NULL) AND (E.[NotedAgentId] IS NULL);

		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + '].NotedResourceId',
			N'Error_Field0IsRequired',
			N'localize:Entry_NotedResource'
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.[AccountId] = A.[Id]
		WHERE (A.[NotedResourceDefinitionId] IS NOT NULL) AND (E.[NotedResourceId] IS NULL);
		
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + '].EntryTypeId',
			N'Error_Field0IsRequired',
			N'localize:Entry_EntryType'
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.[AccountId] = A.[Id]
		JOIN dbo.[AccountTypes] AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[EntryTypes] ET ON AC.[EntryTypeParentId] = ET.[Id]
		WHERE ET.IsActive = 1 AND E.[EntryTypeId] IS NULL;

-- The block below shall be deprecated after we migrate these DBs
IF DB_NAME() IN (N'Tellma.100', N'Tellma.101', N'Tellma.200', N'Tellma.201', N'Tellma.1201')
BEGIN
		WITH PreBalances AS ( -- due to other past and future transactions
			SELECT E.[AccountId], E.[AgentId], E.[ResourceId],
				SUM(CASE WHEN U.UnitType <> N'Pure' THEN E.[Direction] * E.[Quantity] ELSE 0 END) AS [ServiceQuantity],
				SUM(CASE WHEN U.UnitType = N'Pure' THEN E.[Direction] * E.[Quantity] ELSE 0 END) AS [PureQuantity],
				SUM(E.[Direction] * E.[Value]) AS [NetValue]
			FROM dbo.Entries E
			JOIN dbo.Lines L ON E.[LineId] = L.[Id]
			JOIN dbo.Accounts A ON E.AccountId = A.[Id]
			JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
			JOIN dbo.Units U ON E.[UnitId] = U.[Id]
			JOIN (
				SELECT DISTINCT [AccountId], [AgentId], [ResourceId]
				FROM @Entries
			) FE ON E.[AccountId] = FE.[AccountId] AND E.[AgentId] = FE.[AgentId] AND E.[ResourceId] = FE.[ResourceId]
			WHERE
				AC.[StandardAndPure] = 1
			AND L.[State] = 4
			AND L.[Id] NOT IN (SELECT [Id] FROM @Lines)
			AND E.[Id] NOT IN (SELECT [Id] FROM @Entries)
			GROUP BY E.[AccountId], E.[AgentId], E.[ResourceId]
		),
		CurrentBalances AS (
			SELECT E.[AccountId], E.[AgentId], E.[ResourceId],
				SUM(CASE WHEN U.UnitType <> N'Pure' THEN E.[Direction] * E.[Quantity] ELSE 0 END) AS [ServiceQuantity],
				SUM(CASE WHEN U.UnitType = N'Pure' THEN E.[Direction] * E.[Quantity] ELSE 0 END) AS [PureQuantity],
				SUM(E.[Direction] * E.[Value]) AS [NetValue]
			FROM @Entries E
			JOIN @Lines L ON E.[LineIndex] = L.[Index] AND E.[DocumentIndex] = L.[DocumentIndex]
			JOIN dbo.Accounts A ON E.AccountId = A.[Id]
			JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
			JOIN dbo.Units U ON E.[UnitId] = U.[Id]
			WHERE
				AC.[StandardAndPure] = 1
			GROUP BY E.[AccountId], E.[AgentId], E.[ResourceId]
		)
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Account0QuantityBalanceIsWrong',
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS AgentName
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.AccountId = A.[Id]
		JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[Agents] RL ON E.AgentId = RL.Id
		JOIN CurrentBalances CB ON E.[AccountId] = CB.[AccountId] AND E.[AgentId] = CB.[AgentId] AND E.[ResourceId] = CB.[ResourceId]
		LEFT JOIN PreBalances PB ON E.[AccountId] = PB.[AccountId] AND E.[AgentId] = PB.[AgentId] AND E.[ResourceId] = PB.[ResourceId]
		WHERE
			AC.[StandardAndPure] = 1
		AND ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) NOT IN (0, 1)
		UNION
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Account0ServiceBalanceIsNegative',
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS AgentName
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.AccountId = A.[Id]
		JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[Agents] RL ON E.AgentId = RL.Id
		JOIN CurrentBalances CB ON E.[AccountId] = CB.[AccountId] AND E.[AgentId] = CB.[AgentId] AND E.[ResourceId] = CB.[ResourceId]
		LEFT JOIN PreBalances PB ON E.[AccountId] = PB.[AccountId] AND E.[AgentId] = PB.[AgentId] AND E.[ResourceId] = PB.[ResourceId]
		WHERE
			AC.[StandardAndPure] = 1
		AND ISNULL(PB.[ServiceQuantity], 0) + ISNULL(CB.[ServiceQuantity], 0) < 0
		UNION
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Account0ValueBalanceIsNegative',
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS AgentName
			--ISNULL(PB.[ServiceQuantity], 0) + ISNULL(CB.[ServiceQuantity], 0) AS ServiceBalance,
			--ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) AS PureBalance
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.AccountId = A.[Id]
		JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[Agents] RL ON E.AgentId = RL.Id
		JOIN CurrentBalances CB ON E.[AccountId] = CB.[AccountId] AND E.[AgentId] = CB.[AgentId] AND E.[ResourceId] = CB.[ResourceId]
		LEFT JOIN PreBalances PB ON E.[AccountId] = PB.[AccountId] AND E.[AgentId] = PB.[AgentId] AND E.[ResourceId] = PB.[ResourceId]
		WHERE
			AC.[StandardAndPure] = 1
		AND ISNULL(PB.[NetValue], 0) + ISNULL(CB.[NetValue], 0) < 0
		UNION
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Account0RequiresAnEntryWithPureQuantity',
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS AgentName
			--ISNULL(PB.[ServiceQuantity], 0) + ISNULL(CB.[ServiceQuantity], 0) AS ServiceBalance,
			--ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) AS PureBalance
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.AccountId = A.[Id]
		JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[Agents] RL ON E.AgentId = RL.Id
		JOIN CurrentBalances CB ON E.[AccountId] = CB.[AccountId] AND E.[AgentId] = CB.[AgentId] AND E.[ResourceId] = CB.[ResourceId]
		LEFT JOIN PreBalances PB ON E.[AccountId] = PB.[AccountId] AND E.[AgentId] = PB.[AgentId] AND E.[ResourceId] = PB.[ResourceId]
		WHERE
			AC.[StandardAndPure] = 1
		AND ISNULL(PB.[ServiceQuantity], 0) + ISNULL(CB.[ServiceQuantity], 0) <> 0
		AND ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) = 0
		UNION
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Account0HasNoResourceButValueBalanceIsNonZero',
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS AgentName
			--ISNULL(PB.[ServiceQuantity], 0) + ISNULL(CB.[ServiceQuantity], 0) AS ServiceBalance,
			--ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) AS PureBalance
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.Accounts A ON E.AccountId = A.[Id]
		JOIN dbo.AccountTypes AC ON A.[AccountTypeId] = AC.[Id]
		JOIN dbo.[Agents] RL ON E.AgentId = RL.Id
		JOIN CurrentBalances CB ON E.[AccountId] = CB.[AccountId] AND E.[AgentId] = CB.[AgentId] AND E.[ResourceId] = CB.[ResourceId]
		LEFT JOIN PreBalances PB ON E.[AccountId] = PB.[AccountId] AND E.[AgentId] = PB.[AgentId] AND E.[ResourceId] = PB.[ResourceId]
		WHERE
			AC.[StandardAndPure] = 1
		AND ISNULL(PB.[NetValue], 0) + ISNULL(CB.[NetValue], 0) <> 0
		AND ISNULL(PB.[PureQuantity], 0) + ISNULL(CB.[PureQuantity], 0) = 0
	END
END
	-- cannot unpost (4=>1,2,3) if it causes negative quantity
	IF @State < 4 and (1=0)
	BEGIN
	WITH InventoryAccounts AS (
		SELECT A.[Id]
		FROM dbo.Accounts A
		JOIN dbo.AccountTypes ATC ON A.[AccountTypeId] = ATC.[Id]
		JOIN dbo.AccountTypes ATP ON ATC.[Node].IsDescendantOf(ATP.[Node])  = 1
		WHERE ATP.[Concept] = N'Inventories'
	),
	NegativeBalancesDocuments AS (
	SELECT
		L.[DocumentIndex], L.[Index] AS [LineIndex], E.[Index], BD.Code, E.ResourceId, E.[AgentId],
		SUM(BE.[Direction] * BE.[Quantity]) 
			OVER (Partition BY BE.[ResourceId], BE.[AgentId] ORDER BY BL.[PostingDate], [LineId]) AS RunningTotal
		FROM (
			SELECT LFE.[Id], LFE.[PostingDate], LFE.[Index], LFE.[DocumentIndex], LBE.[DocumentId]
			FROM @Lines LFE
			JOIN dbo.Lines LBE ON LFE.[Id] = LBE.[Id]
			WHERE LBE.[State] = 4
		) L -- focus on lines that were posted and now are being unposted
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN InventoryAccounts A ON A.[Id] = E.[AccountId]
		JOIN dbo.Entries BE ON BE.[AccountId] = E.[AccountId] AND BE.[ResourceId] = E.[ResourceId] AND BE.[AgentId] = E.[AgentId]
		JOIN dbo.Lines BL ON BE.LineId = BL.[Id]
		JOIN map.Documents() BD ON BL.DocumentId = BD.[Id]
		WHERE BL.[State] = 4
		AND (BL.[Id] NOT IN (SELECT [Id] FROM @Lines))
	)
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1],[Argument2],[Argument3], [Argument4])
	SELECT DISTINCT TOP (@Top)
		'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' +
			CAST(E.[Index]  AS NVARCHAR (255))+ ']',
			N'Error_Resource01AndAgent23AppearInLaterDocument4', -- cause negative quantity in document
			dbo.fn_Localize(RD.[TitleSingular], RD.[TitleSingular2], RD.[TitleSingular3]) AS ResourceDefinition,
			dbo.fn_Localize(R.[Name], R.[Name2], R.[Name3]) AS [Resource],
			dbo.fn_Localize(AD.[TitleSingular], AD.[TitleSingular2], AD.[TitleSingular3]) AS AgentDefinition,
			dbo.fn_Localize(RL.[Name], RL.[Name2], RL.[Name3]) AS [Agent],
			E.Code
		FROM
		NegativeBalancesDocuments E
		JOIN dbo.Resources R ON E.ResourceId = R.[Id]
		JOIN dbo.ResourceDefinitions RD ON R.DefinitionId = RD.Id
		JOIN dbo.[Agents] RL ON E.[AgentId] = RL.[Id]
		JOIN dbo.[AgentDefinitions] AD ON RL.DefinitionId = AD.[Id]
		WHERE E.RunningTotal < 0

	END
	-- cannot post (1,2,3=>4) if it causes negative anywhere
	IF @State = 4 and (1=0)
	BEGIN
		WITH InventoryAccounts AS (
			SELECT A.[Id]
			FROM dbo.Accounts A
			JOIN dbo.AccountTypes ATC ON A.[AccountTypeId] = ATC.[Id]
			JOIN dbo.AccountTypes ATP ON ATC.[Node].IsDescendantOf(ATP.[Node])  = 1
			WHERE ATP.[Concept] = N'Inventories'
		),
		NegativeBalancesDocuments AS (
		SELECT
			L.[DocumentIndex], L.[Index] AS LineIndex, E.[Index], BD.Code, E.ResourceId, E.[AgentId],
			SUM(BE.[Direction] * BE.[Quantity]) 
				OVER (Partition BY BE.[ResourceId], BE.[AgentId] ORDER BY MONTH(BL.[PostingDate]), BE.[Direction] DESC) AS RunningTotal
			FROM @Lines L
			JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
			JOIN InventoryAccounts A ON A.[Id] = E.[AccountId]
			JOIN dbo.Entries BE ON BE.[AccountId] = E.[AccountId] AND BE.[ResourceId] = E.[ResourceId] AND BE.[AgentId] = E.[AgentId]
			JOIN dbo.Lines BL ON BE.LineId = BL.[Id]
			JOIN map.Documents() BD ON BL.DocumentId = BD.[Id]
			WHERE BL.[State] = 4
		)
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1],[Argument2],[Argument3], [Argument4])
		SELECT DISTINCT TOP (@Top)
			'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index]  AS NVARCHAR (255))+ ']',
				N'Error_Resource01AndAgent23AppearInLaterDocument4', -- cause negative quantity in document
				[dbo].[fn_Localize](RD.[TitleSingular], RD.[TitleSingular2], RD.[TitleSingular3]) AS ResourceDefinition,
				[dbo].[fn_Localize](R.[Name], R.[Name2], R.[Name3]) AS [Resource],
				[dbo].[fn_Localize](AD.[TitleSingular], AD.[TitleSingular2], AD.[TitleSingular3]) AS AgentDefinition,
				[dbo].[fn_Localize](RL.[Name], RL.[Name2], RL.[Name3]) AS [Agent],
				E.Code
			FROM NegativeBalancesDocuments E
			JOIN dbo.Resources R ON E.ResourceId = R.[Id]
			JOIN dbo.ResourceDefinitions RD ON R.DefinitionId = RD.Id
			JOIN dbo.[Agents] RL ON E.[AgentId] = RL.[Id]
			JOIN dbo.[AgentDefinitions] AD ON RL.DefinitionId = AD.[Id]
			WHERE E.[RunningTotal] < 0
	END

	IF @State > 0
	BEGIN
		-- No inactive account, for any positive state
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT DISTINCT TOP (@Top)
			'[' + ISNULL(CAST(L.[Index] AS NVARCHAR (255)),'') + ']', 
			N'Error_TheAccount0IsInactive',
			[dbo].[fn_Localize](A.[Name], A.[Name2], A.[Name3]) AS Account
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN dbo.[Accounts] A ON A.[Id] = E.[AccountId]
		WHERE (A.[IsActive] = 0);
		-- Cannot bypass the balance limits
		WITH FE_AB (EntryId, AccountBalanceId) AS (
			SELECT E.[Id] AS EntryId, AB.[Id] AS AccountBalanceId
			FROM @Lines FE
			JOIN @Entries E ON FE.[Index] = E.[LineIndex] AND FE.[DocumentIndex] = E.[DocumentIndex]
			JOIN dbo.Lines L ON FE.[Id] = L.[Id]
			JOIN map.LineDefinitions () LD ON L.[DefinitionId] = LD.[Id]
			JOIN dbo.AccountBalances AB ON
				(E.[CenterId] = AB.[CenterId])
			AND (AB.[AgentId] IS NULL OR E.[AgentId] = AB.[AgentId])
			AND (AB.[ResourceId] IS NULL OR E.[ResourceId] = AB.[ResourceId])
			AND (AB.[CurrencyId] = E.[CurrencyId])
			AND (E.[AccountId] = AB.[AccountId]) -- This will work only after E.AccountId is determined
			WHERE AB.BalanceEnforcedState <= @State
			AND AB.[BalanceEnforcedState] BETWEEN 1 AND 4
			AND (L.[State] >= AB.[BalanceEnforcedState] OR LD.[HasWorkflow] = 0 AND L.[State] = 0)
		),
		BreachingEntries ([AccountBalanceId], [NetBalance]) AS (
			SELECT DISTINCT TOP (@Top)
				AB.[Id] AS [AccountBalanceId], 
				FORMAT(SUM(E.[Direction] * E.[MonetaryValue]), 'N', 'en-us') AS NetBalance
			FROM dbo.Documents D
			JOIN dbo.Lines L ON L.DocumentId = D.[Id]
			JOIN map.LineDefinitions () LD ON L.[DefinitionId] = LD.[Id]
			JOIN dbo.Entries E ON L.[Id] = E.[LineId]
			JOIN dbo.AccountBalances AB ON
				(E.[CenterId] = AB.[CenterId])
			AND (AB.[AgentId] IS NULL OR E.[AgentId] = AB.[AgentId])
			AND (AB.[ResourceId] IS NULL OR E.[ResourceId] = AB.[ResourceId])
			AND (AB.[CurrencyId] = E.[CurrencyId])
			AND (E.[AccountId] = AB.[AccountId]) -- This will work only after E.AccountId is determined
			WHERE AB.Id IN (Select [AccountBalanceId] FROM FE_AB)
			AND ((L.[State] >= AB.[BalanceEnforcedState]) OR 
				L.[Id] IN (Select [Id] FROM @Lines)
				AND LD.[HasWorkflow] = 0
				AND L.[State] = 0)
			GROUP BY AB.[Id], AB.[MinMonetaryBalance], AB.[MaxMonetaryBalance], AB.[MinQuantity], AB.[MaxQuantity]
			HAVING SUM(E.[Direction] * E.[MonetaryValue]) NOT BETWEEN AB.[MinMonetaryBalance] AND AB.[MaxMonetaryBalance]
			OR SUM(E.[Direction] * E.[Quantity]) NOT BETWEEN AB.[MinQuantity] AND AB.[MaxQuantity]
		)
		INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
		SELECT
			'[' + CAST(L.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
				CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' +
				CAST(E.[Index] AS NVARCHAR (255)) + ']',
			N'Error_TheEntryCausesOffLimitBalance0' AS [ErrorName],
			BE.NetBalance
		FROM @Lines L
		JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
		JOIN FE_AB ON E.[Id] = FE_AB.[EntryId]
		JOIN BreachingEntries BE ON FE_AB.[AccountBalanceId] = BE.[AccountBalanceId]
	END

	SET @IsError = CASE WHEN EXISTS(SELECT 1 FROM @ValidationErrors) THEN 1 ELSE 0 END;

	SELECT TOP(@Top) * FROM @ValidationErrors;
END;