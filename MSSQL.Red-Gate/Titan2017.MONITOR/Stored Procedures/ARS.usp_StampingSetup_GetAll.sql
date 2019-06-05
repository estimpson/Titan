SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [ARS].[usp_StampingSetup_GetAll]
	@Sort varchar(20)
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
			order by
				ss.PoNumber
		end
			
	end try
	begin catch
		throw;
	end catch
end
GO
