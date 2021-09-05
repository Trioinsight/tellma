﻿CREATE FUNCTION [map].[AccountTypes] ()
RETURNS TABLE
AS
RETURN (
    SELECT
        [Id],
        [ParentId],
        [Code],
        [Concept],
        [Name],
        [Name2],
        [Name3],
        [Description],
        [Description2],
        [Description3],
        [Node],
        [IsMonetary],
        [IsAssignable],
        [StandardAndPure],
        [EntryTypeParentId],
        [Time1Label],
        [Time1Label2],
        [Time1Label3],
        [Time2Label],
        [Time2Label2],
        [Time2Label3],
        [ExternalReferenceLabel],
        [ExternalReferenceLabel2],
        [ExternalReferenceLabel3],
        [ReferenceSourceLabel],
        [ReferenceSourceLabel2],
        [ReferenceSourceLabel3],
        [InternalReferenceLabel],
        [InternalReferenceLabel2],
        [InternalReferenceLabel3],
        [NotedAgentNameLabel],
        [NotedAgentNameLabel2],
        [NotedAgentNameLabel3],
        [NotedAmountLabel],
        [NotedAmountLabel2],
        [NotedAmountLabel3],
        [NotedDateLabel],
        [NotedDateLabel2],
        [NotedDateLabel3],
        [IsActive],
        [IsSystem],
        [SavedById],
	    TODATETIMEOFFSET([ValidFrom], '+00:00') AS [SavedAt],
        [ValidFrom],
        [ValidTo],
        [Node].GetAncestor(1)  AS [ParentNode],
        [Node].GetLevel() AS [Level],
        [Node].ToString() AS [Path],
	    [ActiveChildCount],
	    [ChildCount]
    FROM [dbo].[AccountTypes]
);
