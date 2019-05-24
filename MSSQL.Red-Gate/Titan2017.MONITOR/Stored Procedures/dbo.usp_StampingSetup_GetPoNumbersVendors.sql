SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_StampingSetup_GetPoNumbersVendors]
	@RawPart varchar(30)
as
begin
	begin try

		select
			ph.po_number as PoNumber
		,	ph.vendor_code as VendorCode
		from
			dbo.po_detail pd
			join dbo.po_header ph
				on ph.po_number = pd.po_number
		where
			pd.part_number = @RawPart
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
