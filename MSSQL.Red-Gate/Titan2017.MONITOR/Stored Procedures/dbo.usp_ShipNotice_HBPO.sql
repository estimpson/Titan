SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[usp_ShipNotice_HBPO]  (@shipper int)
as
begin

--[dbo].[usp_ShipNotice_HBPO] 80517

/* -----------------Flat File Definition----------------


  
    FlatFile Layout for Overlay: HB1_DESADV_D_Dr05B_HBPO T SYSTEMS_100414     01-27-1

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

       DESPATCH ADVICE #                                    AN   003   035    1BGM020

       DOCUMENT MSG DATE/TIME                               AN   038   035    1DTM010

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '02'                                             02   001   002           

       DESPATCH DATE/TIME                                   AN   003   035    2DTM010

       TRANSPORT ARRIVAL DATE/TIME                          AN   038   035    3DTM010

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '03' (3 x - End Record '03')                     03   001   002           

       PROPERTY MEASURED CODE                               AN   003   003    1MEA020

       MEA UNIT TYPE                                        AN   006   003    1MEA030

       GROSS/NET WEIGHT/SHIPPED QTY                         AN   009   018    1MEA030

       ('                                               ... AN   027   054           

       Record Length:                                                  080           

    Record '04'                                             04   001   002           

       CARRIER'S REF #                                      AN   003   035    1RFF010

       BUYER ID                                             AN   038   035    1NAD020

                                          1
    Description                                            Type Start Length Element 

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '05'                                             05   001   002           

       BUYER NAME                                           AN   003   035    1NAD040

       ADDRESS INFO                                         AN   038   035    1NAD050

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '06'                                             06   001   002           

       CITY NAME                                            AN   003   035    1NAD06 

       ZIP CODE                                             AN   038   009    1NAD08 

       COUNTRY                                              AN   047   003    1NAD09 

       FILLER('                               ')            AN   050   031           

       Record Length:                                                  080           

    Record '07'                                             07   001   002           

       SUPPLIER ID                                          AN   003   035    2NAD020

       SUPPLIER NAME                                        AN   038   035    2NAD040

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '08'                                             08   001   002           

       ADDRESS INFO                                         AN   003   035    2NAD050

       CITY NAME                                            AN   038   035    2NAD06 

       FILLER('        ')                                   AN   073   008           

       Record Length:                                                  080           

    Record '09'                                             09   001   002           

       ZIP CODE                                             AN   003   009    2NAD08 

       COUNTRY                                              AN   012   003    2NAD09 

       ('                                               ... AN   015   066           

       Record Length:                                                  080           

    Loop Start                                                                       

       Record '10'                                          10   001   002           

          SHIP TO ID                                        AN   003   035    3NAD020

          SHIP TO NAME                                      AN   038   035    3NAD040

          FILLER('        ')                                AN   073   008           

          Record Length:                                               080           

                                          2
    Description                                            Type Start Length Element 

       Record '11'                                          11   001   002           

          ADDRESS INFO                                      AN   003   035    3NAD050

          CITY NAME                                         AN   038   035    3NAD06 

          FILLER('        ')                                AN   073   008           

          Record Length:                                               080           

       Record '12'                                          12   001   002           

          ZIP CODE                                          AN   003   009    3NAD08 

          COUNTRY                                           AN   012   003    3NAD09 

          ('                                            ... AN   015   066           

          Record Length:                                               080           

       Record '13' (10 x - End Record '13')                 13   001   002           

          FINAL DELIVERY POINT                              AN   003   025    5LOC020

          ('                                            ... AN   028   053           

          Record Length:                                               080           

    Record '14'                                             14   001   002           

       MODE OF TRANSPORT CODE                               AN   003   003    1TDT030

       CARRIER ID                                           AN   006   017    1TDT050

       CODE LIST RESP.AGENCY CODE                           AN   023   003    1TDT050

       CARRIER NAME                                         AN   026   035    1TDT050

       FILLER('                    ')                       AN   061   020           

       Record Length:                                                  080           

    Record '15' (10 x - End Record '15')                    15   001   002           

       EQUIPMENT TYPE                                       AN   003   003    1EQD01 

       CONTAINER/RAIL CAR/TRAILER #                         AN   006   017    1EQD020

       ('                                               ... AN   023   058           

       Record Length:                                                  080           

    Loop Start (9999 x - End Record '49')                                            

       Record '16'                                          16   001   002           

          PACKAGING LEVEL CODE                              AN   003   003    1CPS03 

          ('                                            ... AN   006   075           

          Record Length:                                               080           

       Loop Start (9999 x - End Record '23')                                         

          Record '17'                                       17   001   002           

             NO. OF PACKAGES                                R    003   010    3PAC01 

                                          3
    Description                                            Type Start Length Element 

             PKG TERMS/CONDITIONS CODE                      AN   013   003    3PAC020

             HBPO PACKAGE TYPE                              AN   016   017    3PAC030

             NO. OF PKGS                                    R    033   010    2PAC01 

             HBPO PACKAGE TYPE                              AN   043   017    2PAC030

             QTY PER PACK                                   R    060   017    4QTY010

             UOM                                            AN   077   003    4QTY010

             FILLER(' ')                                    AN   080   001           

             Record Length:                                            080           

          Loop Start (1000 x - End Record '23')                                      

             Record '18'                                    18   001   002           

                MARKING INSTRUCTIONS CODE                   AN   003   003    2PCI01 

                TYPE OF MARKING CODE                        AN   006   003    2PCI040

                ('                                      ... AN   009   072           

                Record Length:                                         080           

             Loop Start (99 x - End Record '23')                                     

                Record '19'                                 19   001   002           

                   MARKING/LABEL #                          AN   003   035    2GIN020

                   IDENTITY NUMBER                          AN   038   035    2GIN020

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '20'                                 20   001   002           

                   IDENTITY NUMBER                          AN   003   035    2GIN030

                   IDENTITY NUMBER                          AN   038   035    2GIN030

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '21'                                 21   001   002           

                   IDENTITY NUMBER                          AN   003   035    2GIN040

                   IDENTITY NUMBER                          AN   038   035    2GIN040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '22'                                 22   001   002           

                   IDENTITY NUMBER                          AN   003   035    2GIN050

                   IDENTITY NUMBER                          AN   038   035    2GIN050

                   FILLER('        ')                       AN   073   008           

                                          4
    Description                                            Type Start Length Element 

                   Record Length:                                      080           

                Record '23'                                 23   001   002           

                   IDENTITY NUMBER                          AN   003   035    2GIN060

                   IDENTITY NUMBER                          AN   038   035    2GIN060

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

       Loop Start (9999 x - End Record '32')                                         

          Record '24'                                       24   001   002           

             LINE ITEM #                                    AN   003   006    2LIN01 

             BUYER'S ITEM #                                 AN   009   035    2LIN030

             FI...('                                     ') AN   044   037           

             Record Length:                                            080           

          Record '25' (10 x - End Record '25')              25   001   002           

             DRAWING REV/SUPPLIER ITEM #                    AN   003   035    2PIA020

             ITEM NUMBER TYPE                               AN   038   003    2PIA020

             ITEM NUMBER                                    AN   041   035    2PIA030

             ITEM NUMBER TYPE                               AN   076   003    2PIA030

             FILLER('  ')                                   AN   079   002           

             Record Length:                                            080           

          Record '26'                                       26   001   002           

             DESPATCH QTY                                   R    003   017    3QTY010

             MEA UNIT TYPE                                  AN   020   003    3QTY010

             COUNTRY OF ORIGIN CODE                         AN   023   003    2ALI01 

             ('                                         ... AN   026   055           

             Record Length:                                            080           

          Loop Start (99 x - End Record '31')                                        

             Record '27'                                    27   001   002           

                FREE TEXT                                   AN   003   070    2FTX040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '28'                                    28   001   002           

                FREE TEXT                                   AN   003   070    2FTX040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

                                          5
    Description                                            Type Start Length Element 

             Record '29'                                    29   001   002           

                FREE TEXT                                   AN   003   070    2FTX040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '30'                                    30   001   002           

                FREE TEXT                                   AN   003   070    2FTX040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '31'                                    31   001   002           

                FREE TEXT                                   AN   003   070    2FTX040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

          Record '32'                                       32   001   002           

             BUYER'S ORDER #                                AN   003   035    3RFF010

             WAREHOUSE ID                                   AN   038   025    2LOC020

             FILLER('                  ')                   AN   063   018           

             Record Length:                                            080           

       Loop Start (9999 x - End Record '49')                                         

          Record '33'                                       33   001   002           

             PACKAGING LEVEL CODE                           AN   003   003    2CPS03 

             ('                                         ... AN   006   075           

             Record Length:                                            080           

          Loop Start (9999 x - End Record '40')                                      

             Record '34'                                    34   001   002           

                NO. OF PACKAGES                             R    003   010    1PAC01 

                PKG TERMS AND CONDITIONS CODE               AN   013   003    1PAC020

                HBPO PACKAGE TYPE                           AN   016   017    1PAC030

                NO. OF PACKAGES                             R    033   010    4PAC01 

                HBPO PACKAGE TYPE                           AN   043   017    4PAC030

                QTY PER PACK                                R    060   017    1QTY010

                MEA  UNIT TYPE                              AN   077   003    1QTY010

                FILLER(' ')                                 AN   080   001           

                Record Length:                                         080           

             Loop Start (1000 x - End Record '40')                                   

                                          6
    Description                                            Type Start Length Element 

                Record '35'                                 35   001   002           

                   MARKING INSTRUCTIONS CODE                AN   003   003    1PCI01 

                   TYPE OF MARKING CODE                     AN   006   003    1PCI040

                   ('                                   ... AN   009   072           

                   Record Length:                                      080           

                Loop Start (99 x - End Record '40')                                  

                   Record '36'                              36   001   002           

                     MARKING/LABEL #                       AN   003   035    1GIN0201

                     IDENTITY #                            AN   038   035    1GIN0202

                     FILLER('        ')                    AN   073   008            

                     Record Length:                                   080            

                   Record '37'                              37   001   002           

                     IDENTITY NUMBER                       AN   003   035    1GIN0301

                     IDENTITY NUMBER                       AN   038   035    1GIN0302

                     FILLER('        ')                    AN   073   008            

                     Record Length:                                   080            

                   Record '38'                              38   001   002           

                     IDENTITY NUMBER                       AN   003   035    1GIN0401

                     IDENTITY NUMBER                       AN   038   035    1GIN0402

                     FILLER('        ')                    AN   073   008            

                     Record Length:                                   080            

                   Record '39'                              39   001   002           

                     IDENTITY NUMBER                       AN   003   035    1GIN0501

                     IDENTITY NUMBER                       AN   038   035    1GIN0502

                     FILLER('        ')                    AN   073   008            

                     Record Length:                                   080            

                   Record '40'                              40   001   002           

                     IDENTITY NUMBER                       AN   003   035    1GIN0601

                     IDENTITY NUMBER                       AN   038   035    1GIN0602

                     FILLER('        ')                    AN   073   008            

                     Record Length:                                   080            

          Loop Start (9999 x - End Record '49')                                      

             Record '41'                                    41   001   002           

                LINE ITEM #                                 AN   003   006    1LIN01 

                                          7
    Description                                            Type Start Length Element 

                BUYER'S ITEM #                              AN   009   035    1LIN030

                ..('                                     ') AN   044   037           

                Record Length:                                         080           

             Record '42' (10 x - End Record '42')           42   001   002           

                DRAWING REV/SUPPLIER ITEM #                 AN   003   035    1PIA020

                ITEM NUMBER TYPE                            AN   038   003    1PIA020

                ITEM NUMBER                                 AN   041   035    1PIA030

                ITEM NUMBER TYPE, CODED                     AN   076   003    1PIA030

                FILLER('  ')                                AN   079   002           

                Record Length:                                         080           

             Record '43'                                    43   001   002           

                DESPATCH QTY                                R    003   017    2QTY010

                MEA UNIT TYPE                               AN   020   003    2QTY010

                COUNTRY OF ORIGIN CODE                      AN   023   003    1ALI01 

                ('                                      ... AN   026   055           

                Record Length:                                         080           

             Loop Start (99 x - End Record '48')                                     

                Record '44'                                 44   001   002           

                   FREE TEXT                                AN   003   070    1FTX040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '45'                                 45   001   002           

                   FREE TEXT                                AN   003   070    1FTX040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '46'                                 46   001   002           

                   FREE TEXT                                AN   003   070    1FTX040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '47'                                 47   001   002           

                   FREE TEXT                                AN   003   070    1FTX040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

                Record '48'                                 48   001   002           

                                          8
    Description                                            Type Start Length Element 

                   FREE TEXT                                AN   003   070    1FTX040

                   FILLER('        ')                       AN   073   008           

                   Record Length:                                      080           

             Record '49'                                    49   001   002           

                BUYER'S ORDER #                             AN   003   035    2RFF010

                WAREHOUSE ID                                AN   038   025    1LOC020

                FILLER('                  ')                AN   063   018           

                Record Length:                                         080           


*/



