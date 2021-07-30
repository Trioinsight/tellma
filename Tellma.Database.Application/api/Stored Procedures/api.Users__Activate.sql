﻿CREATE PROCEDURE [api].[Users__Activate]
	@Ids [dbo].[IndexedIdList] READONLY,
	@IsActive BIT,
	@ValidateOnly BIT = 0,
	@Top INT = 200,
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	-- (1) Validate
	DECLARE @IsError BIT;
	EXEC [bll].[Users_Validate__Activate]
		@Ids = @Ids,
		@IsActive = @IsActive,
		@Top = @Top,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1 OR @ValidateOnly = 1
		RETURN;

	-- (2) Activate/Deactivate the entities
	EXEC [dal].[Users__Activate]
		@Ids = @Ids, 
		@IsActive = @IsActive,
		@UserId = @UserId;
END