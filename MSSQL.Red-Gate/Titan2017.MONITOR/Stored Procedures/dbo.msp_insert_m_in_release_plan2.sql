SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_insert_m_in_release_plan2]
as
begin
  begin transaction
  insert into m_in_release_plan
    select rtrim(customer_part),
      rtrim(ship_to),'','','','A',
      convert(decimal(20,6),cum_qty),'S',
      convert(datetime,date1)
      from fd5_830_releases
      where date_indicator='F'
  commit transaction
  select 1
end
GO
