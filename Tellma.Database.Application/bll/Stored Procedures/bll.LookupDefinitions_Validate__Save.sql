﻿CREATE PROCEDURE [bll].[LookupDefinitions_Validate__Save]
	@Entities [LookupDefinitionList] READONLY, -- @ValidationErrorsJson NVARCHAR(MAX) OUTPUT,
	@Top INT = 10,
	@ValidationErrorsJson NVARCHAR(MAX) OUTPUT
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];

	-- TODO

	SELECT @ValidationErrorsJson = 
	(
		SELECT *
		FROM @ValidationErrors
		FOR JSON PATH
	);

	SELECT TOP(@Top) * FROM @ValidationErrors;