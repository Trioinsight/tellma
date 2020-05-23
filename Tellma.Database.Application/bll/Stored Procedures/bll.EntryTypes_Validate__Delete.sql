﻿CREATE PROCEDURE [bll].[EntryTypes_Validate__Delete]
	@Ids [dbo].[IndexedIdList] READONLY,
	@Top INT = 10,
	@ValidationErrorsJson NVARCHAR(MAX) OUTPUT
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];


	SELECT @ValidationErrorsJson = 
	(
		SELECT *
		FROM @ValidationErrors
		FOR JSON PATH
	);

	SELECT TOP (@Top) * FROM @ValidationErrors;
