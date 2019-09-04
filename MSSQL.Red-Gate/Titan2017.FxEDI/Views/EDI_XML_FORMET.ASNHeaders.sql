SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_FORMET].[ASNHeaders]
as
select
	ShipperID = s.id
,	iConnectID = es.IConnectID
,	TradingPartnerID = coalesce(nullif(es.trading_partner_code, ''), 'FORMET TESTING')
,	ASNDate = convert(date, getdate())
,	ASNTime = convert(time, getdate())
,	ShipDateTime = s.date_shipped
,	ShipDate = convert(date, s.date_shipped)
,	ShipTime = convert(time, s.date_shipped)
,	GrossWeight = convert(int, round(s.gross_weight, 0))
,	TareWeight = convert(int, round(s.tare_weight, 0))
,	NetWeight = convert(int, round(s.net_weight, 0))
,	PackageType = 'CTN'
,	BOLQuantity = staged_objs
,	Carrier = s.ship_via
,	TransMode = s.trans_mode
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
,	BOLNumber = s.id
,	ShipTo = es.parent_destination
,	ShipToName = d.name
,	SupplierCode = es.supplier_code
,	CompanyName = p.company_name
--,	*
from
	Fx.shipper s
	join Fx.edi_setups es
		on s.destination = es.destination
		and es.asn_overlay_group like 'FMT%'
	join Fx.destination d
		on d.destination = s.destination
	cross join Fx.parameters p
where
	coalesce(s.type, 'N') in ('N', 'M')
	--and s.id = 75964go
GO
