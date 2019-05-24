SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[msp_adjust_planning_862]
as
begin transaction

delete	order_detail
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.the_cum <=
	(	select	max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) and
	order_detail.due_date =
	(	select min ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	due_date =
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ) + 1

from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.due_date <=
	(	select max ( od2.due_date )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )

update	order_detail
set	our_cum =
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )
	
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule on 
	order_header.customer_part = m_in_ship_schedule.customer_part and
	order_header.destination = m_in_ship_schedule.shipto_id

where	type = 'P' and
	order_detail.our_cum =
	(	select min ( od2.our_cum )
		from	order_detail od2
		where	od2.type = 'P' and
			order_detail.order_no = od2.order_no ) and
	order_detail.our_cum <>
	(	select max ( od2.the_cum )
		from	order_detail od2
		where	od2.type = 'F' and
			order_detail.order_no = od2.order_no )


commit transaction


GO
