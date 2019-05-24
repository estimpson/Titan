SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  PROCEDURE [dbo].[ftsp_EDI_ASN_Invoice_Modatec] @Shipper INT   AS
BEGIN

--exec ftsp_EDI_ASN_Invoice_Modatec 82195

/*

MG1_856_D_v4010_MAGNA^SI_130515


*/

SET ANSI_PADDING ON

DECLARE
	@TradingPartner	CHAR(12),
	@ShipperID CHAR(30),
	@ShipperID2 CHAR(11),
	@PartialComplete CHAR(1),
	@PurposeCode CHAR(2),
	@ASNDateYYMMDD CHAR(6),
	@ASNTimeHHMM CHAR(8),
	@ShippedDateYYMMDD CHAR(6),
	@ShippedTimeHHMM CHAR(4),
	@TimeCode CHAR(2),
	@Century CHAR(2),
	@ArrivalDateYYMMDD CHAR(6),
	@ArrivalTimeHHMM CHAR(4),
	@Mea01 CHAR(2),
	@Mea02G CHAR(3),
	@Mea02N CHAR(3),
	@GrossWeightLbs CHAR(12),
	@WeightUM CHAR(2),
	@NetWeightLbs CHAR(12),
	@PackagingCode CHAR(5),
	@PackCountHeader CHAR(8),
	@RoutingSequnceCodeTD501 CHAR(2),
	@IDCodeQualifierTD502 CHAR(2),
	@SCAC CHAR(17),
	@TransMode CHAR(2),
	@PPCode CHAR(7),
	@EquipDesc CHAR(2),
	@EquipInit CHAR(4),
	@TrailerNumber CHAR(10),
	@REFBMQual CHAR(3),
	@REFPKQual CHAR(3),
	@REFCNQual CHAR(3),
	@REFSTQual CHAR(2),
	@REFSUQual CHAR(2),
	@REF92Qual CHAR(2),
	@REF01Qual CHAR(2),
	@REFBMValue CHAR(20),
	@REFPKValue CHAR(20),
	@REFCNValue CHAR(20),
	@FOB CHAR(2),
	@ProNumber CHAR(16),
	@SealNumber CHAR(8),
	@N1QualifierST CHAR(3),
	@N1QualifierMI CHAR(3),
	@N1QualifierSU CHAR(3),
	@N1Type CHAR(3),
	@SupplierName CHAR(60),
	@SupplierCode CHAR(70),
	@ShipToName CHAR(60),
	@ShipToID CHAR(70),
	@MaterialIssuerName CHAR(60),
	@MaterialIssuerCode CHAR(70),
	@TimeZone CHAR(2),
	@AETCResponsibility CHAR(1),
	@AETC CHAR(8),
	@PoolCode CHAR(25),
	@EquipInitial CHAR(4),
	@DockCode CHAR(8),
	@PartialCompete CHAR(1),
	@ShippedDateQualifier CHAR(3),
	@ArrivalDateQualifier CHAR(3)
	
