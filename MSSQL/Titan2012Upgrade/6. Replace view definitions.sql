alter view dbo.GMBlanketOrders as
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
	

go
alter view custom.Label_FinishedGoodsData
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

go
alter view custom.Label_FinishedGoodsData_Master
as
/*	Do not modify this view without making sure you test performance before and after.
			1) All rows in < 10 seconds.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn

			2) Single row in <= 1 second.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn
where
	lfgdmn.Serial = 1607091

			3) Shipper list < 3 seconds.

select
	*
from
	dbo.Shipping_OpenShipperList sosl

*/
select
	*
,	LabelDataCheckSum = binary_checksum(*)
from
	(	select
			Serial = case when rl.name in ('Benteler Master') then oPallet.serial end
		--,	PalletSerialCooper = case when rl.name in ('Cooper Master') then right(('000000000' + convert(varchar, oPallet.serial)), 9) end
		--,	LotNumber = case when rl.name in ('APT_MASTER') then oBoxOnPallet.FirstLot end
		--,	LicensePlate = case when rl.name in ('AMAXLE_MASTER','GM_Master') then 'UN' + es.supplier_code + '' + convert(varchar, oPallet.serial) end
		--,	MfgDate = case when rl.name in ('Cooper Master') then convert(varchar(10), coalesce(atFirst.RowCreateDT, oPallet.last_date), 101) end 
		--,	MfgDateMM = case when rl.name in ('Ford_Master') then convert(varchar(6), coalesce(atFirst.RowCreateDT, oPallet.last_date), 12) end
		--,	MfgDateMMM = case when rl.name in ('Ford_Master') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '')) end
		--,	MfgDateMMMDashes = case when rl.name in ('APT_MASTER') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '-')) end
		,	UM = case when rl.name in ('Benteler Master') then oBoxOnPallet.FirstUM end 
		--,	PalletNetWeight = case when rl.name in ('NPG Master') then round(oBoxOnPallet.BoxTotalNetWeight, 2) end
		--,	PalletGrossWeight = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then round(coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PalletGrossWeightKG = case when rl.name in ('GM_Master') then round((coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0))/ 2.2, 0) end
		--,	PalletTareWeight = case when rl.name in ('AMAXLE_MASTER') then round(coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PartCode = case when rl.name in ('APT_MASTER','Ford_Master') then oBoxOnPallet.FirstPart end
		--,	WorkorderPartCode = case when rl.name in ('PALLET') then mjl.PartCode end
		--,	PartName = case when rl.name in ('AMAXLE_MASTER','APT_MASTER','Ford_Master','NPG Master') then pFirst.name end
		,	PalletQty = case when rl.name in ('Benteler Master') then coalesce(oBoxOnPallet.PalletQty, 0) else 0 end
		--,	Boxes = case when rl.name in ('AMAXLE_MASTER','GM_Master') then oBoxOnPallet.BoxCount end
		--,	BoxQty = case when rl.name in ('GM_Master') then oBoxOnPallet.BoxQty end
		/*,	ECN = case when rl.name in ('AMAXLE_MASTER','APT_MASTER','Cooper Master') then
			(	select
					max(engineering_level)
				from
					effective_change_notice
				where
					part = oBoxOnPallet.FirstPart
					and effective_date =
					(	select
							max(e.effective_date)
						from
							effective_change_notice e
						where
							e.part = oBoxOnPallet.FirstPart
					)
			) end */
		--,	CustomerPO = case when rl.name in (/*'AMAXLE_MASTER',*/'Cooper Master') then oh.customer_po end
		,	CustomerPart = case when rl.name in ('Benteler Master') then oh.customer_part end
		,	ShipToID = case when rl.name in ('Benteler Master') then es.parent_destination end
		,	ShipToCode = case when rl.name in ('Benteler Master') then oh.destination end
		,	SupplierCode = case when rl.name in ('Benteler Master') then es.supplier_code end
		,	ShipToName = case when rl.name in ('Benteler Master') then d.name end
		,	ShipToAddress1 = case when rl.name in ('Benteler Master') then d.address_1 end
		,	ShipToAddress2 = case when rl.name in ('Benteler Master') then d.address_2 end
		--,	ShipToAddress3 = case when rl.name in ('AMAXLE_MASTER','NPG Master') then d.address_3 end
		--,	ShipToAddress4 = case when rl.name in ('AMAXLE_MASTER') then d.address_4 end
		--,	PoolCode = case when rl.name in ('DCX_Master') then es.pool_code end
		--,	Custom5 = case when rl.name in ('AMAXLE_MASTER') then oBoxOnPallet.FirstCustom5 end
		,	DockCode = case when rl.name in ('Benteler Master') then oh.dock_code end
		--,	LineFeedCode = case when rl.name in ('Ford_Master') then oh.line_feed_code end
		--,	ZoneCode = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then oh.zone_code end
		--,	Line11 = case when rl.name in ('GM_Master') then oh.line11 end -- material handling code
		--,	Line12 =case when rl.name in ('GM_Master') then oh.line12 end --Plant/Dock on GM Master Label
		--,	Location = case when rl.name in ('PALLET') then oPallet.location end
		--,	ContainerType = case when rl.name in ('Ford_Master') then oPallet.package_type end
		,	CompanyName = case when rl.name in ('Benteler Master') then parm.company_name end
		,	CompanyAddress1 = case when rl.name in ('Benteler Master') then parm.address_1 end
		,	CompanyAddress2 = case when rl.name in ('Benteler Master') then parm.address_2 end
		,	CompanyAddress3 = case when rl.name in ('Benteler Master') then parm.address_3 end
		--,	PhoneNumber = case when rl.name in ('AMAXLE_MASTER','GM_Master') then parm.phone_number end
		/*,	MasterMixed =	case	
								when rl.name in ('DCX_Master') and (select count(distinct part) from object where parent_serial = oPallet.serial) > 1 then 'MIXED PALLET'
								when rl.name in ('DCX_Master') and (select count(distinct part) from object where parent_serial = oPallet.serial) = 1 then 'MASTER LABEL'
								else 'GENERIC'
							end */
		,	PalletLabelFormat = rl.name
		from
			dbo.object oPallet
				left join
					(	select
							oBoxes.parent_serial
						,	PalletQty = sum(oBoxes.std_quantity)
						,	BoxCount = count(*)
						,	FirstSerial = min(oBoxes.serial)
						,	FirstLot = min(oBoxes.lot)
						,	FirstUM = min(oBoxes.unit_measure)
						,	FirstPart = min(oBoxes.part)
						,	FirstCustom5 = min(oBoxes.custom5)
						,	BoxQty = max(oBoxes.std_quantity)
						,	BoxTotalTareWeight = sum(oBoxes.tare_weight)
						,	BoxTotalNetWeight = sum(oBoxes.weight)
						,	BoxShipper = max(oBoxes.shipper)
						,	BoxOrigin = max(case when oBoxes.origin not like '%[^0-9]%' and len(oBoxes.origin) < 10 then convert (int, oBoxes.origin) end)
						from
							dbo.object oBoxes
						where
							oBoxes.parent_serial is not null
						group by
							oBoxes.parent_serial
					) oBoxOnPallet on
					oBoxOnPallet.parent_serial = oPallet.serial
				left join dbo.part pFirst
					on pFirst.part = oBoxOnPallet.FirstPart
			left join shipper_detail sd
				on sd.shipper = coalesce(oBoxOnPallet.BoxShipper, oBoxOnPallet.BoxOrigin)
				and sd.part_original = oBoxOnPallet.FirstPart
			left join order_header oh
					left join customer c
						on c.customer = oh.customer
					left join destination d
						on d.destination = oh.destination
					left join edi_setups es
						on es.destination = oh.destination
				on oh.order_no = coalesce(sd.order_no, oBoxOnPallet.BoxOrigin)
			--left join dbo.Mes_JobList mjl
			--	on mjl.WorkOrderNumber = oPallet.workorder
			join dbo.report_library rl on
				rl.name = coalesce(oh.pallet_label, 'PALLET')
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
									--min(at.RowID)
									min(at.date_stamp)
								from
									dbo.audit_trail at
								where
									at.serial = atFirst.serial ) ) atFirst
				on atFirst.serial = oPallet.serial
			cross join dbo.parameters parm
		where
			oPallet.type = 'S'
	) rawLabelData



GO

go
alter view custom.Label_FinishedGoodsData_Master_Formet
as
/*	Do not modify this view without making sure you test performance before and after.
			1) All rows in < 10 seconds.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn

			2) Single row in <= 1 second.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn
where
	lfgdmn.Serial = 1607091

			3) Shipper list < 3 seconds.

select
	*
from
	dbo.Shipping_OpenShipperList sosl

*/
select
	*
,	LabelDataCheckSum = binary_checksum(*)
from
	(	select
			ShipperID = oPallet.shipper
			,Serial = oPallet.serial
		--,	PalletSerialCooper = case when rl.name in ('Cooper Master') then right(('000000000' + convert(varchar, oPallet.serial)), 9) end
		--,	LotNumber = case when rl.name in ('APT_MASTER') then oBoxOnPallet.FirstLot end
		--,	LicensePlate = case when rl.name in ('AMAXLE_MASTER','GM_Master') then 'UN' + es.supplier_code + '' + convert(varchar, oPallet.serial) end
		--,	MfgDate = case when rl.name in ('Cooper Master') then convert(varchar(10), coalesce(atFirst.RowCreateDT, oPallet.last_date), 101) end 
		--,	MfgDateMM = case when rl.name in ('Ford_Master') then convert(varchar(6), coalesce(atFirst.RowCreateDT, oPallet.last_date), 12) end
		--,	MfgDateMMM = case when rl.name in ('Ford_Master') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '')) end
		--,	MfgDateMMMDashes = case when rl.name in ('APT_MASTER') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '-')) end
		,	UM =  oBoxOnPallet.FirstUM
		--,	PalletNetWeight = case when rl.name in ('NPG Master') then round(oBoxOnPallet.BoxTotalNetWeight, 2) end
		--,	PalletGrossWeight = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then round(coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PalletGrossWeightKG = case when rl.name in ('GM_Master') then round((coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0))/ 2.2, 0) end
		--,	PalletTareWeight = case when rl.name in ('AMAXLE_MASTER') then round(coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PartCode = case when rl.name in ('APT_MASTER','Ford_Master') then oBoxOnPallet.FirstPart end
		--,	WorkorderPartCode = case when rl.name in ('PALLET') then mjl.PartCode end
		,	PartName = pFirst.name
		,	PalletQty = coalesce(oBoxOnPallet.PalletQty, 0) 
		--,	Boxes = case when rl.name in ('AMAXLE_MASTER','GM_Master') then oBoxOnPallet.BoxCount end
		--,	BoxQty = case when rl.name in ('GM_Master') then oBoxOnPallet.BoxQty end
		/*,	ECN = case when rl.name in ('AMAXLE_MASTER','APT_MASTER','Cooper Master') then
			(	select
					max(engineering_level)
				from
					effective_change_notice
				where
					part = oBoxOnPallet.FirstPart
					and effective_date =
					(	select
							max(e.effective_date)
						from
							effective_change_notice e
						where
							e.part = oBoxOnPallet.FirstPart
					)
			) end */
		--,	CustomerPO = case when rl.name in (/*'AMAXLE_MASTER',*/'Cooper Master') then oh.customer_po end
		,	CustomerPart = oh.customer_part
		,	ShipToID = es.parent_destination 
		,	ShipToCode = oh.destination
		,	SupplierCode = es.supplier_code
		,	ShipToName = d.name 
		,	ShipToAddress1 = d.address_1
		,	ShipToAddress2 = d.address_2
		--,	ShipToAddress3 = case when rl.name in ('AMAXLE_MASTER','NPG Master') then d.address_3 end
		--,	ShipToAddress4 = case when rl.name in ('AMAXLE_MASTER') then d.address_4 end
		--,	PoolCode = case when rl.name in ('DCX_Master') then es.pool_code end
		--,	Custom5 = case when rl.name in ('AMAXLE_MASTER') then oBoxOnPallet.FirstCustom5 end
		,	DockCode = oh.dock_code
		--,	LineFeedCode = case when rl.name in ('Ford_Master') then oh.line_feed_code end
		--,	ZoneCode = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then oh.zone_code end
		--,	Line11 = case when rl.name in ('GM_Master') then oh.line11 end -- material handling code
		--,	Line12 =case when rl.name in ('GM_Master') then oh.line12 end --Plant/Dock on GM Master Label
		--,	Location = case when rl.name in ('PALLET') then oPallet.location end
		--,	ContainerType = case when rl.name in ('Ford_Master') then oPallet.package_type end
		--,	CompanyName = case when rl.name in ('Benteler Master') then parm.company_name end
		--,	CompanyAddress1 = case when rl.name in ('Benteler Master') then parm.address_1 end
		--,	CompanyAddress2 = case when rl.name in ('Benteler Master') then parm.address_2 end
		--,	CompanyAddress3 = case when rl.name in ('Benteler Master') then parm.address_3 end
		--,	PhoneNumber = case when rl.name in ('AMAXLE_MASTER','GM_Master') then parm.phone_number end
		/*,	MasterMixed =	case	
								when rl.name in ('DCX_Master') and (select count(distinct part) from object where parent_serial = oPallet.serial) > 1 then 'MIXED PALLET'
								when rl.name in ('DCX_Master') and (select count(distinct part) from object where parent_serial = oPallet.serial) = 1 then 'MASTER LABEL'
								else 'GENERIC'
							end */
		,	PalletLabelFormat = rl.name
		from
			dbo.object oPallet
				left join
					(	select
							oBoxes.parent_serial
						,	PalletQty = sum(oBoxes.std_quantity)
						,	BoxCount = count(*)
						,	FirstSerial = min(oBoxes.serial)
						,	FirstLot = min(oBoxes.lot)
						,	FirstUM = min(oBoxes.unit_measure)
						,	FirstPart = min(oBoxes.part)
						,	FirstCustom5 = min(oBoxes.custom5)
						,	BoxQty = max(oBoxes.std_quantity)
						,	BoxTotalTareWeight = sum(oBoxes.tare_weight)
						,	BoxTotalNetWeight = sum(oBoxes.weight)
						,	BoxShipper = max(oBoxes.shipper)
						,	BoxOrigin = max(case when oBoxes.origin not like '%[^0-9]%' and len(oBoxes.origin) < 10 then convert (int, oBoxes.origin) end)
						from
							dbo.object oBoxes
						where
							oBoxes.parent_serial is not null
						group by
							oBoxes.parent_serial
					) oBoxOnPallet on
					oBoxOnPallet.parent_serial = oPallet.serial
				left join dbo.part pFirst
					on pFirst.part = oBoxOnPallet.FirstPart
			left join shipper_detail sd
				on sd.shipper = coalesce(oBoxOnPallet.BoxShipper, oBoxOnPallet.BoxOrigin)
				and sd.part_original = oBoxOnPallet.FirstPart
			left join order_header oh
					left join customer c
						on c.customer = oh.customer
					left join destination d
						on d.destination = oh.destination
					left join edi_setups es
						on es.destination = oh.destination
				on oh.order_no = coalesce(sd.order_no, oBoxOnPallet.BoxOrigin)
			--left join dbo.Mes_JobList mjl
			--	on mjl.WorkOrderNumber = oPallet.workorder
			join dbo.report_library rl on
				rl.name = coalesce(oh.pallet_label, 'PALLET')
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
									--min(at.RowID)
									min(at.date_stamp)
								from
									dbo.audit_trail at
								where
									at.serial = atFirst.serial ) ) atFirst
				on atFirst.serial = oPallet.serial
			cross join dbo.parameters parm
		where
			oPallet.type = 'S'
	) rawLabelData