--dbo.usp_ShipNotice_HBPO 79135
set ANSI_Padding on
--ASN Header

declare
	@TradingPartner	char(12),
	@ShipperID char(35),
	@ShipperIDHeader char(30),
	@PartialComplete char(1),
	@ASNDate char(8),
	@ASNTime char(4),
	@ASNDateTime char(35),
	@ShippedDate char(8),
	@ShippedTime char(4),
	@ShippedDateTime char(35),
	@ArrivalDate char(35),
	@ArrivalTime char(4),
	@ArrivalDateTime char(35),
	@GrossWeightLbs char(18),
	@NetWeightLbs char(18),
	@PackagingCode char(5),
	@PackCount char(8),
	@TDT03_1_TransMode char(3),
	@TDT05_1_SCAC char(17),
	@TDT05_3_AgencyCode char(3),
	@TDT05_4_CarrierName char(35),
	@EQD_01_TrailerNumberQual char(3),	
	@EQD_02_01_TrailerNumber char(17),
	@REFBMQual char(3),
	@REFPKQual char(3),
	@REFCNQual char(3),
	@REFBMValue char(35),
	@REFPKValue char(35),
	@REFCNValue char(35),
	@FOB char(2),
	@SupplierName char(75),
	@SupplierCode char(35),
	@ShipToName char(35),
	@ShipToID char(35),
	@RoutingCode char(35),
	@BuyerID char(35),
	@BuyerName char(35),
	@SellerID char(35),
	@SellerName char(75),
	@SoldToID char(35),
	@ConsolidationCenterID char(35),
	@SoldToName char(35),
	@ConsolidationCenterName char(35),
	@LOC02_DockCode char(25),
	@MEAGrossWghtQualfier char(3) ,
	@MEANetWghtQualfier char(3) ,
	@MEALadingQtyQualfier char(3),
	@MEAGrossWghtUM char(3) ,
	@MEANetWghtUM char(3) ,
	@MEALadingQtyUM char(3) ,
	@MEAGrossWghtKG char(18),
	@MEANetWghtKG  char(18), 
	@MEALadingQty char(18),
	@REFProNumber char(35),
	@DESADV char(10) ,
	@NADBuyerAdd1 char(35)  ,
	@NADSupplierAdd1 char(35) ,
	@NADShipToAdd1 char(35)  ,
	@NADShipToID char(35)
	
	select
		@TDT03_1_TransMode  = '3',
		@TDT05_3_AgencyCode  = '182',
		@EQD_01_TrailerNumberQual = 'TL',
		@MEAGrossWghtQualfier = 'G',
		@MEANetWghtQualfier = 'N',
		@MEALadingQtyQualfier = 'SQ',
		@MEAGrossWghtUM = 'KG',
		@MEANetWghtUM  = 'KG',
		@MEALadingQtyUM = 'C62',
		@DESADV = 'DESADV',
		@NADBuyerAdd1 = coalesce(c.address_1, 'HBPO Buyer Street Address'),
		@NADSupplierAdd1 = '2801 Howard Ave',
		@NADShipToAdd1 = coalesce(d.address_1, 'HBPO Ship To Street Address'),
		@TradingPartner	= coalesce(es.trading_partner_code, 'HBPO'),
		@ShipperID =  s.id,
		@ShipperIDHeader =  s.id,
		@PartialComplete = '' ,
		@ASNDate = convert(char, getdate(), 112) ,
		@ASNTime = left(replace(convert(char, getdate(), 108), ':', ''),4),
		@ASNDateTime = rtrim(@ASNDate)+rtrim(@ASNTime),
		@ShippedDate = convert(char, s.date_shipped, 112)  ,
		@ShippedTime =  left(replace(convert(char, date_shipped, 108), ':', ''),4),
		@ShippedDateTime = rtrim(@ShippedDate)+rtrim(@ShippedTime),
		@ArrivalDate = convert(char, dateadd(dd,1, s.date_shipped), 112)  ,
		@ArrivalTime =  left(replace(convert(char, date_shipped, 108), ':', ''),4),
		@ArrivalDateTime = rtrim(@ArrivalDate)+rtrim(@ArrivalTime),
		@GrossWeightLbs = convert(char,convert(int,s.gross_weight)),
		@MEAGrossWghtKG = convert(char,convert(int,s.gross_weight/2.2)),
		@MEANetWghtKG = convert(char,convert(int,s.net_weight/2.2)),
		@PackagingCode = 'CNT71' ,
		@MEALadingQty = s.staged_objs,
		@TDT05_1_SCAC = s.ship_via,
		@TDT05_4_CarrierName = s.ship_via,
		@EQD_02_01_TrailerNumber = coalesce(nullif(s.truck_number,''), s.id),
		@REFBMQual = 'BM' ,
		@REFPKQual = 'PK',
		@REFCNQual = 'CN',
		@REFBMValue = coalesce(bill_of_lading_number, id),
		@REFPKValue = id,
		@REFCNValue = coalesce(pro_number,''),
		@FOB = case when freight_type =  'Collect' then 'CC' when freight_type in  ('Consignee Billing', 'Third Party Billing') then 'TP' when freight_type  in ('Prepaid-Billed', 'PREPAY AND ADD') then 'PA' when freight_type = 'Prepaid' then 'PP' else '' end ,
		@RoutingCode = 'NA',
		@ConsolidationCenterID  = case when trans_mode like '%A%' then '' else coalesce(pool_code, '') end,
		@ConsolidationCenterName = coalesce((select max(name) from destination where destination = pool_code),''),
		@SoldToID = d.destination,
		@SoldToName =  d.name,
		@ShipToID = coalesce(es.parent_destination, es.destination),
		@LOC02_DockCode = coalesce(s.shipping_dock,''),
		@ShipToName =  d.name,
		@SellerID =  coalesce(es.supplier_code,'SUPP'),
		@SellerName = 'Titan Tool & Die, Ltd.',
		@SupplierCode =  coalesce(es.supplier_code,'SUPP'),	
		@SupplierName = 'Titan Tool & Die, Ltd.',
		@BuyerID = c.customer,
		@BuyerName = 'HBPO'
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
	

