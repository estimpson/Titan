SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_data_transfer_gm_delfor]
as
begin
  insert into m_in_release_plan(customer_part,
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
      convert(decimal(20,6),quantity),'S',
      convert(datetime,start_date)
      from delfor_releases
      where rtrim(forecast_type)='4'
  if @@ROWCOUNT>0
    execute msp_process_in_release_plan
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
      from delfor_releases
      where rtrim(forecast_type)='1'
  if @@ROWCOUNT>0
    execute msp_process_in_ship_sched
  insert into gm_pilot_releases(customer_part,
    ship_to_id,
    customer_po,
    model_year,
    release_no,
    quantity,
    release_date)
    select rtrim(buyer_part),
      rtrim(ship_to_id),' ',
      rtrim(model_year),
      rtrim(release_number),
      convert(decimal(20,6),rtrim(quantity)),
      convert(datetime,rtrim(start_date))
      from delfor_releases
      where rtrim(forecast_type)='11'
  delete from delfor_releases
  select id,
     message 
    from  log 
    where spid=@@spid order by
    id asc
end
GO
