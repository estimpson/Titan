SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










--Select * From  [dbo].[Label_FinishedGoodsData]

CREATE PROCEDURE  [dbo].[Ftsp_LabelFinishedGoodsData] (@serial VARCHAR(25)) --2901027
AS

BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF
 

 -- [dbo].[Ftsp_LabelFinishedGoodsData] 2881771
 --ASB FT, LLC 02/26/2019 : If line12 data no populated with data use EDI plant code

DECLARE		@Shipper INT,
						@LastSalesOrder INT,
						@Part VARCHAR(25),
						@Origin INT

Select @Shipper = ( SELECT shipper
								 FROM object
								 JOIN	shipper ON shipper.id = object.shipper AND shipper.status IN ( 'O', 'S') 
									WHERE object.serial = @serial and ISNULL(shipper,0) > 0)
Select @Origin = ( SELECT ISNULL(origin,0)
								 FROM object
								 JOIN	shipper ON shipper.id = object.shipper AND shipper.status IN ( 'O', 'S') 
									WHERE object.serial = @serial and ISNULL(shipper,0) > 0
									AND ISNUMERIC(object.origin) = 1)
SELECT  @part =  ( SELECT part FROM object  WHERE object.serial = @serial)
Select  @LastSalesOrder =  (SELECT TOP 1 order_no FROM order_header WHERE blanket_part =  @Part ORDER BY order_no desc)
  
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
		--	Fields on every label    
			Serial = o.serial
		,	Quantity = CONVERT (INT, o.quantity)
		,	CustomerPart = COALESCE(oh.customer_part, oh2.customer_part)
		,	CompanyName = param.company_name
		,	CompanyAddress1 = param.address_1
		,	CompanyAddress2 = param.address_2
		,	CompanyAddress3 = param.address_3
		,	CompanyPhoneNumber = param.phone_number
		--	Fields on some labels ...
		,	LicensePlate = 'UN' + COALESCE(es.supplier_code, es2.supplier_code) + '' + CONVERT(VARCHAR, o.serial) 
		--,	SerialThreeDigitTesla = CONVERT(CHAR(3), RIGHT(o.serial, 3))
		--,	SerialTenDigitTesla = RIGHT(('0000000000' + CONVERT(VARCHAR, o.serial)), 10)
		--,	SerialCooper =  RIGHT(('000000000' + CONVERT(VARCHAR, o.serial)), 9)
		--,	SerialPaddedNineNines =  RIGHT(('999999999' + CONVERT(VARCHAR, o.serial)), 9)
		,	EDISetupsparentDestination = COALESCE(es.parent_destination, es2.parent_destination)
		,	EDISetupsMaterialIssuer = COALESCE(es.material_issuer, es2.material_issuer)
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
		,	DockCode =  COALESCE(oh.dock_code, oh2.dock_code)
		,	ZoneCode = COALESCE(oh.zone_code, oh2.dock_code)
		,	LineFeedCode = COALESCE(oh.line_feed_code, oh2.dock_code)
		,	Line11 = COALESCE(oh.line11, oh2.line11) -- Material Handling Code
		,	Line12 =COALESCE(NULLIF(oh.line12,''), NULLIF(oh2.line12,''),es.ediShipToID, es.parent_destination, es2.EDIShipToID, es2.parent_destination, RIGHT(es.destination,5),RIGHT(es2.destination,5) )  --Plant/Dock on GM Label
		,	Line13 = COALESCE(oh.line13, oh2.line13)
		,	Line14 = COALESCE(oh.line14, oh2.line14)
		,	Line15 = COALESCE(oh.line15, oh2.line15)
		,	Line16 = COALESCE(oh.line16, oh2.line16)
		,	Line17 = COALESCE(oh.line17, oh2.line17)
		,	BTM = oh.contact
		,	SupplierCode = COALESCE(es.supplier_code, es2.supplier_code)
		,	MaterialIssuer = COALESCE(es.material_issuer, es2.material_issuer)
		,	Shipper = sd.shipper
		,	CustomerPO =  COALESCE(sd.customer_po, oh2.customer_po)
		,	EngineeringLevel =  COALESCE(oh.engineering_level, oh2.engineering_level)
		,	Destination = COALESCE(oh.destination, oh2.destination)
		,	DestinationName = COALESCE(d.name, d2.name)
		,	DestinationAddress1 = COALESCE(d.address_1, d2.address_1)
		,	DestinationAddress2 = COALESCE(d.address_2, d2.address_2)
		,	DestinationAddress3 = COALESCE(d.address_3, d2.address_3)
		,	DestinationAddress4 = COALESCE(d.address_4, d2.address_4)
		,	ObjectKANBAN = COALESCE(o.kanban_number, '') 
		,	ObjectCustom5 = COALESCE(o.custom5, '')
		,	ShipToID = COALESCE(es.ediShipToID, es.parent_destination, es2.EDIShipToID, es2.parent_destination, es.destination,es2.destination)
		,	PO_or_Release =   
				CASE
				WHEN NULLIF(sd.customer_po,'') IS NULL
				THEN sd.release_no 
				ELSE sd.customer_po 
				END
				
		,	ReleaseNumber =  sd.release_no
		,	ShipperDateStamp = s.date_stamp
		--,	DecoPlasBarcode = 'A'+oh.customer_part +'  '+'00'+CONVERT(VARCHAR(15), CONVERT(INT, o.quantity))+'.000'+'EA'+'A'+CONVERT(VARCHAR(15),o.serial)
		--,	OHCustom01 = oh.custom01
		--,	OHcustom02 = oh.custom02
		--,	OHCustom03 = oh.custom03
		--,	TeslaShipDate = COALESCE(CONVERT(VARCHAR(8), s.date_stamp, 112), CONVERT(VARCHAR(8), GETDATE(), 112) ) -- YYYYMMDD
		--,	TeslaQuantity = RIGHT('000000' + CONVERT(VARCHAR(6), CONVERT(INT, o.quantity) ), 6 )
		--,	TeslaCustomerPart = RIGHT('0000000000' + REPLACE(REPLACE(oh.customer_part, '-', ''), ' ', ''), 10 )
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
		, @Shipper AS ShipperID
		, @LastSalesOrder AS LastOrderNo
		, SafetyPart = COALESCE(NULLIF(pi.safety_part,''), 'N')
		FROM
			dbo.OBJECT o
		LEFT JOIN dbo.shipper s
				JOIN dbo.shipper_detail sd
					ON sd.shipper = s.id
				ON s.id = COALESCE(@Shipper, @Origin)
				AND sd.part_original = o.part
			LEFT JOIN dbo.order_header oh ON
				oh.order_no = sd.order_no
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
			LEFT JOIN order_header oh2 ON oh2.order_no = @LastSalesOrder
			LEFT JOIN edi_setups es2 ON es2.destination = oh2.destination
			LEFT JOIN dbo.destination d2 ON d2.destination = oh2.destination
			CROSS JOIN dbo.parameters param
			WHERE o.serial = CONVERT(INT, @serial)
	) rawLabelData


	END


















GO
