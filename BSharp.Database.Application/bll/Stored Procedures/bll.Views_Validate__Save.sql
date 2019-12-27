﻿CREATE PROCEDURE [bll].[Views_Validate__Save]
	@Views [dbo].[ViewList] READONLY,
	@Permissions [dbo].[PermissionList] READONLY,
	@Top INT = 10
AS
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];

	-- No missing role -- C#
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT
		'[' + CAST(P.[HeaderIndex] AS NVARCHAR (255)) + '].Permissions[' + 
			CAST(P.[Index] AS NVARCHAR (255)) + '].RoleId',
		N'Error_TheRole0IsNotSpecified',
		P.[RoleId]
	FROM @Permissions P
	WHERE P.RoleId IS NULL

    INSERT INTO @ValidationErrors([Key], [ErrorName])
    SELECT
		'[' + CAST([Index] AS NVARCHAR (255)) + ']',
		N'Error_CannotModifyInactiveItem'
    FROM @Views
    WHERE Id NOT IN (SELECT Id from [dbo].[Views] WHERE IsActive = 1)
	OPTION(HASH JOIN);
	   
	-- No inactive role
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT
		'[' + CAST(P.[HeaderIndex] AS NVARCHAR (255)) + '].Permissions[' + 
			CAST(P.[Index] AS NVARCHAR (255)) + '].RoleId',
		N'Error_TheRole0IsInactive',
		P.[RoleId]
	FROM @Permissions P
	WHERE P.RoleId IN (
		SELECT [Id] FROM dbo.[Roles] WHERE IsActive = 0
		);

	SELECT TOP (@Top) * FROM @ValidationErrors;