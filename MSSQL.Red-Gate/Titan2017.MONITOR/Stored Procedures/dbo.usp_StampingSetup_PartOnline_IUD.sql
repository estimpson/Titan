SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[usp_StampingSetup_PartOnline_IUD]
	@ID int = null -- used for delete
,	@FinishedGood varchar(25)
,	@RawPart varchar(25)
,	@Supplier varchar(30) = null
,	@PoNumber int = null
as
begin
set nocount on

	begin try
	begin transaction

		if (@ID is null) begin

			merge into dbo.StampingSetup with (holdlock) as tgt
			using (values(@FinishedGood, @RawPart, @Supplier, @PoNumber)) 
				as src(FinishedGood, RawPart, Supplier, PoNumber)
					on src.FinishedGood = tgt.FinishedGood
					and src.RawPart = tgt.RawPart
			when matched and (exists (select src.Supplier except select tgt.Supplier) 
							or exists (select src.PoNumber except select tgt.PoNumber)) then update
			--(src.Supplier <> tgt.Supplier
			--				or src.PoNumber <> tgt.PoNumber) then update
				set tgt.Supplier = src.Supplier,
					tgt.PoNumber = src.PoNumber
			when not matched then insert
				values(src.FinishedGood, src.RawPart, src.Supplier, src.PoNumber);


			merge into dbo.part_online with (holdlock) as tgt
			using (values(@RawPart, @Supplier, @PoNumber))
				as src(RawPart, Supplier, PoNumber)
					on src.RawPart = tgt.part
			when matched and (exists (select src.Supplier except select tgt.default_vendor) 
							or exists (select src.PoNumber except select tgt.default_po_number)) then update
			--when matched and (src.Supplier <> tgt.default_vendor
			--				or src.PoNumber <> tgt.default_po_number) then update
				set tgt.default_vendor = src.Supplier,
					tgt.default_po_number = src.PoNumber;

		end
		else begin -- delete

			merge into dbo.StampingSetup with (holdlock) as tgt
			using (values(@ID, @RawPart)) 
				as src(ID, RawPart)
					on src.ID = tgt.ID
			when matched then
				delete;


			merge into dbo.part_online with (holdlock) as tgt
			using (values(@RawPart, @Supplier, @PoNumber))
				as src(RawPart, Supplier, PoNumber)
					on src.RawPart = tgt.part
			when matched then update
				set tgt.default_vendor = null,
					tgt.default_po_number = null;

		end
		
	commit transaction
	end try
	begin catch
		
		if @@trancount > 0 rollback transaction;
		throw;

	end catch
end
GO