Create	table	#ASNFlatFile (
				LineId	int identity,
				LineData char(79) )

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'//STX12//X12'
				+ @TradingPartner 
				+ @ShipperIDHeader
				+ @PartialComplete
				+ @DESADV 
				+ left(@DESADV,6)
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'01'
				+  @ShipperID 
				+  @ASNDateTime  )

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'02'
				+  @ShippedDateTime 
				+  @ArrivalDateTime  )


INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+ @MEAGrossWghtQualfier
				+ @MEAGrossWghtUM
				+ @MEAGrossWghtKG 
				
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+ @MEANetWghtQualfier
				+ @MEANetWghtUM
				+ @MEANetWghtKG 
				
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+ @MEALadingQtyQualfier
				+ @MEALadingQtyUM
				+ @MEALadingQty				
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'04'
				+ @REFCNValue
				+ @BuyerID
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'05'
				+ @BuyerName
				+ @NADBuyerAdd1
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'07'
				+ @SupplierCode
				+ @SupplierName
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'08'
				+ @NADSupplierAdd1	
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'10'
				+ @ShipToID
				+ @ShipToName
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'11'
				+ @NADShipToAdd1	
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'13'
				+ @LOC02_DockCode
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'14'
				+ @TDT03_1_TransMode
				+ @TDT05_1_SCAC
				+ @TDT05_3_AgencyCode 
				+ @TDT05_4_CarrierName
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'15'
				+ @EQD_01_TrailerNumberQual
				+ @EQD_02_01_TrailerNumber
			)


 --ASN Detail