GO

go
alter view dbo.bill_of_material
    ( parent_part,
      part,
      type,
      quantity,
      unit_measure,
      reference_no,
      std_qty,
      substitute_part ) AS
  select bill_of_material_ec.parent_part,
         bill_of_material_ec.part,
         bill_of_material_ec.type,
         bill_of_material_ec.quantity * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.unit_measure,
         bill_of_material_ec.reference_no,
         bill_of_material_ec.std_qty * (1 + bill_of_material_ec.scrap_factor),
         bill_of_material_ec.substitute_part         
    from bill_of_material_ec
   where ( bill_of_material_ec.start_datetime <= getdate() ) AND
         (bill_of_material_ec.end_datetime > getdate() OR
         bill_of_material_ec.end_datetime is null)


GO

go
alter view dbo.BlanketOrders
AS
SELECT
	oh.model_year,
	BlanketOrderNo = oh.order_no
,	ShipToCode = oh.destination
,	EDIShipToCode = COALESCE(NULLIF(es.EDIShipToID,''), NULLIF(es.parent_destination,''), es.destination)
,	ShipToConsignee = es.pool_code
,	SupplierCode = es.supplier_code
,	CustomerPart = oh.customer_part
,	CustomerPO = oh.customer_po
,	CheckCustomerPOPlanning = CONVERT(BIT, CASE COALESCE(check_po, 'N') WHEN 'Y' THEN 1 ELSE 0 END)
,	CheckCustomerPOShipSchedule = COALESCE(CheckCustomerPOFirm, 0)
,	ModelYear862 = COALESCE(RIGHT(oh.model_year,1),'')
,	ModelYear830 = COALESCE(LEFT(oh.model_year,1),'')
,	CheckModelYearPlanning = CONVERT(BIT, CASE COALESCE(check_model_year, 'N') WHEN 'Y' THEN 1 ELSE 0 END)
,	CheckModelYearShipSchedule = 0
,	PartCode = oh.blanket_part
,	OrderUnit = oh.shipping_unit
,	LastSID = oh.shipper
,	LastShipDT = s.date_shipped
,	LastShipQty = (SELECT MAX(qty_packed) FROM dbo.shipper_detail WHERE shipper = oh.shipper AND order_no = oh.order_no)
,	PackageType = oh.package_type
,	UnitWeight = pi.unit_weight
,	AccumShipped = oh.our_cum
,	ProcessReleases = COALESCE(es.ProcessEDI,0)
,	ActiveOrder = CONVERT(BIT, CASE WHEN COALESCE(order_status,'') = 'A' THEN 1 ELSE 0 END )
,	ModelYear = oh.model_year
,	PlanningFlag= COALESCE(es.PlanningReleasesFlag,'A')
,	TransitDays =  COALESCE(es.TransitDays,0)
,	ReleaseDueDTOffsetDays =  COALESCE(es.EDIOffsetDays,0)
,	ReferenceAccum = COALESCE(ReferenceAccum,'O')
,	AdjustmentAccum = COALESCE(AdjustmentAccum,'C')
,	PlanningReleaseHorizonDaysBack = -1*(COALESCE(PlanningReleaseHorizonDaysBack,30))
,	ShipScheduleHorizonDaysBack = -1*(COALESCE(ShipScheduleHorizonDaysBack,30))
,	ProcessPlanningRelease = COALESCE(es.ProcessPlanningRelease,1)
,	ProcessShipSchedule = COALESCE(es.ProcessShipSchedule,1)
FROM
	dbo.order_header oh
	JOIN dbo.edi_setups es
		ON es.destination = oh.destination
	JOIN dbo.part_inventory pi
		ON pi.part = oh.blanket_part
	LEFT JOIN dbo.shipper s
		ON s.id = oh.shipper
WHERE
	oh.order_type = 'B' 
 AND COALESCE(ProcessEDI,1) = 1
--	es.InboundProcessGroup in ( 'EDI2001' )











GO

go
alter view dbo.cdivw_blanket_po (
	po_header_ship_to_destination,   
	po_header_plant,   
	po_header_type,   
	po_header_release_no,   
	vendor_company,   
	vendor_address_1,   
	vendor_address_2,   
	vendor_address_3,   
	vendor_fax,   
	po_header_fob,   
	parameters_company_name,   
	parameters_address_1,   
	parameters_address_2,   
	parameters_address_3,   
	parameters_phone_number,   
	vendor_buyer,   
	vendor_name,   
	part_cross_ref,   
	po_header_po_date,   
	po_header_freight_type,   
	po_header_po_number,   
	po_header_vendor_code,
	po_header_buyer,   
	carrier_name,   
	po_header_terms,   
	po_header_notes,   
	part_vendor_receiving_um,   
	part_vendor_vendor,   
	part_vendor_vendor_part,   
	po_header_blanket_part,   
	part_name,   
	vendor_address_4,   
	vendor_address_5,   
	vendor_address_6,   
	destination_name,   
	destination_address_1,   
	destination_address_2,   
	destination_address_3,   
	destination_address_4,   
	destination_address_5,   
	destination_address_6,   
	vendor_contact,
	part_vendor_note,
	part_vendor_part) as
select	po_header.ship_to_destination,   
	po_header.plant,   
	po_header.type,   
	po_header.release_no,   
	vendor.company,   
	vendor.address_1,   
	vendor.address_2,   
	vendor.address_3,   
	vendor.fax,   
	po_header.fob,   
	parameters.company_name,   
	parameters.address_1,   
	parameters.address_2,   
	parameters.address_3,   
	parameters.phone_number,   
	vendor.buyer,   
	vendor.name,   
	part.cross_ref,   
	po_header.po_date,   
	po_header.freight_type,   
	po_header.po_number,   
	po_header.vendor_code,
	po_header.buyer,   
	carrier.name,   
	po_header.terms,   
	po_header.notes,   
	part_vendor.receiving_um,   
	part_vendor.vendor,   
	part_vendor.vendor_part,   
	po_header.blanket_part,   
	part.name,   
	vendor.address_4,   
	vendor.address_5,   
	vendor.address_6,   
	destination.name,   
	destination.address_1,   
	destination.address_2,   
	destination.address_3,   
	destination.address_4,   
	destination.address_5,   
	destination.address_6,   
	vendor.contact,
	part_vendor.note,
	part_vendor.part
from	po_header  
	left outer join destination ON po_header.ship_to_destination = destination.destination,   
	part,   
	vendor,   
	part_vendor,   
	parameters,   
	carrier
where	( po_header.vendor_code = vendor.code ) and  
	( po_header.vendor_code = part_vendor.vendor ) and  
	( po_header.ship_via = carrier.scac ) and 
	( part_vendor.part = part.part ) and  
	( part_vendor.part in (select part_number from po_detail where po_detail.po_number = po_header.po_number and isnull(selected_for_print,'N') = 'Y' ) )
GO

go
alter view dbo.cdivw_ford856_asn 
	(audit_trail_serial, 
	audit_trail_quantity, 
	edi_setups_prev_cum_in_asn,
	shipper_detail_customer_part, 
	shipper_detail_alternative_qty, 
	shipper_detail_alternative_unit, 
	shipper_detail_net_weight, 
	shipper_detail_gross_weight, 
	shipper_detail_accum_shipped, 
	shipper_detail_shipper, 
	shipper_detail_customer_po,
	DOR,
	accum2,
	shipper_id)
as
select	audit_trail.serial, 
	audit_trail.quantity, 
	edi_setups.prev_cum_in_asn,
	shipper_detail.customer_part, 
	shipper_detail.alternative_qty, 
	shipper_detail.alternative_unit, 
	shipper_detail.net_weight, 
	shipper_detail.gross_weight, 
	shipper_detail.accum_shipped, 
	shipper_detail.shipper, 
	shipper_detail.customer_po,
	(CASE WHEN substring(shipper_detail.note,1,3) = 'DLR' THEN substring(shipper_Detail.note,1,16)
		ELSE ''
	END) as DOR,
	(SELECT isNULL(max(sd2.accum_shipped),0)
	FROM	shipper_detail sd2
	WHERE	sd2.order_no = shipper_detail.order_no and
		convert(datetime,sd2.date_shipped,101) = (SELECT max(convert(datetime,sd3.date_shipped,101))
					FROM	shipper_detail sd3
					WHERE	sd3.order_no = shipper_detail.order_no and
					convert(datetime,sd3.date_shipped,101) < convert(datetime,shipper_detail.date_shipped,101))) as accum2,
	shipper.id						
FROM	audit_trail, 
	edi_setups, 
	shipper_detail,
	shipper 
WHERE 	( audit_trail.shipper = convert(varchar,shipper.id)) and
	( shipper.destination = edi_setups.destination) and
	( audit_trail.part = shipper_detail.part_original ) and 
	( shipper_detail.shipper = shipper.id )
GO

go
alter view dbo.cdivw_ford856_end_asn
	(package_type, 
	row_count, 
	returncontainer, 
	po, 
	um,
	supplier_code,
	id)
as
SELECT 	audit_trail.package_type, 
	(select count(audit_trail.package_type) from audit_trail where shipper = convert(varchar(30),shipper.id) and audit_trail.package_type = package_materials.code) as row_count, 
	'RC' as returncontainer, 
	'NONE' as po, 
	'PC' as um,
	supplier_code,
	shipper.id
fROM	audit_trail, 
	package_materials, 
	shipper,
	edi_setups
WHERE 	( shipper.destination = edi_setups.destination ) and
	( audit_trail.package_type = package_materials.code ) and 
	( convert(varchar(30),shipper.id) = audit_trail.shipper ) and 
	( package_materials.returnable = 'Y' )  and
	audit_trail.type = 'S'	 
GO

go
alter view dbo.cdivw_getreleaseno (	
	order_no,
	part,
	due_date,
	release_no)
as
select	od.order_no, od.part_number, convert(varchar(10), od.due_date, 110), min(od.release_no)
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
where	od.committed_qty < od.quantity and 
	od.release_no > ''
group by od.order_no, od.part_number, convert(varchar(10), od.due_date, 110)
GO

go
alter view dbo.cdivw_getreleases (	
	order_no,
	part,
	due_date,
	release_no,
	quantity,
	committedqty)
as
select	od.order_no, od.part_number, convert(varchar(10), od.due_date, 110) due, od.release_no, od.quantity, od.committed_qty
from	order_detail od
	join order_header oh on oh.order_no = od.order_no
where	isnull(oh.status,'O') = 'O' and
	od.committed_qty < od.quantity and 
	od.release_no > ''
group by od.order_no, od.part_number, convert(varchar(10), od.due_date, 110), od.release_no, od.quantity, od.committed_qty
GO

go
alter view dbo.cdivw_inv_inquiry (	
	invoice_number,   
	id,   
	date_shipped,   
	destination,   
	customer,   
	ship_via,   
	invoice_printed,   
	notes,   
	type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time, 
	part) as  
select	shipper.invoice_number,   
	shipper.id,   
	shipper.date_shipped,   
	shipper.destination,   
	shipper.customer,   
	shipper.ship_via,   
	shipper.invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipper.shipping_dock,   
	shipper.status,   
	shipper.aetc_number,   
	shipper.freight_type,   
	shipper.printed,   
	shipper.bill_of_lading_number,   
	shipper.model_year_desc,   
	shipper.model_year,   
	shipper.location,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.invoiced,   
	shipper.freight,   
	shipper.tax_percentage,   
	shipper.total_amount,   
	shipper.gross_weight,   
	shipper.net_weight,   
	shipper.tare_weight,   
	shipper.responsibility_code,   
	shipper.trans_mode,   
	shipper.pro_number,   
	shipper.time_shipped,   
	shipper.truck_number,   
	shipper.seal_number,   
	shipper.terms,   
	shipper.tax_rate,   
	shipper.staged_pallets,   
	shipper.container_message,   
	shipper.picklist_printed,   
	shipper.dropship_reconciled,   
	shipper.date_stamp,   
	shipper.platinum_trx_ctrl_num,   
	shipper.posted,   
	shipper.scheduled_ship_time,  
	shipper_detail.part_original
from	shipper 
	left outer join shipper_detail on shipper_detail.shipper = shipper.id
where	isnull(shipper.type,'') not in ('V','O') and
	isnull(shipper_detail.qty_packed,0) > 0 
GO