SELECT			@TradingPartner = COALESCE(NULLIF(trading_partner_code,''), 'MODATEK'),
				@PartialComplete = '',
				@PurposeCode = '00' ,
				@ShipperID= s.id,
				@ShipperID2 =s.id,
				@ASNDateYYMMDD = CONVERT (VARCHAR(25), GETDATE(), 12),
				@ASNTimeHHMM = LEFT(CONVERT (VARCHAR(25), GETDATE(), 24),2)+SUBSTRING(CONVERT (VARCHAR(25), GETDATE(), 24),4,2),
				@ShippedDateQualifier = '011',
				@ShippedDateYYMMDD =   CONVERT (VARCHAR(25), s.date_shipped, 12),
				@ShippedTimeHHMM = LEFT(CONVERT (VARCHAR(25), s.date_shipped, 24),2)+SUBSTRING(CONVERT (VARCHAR(25), s.date_shipped, 24),4,2),
				@TimeCode = [dbo].[udfGetDSTIndication](GETDATE()),
				@Century = LEFT(CONVERT (VARCHAR(25), GETDATE(), 12), 2),
				@ArrivalDateQualifier = '017',
				@ArrivalDateYYMMDD = CONVERT (VARCHAR(25), DATEADD(dd,CONVERT(INT, ISNULL(NULLIF(id_code_type,''),0)), s.date_shipped) , 12),
				@ArrivalTimeHHMM = LEFT(CONVERT (VARCHAR(25), DATEADD(dd,CONVERT(INT, ISNULL(NULLIF(id_code_type,''),0)), s.date_shipped), 24),2)+SUBSTRING(CONVERT (VARCHAR(25), DATEADD(dd,CONVERT(INT, ISNULL(NULLIF(id_code_type,''),0)), s.date_shipped), 24),4,2) ,
				@Mea01 = 'PD',
				@Mea02G = 'G',
				@Mea02N = 'N',
				@GrossWeightLbs = CONVERT( varchar(12), CONVERT(int, s.gross_weight)),
				@NetWeightLbs = CONVERT( varchar(12), CONVERT(int, s.net_weight)), 
				@WeightUM = 'LB',
				@SCAC  = COALESCE(s.ship_via, ''),
				@TransMode = COALESCE(s.trans_mode,''),
				@TrailerNumber = COALESCE(s.truck_number,CONVERT(VARCHAR(25), s.id)),
				@REFPKQual = 'PK',
				@REFBMQual = 'BM',
				@REFSTQual = 'ST',
				@REF92Qual = '92',
				@ShipToID =  COALESCE(parent_destination, s.destination) ,
				@REFSUQual = 'SU',
				@REF01Qual = '01',
				@N1QualifierMI = 'MI',
				@N1QualifierST = 'ST',
				@N1QualifierSU = 'SU',
				@N1Type = '92',
				@SupplierCode = COALESCE(es.supplier_code,'5199661234'),
				@SupplierName = 'Titan Tool & Die Limited',
				@MaterialIssuerCode = COALESCE(es.material_issuer,'253990576P'),
				@MaterialIssuerName = 'MODATEK SYSTEMS',
				@ShipToID = COALESCE(es.parent_destination, '253990576P'),
				@ShipToName = LEFT(d.name,35),
				@packagingCode = 'CNT90',
				@PackCountHeader = s.staged_objs,
				@REFBMValue = COALESCE(s.bill_of_lading_number, s.id),
				@RefPKValue = s.id,
				@EquipDesc = 'TL',
				@RoutingSequnceCodeTD501 = 'B',
				@IDCodeQualifierTD502 = '2'
FROM
		Shipper s
	JOIN
		dbo.edi_setups es ON s.destination = es.destination
	JOIN
		dbo.destination d ON es.destination = d.destination
	LEFT JOIN
		dbo.bill_of_lading bol ON s.bill_of_lading_number = bol_number
	WHERE
		s.id = @shipper
	
--SELECT @PartialComplete = 'P'	
		
CREATE	TABLE	#ASNResultSet (
				LineId	INT IDENTITY (1,1),
				LineData CHAR(80))

INSERT	#ASNResultSet (LineData)
	SELECT	('//STX12//856'+  @TradingPartner + @ShipperID+ @PartialComplete )