declare	@ShipperDetail table (
	ID int identity(1,1),
	Part varchar(25),
	CustomerPart varchar(35),
	CustomerPO varchar(35),
	CustomerECL varchar(35),
	DockCode varchar(35),
	Qty int,
	AccumShipped int primary key (ID))
	
insert	@ShipperDetail 
(	Part,
	CustomerPart,
	CustomerPO,
	CustomerECL,
	DockCode,
	Qty,
	AccumShipped
	)
	
select
	part_original,
	sd.customer_part,
	sd.customer_po,
	coalesce(oh.engineering_level,''),
	coalesce(s.shipping_dock,''),
	qty_packed,
	sd.accum_shipped
from
	shipper_detail sd
join
	order_header oh on oh.order_no = sd.order_no
join
	shipper s on s.id = @shipper
Where
	sd.shipper = @shipper
	
	
declare	@AuditTrailLooseSerial table (
Part varchar(25),
PackageType varchar(35),
PartPackCount int,
SerialQuantity int,
ParentSerial int,
Serial int, 
id int identity primary key (id))
	
insert	@AuditTrailLooseSerial 
(	Part,
	PackageType,
	PartPackCount,
	SerialQuantity,
	ParentSerial,
	Serial 
)
	
select
	part,
	coalesce(pm.name,'CTN71') ,
	1,
	quantity,
	0,
	serial
