SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[msp_data_transfer_gm_deljit]
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
      convert(datetime,rtrim(date_time),101)
      from deljit_releases
  execute msp_process_in_ship_sched
  commit transaction
  begin transaction
  update order_header set
    order_header.dock_code=rtrim(deljit_oh.dock_code)
    from order_header,deljit_oh
    where destination=rtrim(ship_to_id)
    and customer_part=rtrim(buyer_part)
    and deljit_oh.dock_code>' '
  commit transaction
  begin transaction
  update order_header set
    order_header.line_feed_code=rtrim(deljit_oh.line_feed_code)
    from order_header,deljit_oh
    where destination=rtrim(ship_to_id)
    and customer_part=rtrim(buyer_part)
    and deljit_oh.line_feed_code>' '
  commit transaction
  begin transaction
  update order_header set
    line11=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='11Z'
  commit transaction
  begin transaction
  update order_header set
    line12=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='12Z'
  commit transaction
  begin transaction
  update order_header set
    line13=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='13Z'
  commit transaction
  begin transaction
  update order_header set
    line14=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='14Z'
  commit transaction
  begin transaction
  update order_header set
    line15=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='15Z'
  commit transaction
  begin transaction
  update order_header set
    line16=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='16Z'
  commit transaction
  begin transaction
  update order_header set
    line17=kanban_line
    from deljit_kanban as doh
    ,order_header as oh
    ,edi_setups as es
    where rtrim(doh.buyer_part)=oh.customer_part
    and rtrim(doh.ship_to_id)=oh.destination
    and rtrim(doh.ship_to_id)=es.destination
    and rtrim(line_id)='17Z'
  commit transaction
  begin transaction
  delete from deljit_releases
  delete from deljit_cytd
  delete from deljit_kanban
  delete from deljit_oh
  commit transaction
end
GO