go
alter view dbo.cdivw_msf_inv
(	description
,	unit
,	onhand
,	wo_quantity
,	batch_quantity
,	bom_part
,	bom_qty
,	work_order
)
as
	select
		max(name) description
	,	max(unit_measure) unit
	,	max(isnull(on_hand, 0)) onhand
	,	sum(isnull(quantity, 0) * isnull(qty_required, 0)) wo_quantity
	,	sum(isnull(mfg_lot_size, 0) * isnull(quantity, 0)) batch_quantity
	,	max(bill_of_material.part) bom_part
	,	sum(isnull(quantity, 0)) bom_qty
	,	max(work_order.work_order)
	from
		dbo.bill_of_material
		join dbo.work_order
			join dbo.machine_policy
				on work_order.machine_no = machine
				   and material_substitution = 'N'
			join dbo.workorder_detail
				on workorder_detail.workorder = work_order.work_order
			on bill_of_material.parent_part = workorder_detail.part
		join dbo.part
			on bill_of_material.part = part.part
		left join dbo.part_online
			on bill_of_material.part = part_online.part
		join part_mfg
			on bill_of_material.part = part_mfg.part
	where
		bill_of_material.substitute_part <> 'Y'
	group by
		bill_of_material.part
	,	work_order.work_order
GO

go
alter view dbo.cdivw_partlist 
(	part,   
	name,   
	cross_ref,   
	class,   
	type,   
	commodity,   
	group_technology,   
	product_line,   
	drawing_number,
	user_defined_1,
	user_defined_2,
	pc_user_defined_1,   
	standard_unit,   
	primary_location,   
	label_format,   
	unit_weight,   
	standard_pack,
	PMUD1,
	PMUD2,
	PMUD3,
	company_name,
	logo)
as	
SELECT	part.part,   
	part.name,   
	part.cross_ref,   
	part.class,   
	part.type,   
	part.commodity,   
	part.group_technology,   
	part.product_line,   
	part.drawing_number,
	part.user_defined_1,
	part.user_defined_2,
	part_characteristics.user_defined_1,   
	part_inventory.standard_unit,   
	part_inventory.primary_location,   
	part_inventory.label_format,   
	part_inventory.unit_weight,   
	part_inventory.standard_pack,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 1 and
	module = 'PM') as PMUD1,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 2 and
	module = 'PM') as PMUD2,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 3 and
	module = 'PM') as PMUD3,
	pmt.company_name company_name,
	pmt.company_logo logo
FROM	part
	join part_inventory on part_inventory.part = part.part
	left outer join part_characteristics on part_characteristics.part = part.part
	cross join parameters pmt
GO

go
alter view dbo.cdivw_po_inquiry (
 	po_number,   
	vendor_code,   
	po_date,   
	date_due,   
	terms,   
	fob,   
	ship_via,   
	ship_to_destination,   
	status,   
	type,   
	description,   
	plant,   
	freight_type,   
	buyer,   
	printed,   
	total_amount,   
	shipping_fee,   
	sales_tax,   
	blanket_orderded_qty,   
	blanket_frequency,   
	blanket_duration,   
	blanket_qty_per_release,   
	blanket_part,   
	blanket_vendor_part,   
	price,   
	std_unit,   
	ship_type,   
	flag,   
	release_no,   
	release_control,   
	tax_rate,   
	scheduled_time) as  
select	distinct po_header.po_number,   
	po_header.vendor_code,   
	po_header.po_date,   
	po_header.date_due,   
	po_header.terms,   
	po_header.fob,   
	po_header.ship_via,   
	po_header.ship_to_destination,   
	po_header.status,   
	po_header.type,   
	po_header.description,   
	po_header.plant,   
	po_header.freight_type,   
	po_header.buyer,   
	po_header.printed,   
	po_header.total_amount,   
	po_header.shipping_fee,   
	po_header.sales_tax,   
	po_header.blanket_orderded_qty,   
	po_header.blanket_frequency,   
	po_header.blanket_duration,   
	po_header.blanket_qty_per_release,   
	isnull(po_header.blanket_part, po_detail.part_number) as blanket_part,   
	po_header.blanket_vendor_part,   
	po_header.price,   
	po_header.std_unit,   
	po_header.ship_type,   
	po_header.flag,   
	po_header.release_no,   
	po_header.release_control,   
	po_header.tax_rate,   
	po_header.scheduled_time  
from	po_header
	left outer join po_detail on po_detail.po_number = po_header.po_number
GO

go
alter view dbo.cdivw_scrapqtylist
	(part,
	 scrapcode,
	scrapqty,
	scrapdate)
as	
select	df.part, 
	df.reason,
	df.quantity scrapqty,
	df.defect_date
from	defects df
union 
select	at.part,
	at.user_defined_status,
	at.quantity scrapqty,
	at.date_stamp
from	audit_trail at
where	at.status = 'S'
GO

go
alter view dbo.cdivw_so_inquiry (	
	order_no,   
	customer,   
	order_date,   
	contact,   
	destination,   
	blanket_part,
	model_year,   
	customer_part,   
	box_label,   
	pallet_label,   
	standard_pack,   
	our_cum,   
	the_cum,   
	order_type,   
	amount,   
	shipped,   
	deposit,   
	artificial_cum,   
	shipper,   
	status,   
	location,   
	ship_type,   
	unit,   
	revision,   
	customer_po,   
	blanket_qty,   
	price,   
	price_unit,   
	salesman,   
	zone_code,   
	term,   
	dock_code,   
	package_type,   
	plant,   
	notes,   
	shipping_unit,   
	line_feed_code,   
	fab_cum,   
	raw_cum,   
	fab_date,   
	raw_date,   
	po_expiry_date,   
	begin_kanban_number,   
	end_kanban_number,   
	line11,   
	line12,   
	line13,   
	line14,   
	line15,   
	line16,   
	line17,   
	custom01,   
	custom02,   
	custom03,   
	cs_status ) as
select	distinct order_header.order_no,   
	order_header.customer,   
	order_header.order_date,   
	order_header.contact,   
	order_header.destination,   
	isnull(order_header.blanket_part, order_detail.part_number) as blanket_part,
	order_header.model_year,   
	order_header.customer_part,   
	order_header.box_label,   
	order_header.pallet_label,   
	order_header.standard_pack,   
	order_header.our_cum,   
	order_header.the_cum,   
	order_header.order_type,   
	order_header.amount,   
	order_header.shipped,   
	order_header.deposit,   
	order_header.artificial_cum,   
	order_header.shipper,   
	order_header.status,   
	order_header.location,   
	order_header.ship_type,   
	order_header.unit,   
	order_header.revision,   
	order_header.customer_po,   
	order_header.blanket_qty,   
	order_header.price,   
	order_header.price_unit,   
	order_header.salesman,   
	order_header.zone_code,   
	order_header.term,   
	order_header.dock_code,   
	order_header.package_type,   
	order_header.plant,   
	order_header.notes,   
	order_header.shipping_unit,   
	order_header.line_feed_code,   
	order_header.fab_cum,   
	order_header.raw_cum,   
	order_header.fab_date,   
	order_header.raw_date,   
	order_header.po_expiry_date,   
	order_header.begin_kanban_number,   
	order_header.end_kanban_number,   
	order_header.line11,   
	order_header.line12,   
	order_header.line13,   
	order_header.line14,   
	order_header.line15,   
	order_header.line16,   
	order_header.line17,   
	order_header.custom01,   
	order_header.custom02,   
	order_header.custom03,   
	order_header.cs_status
from	order_header 
	left outer join order_detail on order_detail.order_no = order_header.order_no
GO

go
alter view dbo.cdivw_titan_invform
	(shipper_id,   
	destination_company,   
	destination_destination,   
	destination_name,   
	destination_address_1,   
	destination_address_2,   
	destination_address_3,   
	destination_address_4,   
	customer_customer,   
	customer_name,   
	customer_address_1,   
	customer_address_2,   
	customer_address_3,   
	customer_address_4,   
	edi_setups_supplier_code,   
	shipper_aetc_number,   
	destination_shipping_fob,   
	shipper_freight_type,   
	carrier_name,   
	shipper_detail_note,   
	order_header_customer_po,   
	shipper_detail_qty_original,   
	shipper_detail_qty_packed,   
	part_part,   
	part_cross_ref,   
	shipper_staged_objs,  
	shipper_gross_weight,   
	shipper_staged_pallets, 
	destination_shipping_note_for_bol,
	shipper_notes,
	shipper_detail_customer_part,
	shipper_tare_weight,
	shipper_net_weight,
	part_name,
	shipper_detail_boxes_staged,
	edi_setups_prev_cum_in_asn,
	shipper_detail_accum_shipped,
	consignee_name,
	consignee_address_1,
	consignee_address_2,
	consignee_address_3,
	consignee_address_4,
	shipper_detail_part_original,
	shipper_detail_customer_po,
	order_header_notes,
	shipper_shipping_dock,
	shipper_date_stamp,
	loose_objects)
as
select	shipper.id,   
	destination.company,   
	destination.destination,   
	destination.name,   
	destination.address_1,   
	destination.address_2,   
	destination.address_3,   
	destination.address_4,   
	customer.customer,   
	customer.name,   
	customer.address_1,   
	customer.address_2,   
	customer.address_3,   
	customer.address_4,   
	edi_setups.supplier_code,   
	shipper.aetc_number,   
	destination_shipping.fob,   
	shipper.freight_type,   
	carrier.name,   
	shipper_detail.note,   
	order_header.customer_po,   
	shipper_detail.qty_original,   
	shipper_detail.qty_packed,   
	part.part,   
	part.cross_ref,   
	shipper.staged_objs,  
	shipper.gross_weight,   
	isNULL(shipper.staged_pallets,0), 
	destination_shipping.note_for_bol,
	shipper.notes,
	shipper_detail.customer_part,
	shipper.tare_weight,
	shipper.net_weight,
	part.name,
	shipper_detail.boxes_staged,
	edi_setups.prev_cum_in_asn,
	shipper_detail.accum_shipped,
	consignee.name,
	consignee.address_1,
	consignee.address_2,
	consignee.address_3,
	consignee.address_4,
	shipper_detail.part_original,
	shipper_detail.customer_po,
	order_header.notes,
	shipper.shipping_dock,
	shipper.date_stamp,
	(Select isnull(count(1),0) from object
	where  object.shipper = shipper.id and
	(parent_serial is NULL or parent_serial =0)and
	object.part<>'PALLET' and
	show_on_shipper='Y') as loose_objects 
from	shipper
	join shipper_detail on shipper_detail.shipper = shipper.id
	left outer join destination on destination.destination = shipper.destination
	left outer join destination as consignee ON consignee.destination = substring((shipper.destination + (CASE WHEN PATINDEX ('%*%',shipper.shipping_dock)>0 THEN SUBSTRING (shipper.shipping_dock,1,PATINDEX ('%*%',shipper.shipping_dock)-1)
												ELSE shipper.shipping_dock END)),1,10)
	left outer join customer on customer.customer = destination.customer
	left outer join destination_shipping on destination_shipping.destination = destination.destination
	left outer join edi_setups on edi_setups.destination = destination.destination
	left outer join order_header on order_header.order_no = shipper_detail.order_no
	join part on part.part = shipper_detail.part_original
	left outer join carrier on carrier.scac = shipper.ship_via






GO

go
alter view dbo.cdivw_vendorlist
(	code,   
	name,   
	contact,   
	phone,   
	terms,   
	ytd_sales,   
	balance,   
	frieght_type,   
	fob,   
	buyer,   
	plant,   
	ship_via,   
	address_1,   
	address_2,   
	address_3,   
	fax,   
	outside_processor,   
	address_4,   
	address_5,   
	address_6,
	kanban,
	status,
	custom1,
	custom2,
	custom3,
	custom4,
	custom5,
	VNDUD1,
	VNDUD2,
	VNDUD3,
	VNDUD4,
	VNDUD5,
	company_name, 
	logo 
) as
SELECT	vendor.code,   
	vendor.name,   
	vendor.contact,   
	vendor.phone,   
	vendor.terms,   
	vendor.ytd_sales,   
	vendor.balance,   
	vendor.frieght_type,   
	vendor.fob,   
	vendor.buyer,   
	vendor.plant,   
	vendor.ship_via,   
	vendor.address_1,   
	vendor.address_2,   
	vendor.address_3,   
	vendor.fax,   
	vendor.outside_processor,   
	vendor.address_4,   
	vendor.address_5,   
	vendor.address_6,
	vendor.kanban,
	vendor.status,
	vendor_custom.custom1,
	vendor_custom.custom2,
	vendor_custom.custom3,
	vendor_custom.custom4,
	vendor_custom.custom5,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 1 and
	module = 'VM') as VNDUD1,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 2 and
	module = 'VM') as VNDUD2,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 3 and
	module = 'VM') as VNDUD3,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 4 and
	module = 'VM') as VNDUD4,
	( Select	label
	from	user_definable_module_labels
	where	sequence = 5 and
	module = 'VM') as VNDUD5,
	pmt.company_name company_name, 
	pmt.company_logo logo
FROM	vendor
	left outer join vendor_custom on vendor_custom.code = vendor.code
	cross join parameters pmt
GO

go
alter view dbo.Commision(customer_part,salesrep, name ,commission_rate) as select order_header.customer_part,salesrep.salesrep,salesrep. name ,salesrep.commission_rate from order_header,.salesrep where(order_header.salesman=salesrep.salesrep)
GO

go
alter view dbo.Commissions(customer_part,salesrep, name ,commission_rate) as select order_header.customer_part,salesrep.salesrep,salesrep. name ,salesrep.commission_rate from order_header,.salesrep where(order_header.salesman=salesrep.salesrep)
GO

go
alter view dbo.cs_contact_call_log_vw
as 
	select	contact_call_log.contact,
		contact_call_log.start_date,
		contact_call_log.stop_date,
		contact_call_log.call_subject,
		contact_call_log.call_content,
		contact.customer as customer,
		contact.destination as destination
	from	contact_call_log,contact
	where	contact_call_log.contact = contact.name

GO

go
alter view dbo.cs_contacts_vw
as 
	select	contact.name,
		contact.phone,
		contact.fax_number,
		contact.email1,
		contact.email2,
		contact.title,
		contact.notes,
		contact.customer,
		contact.destination
	from	contact
GO

