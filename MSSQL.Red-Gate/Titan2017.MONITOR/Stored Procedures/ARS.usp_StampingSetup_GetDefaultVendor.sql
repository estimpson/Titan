SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [ARS].[usp_StampingSetup_GetDefaultVendor]
	@RawPart varchar(25)
as
begin
	begin try

		select
			coalesce(po.default_vendor, '') as Vendor
		from
			dbo.part_online po
		where
			po.part = @RawPart

	end try
	begin catch
		throw;
	end catch
end
GO
