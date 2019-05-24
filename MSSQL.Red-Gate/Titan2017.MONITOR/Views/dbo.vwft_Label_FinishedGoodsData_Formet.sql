SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwft_Label_FinishedGoodsData_Formet]
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
