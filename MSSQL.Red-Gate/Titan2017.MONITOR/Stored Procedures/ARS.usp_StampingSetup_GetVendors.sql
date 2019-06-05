SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [ARS].[usp_StampingSetup_GetVendors]
as
begin
	begin try
		
		select
			v.code as Vendor
		from
			dbo.vendor v
		order by
			Code

	end try
	begin catch
		throw;
	end catch
end
GO
