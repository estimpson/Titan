SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--SELECT * FROM shipper_detail WHERE release_no LIKE '%!%'

CREATE PROCEDURE [dbo].[ftsp_EDI_ASN_Benteler_si] @Shipper INT   AS
BEGIN

--exec ftsp_EDI_ASN_Benteler_si 84083 --84092 --84083

/*

    FlatFile Layout for Overlay: BEN_856_D_v4010_BENTELER SI_100429     02-20-15 13:3

    Fixed Record/Fixed Field (FF)        Max Record Length: 080

    Input filename: DX-FX-FF.080         Output filename: DX-XF-FF.080


    Description                                            Type Start Length Element 

    Header Record '//'                                      //   001   002           

       RESERVED (MANDATORY)('STX12//')                      ID   003   007           

       X12 TRANSACTION ID (MANDATORY X12)                   ID   010   003           

       TRADING PARTNER (MANDATORY)                          AN   013   012           

       DOCUMENT NUMBER (MANDATORY)                          AN   025   030           

       FOR PARTIAL TRANSACTION USE A 'P' (OPTIONAL)         ID   055   001           

       EDIFACT(EXTENDED) TRANSACTION ID (MANDATORY EDIFACT) ID   056   010           

       DOCUMENT CLASS CODE (OPTIONAL)                       ID   066   006           

       OVERLAY CODE (OPTIONAL)                              ID   072   003           

       FILLER('      ')                                     AN   075   006           

       Record Length:                                                  080           

    Record '01'                                             01   001   002           

       SUPPLIER SHIPMENT #                                  AN   003   009    1BSN02 

       ASN DATE                                             DT   012   008    1BSN03 

       ASN TIME                                             TM   020   008    1BSN04 

       SHIPMENT DATE                                        DT   028   008    1DTM02 

       SHIPMENT TIME                                        TM   036   004    1DTM03 

       FILLER('                                         ')  AN   040   041           

       Record Length:                                                  080           

    Record '02' (20 x - End Record '02')                    02   001   002           

       LADING QUANTITY                                      N    003   008    1TD102 

       ('                                               ... AN   011   070           

       Record Length:                                                  080           

    Loop Start (12 x - End Record '04')                                              

       Record '03'                                          03   001   002           

          ID CODE                                           AN   003   078    1TD503 

          Record Length:                                               080           

       Record '04'                                          04   001   002           

          TRANSPORTATION METHOD/TYPE CODE                   AN   003   002    1TD504 

          ('                                            ... AN   005   076           

                                          1 
    Description                                            Type Start Length Element 

          Record Length:                                               080           

    Record '05' (12 x - End Record '05')                    05   001   002           

       EQUIPMENT DESCRIPTION CODE                           AN   003   002    1TD301 

       EQUIPMENT #                                          AN   005   010    1TD303 

       ('                                               ... AN   015   066           

       Record Length:                                                  080           

    Record '06'                                             06   001   002           

       BENTELER PLANT CODE                                  AN   003   004    1N104  

       SHIP TO NAME                                         AN   007   060    1N102  

       SUPPLIER DUNS NUMBER                                 AN   067   009    2N104  

       FILLER('     ')                                      AN   076   005           

       Record Length:                                                  080           

    Loop Start (200000 x - End Record '07')                                          

       Record '07'                                          07   001   002           

          BENTELER MATERIAL #                               AN   003   018    1LIN03 

          CHANGE LEVEL                                      AN   021   002    1LIN05 

          PO LINE #                                         AN   023   005    1LIN07 

          PO #                                              AN   028   010    1LIN09 

          RELEASE #                                         AN   038   009    1LIN11 

          # OF UNITS SHIPPED                                R    047   012    1SN102 

          UNIT OF MEASURE                                   AN   059   002    1SN103 

          FILLER('                    ')                    AN   061   020           

          Record Length:                                               080           



*/

SET ANSI_PADDING ON

DECLARE
	@TradingPartner	CHAR(12),
	@ShipperID CHAR(9),
	@ShipperID2 CHAR(11),
	@PartialComplete CHAR(1),
	@PurposeCode CHAR(2),
	@ASNDateYYMMDD CHAR(8),
	@ASNTimeHHMM CHAR(8),
	@ShippedDateYYMMDD CHAR(8),
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
	@SCAC CHAR(76),
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
	@SupplierCode CHAR(9),
	@ShipToName CHAR(60),
	@ShipToID CHAR(4),
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
	