from
	dbo.audit_trail at
left join
	dbo.package_materials pm on pm.code = at.package_type
Where
	at.shipper = convert(varchar(15),@shipper) and
	at.type = 'S' and
	nullif(at.parent_serial,0) is null and
	part != 'Pallet'
order by serial	

declare	@AuditTrailPartPackGroup table (
Part varchar(25),
PackageType varchar(35),
PartPackQty int, 
PartPackCount int, primary key (Part, PackageType, PartPackQty))


insert	@AuditTrailPartPackGroup
(	Part,
	PackageType,
	PartPackQty,
	PartPackCount
)

Select 
	part,
	PackageType,
	SerialQuantity,
	sum(PartPackCount)
From
	@AuditTrailLooseSerial
group by
	part,
	PackageType,
	SerialQuantity



declare	@AuditTrailPartPackGroupRangeID table (
Part varchar(25),
PackageType varchar(35),
PartPackQty int,
Serial int,
RangeID int, primary key (Serial))


insert	@AuditTrailPartPackGroupRangeID
(	Part,
	PackageType,
	PartPackQty,
	Serial,
	RangeID
)

Select 
	atl.part,
	atl.PackageType,
	SerialQuantity,
	Serial,
	Serial-id
	
From
	@AuditTrailLooseSerial atL
