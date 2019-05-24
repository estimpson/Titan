SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [custom].[Label_FinishedGoodsData]
as
select
	*
,	LabelDataCheckSum = binary_checksum(*)
from
	(	select
		--	Fields on every label   
		-- 
			Serial = o.serial
		,	Quantity = convert (int, o.quantity)
		,	CustomerPart = oh.customer_part
		,	CompanyName = param.company_name
		,	CompanyAddress1 = param.address_1
		,	CompanyAddress2 = param.address_2
		,	CompanyAddress3 = param.address_3
		,	CompanyPhoneNumber = param.phone_number
		--
		--	Fields on some labels (all need case statements)...
		--
		--,	LicensePlate = case when rl.name in ('GM_Part','AMAXLE2') then 'UN' + es.supplier_code + '' + convert(varchar, o.serial) end
		--,	SerialCooper = case when rl.name in ('Cooper Part') then right(('000000000' + convert(varchar, o.serial)), 9) end
		--,	PartNumber = o.part
		,	UnitOfMeasure = case when rl.name in ('Benteler') then o.unit_measure end
		--,	Location = case when rl.name in ('STD_WIP') then o.location end
		--,	Lot = case when rl.name in ('APT_BOX','AMAXLE2','Borg Part Label','STD_WIP') then o.lot end
		--,	Operator = case when rl.name in ('STD_WIP') then o.operator end
		,	MfgDate = case when rl.name in ('Benteler') then convert(varchar(10), coalesce(atFirst.date_stamp, o.last_date), 101) end
		--,	MfgTime = case when rl.name in ('STD_WIP') then convert(varchar(5), coalesce(atFirst.RowCreateDT, o.last_date), 108) end
		--,	MfgDateMM = case when rl.name in ('Ford_Part Container') then convert(varchar(6), o.coalesce(atFirst.RowCreateDT, o.last_date), 12) end
		--,	MfgDateMMM = case when rl.name in ('AMAXLE2','Ford_Part Container','GM_Part') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, o.last_date), 106), ' ', '')) end
		--,	MfgDateMMMDashes = case when rl.name in ('APT_BOX') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, o.last_date), 106), ' ', '-')) end
		--,	GrossWeight = case when rl.name in (/*'AMAXLE2',*/'Borg Part Label','Ford_Part Container') then convert(numeric(10,2), round((o.weight + o.tare_weight),2)) end
		--,	GrossWeightKilograms = case when rl.name in ('GM_Part') then convert(numeric(10,0),((o.weight + o.tare_weight) / 2.2)) end
		--,	NetWeight = case when rl.name in ('Borg Part Label','NPG Part','MPTMuncie_Box') then convert(numeric(10,2), round(o.weight,2)) end
		--,	TareWeight = case when rl.name in ('AMAXLE2') then o.tare_weight end
		--,	StagedObjects = case when rl.name in ('Borg Part Label') then s.staged_objs end
		--,	Origin = o.origin
		--,	PackageType = case when rl.name in ('GM_Part','Ford_Part Container') then o.package_type end
		,	PartName = case when rl.name in ('Benteler') then p.name end
		--,	Customer = oh.customer
		,	DockCode =  case when rl.name in ('Benteler') then oh.dock_code end
		--,	ZoneCode = case when rl.name in ('AMAXLE2','DCX_Part','Ford_Part Container','MPTMuncie_Box') then oh.zone_code end
		--,	LineFeedCode = case when rl.name in ('Ford_Part Container','MITSUBISHI_RAN') then oh.line_feed_code end
		--,	Line11 = case when rl.name in ('GM_Part') then oh.line11 end -- Material Handling Code
		--,	Line12 =case when rl.name in ('GM_Part') then oh.line12 end --Plant/Dock on GM Label
		--,	Line13 = oh.line13
		--,	Line14 = case when rl.name in ('GM_Part') then oh.line14 end
		--,	Line15 = case when rl.name in ('GM_Part') then oh.line15 end
		--,	Line16 = oh.line16
		--,	Line17 = case when rl.name in ('GM_Part') then oh.line17 end
		,	SupplierCode = case when rl.name in ('Benteler') then coalesce(es.supplier_code, '') end
		--,	Shipper = case when rl.name in ('Borg Part Label') then sd.shipper end
		,	CustomerPO = case when rl.name in ('Benteler') then oh.customer_po end
		--,	EngineeringLevel = case when rl.name in ('APT_BOX','AMAXLE2','Borg Part Label','CLBL','Cooper Part','DCX_Part','TSMStorage','NPG Part') then ecn.engineering_level end
		,	DestinationID = case when rl.name in ('Benteler') then es.parent_destination end
		,	DestinationCode = case when rl.name in ('Benteler') then oh.destination end
		,	DestinationName = case when rl.name in ('Benteler') then d.name end
		,	DestinationAddress1 = case when rl.name in ('Benteler') then d.address_1 end
		,	DestinationAddress2 = case when rl.name in ('Benteler') then d.address_2 end
		--,	DestinationAddress3 = case when rl.name in ('AMAXLE2','Borg Part Label','NPG Part','MPTMuncie_Box') then d.address_3 end
		--,	DestinationAddress4 = case when rl.name in ('AMAXLE2') then d.address_4 end 
		--,	ObjectKANBAN = case when rl.name in ('AMAXLE2') then coalesce(o.kanban_number, '') end
		--,	ObjectCustom5 = case when rl.name in ('AMAXLE2') then coalesce(o.custom5, '') end
		--,	MitsuRAN = case when rl.name in ('MITSUBISHI_RAN') then coalesce(o.custom1, '') end
		--,	ShipToID = case when rl.name in ('MITSUBISHI_RAN') then es.parent_destination end
		--,	RecArea = case when rl.name in ('MITSUBISHI_RAN') then s.shipping_dock end
		--,	DateTimeZoneDue = case when rl.name in ('MITSUBISHI_RAN') then (Select max(CONVERT(VARCHAR(10),PickUpDT,105)) from EDIMitsubishi.RanDetails where RAN = o.custom1) end
		--,	RevLevelMitsuRAN = case when rl.name in ('MITSUBISHI_RAN') then oh.engineering_level end 
		--
		--	Make sure we printed the correct label format.
		--
		,	BoxLabelFormat = rl.name
		from
			dbo.object o
			left join (select max(engineering_level) as engineering_level, part as ecn_part from dbo.effective_change_notice group by part) ecn on
				ecn.ecn_part = o.part
			left join dbo.shipper s
				join dbo.shipper_detail sd
					on sd.shipper = s.id
				on s.id = coalesce(o.shipper, case when o.origin not like '%[^0-9]%' and len(o.origin) < 10 then convert (int, o.origin) end)
				and sd.part_original = o.part
			left join dbo.order_header oh on
				oh.order_no = coalesce(sd.order_no, case when o.origin not like '%[^0-9]%' and len(o.origin) < 10 then convert(int, o.origin) end)
				and oh.blanket_part = o.part
			left join dbo.destination d on
				d.destination = coalesce(s.destination, oh.destination, o.destination)
			left join dbo.edi_setups es on
				es.destination = coalesce(s.destination, oh.destination, o.destination)
			--left join (select max(convert(varchar(10),PickUpDT,105)) as date_time_zone_due, RAN from EDIMitsubishi.RanDetails group by RAN) mran on
			--	mran.RAN = o.custom1
			join dbo.part p on
				p.part = o.part
			join dbo.part_inventory pi on
				pi.part = p.part
			join dbo.report_library rl on
				rl.name = coalesce(oh.box_label, pi.label_format)
			left join
				(	select
						atFirst.serial
					--,	atFirst.RowCreateDT
					  , atFirst.date_stamp
					from
						dbo.audit_trail atFirst
					where
						--atFirst.RowID =
						atFirst.date_stamp =
							(	select
							 		--min(RowID)
							 		min(date_stamp)
							 	from
							 		dbo.audit_trail
								where
									serial = atFirst.serial ) ) atFirst
				on atFirst.serial = o.serial
			cross join dbo.parameters param
	) rawLabelData


GO
