SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [ARS].[usp_StampingSetup_GetSearched]
	@Value varchar(30) 
,	@Sort varchar(20)
as
begin
	begin try
		
		if (@Sort = 'FinishedGoods') begin
			select
				ss.RowID
			,	ss.FinishedGood
			,	ss.RawPart
			,	ss.Supplier
			,	ss.PONumber
			from
				ARS.StampingSetup ss
			where
				ss.FinishedGood like '%' + @value + '%'
				or ss.RawPart like '%' + @value + '%'
				or ss.Supplier like '%' + @value + '%'
				or ss.PONumber like '%' + @value + '%'
			order by
				ss.FinishedGood
		end
		else if (@Sort = 'RawParts') begin
			select
				ss.RowID
			,	ss.FinishedGood
			,	ss.RawPart
			,	ss.Supplier
			,	ss.PONumber
			from
				ARS.StampingSetup ss
			where
				ss.FinishedGood like '%' + @value + '%'
				or ss.RawPart like '%' + @value + '%'
				or ss.Supplier like '%' + @value + '%'
				or ss.PONumber like '%' + @value + '%'
			order by
				ss.RawPart
		end
		else if (@Sort = 'Supplier') begin
			select
				ss.RowID
			,	ss.FinishedGood
			,	ss.RawPart
			,	ss.Supplier
			,	ss.PONumber
			from
				ARS.StampingSetup ss
			where
				ss.FinishedGood like '%' + @value + '%'
				or ss.RawPart like '%' + @value + '%'
				or ss.Supplier like '%' + @value + '%'
				or ss.PONumber like '%' + @value + '%'
			order by
				ss.Supplier
		end
		else begin
			select
				ss.RowID
			,	ss.FinishedGood
			,	ss.RawPart
			,	ss.Supplier
			,	ss.PONumber
			from
				ARS.StampingSetup ss
			where
				ss.FinishedGood like '%' + @value + '%'
				or ss.RawPart like '%' + @value + '%'
				or ss.Supplier like '%' + @value + '%'
				or ss.PONumber like '%' + @value + '%'
			order by
				ss.PONumber
		end

	end try
	begin catch
		throw;
	end catch
end
GO
