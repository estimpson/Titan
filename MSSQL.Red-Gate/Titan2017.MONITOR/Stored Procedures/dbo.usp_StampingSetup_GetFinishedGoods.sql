SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[usp_StampingSetup_GetFinishedGoods]
as
begin
	begin try
		
		select
			oh.blanket_part as BlanketPart
		from
			dbo.order_header oh
		where
			oh.blanket_part is not null
		group by
			oh.blanket_part
		order by
			BlanketPart

	end try
	begin catch
		throw;
	end catch
end
GO