go
alter view dbo.cs_customers_vw
as 
select	c.customer,
	c.create_date,
	ca.closure_rate*100 as closure_rate,
	ca.ontime_rate*100 as ontime_rate,
	ca.return_rate*100 as return_rate,
	c.cs_status,
	c.name,
	c.address_1,
	c.address_2,
	c.address_3,
	c.address_4,
	c.address_5,
	c.address_6,
	c.phone,
	c.fax,
	c.modem,
	c.contact,
	c.salesrep,
	c.terms,
	c.notes,
	c.default_currency_unit,
	c.show_euro_amount,
	c.custom1,
	c.custom2,
	c.custom3,
	c.custom4,
	c.custom5,
	c.origin_code,
	c.sales_manager_code,
	c.region_code
from	customer as c,
	customer_additional as ca,
	customer_service_status as css
where	c.customer=ca.customer and
	css.status_name = c.cs_status and
	css.status_type <> 'C'
GO

go
alter view dbo.cs_invoices_vw  as
SELECT	invoice_number,   
	id,   
	date_shipped,   
	ship_via,   
	invoice_printed,   
	shipper.notes,   
	shipper.type,   
	shipping_dock,   
	status,   
	aetc_number,   
	freight_type,   
	printed,   
	bill_of_lading_number,   
	model_year_desc,   
	model_year,   
	location,   
	staged_objs,   
	shipper.plant,   
	invoiced,   
	freight,   
	tax_percentage,   
	total_amount,   
	gross_weight,   
	net_weight,   
	tare_weight,   
	responsibility_code,   
	trans_mode,   
	pro_number,   
	time_shipped,   
	truck_number,   
	seal_number,   
	shipper.terms,   
	tax_rate,   
	staged_pallets,   
	container_message,   
	picklist_printed,   
	dropship_reconciled,   
	date_stamp,   
	platinum_trx_ctrl_num,   
	posted,   
	scheduled_ship_time,
	customer.name as customer_name,
	destination.name as destination_name,
	shipper.destination,   
	shipper.customer
FROM	shipper
		join destination on destination.destination = shipper.destination
		join customer on customer.customer = destination.customer
WHERE	isnull(invoice_number,0) > 0
GO

go
alter view dbo.cs_issues_vw
as 
	select  issues.issue_number issue_number,
		issues.issue issue,
		issues.status status,
		issues.solution solution,
		issues.start_date start_date,
		issues.stop_date stop_date,
		issues.category category,
		issues.sub_category sub_category,
		issues.priority_level priority_level,
		issues.product_line product_line,
		issues.product_code product_code,
		issues.origin_type origin_type,
		issues.origin origin,
		issues.assigned_to assigned_to,
		issues.authorized_by authorized_by,
		issues.documentation_change documentation_change,
		issues.fax_sheet,   
		issues.environment environment,
		issues.entered_by entered_by,
		issues.product_component product_component, 
		issues_status.type type
	from  issues
		left outer join issues_status on issues_status.status = issues.status

GO

go
alter view dbo.cs_orders_vw
as 
-----------------------------------------------------------------------------------------
--	GPH	2/22/01	Included isnull function on status column in the where clause and
--		8:30am	also included order no. greater than 0 check as part of the where
--			clause.
-----------------------------------------------------------------------------------------
select 	oh.order_no,
	oh.order_date,
	oh.destination,
	oh.amount,
	oh.status,
	oh.notes,
	oh.customer,
	isnull(min(od.due_date),oh.due_date) due_date
from 	order_header oh
		left outer join order_detail od on oh.order_no = od.order_no,
	customer_service_status as css
where 	css.status_name = oh.cs_status and
	css.status_type <> 'C' and
	isnull(oh.status,'') <> 'C' and
	oh.order_no > 0
group by oh.order_no,
	oh.order_date,
	oh.destination,
	oh.amount,
	oh.status,
	oh.notes,
	oh.customer,
	oh.due_date
GO

go
alter view dbo.cs_part_profile_vw
  as select part,
    customer_part,
    customer_standard_pack,
    customer_unit,
    taxable,
    type,
    customer
    from part_customer
GO

go
alter view dbo.cs_quotes_vw
  as select quote_number,
    quote_date,
    contact,
    status,
    amount,
    notes,
    expire_date,
    customer,
    destination
    from quote
GO

go
alter view dbo.cs_returns_vw as
SELECT 	id,
	status, 
	customer, 
	destination, 
	date_stamp, 
	operator
FROM 	shipper
where 	type = 'R' and status in ( 'O' , 'S' )
GO

go
alter view dbo.cs_rma_detail_vw
as 
select	distinct	shipper,
	part_original,
	isnull(suffix,0) as suffix,
	part,
	qty_required,
	qty_packed,
	shipper_detail.operator,
	price,
	customer as rmacustomer,
	shipper_detail.old_shipper as original_shipper,
	(case 
		when abs(isnull(qty_packed,0)) >= abs(isnull(qty_required,0)) then 'RMA CLOSED & READY FOR INVOICING '
		else 'RMA PENDING & NOT READY FOR INVOICING ' 
	end) RMAstatus
from 	shipper_detail 
	join shipper on id=shipper
GO

go
alter view dbo.cs_ship_history_detail_vw 
as 
select	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	destination.name,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper_detail.part_original,   
	shipper_detail.customer_part,   
	shipper_detail.customer_po,   
	shipper.staged_pallets,   
	shipper_detail.boxes_staged,   
	shipper_detail.order_no,
	isnull(bill_of_lading.printed,'N') bol_printed
from	shipper
	left outer join bill_of_lading on shipper.bill_of_lading_number = bill_of_lading.bol_number,   
	destination,
	customer,   
	customer_service_status,   
	shipper_detail  
where	( shipper.destination = destination.destination ) and  
	( shipper.customer = customer.customer ) and  
	( shipper.cs_status = customer_service_status.status_name ) and  
	( shipper_detail.shipper = shipper.id ) and  
	( shipper.status = 'C' OR shipper.status = 'Z'  ) AND  
	customer_service_status.status_type <> 'C'and
	( shipper.type = 'V' or shipper.type = 'O' or shipper.type = 'Q'  or shipper.type is null ) 
GO

go
alter view dbo.cs_ship_history_summary_vw 
as 
select	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	destination.name,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper.staged_pallets,
	isnull(customer.name,vendor.name) vname,
	isnull(bill_of_lading.printed,'N') bol_printed
from	shipper
	left outer join bill_of_lading on bill_of_lading.bol_number = shipper.bill_of_lading_number,   
	destination
	join customer on customer.customer = destination.customer
	left outer join vendor on vendor.code = destination.vendor,   
	customer_service_status
where	( shipper.destination = destination.destination ) and  
	( shipper.cs_status = customer_service_status.status_name ) and  
	( shipper.status = 'C' OR shipper.status = 'Z' ) and 
	customer_service_status.status_type <> 'C' and
	( shipper.type = 'V' or shipper.type = 'O' or shipper.type = 'Q'  or shipper.type is null ) 
GO

go
alter view dbo.cs_ship_history_vw 
as 
select	distinct shipper,
	part_original,
	isnull(suffix,0) as suffix,
	part,
	qty_required,
	qty_packed,
	shipper.bill_of_lading_number as bol_number,	
	shipper_detail.operator,
	shipper.truck_number,
	shipper.pro_number,
	shipper.ship_via,
	shipper.date_shipped,
	shipper_detail.customer_part,
	shipper_detail.order_no,
	shipper_detail.customer_po,
	shipper.destination,
	shipper.customer,
	customer.name customer_name,
	destination.name destination_name
from 	shipper_detail 
	join shipper on id=shipper
	join destination on destination.destination = shipper.destination
	join customer on customer.customer = destination.customer
where	(shipper.status='Z' or shipper.status='C') and
	(shipper.type='O' or shipper.type='Q' or shipper.type='V' or shipper.type is null)
GO

go
alter view dbo.cs_ship_schedule_vw 
as 
SELECT 	shipper.id,   
	shipper.destination,   
	shipper.date_stamp,   
	shipper.ship_via,   
	shipper.bill_of_lading_number,   
	shipper.staged_objs,   
	shipper.plant,   
	shipper.printed,   
	shipper.customer,   
	shipper.gross_weight,   
	shipper.pro_number,   
	shipper.status,   
	shipper.notes,   
	shipper.type,   
	shipper.net_weight,   
	shipper.picklist_printed,   
	shipper.invoice_number,   
	shipper.scheduled_ship_time,   
	shipper.cs_status,   
	shipper_detail.part_original,   
	shipper_detail.customer_part,   
	shipper_detail.customer_po,   
	shipper.staged_pallets,   
	shipper_detail.boxes_staged,   
	shipper_detail.order_no,
	shipper.truck_number,
	destination.name,
	customer.name cname
FROM 	shipper,   
	destination
	join customer on customer.customer = destination.customer,   
	customer_service_status,   
	shipper_detail  
WHERE 	shipper.destination = destination.destination and  
	shipper.cs_status = customer_service_status.status_name and  
	shipper_detail.shipper = shipper.id and  
	( shipper.status = 'O' OR  
	shipper.status = 'S' ) AND  
	isnull(shipper.type,'') <> 'R' and
	customer_service_status.status_type <> 'C'
GO

go
alter view dbo.Label_FinishedGoodsData
AS
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
		--	Fields on every label    
			Serial = o.serial
		,	Quantity = CONVERT (INT, o.quantity)
		,	CustomerPart = oh.customer_part
		,	CompanyName = param.company_name
		,	CompanyAddress1 = param.address_1
		,	CompanyAddress2 = param.address_2
		,	CompanyAddress3 = param.address_3
		,	CompanyPhoneNumber = param.phone_number
		--	Fields on some labels ...
		,	CustPartRemove0 = REPLACE(LTRIM(REPLACE(oh.customer_part, '0', ' ')), ' ', '0')
		,	LicensePlate = 'UN' + es.supplier_code + '' + CONVERT(VARCHAR, o.serial) 
		,	SerialThreeDigitTesla = CONVERT(CHAR(3), RIGHT(o.serial, 3))
		,	SerialTenDigitTesla = RIGHT(('0000000000' + CONVERT(VARCHAR, o.serial)), 10)
		,	SerialCooper =  RIGHT(('000000000' + CONVERT(VARCHAR, o.serial)), 9)
		,	SerialPaddedNineNines =  RIGHT(('999999999' + CONVERT(VARCHAR, o.serial)), 9)
		,	EDISetupsparentDestination = es.parent_destination
		,	EDISetupsMaterialIssuer = es.material_issuer
		,	InterBoxLicPlate= COALESCE(sd.Customer_part, oh.Customer_part) +'S' + RIGHT(('999999999' + CONVERT(VARCHAR, o.serial)), 9) + 'Q' + CONVERT(VARCHAR(15), CONVERT( INT, o.quantity ))
		,	TELFBoxLicPlate = 'ZZ' + es.supplier_code + RIGHT(('0000000000' + CONVERT(VARCHAR(15), o.serial)), 10)
		,	PartNumber = o.part
		,	UnitOfMeasure =  o.unit_measure
		,	Location = o.location
		,	Lot = o.lot
		,	Operator = o.operator
		,	MfgDate = CONVERT(VARCHAR(10), o.last_date, 101)
		,	MfgTime = CONVERT(VARCHAR(5), o.last_date, 108)
		--,	ThreeDigitDate = FT.fn_GetThreeDigitDate(COALESCE(s.date_stamp, GETDATE()) )
		,	ShippedDate = COALESCE(CONVERT(VARCHAR(10), s.date_stamp, 101), CONVERT(VARCHAR(10), GETDATE(), 101))
		--,	MfgDateMM = case when rl.name in ('Ford_Part Container') then convert(varchar(6), o.last_time, 12) end
		,	MfgDateMMM = UPPER(REPLACE(CONVERT(VARCHAR, o.last_time, 106), ' ', ''))
		,	MfgDateMMMDashes = UPPER(REPLACE(CONVERT(VARCHAR, o.last_time, 106), ' ', '-'))
		,	GrossWeight = CONVERT(NUMERIC(10,2), ROUND(o.weight + o.tare_weight, 2))
		,	GrossWeightKilograms = CONVERT(NUMERIC(10,0),((o.weight + o.tare_weight) / 2.2))
		,	NetWeightKilograms = CONVERT(NUMERIC(10,0),((o.weight) / 2.2))
		,	NetWeight = CONVERT(NUMERIC(10,2), ROUND(o.weight,2))
		,	TareWeight = CONVERT(NUMERIC(10,2), ROUND(o.tare_weight,2))
		,	StagedObjects = s.staged_objs
--		,	Origin = o.origin
		,	PackageType = o.package_type
		,	PartName = p.name
