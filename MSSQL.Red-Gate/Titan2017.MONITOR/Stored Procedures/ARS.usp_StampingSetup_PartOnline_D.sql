SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [ARS].[usp_StampingSetup_PartOnline_D]
	@RowID int = null
,	@RawPart varchar(25)
as
begin
set nocount on

	begin try
	begin transaction
		
		-- Delete
		delete from
			ARS.StampingSetup
		where
			RowID = @RowID


		-- Update
		update
			dbo.part_online
		set
			default_vendor = null
		,	default_po_number = null
		where
			part = @RawPart	
		
	commit transaction
	end try
	begin catch
		
		if @@trancount > 0 rollback transaction;
		throw;

	end catch
end
GO
