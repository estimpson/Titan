SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[msp_adjust_planning_862_formet]
AS
begin TRANSACTION

--2018-11-27 ASB FT,LLC - Created for sole purpose of isolating Formet ship schedule processing

delete	order_detail
from	order_detail
	join order_header on order_detail.order_no = order_header.order_no
	join m_in_ship_schedule_formet on 
	order_header.customer_part = m_in_ship_schedule_formet.customer_part and
	order_header.destination = m_in_ship_schedule_formet.shipto_id

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
	join m_in_ship_schedule_formet on 
	order_header.customer_part = m_in_ship_schedule_formet.customer_part and
	order_header.destination = m_in_ship_schedule_formet.shipto_id

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

UPDATE	order_detail
SET	due_date =
	(	SELECT MAX ( od2.due_date )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no ) + 1

FROM	order_detail
	JOIN order_header ON order_detail.order_no = order_header.order_no
	JOIN m_in_ship_schedule_formet ON 
	order_header.customer_part = m_in_ship_schedule_formet.customer_part AND
	order_header.destination = m_in_ship_schedule_formet.shipto_id

WHERE	type = 'P' AND
	order_detail.due_date <=
	(	SELECT MAX ( od2.due_date )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no )

UPDATE	order_detail
SET	our_cum =
	(	SELECT MAX ( od2.the_cum )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no ),
	quantity = order_detail.the_cum -
	(	SELECT MAX ( od2.the_cum )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no ),
	std_qty = order_detail.the_cum -
	(	SELECT MAX ( od2.the_cum )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no )
	
FROM	order_detail
	JOIN order_header ON order_detail.order_no = order_header.order_no
	JOIN m_in_ship_schedule_formet ON 
	order_header.customer_part = m_in_ship_schedule_formet.customer_part AND
	order_header.destination = m_in_ship_schedule_formet.shipto_id

WHERE	type = 'P' AND
	order_detail.our_cum =
	(	SELECT MIN ( od2.our_cum )
		FROM	order_detail od2
		WHERE	od2.type = 'P' AND
			order_detail.order_no = od2.order_no ) AND
	order_detail.our_cum <>
	(	SELECT MAX ( od2.the_cum )
		FROM	order_detail od2
		WHERE	od2.type = 'F' AND
			order_detail.order_no = od2.order_no )


COMMIT TRANSACTION


GO