--		,	Customer = oh.customer
		,	DockCode =  oh.dock_code
		,	ZoneCode = oh.zone_code
		,	LineFeedCode = oh.line_feed_code
		,	Line11 = oh.line11 -- Material Handling Code
		,	Line12 = oh.line12  --Plant/Dock on GM Label
		,	Line13 = oh.line13
		,	Line14 = oh.line14
		,	Line15 = oh.line15
		,	Line16 = oh.line16
		,	Line17 = oh.line17
		,	BTM = oh.contact
		,	SupplierCode = es.supplier_code
		,	MaterialIssuer = es.material_issuer
		,	Shipper = sd.shipper
		,	CustomerPO =  sd.customer_po
		,	EngineeringLevel =  oh.engineering_level
		,	Destination = oh.destination
		,	DestinationName = d.name
		,	DestinationAddress1 = d.address_1
		,	DestinationAddress2 = d.address_2
		,	DestinationAddress3 = d.address_3
		,	DestinationAddress4 = d.address_4
		,	ObjectKANBAN = COALESCE(o.kanban_number, '') 
		,	ObjectCustom5 = COALESCE(o.custom5, '')
		,	ShipToID = COALESCE(es.ediShipToID, es.parent_destination)
		,	PO_or_Release =  
				CASE
				WHEN NULLIF(sd.customer_po,'') IS NULL
				THEN sd.release_no 
				ELSE sd.customer_po 
				END
				
		,	ReleaseNumber =  sd.release_no
		,	ShipperDateStamp = s.date_stamp
		,	DecoPlasBarcode = 'A'+oh.customer_part +'  '+'00'+CONVERT(VARCHAR(15), CONVERT(INT, o.quantity))+'.000'+'EA'+'A'+CONVERT(VARCHAR(15),o.serial)
		,	OHCustom01 = oh.custom01
		,	OHcustom02 = oh.custom02
		,	OHCustom03 = oh.custom03
		,	TeslaShipDate = COALESCE(CONVERT(VARCHAR(8), s.date_stamp, 112), CONVERT(VARCHAR(8), GETDATE(), 112) ) -- YYYYMMDD
		,	TeslaQuantity = RIGHT('000000' + CONVERT(VARCHAR(6), CONVERT(INT, o.quantity) ), 6 )
		,	TeslaCustomerPart = RIGHT('0000000000' + REPLACE(REPLACE(oh.customer_part, '-', ''), ' ', ''), 10 )
		--,	TeslaContentLabelId = 
		--		'3S' + 
		--		'AVJ' + 
		--		RIGHT('000000' + CONVERT(VARCHAR(6), CONVERT(INT, o.quantity) ), 6 ) +
		--		CONVERT(CHAR(3), RIGHT(o.serial, 3) ) +
		--		FT.fn_GetThreeDigitDate(COALESCE(o.last_date, GETDATE()) ) +
		--		RIGHT('0000000000' + REPLACE(REPLACE(oh.customer_part, '-', ''), ' ', ''), 10 )
		--,	TeslaPOline = lss.CustomerPOLine
		--,	DateTimeZoneDue = CASE WHEN rl.NAME IN ('MITSUBISHI_RAN') THEN mran.date_time_zone_due END
		--,	RevLevel = CASE WHEN rl.NAME IN ('MITSUBISHI_RAN') THEN oh.engineering_level END 
		--	Make sure we printed the correct label format.
		,	BoxLabelFormat = rl.NAME
		FROM
			dbo.OBJECT o
			LEFT JOIN (SELECT MAX(engineering_level) AS engineering_level, part AS ecn_part FROM dbo.effective_change_notice GROUP BY part) ecn ON
				ecn.ecn_part = o.part
			LEFT JOIN dbo.shipper s
				JOIN dbo.shipper_detail sd
					ON sd.shipper = s.id
				ON s.id = COALESCE(o.shipper, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT (INT, o.origin) END)
				AND sd.part_original = o.part
			LEFT JOIN dbo.order_header oh ON
				oh.order_no = COALESCE(sd.order_no, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT(INT, o.origin) END)
				AND oh.blanket_part = o.part
			LEFT JOIN dbo.destination d ON
				d.destination = COALESCE(s.destination, oh.destination, o.destination)
			LEFT JOIN dbo.edi_setups es ON
				es.destination = COALESCE(s.destination, oh.destination, o.destination)
			--LEFT JOIN (SELECT MAX(CONVERT(VARCHAR(10),PickUpDT,105)) AS date_time_zone_due, RAN FROM EDIMitsubishi.RanDetails GROUP BY RAN) mran ON
			--	mran.RAN = o.custom1
				JOIN dbo.part p ON
				p.part = o.part
			JOIN dbo.part_inventory pi ON
				pi.part = p.part
			JOIN dbo.report_library rl ON
				rl.name = COALESCE(oh.box_label, pi.label_format)
			CROSS JOIN dbo.parameters param
	) rawLabelData


	













GO

go
alter view dbo.Label_FinishedGoodsData_Master
AS
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
			Serial = oPallet.serial
		,	SerialTenDigitTesla = RIGHT(('0000000000' + CONVERT(VARCHAR, oPallet.serial)), 10)
		,	PalletSerialCooper = RIGHT(('000000000' + CONVERT(VARCHAR, oPallet.serial)), 9)
		,	InterPalletLicPlate= COALESCE(sd.Customer_part, oh.Customer_part) +'S' + RIGHT(('999999999' + CONVERT(VARCHAR, opallet.serial)), 9) + 'Q' + CONVERT(VARCHAR(15), CONVERT( INT, (	SELECT
					SUM(std_quantity)
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
			)  ))
		,   LotNumber =  oBox.lot 
		,	LicensePlate = 'UN' + es.supplier_code + '' + CONVERT(VARCHAR, oPallet.serial) 
		--,   MfgDate = convert(varchar(10), oPallet.last_date, 101)  
		,   MfgDate = CONVERT(VARCHAR(10), COALESCE((SELECT MAX(date_stamp) FROM audit_trail WHERE type IN ('J', 'B') AND Serial IN (SELECT serial FROM object o2 WHERE o2.parent_serial = oPallet.serial)),oPallet.last_date), 101)  
		--,	MfgDateMM = CONVERT(varchar(6), oPallet.last_time, 12) 
		,	MfgDateMM = CONVERT(VARCHAR(6), COALESCE((SELECT MAX(date_stamp) FROM audit_trail WHERE type IN ('J', 'B') AND Serial IN (SELECT serial FROM object o2 WHERE o2.parent_serial = oPallet.serial)),oPallet.last_time), 12) 
		--,	MfgDateMMM = UPPER(REPLACE(CONVERT(VARCHAR, oPallet.last_date, 106), ' ', '')) 
		,	MfgDateMMM = UPPER(REPLACE(CONVERT(VARCHAR, COALESCE((SELECT MAX(date_stamp) FROM audit_trail WHERE type IN ('J', 'B') AND Serial IN (SELECT serial FROM object o2 WHERE o2.parent_serial = oPallet.serial)),oPallet.last_time), 106), ' ', '')) 
		--,	MfgDateMMMDashes = UPPER(REPLACE(CONVERT(VARCHAR, oPallet.last_time, 106), ' ', '-')) 
		,	MfgDateMMMDashes = UPPER(REPLACE(CONVERT(VARCHAR, COALESCE((SELECT MAX(date_stamp) FROM audit_trail WHERE type IN ('J', 'B') AND Serial IN (SELECT serial FROM object o2 WHERE o2.parent_serial = oPallet.serial)),oPallet.last_time), 106), ' ', '-'))
		,	ShippedDate = COALESCE(CONVERT(VARCHAR(10), sd.date_shipped, 101), CONVERT(VARCHAR(10), GETDATE(), 101))
		,	ShippedDateTesla = COALESCE(CONVERT(VARCHAR(6), sd.date_shipped, 12), CONVERT(VARCHAR(6), GETDATE(), 12))
		,   UM =  oBox.unit_measure  
		--,   Operator = oPallet.operator
		,	PalletNetWeight = 
			(	SELECT
					CONVERT(NUMERIC(10,2), ROUND(SUM(weight),2))
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
			) 
		,	PalletNetWeightKG =
			(	SELECT
					CONVERT(NUMERIC(10,2), ROUND(SUM(weight) / 2.2,2))
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
			)
		,	PalletGrossWeight =
			(	SELECT
					CONVERT(NUMERIC(10,2), ROUND(SUM(COALESCE(object.weight, 0) + COALESCE(object.tare_weight,0)),2))
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
					OR serial = oPallet.serial
			) 
		,	PalletGrossWeightKG = 
			(	SELECT
					CONVERT(NUMERIC(10,0), ROUND(SUM(COALESCE(object.weight,0) + COALESCE(object.tare_weight,0)) / 2.2,2))
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
					OR serial = oPallet.serial
			) 
		,	PalletTareWeight = 
			(	SELECT
					CONVERT(NUMERIC(10,2), ROUND(SUM(object.tare_weight),2))
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
					OR serial = oPallet.serial
			) 
		,	PartCode =  oBox.part 
		,	PartName =  pBox.name 
		--,	UDF1 = pcBox.user_defined_1
		,	PalletQty = 
			(	SELECT
					SUM(std_quantity)
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
			) 
		,	Boxes = 
			(	SELECT
					COUNT(*)
				FROM
					object
				WHERE
					parent_serial = oPallet.serial
			) 
		,	BoxQty = oBox.std_quantity 
		,	ECN = oh.engineering_level
		--,	ECN = 
		--	(	SELECT 
		--			MAX(engineering_level)
		--		FROM
		--			effective_change_notice
		--		WHERE
		--			part = oBox.part
		--			AND effective_date =
		--			(	SELECT
		--					MAX(e.effective_date)
		--				FROM
		--					effective_change_notice e
		--				WHERE
		--					e.part = oBox.part
		--			)
		--	) 
		,   CustomerPO =  oh.customer_po 
		,   CustomerPart =  oh.customer_part 
		--,   CustomerName = c.name
		--,   BillToCode = oh.customer
		,	Shipper = ISNULL(CONVERT(VARCHAR(25),oBox.shipper), '')
		,   ShipToCode = oh.destination 
		,	SupplierCode = es.supplier_code 
		,   ShipToName =  d.name 
		,   ShipToAddress1 =  d.address_1 
		,   ShipToAddress2 =  d.address_2 
		,   ShipToAddress3 = d.address_3 
		,   ShipToAddress4 = d.address_4 
		,	PoolCode = es.pool_code 
		,	DockCode =  oh.dock_code 
		,	LineFeedCode =  oh.line_feed_code 
		,	ZoneCode =  oh.zone_code 
		,	Line11 =  oh.line11  -- material handling code
		,	Line12 = oh.line12  --Plant/Dock on GM Master Label
		,	Line13 = oh.line13
		,	Line14 = oh.line14
		,	Line15 = oh.line15
		,	Line16 = oh.line16
		,	Line17 = oh.line17
		,	Location =  oPallet.location 
		,	ContainerType =  oPallet.package_type 
		,	CompanyName =  parm.company_name 
		,	CompanyAddress1 =  parm.address_1 
		,	CompanyAddress2 =  parm.address_2 
		,	CompanyAddress3 =  parm.address_3 
		,	PhoneNumber =  parm.phone_number
		,	EDISetupsMaterialIssuer = es.material_issuer
		,	SerialPaddedNineNines =  RIGHT(('999999999' + CONVERT(VARCHAR, oPallet.serial)), 9)
		,	SerialCooper =  RIGHT(('000000000' + CONVERT(VARCHAR, oPallet.serial)), 9)
		,	EDISetupsparentDestination = es.parent_destination
		,	MasterMixed =	CASE	
								WHEN (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) > 1 THEN 'MIXED PALLET'
								WHEN  (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) = 1 THEN 'MASTER LABEL'
								ELSE 'GENERIC'
								END
							
		--,	PDF417MessageHeader = '[)>' + char(30)
		--,	PDF417FormatHeader = '06' + char(29)
		--,	PDF417RecordSeparator = char(30)
		--,	PDF417GroupSeparator = char(29)
		--,	PDF417FieldSeparator = char(28)
		--,	PDF417MessageTrailer = char(30) + char(04)
		,	TeslaLicensePlate =
				CASE WHEN
					(	SELECT
							COUNT(DISTINCT part)
						FROM
							dbo.object
						WHERE
							parent_serial = oBox.parent_serial
					) > 1 THEN '5J'
					ELSE '6J'
				END + 
				RIGHT('000000000' + es.supplier_code, 9) + 
				COALESCE(CONVERT(VARCHAR(6), sd.date_shipped, 12), CONVERT(VARCHAR(6), GETDATE(), 12)) +
				--convert(varchar(6), getdate(), 12) + 
				RIGHT(('0000000000' + CONVERT(VARCHAR, oPallet.serial)), 10)
		,	ReleaseNumber =  sd.release_no
		,	PalletLabelFormat = rl.NAME
		FROM
			parameters parm
			CROSS JOIN OBJECT oPallet
			LEFT JOIN OBJECT oBox
				JOIN part pBox
					ON pBox.part = oBox.part
				LEFT JOIN part_characteristics pcBox
					ON pcBox.part = oBox.part
				ON oBox.parent_serial = oPallet.serial
				AND oBox.serial =
				(	SELECT
						MIN(serial)
					FROM
						object
					WHERE
						parent_serial = oPallet.serial
				)
			LEFT JOIN shipper_detail sd
				ON sd.shipper = COALESCE(oBox.shipper, CASE WHEN oBox.origin NOT LIKE '%[^0-9]%' AND LEN(oBox.origin) < 10 THEN CONVERT (INT, oBox.origin) END)
				AND sd.part_original = oBox.part
			LEFT JOIN order_header oh
					LEFT JOIN customer c
						ON c.customer = oh.customer
					LEFT JOIN destination d
						ON d.destination = oh.destination
					LEFT JOIN edi_setups es
						ON es.destination = oh.destination
				ON oh.order_no = COALESCE(sd.order_no, CASE WHEN oBox.origin NOT LIKE '%[^0-9]%' AND LEN(oBox.origin) < 10 THEN CONVERT (INT, oBox.origin) END)
			
			JOIN dbo.report_library rl ON
				rl.name = COALESCE(oh.pallet_label, 'PALLET')
	) rawLabelData









GO

go
alter view dbo.mvw_billofmaterial
    ( parent_part,
      part,
      type,
      std_qty ) AS
-------------------------------------------------------------------
--	View : mvw_billofmaterial required for super cop processing
--	
--	Harish Gubbi 01/07/2000	Created newly for super cop purposes
-------------------------------------------------------------------
select	bill_of_material_ec.parent_part,
        bill_of_material_ec.part,
        bill_of_material_ec.type,
        bill_of_material_ec.std_qty * (1 + bill_of_material_ec.scrap_factor)
from	bill_of_material_ec
where	(bill_of_material_ec.start_datetime <= getdate() ) AND
	(bill_of_material_ec.end_datetime > getdate() OR
	bill_of_material_ec.end_datetime is null) and
	isnull(bill_of_material_ec.substitute_part,'N') <> 'Y'
GO

go
alter view dbo.mvw_demand (	
	part, 
	due_dt, 
	std_qty,
	first_key,
	second_key,
	plant,
	type,
	flag )			
as
select  od.part_number,
	od.due_date,
	od.std_qty,
	od.order_no,
	od.row_id,
	od.plant,
	od.type,
	od.flag
from 	order_detail od
	join order_header oh on oh.order_no = od.order_no
	join customer_service_status css on css.status_name = oh.cs_status 
	cross join parameters
where	od.ship_type = 'N' and
	css.status_type <> 'C' and
	datediff ( dd, getdate(), od.due_date ) <= parameters.days_to_process
GO

go
alter view dbo.mvw_effectivechangenotice(ecn_part,
       effective_date) AS  
select ecn.part,       
       max(ecn.effective_date)
from   effective_change_notice  ecn
group by ecn.part

GO

go
alter view dbo.mvw_eng_level(el_part,
       engineering_level,
       effective_date) AS  
select el.part,
       el.engineering_level,       
       el.effective_date
