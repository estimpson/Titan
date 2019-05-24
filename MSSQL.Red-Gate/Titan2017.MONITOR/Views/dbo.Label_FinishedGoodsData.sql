SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







Create VIEW [dbo].[Label_FinishedGoodsData]
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