INSERT	#ASNResultSet (LineData)
	SELECT	('01'+   @ShipperID + @ASNDateYYMMDD + @ASNTimeHHMM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('02'+  @ShippedDateYYMMDD + @ShippedTimeHHMM + @TimeCode + @Century )
INSERT	#ASNResultSet (LineData)
	SELECT	('03'+   @Mea01 + @Mea02G + @GrossweightLbs + @WeightUM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('03'+   @Mea01 + @Mea02N + @NetWeightLbs + @WeightUM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('04'+   @PackagingCode +  @PackCountHeader  )
INSERT	#ASNResultSet (LineData)
	SELECT	('05'+ @RoutingSequnceCodeTD501 + @IDCodeQualifierTD502 + @SCAC + @TransMode    )
INSERT	#ASNResultSet (LineData)
	SELECT	('06' + @EquipDesc + @TrailerNumber )
INSERT	#ASNResultSet (LineData)
	SELECT	('07' + @REFBMQual + @REFBMValue)
INSERT	#ASNResultSet (LineData)
	SELECT	('07' + @REFPKQual + @REFPKValue)
INSERT	#ASNResultSet (LineData)
	SELECT	('08' + @N1QualifierMI +  @MaterialIssuerCode  )
INSERT	#ASNResultSet (LineData)
	SELECT	('09' +  @MaterialIssuerName  )
INSERT	#ASNResultSet (LineData)
	SELECT	('08' + @N1QualifierSU +  @SupplierCode  )
INSERT	#ASNResultSet (LineData)
	SELECT	('09' +  @SupplierName  )
INSERT	#ASNResultSet (LineData)
	SELECT	('08' + @N1QualifierST +  @ShipToID  )
INSERT	#ASNResultSet (LineData)
	SELECT	('09' + @ShipToName )




--Declare Variables for Detail of ASN
DECLARE	
				@SerialInt INT, 
				@Part VARCHAR(25),
				@LINBP CHAR(2),
				@CustomerPart CHAR(48),
				@PartQty  CHAR(12),
				@PartAccumQty  CHAR(11),
				@PartUM CHAR(2),
				@CustomerPO CHAR(10),
				@CustomerPOLine CHAR(10),
				@PackCount CHAR(6),
				@PackQty CHAR(12),
				@PackType CHAR(5),
				@PackUM CHAR(2),
				@RFFType CHAR(3),
				@SerialNumber CHAR(20)

SELECT	@LINBP = 'BP', @RFFType = 'LS'
			
DECLARE	
				@SerialASN TABLE (
					Serial INT,
					part VARCHAR(25),
					PackType VARCHAR(25),
					PackQty INT
					)

INSERT	
	@SerialASN
SELECT
	serial,
	part,
	COALESCE('CNT90',package_type, 'CNT90') ,
	quantity
FROM
	dbo.audit_trail at
WHERE
	type = 'S' AND
	shipper = CONVERT(VARCHAR(10), @shipper) AND
	show_on_shipper IS NOT NULL
ORDER BY
	part,
	serial
	
	
DECLARE part CURSOR LOCAL 
FOR
SELECT
	DISTINCT part 
FROM
	@SerialASN
	
OPEN
	part
WHILE
	1 = 1 BEGIN
	
	FETCH
		part
	INTO
		@part
		
	IF	@@FETCH_STATUS != 0 BEGIN
		BREAK
	END
	
	SELECT
		@CustomerPart = sd.customer_part,
		@PartQty = CONVERT(INT,sd.qty_packed),
		@PartAccumQty = CONVERT(INT, sd.accum_shipped),
		@PartUm = 'EA',
		@CustomerPO = sd.customer_po
	FROM
		dbo.shipper_detail sd
	WHERE
		part_original = @part AND
		shipper = @shipper
		
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'10' + @LINBP + @CustomerPart 

		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'11'+ SPACE(48) +   @PartQty + @PartUM  + @PartAccumQty
		
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'12' + @CustomerPO
			
			DECLARE partpack CURSOR LOCAL 
				FOR
			SELECT
				part, 
				PackType,
				PackQty,
				COUNT(1) 
			FROM
				@SerialASN
			WHERE
				part = @part
			GROUP BY
				part,
				PackType,
				PackQty
	
			OPEN
				partpack
			WHILE
				1 = 1 BEGIN
	
				FETCH
				partpack
				INTO
				@Part,
				@PackType,
				@PackQty,
				@PackCount
		
		
				IF	@@FETCH_STATUS != 0 BEGIN
				BREAK
				END

											
				INSERT
				#ASNResultSet	( LineData )
				SELECT
				'13' + @PackCount + @PackQty +  @PackType 
								
	
					DECLARE SerialNumber CURSOR LOCAL
					FOR
					SELECT
						serial 
					FROM
						@SerialASN
					WHERE	part = @Part AND
							PackType = CONVERT(VARCHAR(25), RTRIM(@PackType)) AND
							PackQty = CONVERT( INT, @PackQty)
					ORDER BY
							serial
					OPEN
						SerialNumber
						WHILE
					1 = 1 BEGIN
	
					FETCH
					SerialNumber
					INTO
					@SerialInt
					
					
		
					IF	@@FETCH_STATUS != 0 BEGIN
					BREAK
					END
	
					SELECT
					@SerialNumber = @serialInt
	
					INSERT
					#ASNResultSet	( LineData )
					SELECT
					'14' + @SerialNumber
		
					END
					CLOSE
					SerialNumber
 
					DEALLOCATE
					SerialNumber
	
			END
			CLOSE
			PartPack
			DEALLOCATE
			PartPack
			
		END
		CLOSE
		Part
		DEALLOCATE
		Part


/* --Invoice flat file definition for Modatek

    FlatFile Layout for Overlay: CMA_810_D_v3060_COSMA_141239     07-16-15 19:27

*/
--Declare Variables for 810 Flat File
		--Header
		Declare
				--BIG 
				@1BIG01InvoiceDate char(6),
				@1BIG02InvoiceNumber char(22),
				--CUR
				@1CUR02CurrencyCode char(3) ,
				--REF
				@1REF01TLQualifier Char(3) , --Tax License Exemption Qual
				@1REF01TL Char(30), --Tax License Exemption
				@1REF01VXQualifier Char(3) , --GST Registration Number Qual
				@1REF01VX Char(30), --GST Registration Number 
				@1REF01BMQualifier Char(3) , --BOL Qual
				@1REF01BM Char(30), --BOL Number 
				--N1
				@1N101ST	 char(2), 
				@1N103STType char(2),
				@1N104ShipTo char(20),
				@1N101SE	 char(2), 
				@1N103SEType char(2),
				@1N104Seller char(20),
				@1N101BT	 char(2), 
				@1N103BTType char(2),
				@1N104BillTo char(20),
				--ITD This segment is to be sent only if a discount is applicable...Will add this data to the 810 only if Modatec and Titan demand data on 810
				@1ITD01_01	 char(2),  --Terms Code Qualifier 01 = Basic, 03 = Fixed Date and 14 = Previously agreed upon
				@1ITD02_3 char(2), -- ??
				--DTM Shipped Date
				@1DTM02ShippedDate char(6),
				@1DTM03ShippedTime char(8),
				--FOB
				@1FOB01	char(2),
				
				
				--Detail

				--IT1
				@1IT102QtyInvoicedNumeric numeric(20,6), 
				@1IT101LineItem char(20),
				@1IT102QtyInvoiced char(12), 
				@1IT103QtyInvoicedUM char(2),
				@1IT104UnitPrice char(19),
				@1IT104UnitPriceNumeric numeric(20,6),
				@1IT105BasisOfUnitPrice char(2) ,
				@1IT106PartQualifier char(2) ,
				@1IT107CustomerPart char(40),
				@1IT108POQual char(2),
				@1IT109PO char(40) ,
				--PID
				@1PID04 char(12),
				@1PID05 char(76),
				--ITD
				@1ITD01 char(12), 
				@1ITD02 char(76) ,
				--TDS				
				@1TDS01InvoiceAmount char(17),
				@1TDS01InvoiceAmountNumeric numeric(20,6),
				@PartNumber varchar(25),
				--TXI
				@1TXI01GS char(2), -- GST
				@1TXI02GS CHAR(17), --GST Amount
				@1TXI03GS CHAR(12), -- GST %
				@1TXI01VA char(2), -- PST
				@1TXI02VA CHAR(17), --PST Amount
				@1TXI03VA CHAR(12), -- PST %
				--ISS
				@1ISS01 char(12), --Units Shipped
				@1ISS02 char(2), --Units Shipped UM
				@1ISS03 char(12), --Pounds Shipped
				@1ISS04 char(2) --Pounds Shipped UM


select
		
		@1BIG01InvoiceDate= convert(varchar(8), s.date_shipped, 12), 		
		@1BIG02InvoiceNumber = s.invoice_number,
		
		@1CUR02CurrencyCode = 'CAD',
		
		@1REF01TLQualifier = 'TL' , 
		@1REF01TL = COALESCE(nullif(c.custom4,''),'TaxExemption'), 
		@1REF01VXQualifier ='VX' , --GST Registration Number Qual
		@1REF01VX = COALESCE(nullif(c.custom5,''),'GSTRegNumber'), --GST Registration Number 
		@1REF01BMQualifier = 'BL' , --BOL Qual
		@1REF01BM = s.id, --BOL Number 

		@1N101ST = 'ST', 
		@1N103STType = '1',
		@1N104ShipTo = Coalesce(nullif(es.parent_destination,''), es.destination,''),
		@1N101SE	  = 'SE', 
		@1N103SEType = '1',
		@1N104Seller  = Coalesce(nullif(es.supplier_code,''), 'SellerDUNS'), 
		@1N101BT	 = 'BT' , 
		@1N103BTType = '1',
		@1N104BillTo = Coalesce(nullif(c.address_6,''), 'Bill To DUNS'),

		@1DTM02ShippedDate = convert(varchar(8), s.date_shipped, 12),
		@1DTM03ShippedTime  = left(replace(convert(varchar(30), s.date_shipped, 108),':',''), 4),

		@1FOB01 =  CASE WHEN s.freight_type like '%Prepaid%' THEN 'PP' ELSE 'CC' END


		


	from
		Shipper s
	join
		dbo.edi_setups es on s.destination = es.destination
	join
		dbo.destination d on es.destination = d.destination
	join
		dbo.customer c on c.customer = s.customer
	
	where
		s.id = @shipper

-- Insert header of 810 into result set table

INSERT	#ASNResultSet (LineData)
	SELECT	('//STX12//810'
						+  @TradingPartner 
						+  @ShipperID
						+  ' ' )

INSERT	#ASNResultSet (LineData)
	SELECT	(	'01'
				+		@1BIG01InvoiceDate
				+		@1BIG02InvoiceNumber
				+		@1CUR02CurrencyCode
						)
INSERT	#ASNResultSet (LineData)
	SELECT	(	'02'
				+		@1REF01TLQualifier
				+		@1REF01TL
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'02'
				+		@1REF01VXQualifier
				+		@1REF01VX
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'02'
				+		@1REF01BMQualifier
				+		@1REF01BM
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'05'
				+		@1N101ST	 
				+		@1N103STType 
				+		@1N104ShipTo 
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'05'
				+		@1N101SE	 
				+		@1N103SEType 
				+		@1N104Seller
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'05'
				+		@1N101BT	 
				+		@1N103BTType 
				+		@1N104BillTo 
						)
INSERT	#ASNResultSet (LineData)
		SELECT	(	'10'
				+		@1DTM02ShippedDate
				+		@1DTM03ShippedTime
						)
INSERT	#ASNResultSet (LineData)
			SELECT	(	'11'
				+		@1FOB01
						)



declare	@InvoiceDetail table (
	POLine Int Identity (1,1),
	PartNumber varchar(25),
	CustomerPart varchar(50),
	CustomerPO varchar(50),
	PartName varchar(76),
	QtyShipped int,
	ShipperLineWeight int,
	Price numeric(20,6))
	
insert	@InvoiceDetail 
(	PartNumber,
	CustomerPart,
	CustomerPO,
	PartName,
	QtyShipped,
	ShipperLineWeight,
	Price
	)
	
select
	
	sd.part_original,
	sd.customer_part,
	sd.customer_po,
	left(p.name,76),
	round(sd.qty_packed,0),
	round(coalesce(sd.gross_weight,0),0),
	round(sd.alternate_price,4)
from
	shipper_detail sd
join
	shipper s on s.id = @shipper
join
	part p on p.part = sd.part_original
Where
	sd.shipper = @shipper
	
declare
	InvoiceLine cursor local for
select
	POLine,
	'BP',
	PartNumber,
	CustomerPart,
	'PO',
	CustomerPO ,
	'F',
	PartName,
	QtyShipped,
	'EA',
	Price,
	Price,
	'PE'
From
	@InvoiceDetail InvoiceDetail


open
	InvoiceLine

while
	1 = 1 begin
	
	fetch
		InvoiceLine
	into
		@1IT101LineItem,
		@1IT106PartQualifier ,
		@PartNumber,
		@1IT107CustomerPart,
		@1IT108POQual ,
		@1IT109PO ,
		@1PID04,
		@1PID05,
		@1IT102QtyInvoiced, 
		@1IT103QtyInvoicedUM,
		@1IT104UnitPrice,
		@1IT104UnitPriceNumeric,
		@1IT105BasisOfUnitPrice 
		
		
		
			
			
	if	@@FETCH_STATUS != 0 begin
		break
	end

	Insert	#ASNResultSet (LineData)
					Select  '12' 									
							+ @1IT101LineItem
							+ @1IT102QtyInvoiced
							+ @1IT103QtyInvoicedUM
							+ @1IT104UnitPrice
							+ @1IT105BasisOfUnitPrice
							+ @1IT106PartQualifier
							

	Insert	#ASNResultSet (LineData)
					Select  '13' 									
							+ @1IT107CustomerPart
							+ 	@1IT108POQual
						


	INSERT	#ASNResultSet (LineData)
					SELECT  '14' 									
							+ @1IT109PO
						
	--Insert	#ASNResultSet (LineData)
	--				Select  '15' 									
	--						+ @1PID04
							
	--Insert	#ASNResultSet (LineData)
	--				Select  '16' 									
	--						+ @1PID05

END
close
	InvoiceLine	
 
deallocate
	InvoiceLine	

--Get totals and taxes for the invoice

Select @1TDS01InvoiceAmountNumeric = Sum(qtyShipped*price) From @InvoiceDetail

Select @1TDS01InvoiceAmount = substring(convert(varchar(255),round(@1TDS01InvoiceAmountNumeric ,2)),1,patindex('%.%', convert(varchar(255),round(@1TDS01InvoiceAmountNumeric,2)))-1 ) +
				substring(convert(varchar(255),round(@1TDS01InvoiceAmountNumeric ,2)),patindex('%.%', convert(varchar(255),round(@1TDS01InvoiceAmountNumeric ,2)))+1, 2)
				--TXI
Select		@1TXI01GS = 'GS'
Select 		@1TXI02GS = round((.07*@1TDS01InvoiceAmountNumeric),2) --GST Amount
Select		@1TXI03GS = '7'-- GST %
Select		@1TXI01VA = 'VA' -- PST
Select		@1TXI02VA  = round((.07*@1TDS01InvoiceAmountNumeric),2) --PST Amount
Select		@1TXI03VA = '7' -- PST %
				--SS
Select		@1ISS01  = Sum(qtyShipped)  From @InvoiceDetail  --Units Shipped
Select		@1ISS02 = 'EA'				
Select		@1ISS03 =  Sum(ShipperLineWeight)  From @InvoiceDetail --Pounds Shipped
SELECT		@1ISS04 = 'LB' --Pounds Shipped UM


INSERT	#ASNResultSet (LineData)
					SELECT  '20' 									
							+ @1TDS01InvoiceAmount

INSERT	#ASNResultSet (LineData)
					SELECT  '21' 									
							+ @1TXI01GS 
							+ @1TXI02GS
							+ @1TXI03GS

INSERT	#ASNResultSet (LineData)
					Select  '21' 									
							+ @1TXI01VA
							+ @1TXI02VA
							+ @1TXI03VA

Insert	#ASNResultSet (LineData)
					Select  '26' 									
							+ @1ISS01 
							+ @1ISS02
							+ @1ISS03
							+ @1ISS04

	

SELECT	
	LEFT(Linedata,78) + CONVERT(CHAR(2), LineId)
FROM		
	#ASNResultSet
ORDER BY LineID ASC

		
SET ANSI_PADDING OFF


END











GO
