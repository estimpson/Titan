SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ftsp_EDI_ASN_Formet_si_obsolete] @Shipper INT   AS
BEGIN

--exec ftsp_EDI_ASN_Formet 81414

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
	
SELECT	@TradingPartner = COALESCE(NULLIF(trading_partner_code,''), 'Formet Testing'),
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
				@SupplierCode = COALESCE(es.supplier_code,'5199661234'),
				@SupplierName = 'Titan Tool & Die Limited',
				@MaterialIssuerCode = COALESCE(es.material_issuer,'253990576P'),
				@MaterialIssuerName = 'Formet Industries',
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
	SELECT	('08' + @N1QualifierMI + @N1Type + @MaterialIssuerCode  )
INSERT	#ASNResultSet (LineData)
	SELECT	('09' +  @MaterialIssuerName  )
INSERT	#ASNResultSet (LineData)
	SELECT	('08' + @N1QualifierSU + @N1Type + @SupplierCode  )
INSERT	#ASNResultSet (LineData)
	SELECT	('09' +  @SupplierName  )
INSERT	#ASNResultSet (LineData)
	SELECT	('08' + @N1QualifierST + @N1Type + @ShipToID  )
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
	

SELECT	
	LEFT(Linedata,78) + CONVERT(CHAR(2), LineId)
FROM		
	#ASNResultSet
ORDER BY LineID ASC

		
SET ANSI_PADDING OFF


END








GO
