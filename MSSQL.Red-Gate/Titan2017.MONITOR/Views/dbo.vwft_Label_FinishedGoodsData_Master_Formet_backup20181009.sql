SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[vwft_Label_FinishedGoodsData_Master_Formet_backup20181009]
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
