SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [custom].[Label_FinishedGoodsData_Master]
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