from   effective_change_notice  el
join   mvw_effectivechangenotice ecn on ecn.ecn_part = el.part and ecn.effective_date = el.effective_date

GO

go
alter view dbo.mvw_gss_demand
as
SELECT	order_detail.part_number,   
	order_detail.quantity,   
	order_detail.assigned,   
	order_detail.order_no,   
	order_detail.due_date,   
	order_detail.committed_qty,   
	order_detail.release_no,   
	order_detail.suffix,   
	order_detail.alternate_price as price,
	order_detail.destination
FROM 	order_detail, order_header, customer_service_status  
WHERE 	order_detail.quantity > IsNull ( order_detail.committed_qty, 0 )  and  
	order_detail.ship_type = 'N'  and
	order_header.order_no = order_detail.order_no and
	order_header.cs_status = customer_service_status.status_name and
	customer_service_status.status_type <> 'C'
GO

go
alter view dbo.mvw_machinelist 
	(machine,
	sequence,
	part ) 
as
select	part_machine.machine,   
	part_machine.sequence,
	part_machine.part
from	part_machine  
where	part_machine.machine > '' 
--	and part_machine.sequence <= 6 -- needs to be included for guardian
GO

go
alter view dbo.mvw_new (	
	type,   
	part,   
	due,   
	qnty,   
	source,   
	origin,   
	machine,   
	run_time,   
	std_start_date,   
	endgap_start_date,
	startgap_start_date,
	setup,   
	process,
	id,   
	week_no,
	plant,
	eruntime,
	flag)
as
select	part.class type,
	bom.part,
	mps.dead_start due,
	(	case when bom.type = 'T'
			then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) extended_qty,
	mps.source,
	mps.origin,
	IsNull ( part_machine.machine, '' ),
	IsNull ( (	case	when bom.type = 'T' then bom.std_qty
				else mps.qnty * bom.std_qty
			end ) / part_machine.parts_per_hour + (
			case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
				else 0
			end ), 0 ) runtime,
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ))), mps.dead_start ), mps.dead_start ) std_start_date,
	
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ) +
		(case	when part_machine.overlap_type = 'S' then ( part_inventory.standard_pack / part_machine.parts_per_hour ) 
			when part_machine.overlap_type = 'T' then part_machine.overlap_time 
		end ))), mps.due ), mps.dead_start ) endgap_start_date,
	
	IsNull ( dateadd ( mi, - 60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end ) +
		(case	when part_machine.overlap_type = 'S' then ( part_inventory.standard_pack / part_machine.parts_per_hour ) 
			when part_machine.overlap_type = 'T' then part_machine.overlap_time
		end ))), mps.dead_start ), convert( datetime, '1900-01-01' ) ) startgap_start_date,
	
	IsNull ( part_machine.setup_time, 0 ),
	part_machine.process_id,
	mps.id,
	datediff ( wk, parameters.fiscal_year_begin, mps.dead_start ),
	mps.plant,
	(60 * (( 24.00 / parameters.workhours_in_day ) * 
		((case	when bom.type = 'T' then bom.std_qty
			else mps.qnty * bom.std_qty
		end ) / part_machine.parts_per_hour + 
		(case	when parameters.include_setuptime = 'Y' then isnull(part_machine.setup_time,0)
		 	else 0
		end )))) eruntime,
	mvw_demand.flag
from	master_prod_sched mps
	join mvw_demand on mps.origin = mvw_demand.first_key and
	mps.source = mvw_demand.second_key
	join mvw_billofmaterial bom on mps.part = bom.parent_part
	join part on bom.part = part.part
	join part_inventory part_inventory on mps.part = part_inventory.part			
	left outer join part_machine on bom.part = part_machine.part and
		part_machine.sequence = 1
	cross join parameters
GO

go
alter view dbo.mvw_pb_resource_list (
	resource_name,
	resource_type )
as select machine_no,
	1
from	machine
GO

go
alter view dbo.mvw_replenish (
	part,
	std_qty )
as
select	part_number,
	standard_qty
from	po_detail
where	status <> 'C'
union all
select	part,
	qty_required
from	workorder_detail
GO

go
alter view dbo.mvw_resource_shift_list (
	resource_name,
	shift_Id,
	shift_start,
	shift_end,
	shift_labor,
	shift_crew,
	shift_length)
as select machine,
	ai_id,	
	begin_datetime,
	end_datetime,
	labor_code,
	crew_size,
	convert ( numeric, datediff ( hour, begin_datetime, end_datetime) ) 
from	shop_floor_calendar 
	join mvw_pb_resource_list on machine=resource_name
	and resource_type=1 
where	begin_datetime >= dateadd(dd,-1,getdate())
GO

go
alter view dbo.mvw_resource_task_list (
	resource_name,
	resource_type,
	task_id,
	task_type,
	task_sequence,
	task_start,
	task_end,
	task_duration,
	task_description,
	task_due,
	task_balance,
	task_yield)
as select resource_name,
	resource_type,
	Convert ( integer, work_order ),
	1,
	sequence,
	convert(datetime,IsNull(convert(varchar,start_date,111),'0001-01-01')+substring(convert(varchar,start_time,109),12,15)),
	convert(datetime,IsNull(convert(varchar,end_date,111),'0001-01-01')+substring(convert(varchar,end_time,109),12,15)),
	DateDiff ( second, start_date, end_date ) runtime,
	(select min(part)
	from workorder_detail
	where workorder=work_order),
	work_order.due_date,
	IsNull (
	(	select	Min ( balance )
		from	workorder_detail
		where	workorder_detail.workorder = work_order.work_order ), 0 ),
	IsNull (
	(	select	min ( on_hand / bom.std_qty )
		from	workorder_detail
			join bill_of_material bom on workorder_detail.part = bom.parent_part
			join part_online on bom.part = part_online.part
		where	workorder_detail.workorder = work_order.work_order and
			bom.std_qty > 0 ), 0 )
from work_order 
     join mvw_pb_resource_list on machine_no=resource_name and resource_type=1
     
GO

go
alter view dbo.mvw_vendorlist 
	(vendor,
	part ) 
as
select	part_vendor.vendor,
	part_vendor.part
from	part_vendor
where	part_vendor.vendor > '' 
GO

go
alter view dbo.part_mfg(part,
  mfg_lot_size,
  process_id,
  parts_per_cycle,
  parts_per_hour,
  cycle_unit,
  cycle_time,
  overlap_type,
  overlap_time,
  engineering_level,
  drawing_number,
  labor_code,
  gl_account_code,
  activity,
  setup_time,
  eng_effective_date)
  as select part_machine.part,
    part_machine.mfg_lot_size,
    part_machine.process_id,
    part_machine.parts_per_cycle,
    part_machine.parts_per_hour,
    part_machine.cycle_unit,
    part_machine.cycle_time,
    part_machine.overlap_type,
    part_machine.overlap_time,
    part.engineering_level,
    part.drawing_number,
    part_machine.labor_code,
    part.gl_account_code,
    part_machine.activity,
    part_machine.setup_time,
    part.eng_effective_date
    from part_machine,.part
    where part_machine.sequence=1
    and part_machine.part=part.part
GO

go
alter view dbo.part_vendor_accum(part,vendor,accum_qty) as 
  select part,vendor,
    (select Isnull(sum(audit_trail.quantity),0) 
  from audit_trail 
  where audit_trail.part=part_vendor.part and 
        audit_trail.vendor=part_vendor.vendor and 
	audit_trail.type='R' and 
	audit_trail.date_stamp>=part_vendor.beginning_inventory_date) 
  from part_vendor
GO

go
alter view dbo.shop_floor_calendar_new as 
select shop_floor_calendar.machine,
	convert(datetime,begin_datetime) as work_date,
	convert(datetime,begin_datetime) as begin_time,
	convert(numeric(8),datediff(mm,begin_datetime,end_datetime)/60 ) as up_hours,
	convert(numeric(8),0) as down_hours,
	convert(datetime,end_datetime)  as end_time,
	convert(datetime,end_datetime)  as end_date,shop_floor_calendar.crew_size,shop_floor_calendar.labor_code from shop_floor_calendar
GO

go
alter view dbo.Test(customer_part,salesman,salesrep, name ,commission_rate) as select order_header.customer_part,order_header.salesman,salesrep.salesrep,salesrep. name ,salesrep.commission_rate from order_header,.salesrep where(order_header.salesman=salesrep.salesrep)
GO

go
alter view dbo.v_part_qty_in_job
  as select workorder_detail.part,workorder_detail.plant,sum(balance) s_balance from workorder_detail group by workorder_detail.part,workorder_detail.plant
GO

go
alter view dbo.v_part_qty_in_po
  as select po_detail.part_number,po_detail.plant,sum(standard_qty) s_qty from po_detail group by po_detail.part_number,po_detail.plant
GO

go
alter view dbo.vw_CAMI_OrderDetail
as

Select    substring(order_detail.release_no, 1, patindex('%*%', order_detail.release_no)-1) as ReleaseNumber,
        substring(order_detail.release_no, patindex('%*%', order_detail.release_no)+1, 30) as SID,
        order_detail.part_number,
        order_detail.customer_part,
        order_detail.quantity,
        order_detail.due_date
from        order_detail
JOIN        order_header on order_detail.order_no = order_header.order_no
where    release_no like '%*%'  and
        order_header.destination like '%CAMI%'
GO

go
alter view dbo.vw_EDI_BENTELER_830_AccumATH
AS
SELECT TOP 100000		ReleaseNo = RTRIM(r1.ReleaseNo) ,
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler830_AccumATH R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									AccumQuantity = CONVERT(NUMERIC(20,6),RTRIM(RIGHT(R1.AccumQuantity,15))) ,
									LASTDate  = convert(DATETIME,RTRIM(R1.LastDate))
									
FROM 
dbo.edi_benteler830_AccumATH R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  AND LEFT(R1.AccumQuantity,2) = '02'
ORDER BY R1.CustomerPart, R1.LastDate
GO

go
alter view dbo.vw_EDI_BENTELER_830_RELEASES
AS
SELECT TOP 100000		ReleaseNo = RTRIM(r1.ReleaseNo) ,
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler830_Releases R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									Quantity = CONVERT(NUMERIC(20,6),RTRIM(R1.Quantity)) ,
									ShipDate  = convert(DATETIME,RTRIM(R1.ShipDate))
									
FROM 
dbo.edi_benteler830_Releases R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  
ORDER BY R1.CustomerPart, r1.ShipDate
GO

go
alter view dbo.vw_EDI_BENTELER_862_AccumATH
AS
SELECT TOP 100000		ReleaseNo = RTRIM(r1.ReleaseNo) ,
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler862_AccumATH R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									AccumQuantity = CONVERT(NUMERIC(20,6),RTRIM(RIGHT(R1.AccumQuantity,15))) ,
									LASTDate  = convert(DATETIME,RTRIM(R1.LastDate))
									
FROM 
dbo.edi_benteler862_AccumATH R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  AND LEFT(R1.AccumQuantity,2) = '02'
ORDER BY R1.CustomerPart, R1.LastDate
GO

go
alter view dbo.vw_EDI_BENTELER_862_RELEASES
AS

--00020!50001656^211$    
SELECT TOP 100000		ReleaseNo = RTRIM(r1.CustomerPO)+'!'+RTRIM(LEFT(R1.ReleaseNo,22))+'^'+RTRIM(RIGHT(R1.ReleaseNo,22))+'$',
									ShipToID =( SELECT TOP 1 R2.ShipToID FROM edi_benteler862_Releases R2 WHERE R2.ReleaseNo= R1.ReleaseNo AND R2.CustomerPart = R1.CustomerPart AND R2.CustomerPO = R1.CustomerPO  AND LEN(RTRIM(r2.ShipToID))<9 ) ,
									CustomerPart = RTRIM(R1.CustomerPart),
									CustomerPO = RTRIM(r1.CustomerPO) ,
									Quantity = CONVERT(NUMERIC(20,6),RTRIM(R1.Quantity)) ,
									ShipDate  = CONVERT(DATETIME,RTRIM(R1.ShipDate))
									
FROM 
dbo.edi_benteler862_Releases R1
WHERE LEN(RTRIM(r1.ShipToID))>=9  
ORDER BY R1.CustomerPart, r1.ShipDate

GO

go
alter view dbo.vw_edi_cami_desadv_header as
SELECT '' partial_complete,
			'9' purpose_code,
			'MB' ref_no_type,
			'182' resp_agency,
			'12' trans_stage,
			edi_setups.supplier_code,
			edi_setups.material_issuer,   
         shipper.id,   
         shipper.destination,   
         shipper.shipping_dock,   
         shipper.date_shipped,   
         shipper.aetc_number,   
        shipper.bill_of_lading_number,   
         shipper.gross_weight,
         shipper.net_weight,
			shipper.staged_objs,
			shipper.trans_mode,
			shipper.ship_via,
			upper(shipper.truck_number) AS TRAILERNUMBER,
			shipper.seal_number,
         destination.address_6,
			edi_setups.trading_partner_code,
			edi_setups.parent_destination,
			shipper.date_stamp,
			shipperpiecesshipped,
			shipper.pro_number
	 FROM destination,  
         edi_setups,  
         shipper 
	JOIN (Select 		sum(qty_packed) shipperpiecesshipped,
							shipper
							from	shipper_detail
					group by shipper) shipperdetail on shipper.id = shipperdetail.shipper
			
   WHERE ( shipper.destination = edi_setups.destination ) and
			( shipper.destination = destination.destination )
GO

go
alter view dbo.vw_StampingSetup_FinishedGoods
as
select
	isnull(row_number() over(order by oh.blanket_part), 0) as ID
,	oh.blanket_part
from
	dbo.order_header oh
group by
	oh.blanket_part
GO

go
alter view dbo.vwft_EDI_DESADV_PlasticOmnium_Detail

AS

