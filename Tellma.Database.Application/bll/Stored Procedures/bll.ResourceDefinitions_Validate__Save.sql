﻿CREATE PROCEDURE [bll].[ResourceDefinitions_Validate__Save]
	@Entities [ResourceDefinitionList] READONLY,
	@Top INT = 10,
	@ValidationErrorsJson NVARCHAR(MAX) OUTPUT
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];

	-- Id must not be duplicated in the uploaded list
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP (@Top)
		'[' + CAST([Index] AS NVARCHAR (255)) + '].Id',
		N'Error_TheCode0IsDuplicated',
		[Code]
	FROM @Entities
	WHERE [Code] IN (
		SELECT [Code] FROM @Entities
		GROUP BY [Code]
		HAVING COUNT(*) > 1
	);

	SELECT @ValidationErrorsJson = 
	(
		SELECT *
		FROM @ValidationErrors
		FOR JSON PATH
	);

	SELECT TOP (@Top) * FROM @ValidationErrors;