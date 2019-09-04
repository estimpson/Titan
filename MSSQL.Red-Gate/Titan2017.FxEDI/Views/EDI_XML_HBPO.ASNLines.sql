SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_HBPO].[ASNLines]
as
select
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	CustomerECL = oh.engineering_level
,	SupplierPart = sd.part_original
,	QtyPacked = convert(int, sd.alternative_qty)
,	Unit = 'EA'
,	AccumShipped = sd.accum_shipped
,	CustomerPO = ltrim(rtrim(sd.customer_po))
,	ModelYear = right(convert(varchar(max), datepart(year, s.date_shipped)), 2)
,	RowNumber = row_number() over (partition by s.id order by sd.customer_part)
from
	Fx.shipper s
	join Fx.shipper_detail sd
		on sd.shipper = s.id
	join Fx.order_header oh
		on oh.order_no = sd.order_no
	join FX.edi_setups es
		on es.destination = s.destination
		and es.asn_overlay_group like 'HLL%'
where
	coalesce(s.type, 'N') in ('N', 'M')
GO
