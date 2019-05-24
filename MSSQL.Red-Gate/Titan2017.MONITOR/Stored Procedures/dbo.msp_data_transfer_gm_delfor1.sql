SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_data_transfer_gm_delfor1]
as
begin
  begin transaction
  insert into m_in_ship_schedule(customer_part,
    shipto_id,
    customer_po,
    model_year,
    release_no,
    quantity_qualifier,
    quantity,
    release_dt_qualifier,
    release_dt)
    select rtrim(buyer_part),
      rtrim(ship_to_id),' ',
      rtrim(model_year),
      rtrim(release_number),'N',
      convert(decimal(20,6),rtrim(quantity)),'S',
      convert(datetime,rtrim(start_date))
      from delfor_releases,edi_setups
      where rtrim(forecast_type)='1'
      and rtrim(ship_to_id)=edi_setups.destination
      and edi_setups.release_flag='F'
  execute msp_process_in_ship_sched
  commit transaction
end
GO
