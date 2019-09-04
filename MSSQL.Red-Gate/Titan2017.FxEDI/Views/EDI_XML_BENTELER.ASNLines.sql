SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_BENTELER].[ASNLines]
as
select
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	QtyPacked = dpns.Qty
,	Unit = 'EA'
,	AccumShipped = sd.accum_shipped
,	CustomerPO = sd.customer_po
,	CustomerPO2 =
		substring
		(	dpns.DiscretePONumber
		,	charindex('!', dpns.DiscretePONumber) + 1
		,	charindex('^', dpns.DiscretePONumber, charindex('!', dpns.DiscretePONumber) + 1) - charindex('!', dpns.DiscretePONumber) - 1
		)
,	ECLevel =
		coalesce
		(	oh.engineering_level
		,	nullif(
				substring
				(	dpns.DiscretePONumber
				,	charindex('$', dpns.DiscretePONumber) + 1
				,	2
				)
				,''
			)
		,	right(sd.customer_part, 2)
		)
,	POLine =
		substring
		(	dpns.DiscretePONumber
		,	1
		,	charindex('!', dpns.DiscretePONumber) - 1
		)
,	ReleaseNumber =
		substring
		(	dpns.DiscretePONumber
		,	charindex('^', dpns.DiscretePONumber) + 1
		,	charindex('$', dpns.DiscretePONumber, charindex('^', dpns.DiscretePONumber)) - charindex('^', dpns.DiscretePONumber) - 1
		)
,	RowNumber = row_number() over (partition by s.id order by sd.customer_part)
from
	Fx.shipper s
	join Fx.shipper_detail sd
		join (	select
					dpns.OrderNo
				,	ShipDate = max(dpns.ShipDate)
				,	Qty = sum(dpns.Qty)
				,	dpns.DiscretePONumber
				,	dpns.Shipper
				from
					Fx.DiscretePONumbersShipped dpns
				group by
					dpns.OrderNo
				,	dpns.DiscretePONumber
				,	dpns.Shipper
		     ) dpns
			on dpns.Shipper = sd.shipper
			and dpns.OrderNo = sd.order_no
		on sd.shipper = s.id
	join Fx.order_header oh
		on oh.order_no = sd.order_no
	join FX.edi_setups es
		on es.destination = s.destination
		and es.asn_overlay_group like 'BNT%'
where
	coalesce(s.type, 'N') in ('N', 'M')
GO
