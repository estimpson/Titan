SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_StampingSetup_GetRawParts]
as
begin
	begin try
		
		select
			p.part as Part
		from
			dbo.part p
		where
			p.commodity = 'rawmat'
			or p.group_technology = 'stamp'
		order by
			p.part;

	end try
	begin catch
		throw;
	end catch
end
GO
