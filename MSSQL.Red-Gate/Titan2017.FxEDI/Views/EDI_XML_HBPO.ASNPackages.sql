SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [EDI_XML_HBPO].[ASNPackages]
as
select
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	SupplierPart = sd.part_original
,	CustomerECL = oh.engineering_level
,	QtyPacked = convert(int, sd.alternative_qty)
,	Unit = 'EA'
,	AccumShipped = sd.accum_shipped
,	CustomerPO = ltrim(rtrim(sd.customer_po))
,	packages.PackageType
,	packages.PackCount
,	packages.PackQty
,	packages.Type
,	packages.SerialRange
from
	Fx.shipper s
	join Fx.shipper_detail sd
		on sd.shipper = s.id
	join Fx.order_header oh
		on oh.order_no = sd.order_no
	join FX.edi_setups es
		on es.destination = s.destination
		and es.asn_overlay_group like 'HLL%'
	cross apply
	(	select
	 		PackageType = coalesce(pm.name, at.package_type, '0000CART')
		,	PackCount = count(*)
		,	PackQty = max(at.std_quantity)
		,	Type = 1
		,	SerialRange =
				case
					when min(at.serial) = max(at.serial) then convert(varchar(max), max(at.serial))
					else convert(varchar(max), min(at.serial)) + ':' + convert(varchar(max), max(at.serial))
				end
	 	from
	 		Fx.audit_trail at
			left join Fx.package_materials pm
				on pm.code = at.package_type
		where
			at.shipper = convert(varchar(max), s.id)
			and at.type = 'S'
			and at.part = sd.part_original
		group by
			coalesce(pm.name, at.package_type, '0000CART')
		--union all
		--select
	 --		PackageType = atP.PackageType
		--,	PackCount = count(distinct at.parent_serial)
		--,	Type = 2
	 --	from
	 --		Fx.audit_trail at
		--	cross apply
		--		(	select top(1)
		--				PackageType = coalesce(at2.package_type, '0000PALT')
		--			from
		--				Fx.audit_trail at2
		--				left join Fx.package_materials pm2
		--					on pm2.code = at2.package_type
		--			where
		--				at2.shipper = convert(varchar(max), s.id)
		--				and at2.type = 'S'
		--				and at2.serial = at.parent_serial
		--			order by
		--				at2.serial
		--		) atP
		--where
		--	at.shipper = convert(varchar(max), s.id)
		--	and at.type = 'S'
		--	and at.part = sd.part_original
		--group by
		--	atP.PackageType
		) packages
where
	coalesce(s.type, 'N') in ('N', 'M')
GO
