﻿CREATE PROCEDURE [api].[Resources__Activate]
	@DefinitionId INT,
	@Ids [dbo].[IndexedIdList] READONLY,
	@IsActive BIT,
	@ValidateOnly BIT = 0,
	@Top INT = 200,
	@UserId INT,
	@Culture NVARCHAR(50),
	@NeutralCulture NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	-- Set the global values of the session context
	DECLARE @UserLanguageIndex TINYINT = [dbo].[fn_User__Language](@Culture, @NeutralCulture);
    EXEC sys.sp_set_session_context @key = N'UserLanguageIndex', @value = @UserLanguageIndex;
	
	-- (1) Validate
	DECLARE @IsError BIT;
	EXEC [bll].[Resources_Validate__Activate]
		@DefinitionId = @DefinitionId,
		@Ids = @Ids,
		@IsActive = @IsActive,
		@Top = @Top,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1 OR @ValidateOnly = 1
		RETURN;		

	-- (2) Activate/Deactivate the entities
	EXEC [dal].[Resources__Activate]
		@DefinitionId = @DefinitionId,
		@Ids = @Ids, 
		@IsActive = @IsActive,
		@UserId = @UserId;
END;