﻿CREATE FUNCTION [map].[DocumentLineDefinitionEntries]()
RETURNS TABLE
AS
RETURN (
	SELECT 
		[Id],
		[DocumentId],
		[LineDefinitionId],
		[EntryIndex],
		[PostingDate],
		[PostingDateIsCommon],
		[Memo],
		[MemoIsCommon],
		[CurrencyId],
		[CurrencyIsCommon],
		[CenterId],
		[CenterIsCommon],
		[AgentId],
		[AgentIsCommon],
		[NotedAgentId],
		[NotedAgentIsCommon],
		[ResourceId],
		[ResourceIsCommon],
		[Quantity],
		[QuantityIsCommon],
		[UnitId],
		[UnitIsCommon],
		[Time1],
		[Time1IsCommon],
		[Duration],
		[DurationIsCommon],
		[DurationUnitId],
		[DurationUnitIsCommon],
		[Time2],
		[Time2IsCommon],
		[ExternalReference],
		[ExternalReferenceIsCommon],
		[ReferenceSourceId],
		[ReferenceSourceIsCommon],
		[InternalReference],
		[InternalReferenceIsCommon],
		[CreatedAt],
		[CreatedById],
		[ModifiedAt],
		[ModifiedById]	
	FROM [dbo].[DocumentLineDefinitionEntries]
);
