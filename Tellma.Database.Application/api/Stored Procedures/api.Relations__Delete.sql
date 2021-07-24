﻿CREATE PROCEDURE [api].[Relations__Delete]
	@DefinitionId INT,
	@Ids [dbo].[IndexedIdList] READONLY,
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
	EXEC [bll].[Relations_Validate__Delete] 
		@DefinitionId = @DefinitionId,
		@Ids = @Ids,
		@UserId = @UserId,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1
		RETURN;

	-- (2) Execute
	EXEC [dal].[Relations__Delete]
		@DefinitionId = @DefinitionId,
		@Ids = @Ids;
END;