join
	@AuditTrailPartPackGroup atG on
	atG.part = atl.part and
	atg.packageType = atl.PackageType and
	atg.partPackQty = atl.SerialQuantity



declare	@AuditTrailPartPackGroupSerialRange table (
Part varchar(25),
PackageType varchar(35),
PartPackQty int,
SerialRange varchar(50), primary key (SerialRange))


insert	@AuditTrailPartPackGroupSerialRange
(	Part,
	PackageType,
	PartPackQty,
	SerialRange
)

Select 
	part,
	PackageType,
	PartPackQty,
	Case when min(serial) = max(serial) 
		then convert(varchar(15), max(serial)) 
		else convert(varchar(15), min(serial)) + ':' + convert(varchar(15), max(serial)) end
From
	@AuditTrailPartPackGroupRangeID atR

group by
	part,
	PackageType,
	PartPackQty,
	RangeID


/*	Select * From @ShipperDetail
	Select * From @AuditTrailLooseSerial
	Select * From @AuditTrailPartPackGroupRangeID
	Select * From @AuditTrailPartPackGroup
	Select * From @AuditTrailPartPackGroupSerialRange
*/


--Delcare Variables for ASN Details		
declare	
	@LineItemID char(6),
	@CustomerPart char(35) ,
	@Part varchar(50),
	@SupplierPart char(35),
	@SupplierPartQual char(3),
	@CountryOfOrigin char(3),
	@PartQty char(12),
	@PartAccum char(12),
	@PartUM char(3),
	@CustomerPO char(35),
	@CustomerECL char(35),
	@CustomerECLQual char(3),
	@PackageType char(17),
	@DunnagePackType char(17),
	@DunnageCount char(10),
	@DunnageIdentifier char(3),
	@PartPackQty char(17),
	@PartPackCount char(10),
	@PCIQualifier char(3),
	@Serial char(20),
	@DockCode char(25),
	@PCI_S char(3),
	@PCI_M char(3),
	@SupplierSerial char(35),
	@CPS03 Char(3),
	@UM char(3)
	 
