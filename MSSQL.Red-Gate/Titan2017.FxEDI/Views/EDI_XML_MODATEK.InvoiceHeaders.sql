SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_MODATEK].[InvoiceHeaders]
as
select
	ShipperID = s.id
,	iConnectID = es.IConnectID
,	TradingPartnerID = es.trading_partner_code
,	InvoiceNumber = s.invoice_number
,	InvoiceDate = convert(date, s.date_shipped)
,	InvoiceTime = convert(time, s.date_shipped)
,	CurrencyCode = 'CAD'
,	TaxStatus = coalesce(nullif(c.custom4, ''), 'TaxExemption')
,	GSTRegNumber = coalesce(nullif(c.custom5, ''), 'GSTRegNumber')
,	ShipTo = coalesce(nullif(es.parent_destination, ''), es.destination)
,	Seller = coalesce(nullif(es.supplier_code, ''), 'SellerDUNS')
,	BillTo = coalesce(nullif(c.address_6, ''), 'Bill To DUNS')
,	ShipDT = s.date_shipped
,	FreightType = case when s.freight_type like '%Prepaid%' then 'PP' else 'CC' end
,	InvoiceAmount = sd.InvoiceAmount
,	GSTAmount = convert(numeric(10,2), round(0.07 * sd.InvoiceAmount, 2))
,	PSTAmount = convert(numeric(10,2), round(0.07 * sd.InvoiceAmount, 2))
,	QtyShipped = sd.QtyShipped
,	GrossWeight = sd.GrossWeight
--,	*
from
	Fx.shipper s
	join Fx.edi_setups es
		on s.destination = es.destination
		and es.asn_overlay_group like 'MDK%'
	join Fx.destination d
		on d.destination = s.destination
	join Fx.customer c
		on c.customer = d.customer
	cross apply
		(	select
				InvoiceAmount = sum(sd.alternative_qty * sd.alternate_price)
			,	QtyShipped = sum(convert(int, round(sd.alternative_qty, 0)))
			,	GrossWeight = sum(convert(int, round(sd.gross_weight, 0)))
			from
				Fx.shipper_detail sd
			where
				sd.shipper = s.id
		) sd
	cross join Fx.parameters p
where
	coalesce(s.type, 'N') in ('N', 'M')
	--and s.id = 75964go
GO
