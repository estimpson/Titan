Create PROCEDURE dbo.EDI_GMDESADV_Detail (@Shipper INT)
 
AS

BEGIN

SET ANSI_PADDING ON 

--dbo.EDI_GMDESADV_Detail 47880, 47297

--Get Part, Object pack_type, Pallet Pack Type Group
--------This will be used for CPS Loop.
--CPS03 will be 1 for returnables and expendables that replace returnables. It will be 4 for expandables

--------(Package Type = Box and Returnable = 'Y') = 1
--------(Package Type = Box and Returnable = 'N') = 4
--------(Package Type = Other and Returnable = 'Y') = 1
--------(Package Type = Other and Returnable = 'N') = 1
--------(Package Type = Pallet and Returnable = 'N') = 4
--------(Package Type = Pallet and Returnable = 'Y') = 1
-------- CPS03 will be 4 for any part/pallet/box returnable group where either pallet = 4 or box = 4

--Declare Variables

DECLARE

@CPS INT,
@Part	VARCHAR(25),
@PalletPackCode varchar(20),
@PalletPackType CHAR(1),
@ObjectPackCode varchar(20),
@ObjectPackType CHAR(1)

--Delare table variable to store part, object pack type, pallet pack type grouping

DECLARE @PartPackTypeSerials TABLE
		(
		 ObjectSerial INT,
		 ParentSerial INT NOT NULL,
		 PalletPackType char(1) NOT NULL,
		 PalletPackCode VARCHAR(20) NOT NULL,
		 ObjectPackType VARCHAR(1) NOT NULL,
		 ObjectPackCode VARCHAR(20) NOT NULL,
		 Part VARCHAR(25) NOT NULL,
		 ObjectQuantity INT NOT NULL,
		 CustomerPart VARCHAR(30) NOT NULL,
		 CustomerPO VARCHAR(30) NOT NULL,
		 ModelYear VARCHAR(4) NOT NULL,
		 AccumShipped INT NOT NULL,
		 UM CHAR(3) NOT NULL
			PRIMARY KEY (ObjectSerial)
		)		 
		 

-- Insert table variable
	
INSERT	@PartPackTypeSerials
        ( ObjectSerial ,
		  ParentSerial,
		  PalletPackType,
          PalletPackCode ,
          ObjectPackType,
          ObjectPackCode ,
          Part ,
          ObjectQuantity,
          CustomerPart,
          CustomerPO,
          ModelYear,
          AccumShipped,
          UM
        ) 

SELECT	at.serial,
		COALESCE(at.parent_serial,0),
		(CASE WHEN pm.type IS NULL THEN '4' WHEN ((pm.type = 'B' AND pm.returnable = 'N') OR (ppm.type = 'P' AND ppm.returnable = 'N')) THEN '4' ELSE '1' END ),
		(CASE WHEN at.parent_serial IS NULL THEN COALESCE(at.package_type, 'CTN90') ELSE COALESCE(atp.package_type, 'PLT90') END),
		(CASE WHEN ((pm.type = 'B' AND pm.returnable = 'N') OR (ppm.type = 'P' AND ppm.returnable = 'N')) THEN '4' ELSE '1' END ),
		COALESCE(at.package_type, 'CTN90'),
		at.part,
		at.quantity,
		COALESCE(sd.customer_Part,''),
		COALESCE(sd.customer_po, ''),
		convert(varchar(2),RIGHT(isNull(nullif(oh.model_year,''), datepart(yy, getdate())),2)),
		sd.accum_shipped,
		'C62'
		

FROM 	
		dbo.audit_trail at
JOIN	shipper_detail sd ON at.part = sd.part_original AND sd.shipper = @shipper
JOIN	order_header oh ON sd.order_no = oh.order_no
LEFT JOIN	
		dbo.package_materials pm ON at.package_type = pm.code
LEFT JOIN	
		(	SELECT	
				serial PalletSerial, 
				package_type
			FROM
				dbo.audit_trail
			WHERE
				part = 'PALLET' AnD
				type = 'S' AND
				shipper =  CONVERT(VARCHAR(20),@shipper)
				
			
		) atp ON at.serial = PalletSerial
