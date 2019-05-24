SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_insert_m_in_release_plan3]
as
begin
  begin transaction
  delete from fd5_830_releases
  commit transaction
  execute msp_process_in_release_plan
  select  message  from  log 
end
GO
