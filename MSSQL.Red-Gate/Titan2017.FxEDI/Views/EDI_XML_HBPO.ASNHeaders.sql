SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_HBPO].[ASNHeaders]
as
select
	ShipperID = s.id
,	iConnectID = es.IConnectID
,	TradingPartnerID = coalesce(es.trading_partner_code, 'HBPO')
,	ASNDate = convert(date, getdate())
,	ASNTime = convert(time, getdate())
,	ShipDateTime = s.date_shipped
,	ArrivalDateTime = s.date_shipped + 1
,	ShipDate = convert(date, s.date_shipped)
,	ShipTime = convert(time, s.date_shipped)
,	GrossWeight = convert(int, round(s.gross_weight/2.2, 0))
,	TareWeight = convert(int, round(s.tare_weight/2.2, 0))
,	NetWeight = convert(int, round(s.net_weight/2.2, 0))
,	WeightUnit = 'KG'
,	PackageType = 'CTN'
,	BOLQuantity = staged_objs
,	Carrier = s.ship_via
,	TransMode = '3'
,	DockCode = s.shipping_dock
,	LocationQualifier =
		case
			when s.trans_mode in ('A', 'AE') then 'OR'
		end
,	AirportCode =
		case
			when s.trans_mode in ('A', 'AE') then coalesce(nullif(s.seal_number,''),'SAP')
		end
,	EquipmentType =
		case
			when s.trans_mode in ('A', 'AE') then 'AF'
			else 'TL'
		end
,	TruckNumber = s.truck_number
,	PRONumber = s.pro_number
,	SealNumber = s.seal_number
,	BOLNumber = s.id
,	MaterialIssuerCode = es.material_issuer
,	ShipTo = s.destination
,	Buyer = s.customer
,	BuyerAddress = c.address_1
,	ShipToName = d.name
,	ShipToAddress = d.address_1
,	SupplierCode = es.supplier_code
,	CompanyName = p.company_name
,	CompanyAddress = '2801 Howard Ave'
--,	*
from
	Fx.shipper s
	join Fx.customer c
		on c.customer = s.customer
	join Fx.edi_setups es
		on s.destination = es.destination
		and es.asn_overlay_group like 'HLL%'
	join Fx.destination d
		on d.destination = s.destination
	cross join Fx.parameters p
where
	coalesce(s.type, 'N') in ('N', 'M')
	--and s.id = 75964go
GO