LEFT JOIN
		dbo.package_materials ppm ON atp.package_type = ppm.code
WHERE	at.part != 'PALLET' AND
		at.type = 'S' AND
		at.shipper =  CONVERT(VARCHAR(20),@shipper)
		
--CREATE temp storage for flat file lines


Create	table	#DESADVFlatFileLines (
				LineId	int identity,
				LineData char(80) )
				
-- Get Header for DESADV

Select	CONVERT( char(80), '') AS PartialComplete,
		CONVERT( char(80),ISNULL(shipper.ship_via,'')) as bill_of_lading_scac_transfer,
		CONVERT( char(80),ISNULL(bill_of_lading.scac_pickup,'')) AS SCACPickUp,
		CONVERT( char(80),ISNULL(carrier.name,'')) AS CarrierName,
		CONVERT( char(80), ISNULL((case when shipper.freight_type = 'collect' then '1  ' else '2  ' END),'')) AS FreightType,
		convert( char(80), ISNULL(shipper.trans_mode,'')) as TransMode,
		CONVERT( char(80), ISNULL(shipper.staged_pallets,0) ) AS StagedPallets, 
		CONVERT( char(80), ISNULL(SUBSTRING(shipper.aetc_number,3,25),'') ) AS AETCNumber,
		CONVERT( char(80), ISNULL(SUBSTRING(shipper.aetc_number,1,1),'') ) AS AETCNumberReason,
		CONVERT( char(80), ISNULL(SUBSTRING(shipper.aetc_number,2,1),'') ) AS AETCNumberResponsibility,
		CONVERT( char(80), ISNULL(edi_setups.id_code_type,'')) AS IDCodeType,
		CONVERT( char(80), ISNULL(edi_setups.parent_destination,'')) AS ParentDestination, 
		CONVERT( char(80), ISNULL(edi_setups.material_issuer,'')) AS MaterialIssuer,
		CONVERT( char(80), ISNULL(shipper.id,0)) AS ShipperID, 
		CONVERT( char(80), CONVERT(VARCHAR(25), shipper.date_shipped, 112)+LEFT(CONVERT(VARCHAR(25), shipper.date_shipped, 108),2) +SUBSTRING(CONVERT(VARCHAR(25), shipper.date_shipped, 108),4,2)) AS DateShipped,
		CONVERT( char(80), CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),shipper.date_shipped), 112)+LEFT(CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),shipper.date_shipped), 108),2) +SUBSTRING(CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),shipper.date_shipped), 108),4,2)) AS ArrivalDate,
		CONVERT( char(80), CONVERT(VARCHAR(25), GETDATE(), 112)+LEFT(CONVERT(VARCHAR(25), GETDATE(), 108),2) +SUBSTRING(CONVERT(VARCHAR(25), GETDATE(), 108),4,2)) AS ASNDate,
		CONVERT( char(80), ISNULL(edi_setups.pool_code,'')) AS Poolcode, 
		CONVERT( char(80), CONVERT(int, ISNULL(shipper.gross_weight,0) * .45359237)) AS GrossWeightKG, 
		CONVERT( char(80), CONVERT(int, ISNULL(shipper.net_weight,0) * .45359237)) AS NetWeightKG, 
		CONVERT( char(80), CONVERT(int, ISNULL(shipper.gross_weight,0))) AS GrossWeightLBS, 
		CONVERT( char(80), CONVERT(int, ISNULL(shipper.net_weight,0))) AS NetWeightLBS, 
		CONVERT( char(80), CONVERT(int, ISNULL(shipper.staged_objs,0))) AS StagedObjs, 
		CONVERT( char(80), ISNULL(shipper.ship_via,'') ) AS SCAC,
		UPPER(CONVERT( char(80), ISNULL(NULLIF(shipper.truck_number,''), 'TruckNo'))) AS TruckNumber, 
		CONVERT( char(80), ISNULL(shipper.pro_number, '')) AS ProNumber, 
		CONVERT( char(80), ISNULL(shipper.seal_number,'')) AS SealNumber, 
		CONVERT( char(80), COALESCE(NULLIF(edi_setups.parent_destination,''), shipper.destination,'')) AS Destination, 
		CONVERT( char(80), ISNULL(shipper.plant,'')) AS Plant,
		CONVERT( char(80), ISNULL(shipper.shipping_dock,'')) AS ShippingDock,
		CONVERT( char(80), COALESCE(shipper.bill_of_lading_number,shipper.id, 0)) AS BOL, 
		CONVERT( char(80), shipper.date_shipped)AS TimeShipped, 
		CONVERT( char(80), ISNULL(bill_of_lading.equipment_initial,'')) AS EquipInitial, 
		CONVERT( char(80), ISNULL(edi_setups.equipment_description,'')) AS EquipDesription, 
		CONVERT( char(80), COALESCE(edi_setups.trading_partner_code,'AMERICANAXLE')) AS TradingPArtnerCode, 
		CONVERT( char(80), ISNULL(edi_setups.supplier_code,'')) AS SupplierCode, 
		CONVERT( char(80), datepart(dy,getdate())) as DayofYr,
		CONVERT( char(80),(isNULL((Select	count(distinct Parent_serial) 
			from	audit_trail
			where	audit_trail.shipper = convert(char(10),@shipper) and
				audit_trail.type = 'S' and 
				isNULL(parent_serial,0) >0 ),0))) as pallets,
		CONVERT( char(80),(isNULL((Select	count(serial) 
			from	audit_trail,
				package_materials
			where	audit_trail.shipper = convert(char(10),@shipper) and
				audit_trail.type = 'S' and
				part <> 'PALLET' and 
				parent_serial is NULL and
				audit_trail.package_type = package_materials.code and
				package_materials.type = 'B' ),0))) as loose_ctns,
		CONVERT( char(80),(isNULL((Select	count(serial) 
			from	audit_trail,
				package_materials
			where	audit_trail.shipper =  convert(char(10),@shipper) and
				audit_trail.type = 'S' and 
				parent_serial is NULL and
				audit_trail.package_type = package_materials.code and
				package_materials.type = 'O' ),0))) as loose_bins,
		CONVERT( char(80), ISNULL(edi_setups.parent_destination,'')) as edi_shipto,
		CONVERT( char(80), 'DESADV') AS DocumentType,
		CONVERT( char(80), '') AS ASNOverlayGroup,
		CONVERT( char(80), 'LBR') AS LBR,
		CONVERT( char(80), 'C62') AS C62,
		CONVERT( char(80), 'MB') AS QualMB,
		CONVERT( char(80), '16') AS Qual16,
		CONVERT( char(80), '92') AS Qual92,
		CONVERT( char(80), '12') AS TransQual,
		CONVERT( char(80), '182') AS RESPONSIBLEAGENCY,
		CONVERT( char(80), 'TE') AS EQUIPMENTTYPE,
		CONVERT( char(80), '9') AS MESSAGEFUNCTION,
		CONVERT( char(80), 'G') AS G,
		CONVERT( char(80), 'N') AS N,
		CONVERT( char(80), 'SQ') AS SQ,
		CONVERT( char(80), 'MB') AS MB,
		CONVERT( char(80), '182') AS Code182,
		CONVERT( char(80), '11') AS ShipDateQualifier,
		CONVERT( char(80), '137') AS ASNDateQualifier,
		CONVERT( char(80), '132') AS ArrivalDateQualifier,
		CONVERT( char(80), 'MI') AS MI,
		CONVERT( char(80), 'ST') AS ST,
		CONVERT( char(80), 'SU') AS SU
		
		
		
				
	Into	#DESADVHeaderRaw
	from	shipper
	JOIN	edi_setups ON dbo.shipper.destination = dbo.edi_setups.destination 
	LEFT OUTER JOIN bill_of_lading  ON shipper.bill_of_lading_number = bill_of_lading.bol_number 
	left outer join carrier on shipper.bol_carrier = carrier.scac  
	where	( ( shipper.id = @shipper ) )

	INSERT	#DESADVFlatFileLines (LineData)
	SELECT	('//STX12//X12'+ LEFT(TradingPArtnerCode,12)+LEFT(ShipperID,30)+ LEFT(PartialComplete,1) +LEFT(DocumentType,10) + LEFT(DocumentType,6)+ LEFT(ASNOverlayGroup,3)) FROM #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	Select	('01'+ LEFT(ShipperID,35)+ LEFT(MESSAGEFUNCTION,1) + LEFT(ASNDate,12) + LEFT(DateShipped,12) + LEFT(ArrivalDate,12) ) FROM #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	Select	('02'+ LEFT(G,3) + LEFT(LBR,3)+ LEFT(GrossWeightLBS,16)) FROM #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	Select	('02'+ LEFT(N,3) + LEFT(LBR,3)+ LEFT(NetWeightLBS,16) ) FROM #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('02'+ LEFT(SQ,3) + LEFT(C62,3)+ LEFT(StagedObjs,16) ) from #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('03'+ LEFT(MB,3) + LEFT(BOL,35)) from #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('04'+ LEFT(MI,2)+ LEFT(MaterialIssuer,9) + LEFT(ST,2)+ + LEFT(Destination,9) + LEFT(ShippingDock,25) + LEFT(SU,2)+ + LEFT(SupplierCode,9) ) from #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('06' + LEFT(TransQual,2) + LEFT(TransMode,3) + LEFT(SCAC,17) + LEFT(Code182,3) + LEFT(AETCNumberReason,3) + LEFT(AETCNumberResponsibility,3) + LEFT(AETCNumber,17)) from #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('07' + LEFT(EQUIPMENTTYPE,3) + left(TruckNumber,17)) from #DESADVHeaderRaw
	INSERT	#DESADVFlatFileLines (LineData)
	select	('08' + LEFT(SealNumber,10) ) from #DESADVHeaderRaw


