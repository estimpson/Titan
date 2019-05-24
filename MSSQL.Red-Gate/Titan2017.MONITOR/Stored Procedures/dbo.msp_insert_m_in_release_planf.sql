SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_insert_m_in_release_planf]
as
begin
  begin transaction
  insert into m_in_ship_schedule
    select rtrim(customer_part),
      rtrim(ship_to),'','','','A',
      convert(decimal(20,6),cum_qty),'S',
      convert(datetime,date1)
      from fd5_830_releases,edi_setups
      where rtrim(date_indicator)='W'
      and edi_setups.release_flag='F'
      and rtrim(ship_to)=edi_setups.destination
  execute msp_process_in_ship_sched
  commit transaction
end
GO
