SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [ARS].[usp_StampingSetup_GetPoNumbersVendors]
	@RawPart varchar(30)
as
begin
	begin try

		select
			ph.po_number as PoNumber
		,	ph.vendor_code as VendorCode
		from
			dbo.po_header ph
		--where
		--	ph.blanket_part = @RawPart
		--	or exists
		--		(	select
		--				*
		--			from
		--				dbo.po_detail pd
		--			where
		--				pd.po_number = ph.po_number
		--				and pd.part_number = @RawPart
		--		)
		--	or exists
		--		(	select
		--				*
		--			from
		--				dbo.po_detail_history pdh
		--			where
		--				pdh.po_number = ph.po_number
		--				and pdh.part_number = @RawPart
		--		)
		group by
			ph.po_number
		,	ph.vendor_code
		order by
			PoNumber
		,	VendorCode
		
	end try
	begin catch
		throw;
	end catch
end
GO
