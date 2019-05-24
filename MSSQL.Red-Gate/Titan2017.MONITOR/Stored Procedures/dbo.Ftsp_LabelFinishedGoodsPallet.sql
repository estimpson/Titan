SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











--Select * From  [dbo].[Label_FinishedGoodsData]

CREATE PROCEDURE  [dbo].[Ftsp_LabelFinishedGoodsPallet] (@serial VARCHAR(25)) --2901027
AS

BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF

-- [dbo].[Ftsp_LabelFinishedGoodsPallet] 2952577
 

 -- [dbo].[Ftsp_LabelFinishedGoodsData] 2901027
DECLARE		@Shipper INT,
						@LastSalesOrder INT,
						@Part VARCHAR(25),
						@Origin INT,
						@MasterMixed VARCHAR(25),
						@MasterQuantity INT,
						@FirstSerial INT,
						@palletGrossWeightKG INT,
						@NoOfBoxes INT,
						@PackQty INT,
						@Mixedpart1 VARCHAR(25),
						@Mixedpartqty1 INT,
						@Mixedpartcountqty1 INT,
						@Mixedpartqtytotal1 INT,
						@Mixedpart2 VARCHAR(25),
						@Mixedpartqty2 INT,
						@Mixedpartcountqty2 INT,
						@Mixedpartqtytotal2 INT,
						@Mixedpart3 VARCHAR(25),
						@Mixedpartqty3 INT,
						@Mixedpartcountqty3 INT,
						@Mixedpartqtytotal3 INT,
						@Mixedpart4 VARCHAR(25),
						@Mixedpartqty4 INT,
						@Mixedpartcountqty4 INT,
						@Mixedpartqtytotal4 INT,
						@Mixedpart5 VARCHAR(25),
						@Mixedpartqty5 INT,
						@Mixedpartcountqty5 INT,
						@Mixedpartqtytotal5 INT,
						@Mixedpart6 VARCHAR(25),
						@Mixedpartqty6 INT,
						@Mixedpartcountqty6 INT,
						@Mixedpartqtytotal6 INT


Select @Shipper = ( SELECT TOP 1 shipper
								 FROM object
								 JOIN	shipper ON shipper.id = object.shipper AND shipper.status IN ( 'O', 'S') 
									WHERE object.parent_serial = @serial and ISNULL(shipper,0) > 0)
Select @Origin = ( SELECT TOP 1 ISNULL(origin,0)
								 FROM object
								 JOIN	shipper ON shipper.id = object.shipper AND shipper.status IN ( 'O', 'S') 
									WHERE object.parent_serial = @serial and ISNULL(shipper,0) > 0
									AND ISNUMERIC(object.origin) = 1)

SELECT  @part =  ( SELECT TOP 1 part FROM object  WHERE object.parent_serial = @serial)
Select  @LastSalesOrder =  (SELECT TOP 1 order_no FROM order_header WHERE blanket_part =  @Part ORDER BY order_no desc)

SELECT @MasterMixed = (SELECT COUNT(DISTINCT part )FROM object WHERE parent_serial = @serial AND part!='PALLET')
SELECT @FirstSerial =  ( SELECT TOP 1 serial FROM object WHERE parent_serial = @serial )
SELECT @MasterQuantity = ( SELECT SUM(quantity) FROM object WHERE parent_serial =  @serial AND part!= 'PALLET' )
SELECT @palletGrossWeightKG = ( SELECT SUM(object.weight + object.tare_weight)/2.2 FROM object WHERE parent_serial =  @serial AND part!= 'PALLET' )
SELECT @palletGrossWeightKG = ( SELECT SUM(object.weight + object.tare_weight)/2.2 FROM object WHERE parent_serial =  @serial AND part!= 'PALLET' )
SELECT @NoOfBoxes = ( SELECT COUNT(1) FROM object WHERE parent_serial =  @serial AND part!= 'PALLET' )
SELECT @PackQty = ( SELECT TOP 1 quantity FROM object WHERE parent_serial =  @serial AND part!= 'PALLET'  ORDER BY serial desc)
  
  
  --12/15/2018 Asb ft, llc 
  
  
  IF @MasterMixed>1
  BEGIN
   CREATE TABLE  #PartQty
(	ID INT IDENTITY(1,1),
	part VARCHAR(50),
	partpackcount INT,
	partpack INT,
	totalpartqtyperpack INT
)

   CREATE TABLE  #LastOrders
(	lastorderNo INT,
	blanketpart VARCHAR(50),
	customerpart VARCHAR(50)
)

INSERT #LastOrders
SELECT MAX(oh.order_no) 
			,oh.blanket_part
			,oh.customer_part
FROM	order_header oh
JOIN
		object o ON o.part = oh.blanket_part 
		AND o.parent_serial = @serial
GROUP BY oh.blanket_part, oh.customer_part


