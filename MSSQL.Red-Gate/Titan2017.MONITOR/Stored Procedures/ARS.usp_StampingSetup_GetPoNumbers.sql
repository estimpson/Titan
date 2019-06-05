SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [ARS].[usp_StampingSetup_GetPoNumbers]
	@VendorCode varchar(10) 
,	@BlanketPart varchar(30) = null
as
begin
	begin try
		
		if exists (
				select	*
				from	dbo.po_header po
				where	po.vendor_code = @VendorCode ) begin

			select
				po.po_number as PoNumber
			from
				dbo.po_header po
			where
				po.vendor_code = @VendorCode
			order by
				PoNumber

		end
		else begin

			select
				po.po_number as PoNumber
			from
				dbo.po_header po
			order by
				PoNumber

		end

	end try
	begin catch
		throw;
	end catch
end
GO
