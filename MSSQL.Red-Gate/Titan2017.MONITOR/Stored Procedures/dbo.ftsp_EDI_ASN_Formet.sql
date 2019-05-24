SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ftsp_EDI_ASN_Formet] @Shipper INT   AS
BEGIN

--exec ftsp_EDI_ASN_Formet 81414

/*

MG1_856_D_v3060_MAGNA^SOI_070702


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
	@Mea02G CHAR(1),
	@Mea02N CHAR(1),
	@GrossWeightLbs CHAR(22),
	@WeightUM CHAR(2),
	@NetWeightLbs CHAR(22),
	@PackagingCode CHAR(5),
	@PackCountHeader CHAR(8),
	@SCAC CHAR(20),
	@TransMode CHAR(2),
	@PPCode CHAR(7),
	@EquipDesc CHAR(2),
	@EquipInit CHAR(4),
	@TrailerNumber CHAR(10),
	@REFBMQual CHAR(2),
	@REFPKQual CHAR(2),
	@REFCNQual CHAR(2),
	@REFSTQual CHAR(2),
	@REFSUQual CHAR(2),
	@REF92Qual CHAR(2),
	@REF01Qual CHAR(2),
	@REFBMValue CHAR(20),
	@REFPKValue CHAR(20),
	@REFCNValue CHAR(29),
	@FOB CHAR(2),
	@ProNumber CHAR(16),
	@SealNumber CHAR(8),
	@N1QualifierST CHAR(2),
	@N1QualifierMI CHAR(2),
	@N1QualifierSU CHAR(2),
	@N1Type CHAR(2),
	@SupplierName CHAR(35),
	@SupplierCode CHAR(20),
	@ShipToName CHAR(35),
	@ShipToID CHAR(20),
	@MaterialIssuerName CHAR(35),
	@MaterialIssuerCode CHAR(20),
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
				@MaterialIssuerName = 'Formet Industries',
				@ShipToID = COALESCE(es.parent_destination, '253990576P'),
				@ShipToName = LEFT(d.name,35),
				@packagingCode = 'CNT90',
				@PackCountHeader = s.staged_objs,
				@REFBMValue = COALESCE(s.bill_of_lading_number, s.id),
				@RefPKValue = s.id,
				@EquipDesc = 'TL'
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
	SELECT	('01'+  @PurposeCode + @ShipperID + @ASNDateYYMMDD + @ASNTimeHHMM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('02'+  @ShippedDateYYMMDD + @ShippedTimeHHMM + @TimeCode + @Century )
INSERT	#ASNResultSet (LineData)
	SELECT	('03'+   @Mea01 + @Mea02G + @GrossweightLbs + @WeightUM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('03'+   @Mea01 + @Mea02N + @NetWeightLbs + @WeightUM  )
INSERT	#ASNResultSet (LineData)
	SELECT	('04'+   @PackagingCode +  @PackCountHeader  )
INSERT	#ASNResultSet (LineData)
	SELECT	('05'+ @SCAC + @TransMode    )
INSERT	#ASNResultSet (LineData)
	SELECT	('06' + @EquipDesc + SPACE(4) + @TrailerNumber )
INSERT	#ASNResultSet (LineData)
	SELECT	('10' + @REFBMQual + @REFBMValue)
INSERT	#ASNResultSet (LineData)
	SELECT	('10' + @REFPKQual + @REFPKValue)
INSERT	#ASNResultSet (LineData)
	SELECT	('11' + @N1QualifierMI + @N1Type + @MaterialIssuerCode + @MaterialIssuerName )
INSERT	#ASNResultSet (LineData)
	SELECT	('11' + @N1QualifierSU + @N1Type + @SupplierCode + @SupplierName )
INSERT	#ASNResultSet (LineData)
	SELECT	('11' + @N1QualifierST + @N1Type + @ShipToID + @ShipToName )



--Declare Variables for Detail of ASN
DECLARE	
				@SerialInt INT,
				@ParentSerial INT, 
				@Part VARCHAR(25),
				@LINBP CHAR(2),
				@CustomerPart CHAR(40),
				@PartQty  CHAR(12),
				@PartAccumQty  CHAR(11),
				@PartUM CHAR(2),
				@CustomerPO CHAR(22),
				@CustomerPOLine CHAR(10),
				@PackCount CHAR(6),
				@PackQty CHAR(12),
				@PackType CHAR(5),
				@PackUM CHAR(2),
				@RFFType CHAR(3),
				@RFFType2 CHAR(2),
				@SerialNumber CHAR(30),
				@ParentSerialNumber CHAR(30),
				@PackTypeVarchar VARCHAR(25),
				@PackQtyInt INT

SELECT	@LINBP = 'BP', @RFFType = 'LS', @RFFType2 = 'LS'
			
DECLARE	
				@SerialASN TABLE (
					Serial INT,
					ParentSerial INT,
					part VARCHAR(25),
					PackType VARCHAR(25),
					PackQty INT
					)

INSERT	
	@SerialASN
SELECT
	serial,
	COALESCE(parent_serial,0),
	part,
	COALESCE('CNT90',package_type, 'CNT90') ,
	quantity
FROM
	dbo.audit_trail at
WHERE
	type = 'S' AND
	shipper = CONVERT(VARCHAR(10), @shipper) AND
	part!='PALLET'
ORDER BY
	part,
	package_type,
	quantity,
	parent_serial,
	serial



	
	
DECLARE part CURSOR LOCAL 
FOR
SELECT
	DISTINCT Part,PackType,PackQty,ParentSerial 
FROM
	@SerialASN
	
OPEN
	part
WHILE
	1 = 1 BEGIN
	
	FETCH
		part
	INTO
		@part, @PackTypeVarchar, @PackQtyInt, @ParentSerial
		
	IF	@@FETCH_STATUS != 0 BEGIN
		BREAK
	END
	
	SELECT
		@CustomerPart = sd.customer_part,
		@PartQty = CONVERT(INT,SUM(SerialASN.PackQty)),
		@PartAccumQty = CONVERT(INT, MAX(sd.accum_shipped)),
		@PartUm = 'EA',
		@CustomerPO = MAX(sd.customer_po),
		@ParentSerialNumber = ParentSerial
	FROM
		@SerialASN SerialASN
	JOIN
		dbo.shipper_detail sd ON sd.part = SerialASN.part
	WHERE
		sd.part_original = @part AND
		sd.shipper = @shipper AND
		SerialASN.PackType = @PackTypeVarchar AND
		SerialASN.PackQty = @PackQtyInt AND
		SerialASN.ParentSerial = @ParentSerial
	GROUP BY
		sd.customer_part,
		SerialASN.ParentSerial
		
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'12' + @LINBP + @CustomerPart + @PartQty + @PartUM  + @PartAccumQty
		
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'13' + @CustomerPO
		IF @ParentSerial>0
		Begin
		INSERT
			#ASNResultSet	( LineData )
		SELECT
			'16' + @RFFType2 + @ParentSerialNumber
		end
			
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
				part = @part AND
				PackType = @PackTypeVarchar AND
				PackQty =  @PackQtyInt AND
				ParentSerial = @ParentSerial
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

				--INSERT
				--#ASNResultSet	( LineData )
				--SELECT
				--'15' + SPACE(4) + @PackCount 
								
				INSERT
				#ASNResultSet	( LineData )
				SELECT
				'17' + @PackCount + @PackQty +  @PackType 
								
	
					DECLARE SerialNumber CURSOR LOCAL
					FOR
					SELECT
						serial 
					FROM
						@SerialASN
					WHERE	part = @Part AND
							PackType = CONVERT(VARCHAR(25), @PackTypeVarchar) AND
							PackQty = CONVERT( INT, @PackQtyInt) AND
							ParentSerial = @ParentSerial
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
					'18' + @RFFType + @SerialNumber
		
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
	
--SELECT * FROM @SerialASN
SELECT	
	LEFT(Linedata,77) + CONVERT(CHAR(3), LineId)
FROM		
	#ASNResultSet
ORDER BY LineID ASC

		
SET ANSI_PADDING OFF


END













GO