-- Get Detail for DESADV


SET @CPS = 0		
	
declare
	Part cursor local for
select
	DISTINCT CustomerPart, PalletPackType
From
	@PartPackTypeSerials

open
	Part

while
	1 = 1 begin
	
	fetch
		Part
	into
		@Part, @PalletpackType
			
	if	@@FETCH_STATUS != 0 begin
		break
	end
	
	set	@cps = @cps + 1

	Insert	#DESADVFlatFileLines (LineData)
	Select	DISTINCT '09' + convert(char(03), @PalletPackType) /*+ CONVERT(CHAR(30), PalletPackCode)*/ FROM @PartPackTypeSerials where Customerpart = @part
	
	Insert	#DESADVFlatFileLines (LineData)
	Select	'10' + convert(char(10), COUNT(ObjectSerial)) + CONVERT(CHAR(30), PalletPackCode) FROM @PartPackTypeSerials where CustomerPart = @part GROUP BY PalletPackCode
	UNION
	Select	'10' + convert(char(10), COUNT(ObjectSerial)) + CONVERT(CHAR(30), ObjectPackCode) FROM @PartPackTypeSerials where CustomerPart = @part GROUP BY ObjectPackCode
	
	Insert	#DESADVFlatFileLines (LineData)
	Select	'14' + convert(char(8), CustomerPart) + CONVERT(CHAR(35), MAX(ModelYear)) FROM @PartPackTypeSerials where CustomerPart = @part GROUP BY CustomerPart
	
	
	Insert	#DESADVFlatFileLines (LineData)
	Select	'16' + SPACE(3) + convert(char(16), MAX(AccumShipped)) + CONVERT(CHAR(3), MAX(UM)) + CONVERT(CHAR(35), sum(ObjectQuantity)) + CONVERT(CHAR(3), MAX(UM)) + 'CAN' FROM @PartPackTypeSerials where CustomerPart = @part GROUP BY CustomerPart
	
	
	
	

	end	
	
	
close
	Part
 
deallocate
	Part
	
	SELECT	*
	FROM	#DESADVFlatFileLines
	
SET ANSI_PADDING OFF
	
End