INSERT #PartQty
        ( part, partpackcount, partpack, totalpartqtyperpack)

	SELECT	TOP 6 
					COALESCE(oh.customer_part, oh2.customerpart),
					COUNT(1),
					O.quantity,
					partpackttlqty =  ( SELECT  SUM(Oa.quantity) partpackttlqty FROM object oa WHERE oa.parent_serial = O.parent_serial AND oa.part = O.part AND oa.quantity = O.quantity ) 
		FROM 
			dbo.object O
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
			LEFT JOIN #LastOrders oh2 ON oh2.blanketpart = p.part
			WHERE parent_serial = @serial
		AND
			O.part !='PALLET'
		GROUP BY O.part, O.quantity, parent_serial, COALESCE(oh.customer_part, oh2.customerpart)
		ORDER BY O.part, O.quantity

		SELECT @Mixedpart1 = part FROM #PartQty WHERE ID =1
		SELECT @Mixedpartqty1 = partpack FROM #PartQty WHERE ID =1
		SELECT @Mixedpartqtytotal1 = totalpartqtyperpack FROM #PartQty WHERE ID =1
		SELECT @Mixedpartcountqty1  = partpackcount  FROM #PartQty WHERE ID =1
		SELECT @Mixedpart2 = part FROM #PartQty WHERE ID =2
		SELECT @Mixedpartqty2 = partpack FROM #PartQty WHERE ID =2
		SELECT @Mixedpartqtytotal2 = totalpartqtyperpack FROM #PartQty WHERE ID =2
		SELECT @Mixedpartcountqty2  = partpackcount  FROM #PartQty WHERE ID =2
		SELECT @Mixedpart3 = part FROM #PartQty WHERE ID =3
		SELECT @Mixedpartqty3 = partpack FROM #PartQty WHERE ID =3
		SELECT @Mixedpartqtytotal3 = totalpartqtyperpack FROM #PartQty WHERE ID =3
		SELECT @Mixedpartcountqty3  = partpackcount  FROM #PartQty WHERE ID =3
		SELECT @Mixedpart4 = part FROM #PartQty WHERE ID =4
		SELECT @Mixedpartqty4 = partpack FROM #PartQty WHERE ID =4
		SELECT @Mixedpartqtytotal4 = totalpartqtyperpack FROM #PartQty WHERE ID =4
		SELECT @Mixedpartcountqty4  = partpackcount  FROM #PartQty WHERE ID =4
		SELECT @Mixedpart5 = part FROM #PartQty WHERE ID =5
		SELECT @Mixedpartqty5 = partpack FROM #PartQty WHERE ID =5
		SELECT @Mixedpartqtytotal5 = totalpartqtyperpack FROM #PartQty WHERE ID =5
		SELECT @Mixedpartcountqty5  = partpackcount  FROM #PartQty WHERE ID =5
		SELECT @Mixedpart6 = part FROM #PartQty WHERE ID =6
		SELECT @Mixedpartqty6 = partpack FROM #PartQty WHERE ID =6
		SELECT @Mixedpartqtytotal6 = totalpartqtyperpack FROM #PartQty WHERE ID =6
		SELECT @Mixedpartcountqty6  = partpackcount  FROM #PartQty WHERE ID =6


END 

--END 12/15/2018 Asb ft, llc
  

SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
		--	Fields on every label    
			Serial = @serial
		,	Quantity = @MasterQuantity
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
		, MasterMixed = @MasterMixed
		, MasterWeightKG = @palletGrossWeightKG
		, BoxCount = @NoOfBoxes
		, PackQty = @PackQty
		, Mixedpart1 = @Mixedpart1
		, Mixedpartqty1 =  @Mixedpartqty1
		, Mixedpartqtytotal1 = @Mixedpartqtytotal1
		, Mixedpartcountqty1 = @Mixedpartcountqty1
		, Mixedpart2 =  @Mixedpart2
		, Mixedpartqty2 =  @Mixedpartqty2
		, Mixedpartqtytotal2 = @Mixedpartqtytotal2
		, Mixedpartcountqty2 = @Mixedpartcountqty2
		, Mixedpart3 =  @Mixedpart3
		, Mixedpartqty3 =  @Mixedpartqty3
		, Mixedpartqtytotal3 =  @Mixedpartqtytotal3
		, Mixedpartcountqty3 = @Mixedpartcountqty3
		, Mixedpart4 =  @Mixedpart4
		, Mixedpartqty4 =  @Mixedpartqty4
		, Mixedpartqtytotal4 =  @Mixedpartqtytotal4
		, Mixedpartcountqty4 = @Mixedpartcountqty4
		, Mixedpart5 =  @Mixedpart5
		, Mixedpartqty5 =  @Mixedpartqty5
		, Mixedpartqtytotal5 =  @Mixedpartqtytotal5
		, Mixedpartcountqty5 = @Mixedpartcountqty5
		, Mixedpart6 =  @Mixedpart6
		, Mixedpartqty6 =  @Mixedpartqty6
		, Mixedpartqtytotal6 =  @Mixedpartqtytotal6
		, Mixedpartcountqty6 = @Mixedpartcountqty6



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
			WHERE o.serial = CONVERT(INT, @FirstSerial)
	) rawLabelData


	END



















GO