SELECT	@TradingPartner = COALESCE(NULLIF(trading_partner_code,''), 'BENTELER'),
				@PartialComplete = '',
				@PurposeCode = '00' ,
				@ShipperID= s.id,
				@ShipperID2 =s.id,
				@ASNDateYYMMDD = CONVERT (VARCHAR(25), GETDATE(), 112),
				@ASNTimeHHMM = LEFT(CONVERT (VARCHAR(25), GETDATE(), 24),2)+SUBSTRING(CONVERT (VARCHAR(25), GETDATE(), 24),4,2),
				@ShippedDateQualifier = '011',
				@ShippedDateYYMMDD =   CONVERT (VARCHAR(25), s.date_shipped, 112),
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
				@SupplierCode = COALESCE(es.supplier_code,'201865151'),
				@SupplierName = 'Titan Tool & Die Limited',
				@MaterialIssuerCode = COALESCE(es.material_issuer,'253990576P'),
				@MaterialIssuerName = 'Formet Industries',
				@ShipToID = COALESCE(es.parent_destination, '0445'),
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
	SELECT	('01'+   @ShipperID + @ASNDateYYMMDD + @ASNTimeHHMM + @ShippedDateYYMMDD + @ShippedTimeHHMM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('02'+   @PackCountHeader )
INSERT	#ASNResultSet (LineData)
	SELECT	('03' + @SCAC )
INSERT	#ASNResultSet (LineData)
	SELECT	('04'+ @TransMode  )
INSERT	#ASNResultSet (LineData)
	SELECT	('05' +  @EquipDesc + @TrailerNumber )
INSERT	#ASNResultSet (LineData)
	SELECT	('06' +  @ShipToID + @ShipToName + @SupplierCode )




--Declare Variables for Detail of ASN
DECLARE	
				@SerialInt INT, 
				@Part VARCHAR(18),
				@CustomerPartNo VARCHAR(30),
				@LINBP CHAR(2),
				@CustomerPart CHAR(18),
				@CustomerPartECN CHAR(2),
				@PartQty  CHAR(12),
				@PartAccumQty  CHAR(11),
				@PartUM CHAR(2),
				@CustomerPO CHAR(10),
				@CustomerPOLine CHAR(5),
				@ReleaseNo CHAR(9),
				@PackCount CHAR(6),
				@PackQty CHAR(12),
				@PackType CHAR(5),
				@PackUM CHAR(2),
				@RFFType CHAR(3),
				@SerialNumber CHAR(20)

SELECT	@LINBP = 'BP', @RFFType = 'LS', @PackUM = 'PC'
			

DECLARE part CURSOR LOCAL 
FOR
SELECT
	DISTINCT customer_part 
FROM
	dbo.shipper_detail
WHERE
	shipper = @Shipper
	
OPEN
	part
WHILE
	1 = 1 BEGIN
	
	FETCH
		part
	INTO
		@CustomerPartNo
		
	IF	@@FETCH_STATUS != 0 BEGIN
		BREAK
	END
	
	SELECT
		@CustomerPart = sd.customer_part,
		@PartQty = CONVERT(INT,SUM(dpo.Qty)),
		@PartAccumQty = CONVERT(INT, MAX(sd.accum_shipped)),
		@PartUm = 'PC',
		@CustomerPO = SUBSTRING(dpo.DiscretePOnumber, COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)+1),7) , COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)-COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)+1),7)),10)),
		@CustomerPOLine = RIGHT( '00000' + (SUBSTRING(dpo.DiscretePOnumber, 1 , COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)-1),5))),5),
		@ReleaseNo = SUBSTRING(dpo.DiscretePOnumber, COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)+1),9) , COALESCE((PATINDEX('%$%', dpo.DiscretePOnumber)-COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)+1),9)),9)),
		@CustomerpartECN =  COALESCE(oh.engineering_level, NULLIF(SUBSTRING(sd.release_no, COALESCE((PATINDEX('%$%', sd.release_no)+1),2),2),''),RIGHT(sd.customer_part,2))
	FROM
		dbo.shipper_detail sd
	JOIN
		order_header oh ON oh.order_no = sd.order_no
	JOIN
		dbo.DiscretePONumbersShipped dpo ON dpo.Shipper = @shipper AND dpo.OrderNo = sd.order_no
	WHERE
		sd.customer_part = @CustomerPartNo AND
		sd.shipper = @shipper
	GROUP BY
		sd.customer_part,
		SUBSTRING(dpo.DiscretePOnumber, COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)+1),7) , COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)-COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)+1),7)),10)),
		RIGHT( '00000' + (SUBSTRING(dpo.DiscretePOnumber, 1 , COALESCE((PATINDEX('%!%', dpo.DiscretePOnumber)-1),5))),5),
		SUBSTRING(dpo.DiscretePOnumber, COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)+1),9) , COALESCE((PATINDEX('%$%', dpo.DiscretePOnumber)-COALESCE((PATINDEX('%^%', dpo.DiscretePOnumber)+1),9)),9)),
		COALESCE(oh.engineering_level, NULLIF(SUBSTRING(sd.release_no, COALESCE((PATINDEX('%$%', sd.release_no)+1),2),2),''),RIGHT(sd.customer_part,2))
		
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'07'  + @CustomerPart + @CustomerPartECN + @CustomerPOLine + @CustomerPO + @ReleaseNo + @PartQty + @PartUM
		END
		CLOSE
		Part
		DEALLOCATE
		Part
	

SELECT	
	LEFT(Linedata,78) + CONVERT(CHAR(2), LineId)
FROM		
	#ASNResultSet
ORDER BY LineID ASC

		
SET ANSI_PADDING OFF


END













GO
