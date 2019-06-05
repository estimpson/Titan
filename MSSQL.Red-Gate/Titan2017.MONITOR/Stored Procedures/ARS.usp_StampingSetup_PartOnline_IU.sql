SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [ARS].[usp_StampingSetup_PartOnline_IU]
	@RowID int = null
,	@FinishedGood varchar(25)
,	@RawPart varchar(25)
,	@Supplier varchar(30) = null
,	@PoNumber int = null
as
begin
set nocount on

	begin try
	begin transaction
		
		if (@RowID is null) begin
			
			-- Insert
			insert into 
				ARS.StampingSetup
			(
				FinishedGood
			,	RawPart
			,	Supplier
			,	PONumber
			)	
			values
			(
				@FinishedGood
			,	@RawPart
			,	@Supplier
			,	@PoNumber
			)

		end
		else begin

			-- Update
			update
				ARS.StampingSetup
			set
				Supplier = @Supplier
			,	PONumber = @PoNumber
			,	FinishedGood = @FinishedGood
			,	RawPart = @RawPart
			where
				RowID = @RowID

		end
			
				
		-- Update
		update
			dbo.part_online
		set
			default_vendor = @Supplier
		,	default_po_number = @PoNumber
		where
			part = @RawPart	


		update
			ss
		set	ss.Supplier = @Supplier
		,	ss.PONumber = @PoNumber
		from
			ARS.StampingSetup ss
		where
			ss.RawPart = @RawPart
		
	commit transaction
	end try
	begin catch
		
		if @@trancount > 0 rollback transaction;
		throw;

	end catch
end
GO