SELECT	CONVERT(varchar(10),Shipper.id) AS ShipperID,
		'4' AS PackLevelCode,
		CONVERT(varchar(15), Shipper.staged_objs) AS StagedObjects,
		'CONT90' AS PackType,
		CONVERT(varchar(10),(SELECT COUNT(1) FROM shipper_detail sd2 WHERE sd2.part_original<= shipper_detail.part_original AND sd2.shipper = shipper_detail.shipper)) AS LineID,
		shipper_detail.customer_part AS Customerpart,
		CONVERT(varchar(15), CONVERT(int,shipper_detail.alternative_qty)) AS QtyShipped,
		CONVERT(varchar(15), CONVERT(int,shipper_detail.accum_shipped)) AS AccumQtyShipped,
		--ISNULL(SUBSTRING(shipper_detail.customer_po, 1, DATALENGTH(dbo.shipper_detail.customer_po)-3),'') AS CustomerPO,
		--ISNULL(SUBSTRING(shipper_detail.customer_po,DATALENGTH(dbo.shipper_detail.customer_po)-2, 10),'') AS CustomerPOLine,
		shipper_detail.customer_po AS CustomerPO,
		'' AS CustomerPOLine,
		order_header.model_year AS ModelYear		
		
FROM	dbo.shipper
JOIN	dbo.shipper_detail ON dbo.shipper.id = dbo.shipper_detail.shipper
JOIN	order_header ON dbo.shipper_detail.order_no = dbo.order_header.order_no
JOIN	dbo.edi_setups ON dbo.shipper.destination = dbo.edi_setups.destination


GO

go
alter view dbo.vwFT_EDI_DESADV_PlasticOmnium_Header

AS

SELECT	CONVERT(varchar(25), shipper.id) AS ShipperID,
		(CONVERT(varchar(4), DATEPART(yyyy,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(mm,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(dd,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(hh,shipper.date_shipped))+
		CONVERT(varchar(2), DATEPART(mi,shipper.date_shipped)))AS DocumentDate,
		(CONVERT(varchar(4), DATEPART(yyyy,getdate()))+
		CONVERT(varchar(2), DATEPART(mm,getdate()))+
		CONVERT(varchar(2), DATEPART(dd,getdate()))+
		CONVERT(varchar(2), DATEPART(hh,getdate()))+
		CONVERT(varchar(2), DATEPART(mi,getdate())))AS DesadvDate,
		COALESCE(NULLIF(edi_setups.parent_destination,''),edi_setups.destination) AS ShipToID,
		edi_setups.supplier_code AS SupplierCode,
		'' AS Partial_Complete,
		trading_partner_code AS TradingPartner,
		CONVERT (varchar(10),CONVERT(int,shipper.gross_weight)) AS ShipperGrossWeight,
		CONVERT (varchar(10),CONVERT(int,shipper.net_weight)) AS ShipperNetWeight,
		CONVERT (varchar(10),CONVERT(int,shipper.staged_objs)) AS ShipperStagedObjects,
		CONVERT (varchar(10),COALESCE(bill_of_lading_number, id)) AS BOL,
		material_issuer AS MaterialIssuer,
		shipping_dock AS DockCode,
		trans_mode AS ShipperTransMode,
		ship_via AS ShipperSCAC,
		SUBSTRING(aetc_number,1,1) AS AETCReason,
		SUBSTRING(aetc_number,2,1) AS AETCResponsibility,
		SUBSTRING(aetc_number,3,10) AS AETCNumber,
		truck_number AS TrailerNumber,
		seal_number AS SealNumber,
		shipper.pro_number AS ProNumber	
		
FROM	dbo.shipper
JOIN	dbo.edi_setups ON dbo.shipper.destination = dbo.edi_setups.destination


GO

go
alter view dbo.vwft_Label_FinishedGoodsData_Formet
AS
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
		--	Fields on every label   
		-- 
			Serial = o.serial
		,	Quantity = CONVERT (INT, o.quantity)
		,	CustomerPart = COALESCE(oh.customer_part,lastsalesorder.customer_part, 'NoSalesOrderExists')
		--,	CompanyName = param.company_name
		--,	CompanyAddress1 = param.address_1
		--,	CompanyAddress2 = param.address_2
		--,	CompanyAddress3 = param.address_3
		--,	CompanyPhoneNumber = param.phone_number
		--
		--	Fields on some labels (all need case statements)...
		--
		--,	LicensePlate = case when rl.name in ('GM_Part','AMAXLE2') then 'UN' + es.supplier_code + '' + convert(varchar, o.serial) end
		--,	SerialCooper = case when rl.name in ('Cooper Part') then right(('000000000' + convert(varchar, o.serial)), 9) end
		,	PartNumber = o.part
		--,	UnitOfMeasure = CASE WHEN rl.name IN ('Formet') THEN o.unit_measure END
		--,	Location = case when rl.name in ('STD_WIP') then o.location end
		--,	Lot = case when rl.name in ('APT_BOX','AMAXLE2','Borg Part Label','STD_WIP') then o.lot end
		--,	Operator = case when rl.name in ('STD_WIP') then o.operator end
		,	MfgDate =  CONVERT(VARCHAR(10), COALESCE(atFirst.date_stamp, o.last_date), 101) 
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
		,	PartName =  p.name 
		--,	Customer = oh.customer
		,	DockCode =  COALESCE(oh.dock_code, lastsalesorder.dock_code) 
		--,	ZoneCode = case when rl.name in ('AMAXLE2','DCX_Part','Ford_Part Container','MPTMuncie_Box') then oh.zone_code end
		--,	LineFeedCode = case when rl.name in ('Ford_Part Container','MITSUBISHI_RAN') then oh.line_feed_code end
		--,	Line11 = case when rl.name in ('GM_Part') then oh.line11 end -- Material Handling Code
		--,	Line12 =case when rl.name in ('GM_Part') then oh.line12 end --Plant/Dock on GM Label
		--,	Line13 = oh.line13
		--,	Line14 = case when rl.name in ('GM_Part') then oh.line14 end
		--,	Line15 = case when rl.name in ('GM_Part') then oh.line15 end
		--,	Line16 = oh.line16
		--,	Line17 = case when rl.name in ('GM_Part') then oh.line17 end
		--,	SupplierCode = CASE WHEN rl.name IN ('Formet') THEN  COALESCE(es.supplier_code, lastsalesorder.supplier_code) END
		--,	Shipper = case when rl.name in ('Borg Part Label') then sd.shipper end
		--,	CustomerPO = CASE WHEN rl.name IN ('Formet') THEN oh.customer_po END
		--,	EngineeringLevel = case when rl.name in ('APT_BOX','AMAXLE2','Borg Part Label','CLBL','Cooper Part','DCX_Part','TSMStorage','NPG Part') then ecn.engineering_level end
		--,	DestinationID = CASE WHEN rl.name IN ('Formet') THEN es.parent_destination END
		--,	DestinationCode = CASE WHEN rl.name IN ('Formet') THEN oh.destination END
		--,	DestinationName = CASE WHEN rl.name IN ('Formet') THEN d.name END
		--,	DestinationAddress1 = CASE WHEN rl.name IN ('Formet') THEN d.address_1 END
		--,	DestinationAddress2 = CASE WHEN rl.name IN ('Formet') THEN d.address_2 END
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
		FROM
			dbo.object o
			LEFT JOIN (SELECT MAX(engineering_level) AS engineering_level, part AS ecn_part FROM dbo.effective_change_notice GROUP BY part) ecn ON
				ecn.ecn_part = o.part
			LEFT JOIN dbo.shipper s
				JOIN dbo.shipper_detail sd
					ON sd.shipper = s.id
				ON s.id = COALESCE(o.shipper, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT (INT, o.origin) END)
				AND sd.part_original = o.part
			LEFT JOIN dbo.order_header oh ON
				oh.order_no = COALESCE(sd.order_no, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT(INT, o.origin) END)
				AND oh.blanket_part = o.part
			LEFT JOIN dbo.destination d ON
				d.destination = COALESCE(s.destination, oh.destination, o.destination)
			LEFT JOIN dbo.edi_setups es ON
				es.destination = COALESCE(s.destination, oh.destination, o.destination)
		LEFT JOIN 
				(SELECT  TOP 100 PERCENT oh3.customer_part, oh3.customer, es3.parent_destination,  es3.supplier_code, d2.destination, d2.name, d2.address_1, d2.address_2, d2.address_3, d2.address_4, d2.address_5, oh3.blanket_part, oh3.dock_code
						FROM order_header oh3 
						JOIN edi_setups es3 ON es3.destination = oh3.destination
						JOIN 	destination d2 ON d2.destination = es3.destination
						WHERE oh3.destination =  'TFORM01'  AND oh3.order_no  IN  ( SELECT MAX(order_no) FROM order_header oh4 WHERE oh4.destination = 'TFORM01' GROUP BY oh4.blanket_part ) 
						ORDER BY oh3.order_no DESC
                    ) Lastsalesorder ON lastsalesOrder.blanket_part = o.part
			JOIN dbo.part p ON
				p.part = o.part
			JOIN dbo.part_inventory pi ON
				pi.part = p.part
			JOIN dbo.report_library rl ON
				rl.name = COALESCE(oh.box_label, pi.label_format)
			LEFT JOIN
				(	SELECT
						atFirst.serial
					--,	atFirst.RowCreateDT
					  , atFirst.date_stamp
					FROM
						dbo.audit_trail atFirst
					WHERE
						--atFirst.RowID =
						atFirst.date_stamp =
							(	SELECT
							 		--min(RowID)
							 		MIN(date_stamp)
							 	FROM
							 		dbo.audit_trail
								WHERE
									serial = atFirst.serial ) ) atFirst
				ON atFirst.serial = o.serial
			CROSS JOIN dbo.parameters param
	) rawLabelData



GO

go
alter view dbo.vwft_Label_FinishedGoodsData_Master_Formet
AS
/*	Do not modify this view without making sure you test performance before and after.
			1) All rows in < 10 seconds.
select
	*
from
	[dbo].[vwft_Label_FinishedGoodsData_Master_Formet_Test] lfgdmn

			2) Single row in <= 1 second.
select
	*
from
	[dbo].[vwft_Label_FinishedGoodsData_Master_Formet_Test] lfgdmn
where
	lfgdmn.Serial = 1940605

			3) Shipper list < 3 seconds.

select
	*
from
	dbo.Shipping_OpenShipperList sosl

*/
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
			ShipperID = oPallet.shipper
			,Serial = oPallet.serial
		--,	PalletSerialCooper = case when rl.name in ('Cooper Master') then right(('000000000' + convert(varchar, oPallet.serial)), 9) end
		--,	LotNumber = case when rl.name in ('APT_MASTER') then oBoxOnPallet.FirstLot end
		--,	LicensePlate = case when rl.name in ('AMAXLE_MASTER','GM_Master') then 'UN' + es.supplier_code + '' + convert(varchar, oPallet.serial) end
		--,	MfgDate = case when rl.name in ('Cooper Master') then convert(varchar(10), coalesce(atFirst.RowCreateDT, oPallet.last_date), 101) end 
		--,	MfgDateMM = case when rl.name in ('Ford_Master') then convert(varchar(6), coalesce(atFirst.RowCreateDT, oPallet.last_date), 12) end
		--,	MfgDateMMM = case when rl.name in ('Ford_Master') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '')) end
		--,	MfgDateMMMDashes = case when rl.name in ('APT_MASTER') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '-')) end
		,	UM =  oBoxOnPallet.FirstUM
		--,	PalletNetWeight = case when rl.name in ('NPG Master') then round(oBoxOnPallet.BoxTotalNetWeight, 2) end
		--,	PalletGrossWeight = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then round(coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PalletGrossWeightKG = case when rl.name in ('GM_Master') then round((coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0))/ 2.2, 0) end
		--,	PalletTareWeight = case when rl.name in ('AMAXLE_MASTER') then round(coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		,	PartCode =  oBoxOnPallet.FirstPart
		--,	WorkorderPartCode = case when rl.name in ('PALLET') then mjl.PartCode end
		,	PartName = pFirst.name
		,	PalletQty = COALESCE(oBoxOnPallet.PalletQty, 0) 
		--,	Boxes = case when rl.name in ('AMAXLE_MASTER','GM_Master') then oBoxOnPallet.BoxCount end
		--,	BoxQty = case when rl.name in ('GM_Master') then oBoxOnPallet.BoxQty end
		/*,	ECN = case when rl.name in ('AMAXLE_MASTER','APT_MASTER','Cooper Master') then
			(	select
					max(engineering_level)
				from
					effective_change_notice
				where
					part = oBoxOnPallet.FirstPart
					and effective_date =
					(	select
							max(e.effective_date)
						from
							effective_change_notice e
						where
							e.part = oBoxOnPallet.FirstPart
					)
			) end */
		--,	CustomerPO = case when rl.name in (/*'AMAXLE_MASTER',*/'Cooper Master') then oh.customer_po end
		,	CustomerPart = COALESCE(oh.customer_part,lastsalesorder.customer_part, 'NoSalesOrderExists')
		,	ShipToID = COALESCE(es.parent_destination, lastsalesorder.parent_destination )
		,	ShipToCode = COALESCE(oh.destination, lastsalesorder.destination)
		,	SupplierCode = COALESCE(es.supplier_code, lastsalesorder.supplier_code)
		,	ShipToName = COALESCE(d.name, lastsalesorder.name)
		,	ShipToAddress1 = COALESCE(d.address_1, lastsalesorder.address_1)
		,	ShipToAddress2 = COALESCE(d.address_2, lastsalesorder.address_2)
		--,	ShipToAddress3 = case when rl.name in ('AMAXLE_MASTER','NPG Master') then d.address_3 end
		--,	ShipToAddress4 = case when rl.name in ('AMAXLE_MASTER') then d.address_4 end
		--,	PoolCode = case when rl.name in ('DCX_Master') then es.pool_code end
		--,	Custom5 = case when rl.name in ('AMAXLE_MASTER') then oBoxOnPallet.FirstCustom5 end
		,	DockCode = COALESCE(oh.dock_code, lastsalesorder.dock_code)
		--,	LineFeedCode = case when rl.name in ('Ford_Master') then oh.line_feed_code end
		--,	ZoneCode = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then oh.zone_code end
		--,	Line11 = case when rl.name in ('GM_Master') then oh.line11 end -- material handling code
		--,	Line12 =case when rl.name in ('GM_Master') then oh.line12 end --Plant/Dock on GM Master Label
		--,	Location = case when rl.name in ('PALLET') then oPallet.location end
		--,	ContainerType = case when rl.name in ('Ford_Master') then oPallet.package_type end
		--,	CompanyName = case when rl.name in ('Benteler Master') then parm.company_name end
		--,	CompanyAddress1 = case when rl.name in ('Benteler Master') then parm.address_1 end
		--,	CompanyAddress2 = case when rl.name in ('Benteler Master') then parm.address_2 end
		--,	CompanyAddress3 = case when rl.name in ('Benteler Master') then parm.address_3 end
		--,	PhoneNumber = case when rl.name in ('AMAXLE_MASTER','GM_Master') then parm.phone_number end
		,	MasterMixed =	CASE	
								WHEN (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) > 1 THEN 'MIXED'
								WHEN (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) = 1 THEN 'MASTER'
								ELSE 'NO SERIALS ARE ON PALLET'
							END 
		,	PalletLabelFormat = rl.name
		FROM
			dbo.object oPallet
				LEFT JOIN
					(	SELECT
							oBoxes.parent_serial
						,	PalletQty = SUM(oBoxes.std_quantity)
						,	BoxCount = COUNT(*)
						,	FirstSerial = MIN(oBoxes.serial)
						,	FirstLot = MIN(oBoxes.lot)
						,	FirstUM = MIN(oBoxes.unit_measure)
						,	FirstPart = MIN(oBoxes.part)
						,	FirstCustom5 = MIN(oBoxes.custom5)
						,	BoxQty = MAX(oBoxes.std_quantity)
						,	BoxTotalTareWeight = SUM(oBoxes.tare_weight)
						,	BoxTotalNetWeight = SUM(oBoxes.weight)
						,	BoxShipper = MAX(oBoxes.shipper)
						,	BoxOrigin = MAX(CASE WHEN oBoxes.origin NOT LIKE '%[^0-9]%' AND LEN(oBoxes.origin) < 10 THEN CONVERT (INT, oBoxes.origin) END)
						FROM
							dbo.object oBoxes
						WHERE
							oBoxes.parent_serial IS NOT NULL
							AND part != 'PALLET'
						GROUP BY
							oBoxes.parent_serial
					) oBoxOnPallet ON
					oBoxOnPallet.parent_serial = oPallet.serial
				LEFT JOIN dbo.part pFirst
					ON pFirst.part = oBoxOnPallet.FirstPart
			LEFT JOIN shipper_detail sd
				ON sd.shipper = COALESCE(oBoxOnPallet.BoxShipper, oBoxOnPallet.BoxOrigin)
				AND sd.part_original = oBoxOnPallet.FirstPart
			LEFT JOIN order_header oh
					LEFT JOIN customer c
						ON c.customer = oh.customer
					LEFT JOIN destination d
						ON d.destination = oh.destination
					LEFT JOIN edi_setups es
						ON es.destination = oh.destination
				ON oh.order_no = COALESCE(sd.order_no, oBoxOnPallet.BoxOrigin)
			LEFT JOIN 
				(SELECT  TOP 100 PERCENT oh3.customer_part, oh3.customer, es3.parent_destination,  es3.supplier_code, d2.destination, d2.name, d2.address_1, d2.address_2, d2.address_3, d2.address_4, d2.address_5, oh3.blanket_part, oh3.dock_code
						FROM order_header oh3 
						JOIN edi_setups es3 ON es3.destination = oh3.destination
						JOIN 	destination d2 ON d2.destination = es3.destination
						WHERE oh3.destination =  'TFORM01'  AND oh3.order_no  IN  ( SELECT MAX(order_no) FROM order_header oh4 WHERE oh4.destination = 'TFORM01' GROUP BY oh4.blanket_part ) 
						ORDER BY oh3.order_no DESC
                    ) Lastsalesorder ON lastsalesOrder.blanket_part = oBoxOnPallet.FirstPart
			JOIN dbo.report_library rl ON
				rl.name = COALESCE(oh.pallet_label, 'PALLET')
			LEFT JOIN
				(	SELECT
						atFirst.serial
					--,	atFirst.RowCreateDT
					  , atFirst.date_stamp
					FROM
						dbo.audit_trail atFirst
					WHERE
						--atFirst.RowID =
						atFirst.date_stamp =
							(	SELECT
									--min(at.RowID)
									MIN(at.date_stamp)
								FROM
									dbo.audit_trail at
								WHERE
									at.serial = atFirst.serial ) ) atFirst
				ON atFirst.serial = oPallet.serial
			CROSS JOIN dbo.parameters parm
		WHERE
			oPallet.type = 'S'
	) rawLabelData








