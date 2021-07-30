﻿CREATE PROCEDURE [api].[Agents__Save]
	@Entities [AgentList] READONLY,
	@ReturnIds BIT = 0,
	@ValidateOnly BIT = 0,
	@Top INT = 200,
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	-- (1) Validate the Entities
	DECLARE @IsError BIT;
	EXEC [bll].[Agents_Validate__Save] 
		@Entities = @Entities,
		@Top = @Top,
		@IsError = @IsError OUTPUT;

	-- If there are validation errors don't proceed
	IF @IsError = 1 OR @ValidateOnly = 1
		RETURN;

	-- (2) Save the entities
	EXEC [dal].[Agents__Save]
		@Entities = @Entities,
		@ReturnIds = @ReturnIds,
		@UserId = @UserId;
END;