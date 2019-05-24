SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure
[dbo].[msp_data_transfer_gm_delfor2]
as
begin
  begin transaction
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
  execute msp_process_in_release_plan
  commit transaction
  begin transaction
  update order_header set
    order_header.dock_code=rtrim(delfor_oh.dock_code)
    from order_header,delfor_oh
    where order_header.customer_part=rtrim(delfor_oh.buyer_part)
    and order_header.destination=rtrim(delfor_oh.ship_to_id)
    and delfor_oh.dock_code>' '
  commit transaction
  begin transaction
  update order_header set
    order_header.line_feed_code=rtrim(delfor_oh.line_feed_code)
    from order_header,delfor_oh
    where order_header.customer_part=rtrim(delfor_oh.buyer_part)
    and order_header.destination=rtrim(delfor_oh.ship_to_id)
    and delfor_oh.line_feed_code>' '
  commit transaction
  begin transaction
  delete from delfor_releases
  delete from delfor_oh
  delete from delfor_cytd
  commit transaction
end
GO
