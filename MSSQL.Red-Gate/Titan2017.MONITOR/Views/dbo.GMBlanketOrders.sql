SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[GMBlanketOrders] as
Select order_no OrderNo,
		customer_part CustomerPart,
		oh.destination Destination
From
 order_header oh
join
	edi_setups es on es.destination =  oh.destination
where
	(es.asn_overlay_group like 'GM%' or es.asn_overlay_group = 'CA2') and
	oh.destination like 'T[0-9]%'
	

GO