--Populate Static Variables
select	@CountryOfOrigin = 'CA'
select	@PartUM = 'EA'	
select	@PCI_S = 'S'
select	@PCI_M = 'M'
Select	@DunnageIdentifier = '37'
Select	@DunnagePackType = 'HBPODunnage'
Select	@UM = 'C62'
Select  @PCIQualifier = '17'
Select 	@CPS03 = 1
Select	@SupplierPartQual = 'SA'
Select	@CustomerECLQual = 'DR'
 			
declare
	PartPOLine cursor local for
select
	ID = ID,
	InternalPart = Part,
	CustomerPart = customerpart,
	CustomerPO = customerpo,
	CustomerECL = customerECL,
	DockCode = DockCode,
	QtyShipped = convert(int, Qty),
	AccumShipped = convert(int, AccumShipped)
From
	@ShipperDetail SD

open
	PartPOLine

while
	1 = 1 begin
	
	fetch
		PartPOLine
	into
		@LineItemID,
		@Part,
		@CustomerPart,
		@CustomerPO,
		@CustomerECL,
		@DockCode,
		@PartQty,
		@PartAccum
			
	if	@@FETCH_STATUS != 0 begin
		break
	end

		

		Insert	#ASNFlatFile (LineData)
		Select '33'
				+ @CPS03


		declare PartPack cursor local for
			select
				*
			From
				@AuditTrailPartPackGroup
			where
				part = @Part
												
			open
				PartPack

			while
				1 = 1 begin
							
				fetch
					PartPack
				into
					@Part,
					@PackageType,
					@PartPackQty,
					@PartPackCount
								
																								
				if	@@FETCH_STATUS != 0 begin
					break
				end
					Select @DunnageCount = floor((convert(int,@PartPackQty) -.1)/6)+1
																					
					Insert	#ASNFlatFile (LineData)
					Select  '34' 
							+ space(10)
							+ space(3)
							+ space(17)										
							+ @PartPackCount
							+ @PackageType
							+ @PartPackQty
							+ @UM
							
								
					Insert	#ASNFlatFile (LineData)
					Select  '35' 
							+ @PCIQualifier
							+ @PCI_S
										
																	
							declare PartPackSerialRange cursor local for

							Select	
								SerialRange
								From
									@AuditTrailPartPackGroupSerialRange
								Where
									part = @part and
									PackageType = @PackageType and
									PartPackQty = @PartPackQty

													

								open
									PartPackSerialRange

								while
									1 = 1 begin
																					
									fetch
										PartPackSerialRange
									into
										@SupplierSerial
																							
									if	@@FETCH_STATUS != 0 begin
										break
									end
																									
										Insert	#ASNFlatFile (LineData)
										Select  '36' +  @SupplierSerial
																	
									End
																					
									close
										PartPackSerialRange
									deallocate
										PartPackSerialRange
																			
														
																					
					End
							
					close
						PartPack
					deallocate
						PartPack
	

		Select @SupplierPart = @Part
		Insert	#ASNFlatFile (LineData)
		Select  '41' 
				+ @LineItemID 
				+ @CustomerPart
		
		Insert	#ASNFlatFile (LineData)
		Select  '42' 
				+ @SupplierPart 
				+ @SupplierPartQual
				+ @CustomerECL
				+ @CustomerECLQual
		
		Insert	#ASNFlatFile (LineData)
		Select  '43' 
				+ @PartQty 
				+ @UM 
				+ @CountryOfOrigin
		
		Insert	#ASNFlatFile (LineData)
		Select  '49' 
				+ @CustomerPO 
				+ @DockCode
	
	end	
	
	
close
	PartPOLine	
 
deallocate
	PartPOLine


select 
	LineData +convert(char(1), (lineID % 2 ))
From 
	#ASNFlatFile
order by 
	LineID

	
	      
set ANSI_Padding OFF	
End
         








GO
