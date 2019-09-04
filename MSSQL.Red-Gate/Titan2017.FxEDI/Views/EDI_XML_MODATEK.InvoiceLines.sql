SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_MODATEK].[InvoiceLines]
as
select
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	CustomerPO = sd.customer_po
,	QtyInvoiced = convert(int, round(sd.alternative_qty, 0))
,	ShipperLineWeight = convert(int, round(sd.gross_weight, 0))
,	Price = round(sd.alternate_price, 4)
,	RowNumber = row_number() over (partition by s.id order by sd.customer_part)
from
	Fx.shipper s
	join Fx.shipper_detail sd
		on sd.shipper = s.id
	join Fx.order_header oh
		on oh.order_no = sd.order_no
	join FX.edi_setups es
		on es.destination = s.destination
		and es.asn_overlay_group like 'MDK%'
where
	coalesce(s.type, 'N') in ('N', 'M')
GO