GO

go
alter view dbo.vwft_Label_FinishedGoodsData_Master_Formet_backup20181009
AS
/*	Do not modify this view without making sure you test performance before and after.
			1) All rows in < 10 seconds.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn

			2) Single row in <= 1 second.
select
	*
from
	custom.Label_FinishedGoodsData_Master lfgdmn
where
	lfgdmn.Serial = 1607091

			3) Shipper list < 3 seconds.

select
	*
from
	dbo.Shipping_OpenShipperList sosl

*/
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
			ShipperID = oPallet.shipper
			,Serial = oPallet.serial
		--,	PalletSerialCooper = case when rl.name in ('Cooper Master') then right(('000000000' + convert(varchar, oPallet.serial)), 9) end
		--,	LotNumber = case when rl.name in ('APT_MASTER') then oBoxOnPallet.FirstLot end
		--,	LicensePlate = case when rl.name in ('AMAXLE_MASTER','GM_Master') then 'UN' + es.supplier_code + '' + convert(varchar, oPallet.serial) end
		--,	MfgDate = case when rl.name in ('Cooper Master') then convert(varchar(10), coalesce(atFirst.RowCreateDT, oPallet.last_date), 101) end 
		--,	MfgDateMM = case when rl.name in ('Ford_Master') then convert(varchar(6), coalesce(atFirst.RowCreateDT, oPallet.last_date), 12) end
		--,	MfgDateMMM = case when rl.name in ('Ford_Master') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '')) end
		--,	MfgDateMMMDashes = case when rl.name in ('APT_MASTER') then upper(replace(convert(varchar, coalesce(atFirst.RowCreateDT, oPallet.last_date), 106), ' ', '-')) end
		,	UM =  oBoxOnPallet.FirstUM
		--,	PalletNetWeight = case when rl.name in ('NPG Master') then round(oBoxOnPallet.BoxTotalNetWeight, 2) end
		--,	PalletGrossWeight = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then round(coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PalletGrossWeightKG = case when rl.name in ('GM_Master') then round((coalesce(oBoxOnPallet.BoxTotalNetWeight, 0) + coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0))/ 2.2, 0) end
		--,	PalletTareWeight = case when rl.name in ('AMAXLE_MASTER') then round(coalesce(oBoxOnPallet.BoxTotalTareWeight, 0) + coalesce(oPallet.tare_weight, 0), 2) end
		--,	PartCode = case when rl.name in ('APT_MASTER','Ford_Master') then oBoxOnPallet.FirstPart end
		--,	WorkorderPartCode = case when rl.name in ('PALLET') then mjl.PartCode end
		,	PartName = pFirst.name
		,	PalletQty = COALESCE(oBoxOnPallet.PalletQty, 0) 
		--,	Boxes = case when rl.name in ('AMAXLE_MASTER','GM_Master') then oBoxOnPallet.BoxCount end
		--,	BoxQty = case when rl.name in ('GM_Master') then oBoxOnPallet.BoxQty end
		/*,	ECN = case when rl.name in ('AMAXLE_MASTER','APT_MASTER','Cooper Master') then
			(	select
					max(engineering_level)
				from
					effective_change_notice
				where
					part = oBoxOnPallet.FirstPart
					and effective_date =
					(	select
							max(e.effective_date)
						from
							effective_change_notice e
						where
							e.part = oBoxOnPallet.FirstPart
					)
			) end */
		--,	CustomerPO = case when rl.name in (/*'AMAXLE_MASTER',*/'Cooper Master') then oh.customer_po end
		,	CustomerPart = oh.customer_part
		,	ShipToID = es.parent_destination 
		,	ShipToCode = oh.destination
		,	SupplierCode = es.supplier_code
		,	ShipToName = d.name 
		,	ShipToAddress1 = d.address_1
		,	ShipToAddress2 = d.address_2
		--,	ShipToAddress3 = case when rl.name in ('AMAXLE_MASTER','NPG Master') then d.address_3 end
		--,	ShipToAddress4 = case when rl.name in ('AMAXLE_MASTER') then d.address_4 end
		--,	PoolCode = case when rl.name in ('DCX_Master') then es.pool_code end
		--,	Custom5 = case when rl.name in ('AMAXLE_MASTER') then oBoxOnPallet.FirstCustom5 end
		,	DockCode = oh.dock_code
		--,	LineFeedCode = case when rl.name in ('Ford_Master') then oh.line_feed_code end
		--,	ZoneCode = case when rl.name in (/*'AMAXLE_MASTER',*/'Ford_Master') then oh.zone_code end
		--,	Line11 = case when rl.name in ('GM_Master') then oh.line11 end -- material handling code
		--,	Line12 =case when rl.name in ('GM_Master') then oh.line12 end --Plant/Dock on GM Master Label
		--,	Location = case when rl.name in ('PALLET') then oPallet.location end
		--,	ContainerType = case when rl.name in ('Ford_Master') then oPallet.package_type end
		--,	CompanyName = case when rl.name in ('Benteler Master') then parm.company_name end
		--,	CompanyAddress1 = case when rl.name in ('Benteler Master') then parm.address_1 end
		--,	CompanyAddress2 = case when rl.name in ('Benteler Master') then parm.address_2 end
		--,	CompanyAddress3 = case when rl.name in ('Benteler Master') then parm.address_3 end
		--,	PhoneNumber = case when rl.name in ('AMAXLE_MASTER','GM_Master') then parm.phone_number end
		,	MasterMixed =	CASE	
								WHEN (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) > 1 THEN 'MIXED'
								WHEN (SELECT COUNT(DISTINCT part) FROM object WHERE parent_serial = oPallet.serial) = 1 THEN 'MASTER'
								ELSE 'NO SERIALS ARE ON PALLET'
							END 
		,	PalletLabelFormat = rl.name
		FROM
			dbo.object oPallet
				LEFT JOIN
					(	SELECT
							oBoxes.parent_serial
						,	PalletQty = SUM(oBoxes.std_quantity)
						,	BoxCount = COUNT(*)
						,	FirstSerial = MIN(oBoxes.serial)
						,	FirstLot = MIN(oBoxes.lot)
						,	FirstUM = MIN(oBoxes.unit_measure)
						,	FirstPart = MIN(oBoxes.part)
						,	FirstCustom5 = MIN(oBoxes.custom5)
						,	BoxQty = MAX(oBoxes.std_quantity)
						,	BoxTotalTareWeight = SUM(oBoxes.tare_weight)
						,	BoxTotalNetWeight = SUM(oBoxes.weight)
						,	BoxShipper = MAX(oBoxes.shipper)
						,	BoxOrigin = MAX(CASE WHEN oBoxes.origin NOT LIKE '%[^0-9]%' AND LEN(oBoxes.origin) < 10 THEN CONVERT (INT, oBoxes.origin) END)
						FROM
							dbo.object oBoxes
						WHERE
							oBoxes.parent_serial IS NOT NULL
						GROUP BY
							oBoxes.parent_serial
					) oBoxOnPallet ON
					oBoxOnPallet.parent_serial = oPallet.serial
				LEFT JOIN dbo.part pFirst
					ON pFirst.part = oBoxOnPallet.FirstPart
			LEFT JOIN shipper_detail sd
				ON sd.shipper = COALESCE(oBoxOnPallet.BoxShipper, oBoxOnPallet.BoxOrigin)
				AND sd.part_original = oBoxOnPallet.FirstPart
			LEFT JOIN order_header oh
					LEFT JOIN customer c
						ON c.customer = oh.customer
					LEFT JOIN destination d
						ON d.destination = oh.destination
					LEFT JOIN edi_setups es
						ON es.destination = oh.destination
				ON oh.order_no = COALESCE(sd.order_no, oBoxOnPallet.BoxOrigin)
			--left join dbo.Mes_JobList mjl
			--	on mjl.WorkOrderNumber = oPallet.workorder
			JOIN dbo.report_library rl ON
				rl.name = COALESCE(oh.pallet_label, 'PALLET')
			LEFT JOIN
				(	SELECT
						atFirst.serial
					--,	atFirst.RowCreateDT
					  , atFirst.date_stamp
					FROM
						dbo.audit_trail atFirst
					WHERE
						--atFirst.RowID =
						atFirst.date_stamp =
							(	SELECT
									--min(at.RowID)
									MIN(at.date_stamp)
								FROM
									dbo.audit_trail at
								WHERE
									at.serial = atFirst.serial ) ) atFirst
				ON atFirst.serial = oPallet.serial
			CROSS JOIN dbo.parameters parm
		WHERE
			oPallet.type = 'S'
	) rawLabelData







GO

go
alter view FT.vwBOM
(	BOMID
,	ParentPart
,	ChildPart
,	StdQty
,	ScrapFactor
,	SubstitutePart
)
as
	--	Description:
	--	Use bill_of_material view because it only pulls current records.
	select
		BOMID = row_number() over (order by parent_part, part) -- id
	,	ParentPart = parent_part
	,	ChildPart = part
	,	StdQty = std_qty
	,	ScrapFactor = 0 --scrap_factor
	,	SubstitutePart = convert(bit, case when coalesce(substitute_part, 'N') = 'Y' then 1 else 0 end)
	from
		dbo.bill_of_material
	where
		isnull(std_qty, 0) > 0
GO

go
alter view FT.vwPRt
(	Part
,	BufferTime
,	RunRate
,	CrewSize
)
as
	--	Description:
	--	Use part_mfg view because it only pulls primary machine.
	select
		Part = Part.part
	,	BufferTime = 1
	,	RunRate = coalesce(min(1 / nullif(part_machine.parts_per_hour, 0)), 9999)
	,	CrewSize = coalesce(min(part_machine.crew_size), 0)
	from
		dbo.part Part
		left outer join dbo.part_machine part_machine
			on Part.part = part_machine.part
			   and part_machine.sequence = 1
	group by
		Part.part
	having
		count(1) = 1
GO

go