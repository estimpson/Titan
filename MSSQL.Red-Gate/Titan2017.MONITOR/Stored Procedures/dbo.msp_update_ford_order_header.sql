SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure
[dbo].[msp_update_ford_order_header]
/*-------------------------------------------------------------------------------------*/
/*      This procedure sets order header line feeds, dock codes, and reserve dock codes*/
/*      from data read from 862 transaction sets.*/
/*      Modified:       02 March 1999, Pheidippides McKenzie*/
/*      Returns:        0       success*/
/*                      100     no rows found*/
/*-------------------------------------------------------------------------------------*/
as /*      Update order_header with line feeds from 862 data.*/
begin transaction /* (1T)*/
update oh set
  oh.line_feed_code=fd.delivery_location
  from order_header as oh
  ,ford862_linefeed as fd
  where oh.customer_part=fd.customer_part
  and oh.destination=fd.ship_to
  and fd.location_type='LF'
/*      Update order_header with dock codes from 862 data.*/
update oh set
  oh.dock_code=fd.delivery_location
  from order_header as oh
  ,ford862_linefeed as fd
  where oh.customer_part=fd.customer_part
  and oh.destination=fd.ship_to
  and fd.location_type='DK'
/*      Update order_header with reserve line feeds from 862 data.*/
update oh set
  oh.zone_code=fd.delivery_location
  from order_header as oh
  ,ford862_linefeed as fd
  where oh.customer_part=fd.customer_part
  and oh.destination=fd.ship_to
  and fd.location_type='RL'
/*      Remove processed data.*/
delete from ford862_linefeed
commit transaction /* (1T)*/
/*      Check for rows*/
if @@rowcount=0
  return 100
else
  return 0
GO
