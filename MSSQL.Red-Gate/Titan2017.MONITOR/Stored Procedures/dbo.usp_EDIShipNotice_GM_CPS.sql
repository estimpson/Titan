SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[usp_EDIShipNotice_GM_CPS]  (@shipper int)
as
begin
-- Test
-- Exec [dbo].[usp_EDIShipNotice_GM_CPS] 79419
-- Affects Trading Partners GM MGO
/*
   
    FlatFile Layout for Overlay: GM2_DESADV_D_Dr97A_GM MGO_120303    

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

       SHIPMENT ID #                                        AN   003   055    1BGM02 

       ASN PURPOSE                                          AN   058   001    1BGM03 

       ASN DATE/TIME                                        AN   059   012    1DTM010

       FILLER('          ')                                 AN   071   010           

       Record Length:                                                  080           

    Record '02'                                             02   001   002           

       SHIPPED DATE/TIME                                    AN   003   012    2DTM010

       DATE/TIME TYPE                                       AN   015   003    3DTM010

       DATE/TIME                                            AN   018   012    3DTM010

       DATE/TIME FORMAT                                     AN   030   003    3DTM010

       ('                                                ') AN   033   048           

       Record Length:                                                  080           

    Record '03' (3 x - End Record '03')                     03   001   002           

       WEIGHT TYPE                                          AN   003   003    1MEA020

       UOM                                                  AN   006   003    1MEA030

       WEIGHT                                               AN   009   018    1MEA030

       ('                                               ... AN   027   054           

       Record Length:                                                  080           

                                          1
    Description                                            Type Start Length Element 

    Record '04' (2 x - End Record '04')                     04   001   002           

       REF # TYPE                                           AN   003   003    1RFF010

       CARRIER REF #/MASTER BOL #                           AN   006   035    1RFF010

       FILLER('                                        ')   AN   041   040           

       Record Length:                                                  080           

    Loop Start (5 x - End Record '05')                                               

       Record '05'                                          05   001   002           

          PARTY TYPE                                        AN   003   003    2NAD01 

          ID CODE                                           AN   006   035    2NAD020

          ID CODE TYPE                                      AN   041   003    2NAD020

          DOCK CODE                                         AN   044   025    2LOC020

          FILLER('            ')                            AN   069   012           

          Record Length:                                               080           

    Record '06' (2 x - End Record '06')                     06   001   002           

       TRANSPORT STAGE                                      AN   003   002    1TDT01 

       TRANSPORT MODE                                       AN   005   003    1TDT030

       CARRIED ID                                           AN   008   017    1TDT050

       CODE LIST RESP AGENCY                                AN   025   003    1TDT050

       EXCESS TRANS REASON CODE                             AN   028   003    1TDT070

       EXCESS TRANSPORT RESP CODE                           AN   031   003    1TDT070

       CUSTOMER AUTHORIZATION #                             AN   034   017    1TDT070

       FILLER('                              ')             AN   051   030           

       Record Length:                                                  080           

    Record '07' (10 x - End Record '07')                    07   001   002           

       EQUIPT TYPE                                          AN   003   003    1EQD01 

       EQUIPT INITIAL - #                                   AN   006   017    1EQD020

       ('                                               ... AN   023   058           

       Record Length:                                                  080           

    Record '08' (25 x - End Record '08')                    08   001   002           

       SEAL #                                               AN   003   010    1SEL01 

       ('                                               ... AN   013   068           

       Record Length:                                                  080           

    Loop Start (9999 x - End Record '29')                                            

       Record '09'                                          09   001   002           

                                          2
    Description                                            Type Start Length Element 

          PACKAGING LEVEL CODE                              AN   003   003    1CPS03 

          ('                                            ... AN   006   075           

          Record Length:                                               080           

       Loop Start (9999 x - End Record '13')                                         

          Record '10'                                       10   001   002           

             # OF PACKAGES                                  R    003   010    1PAC01 

             PACKAGE TYPE                                   AN   013   017    1PAC030

             ('                                         ... AN   030   051           

             Record Length:                                            080           

          Loop Start (1000 x - End Record '13')                                      

             Record '11'                                    11   001   002           

                PACKAGING INSTRUCTIONS                      AN   003   002    2PCI01 

                REF # TYPE                                  AN   005   003    3RFF010

                REF #                                       AN   008   035    3RFF010

                .('                                      ') AN   043   038           

                Record Length:                                         080           

             Loop Start (99 x - End Record '13')                                     

                Record '12'                                 12   001   002           

                   PRODUCT ID                               AN   003   035    1GIR020

                   PRODUCT ID TYPE                          AN   038   003    1GIR020

                   IDENTITY NUMBER                          AN   041   035    1GIR030

                   IDENTITY # TYPE                          AN   076   003    1GIR030

                   FILLER('  ')                             AN   079   002           

                   Record Length:                                      080           

                Record '13'                                 13   001   002           

                   IDENTITY NUMBER                          AN   003   035    1GIR040

                   IDENTITY # TYPE                          AN   038   003    1GIR040

                   ('                                   ... AN   041   040           

                   Record Length:                                      080           

       Loop Start (9999 x - End Record '29')                                         

          Record '14'                                       14   001   002           

             BUYER ITEM #                                   AN   003   035    1LIN030

             MODEL YR                                       AN   038   035    1PIA020

             FILLER('        ')                             AN   073   008           

                                          3
    Description                                            Type Start Length Element 

             Record Length:                                            080           

          Record '15'                                       15   001   002           

             ITEM NUMBER                                    AN   003   035    1PIA030

             ITEM # TYPE                                    AN   038   003    1PIA030

             ITEM NUMBER                                    AN   041   035    1PIA040

             ITEM # TYPE                                    AN   076   003    1PIA040

             FILLER('  ')                                   AN   079   002           

             Record Length:                                            080           

          Record '16' (3 x - End Record '16')               16   001   002           

             QUANTITY TYPE                                  AN   003   003    1QTY010

             QUANTITY                                       R    006   014    1QTY010

             UOM                                            AN   020   003    1QTY010

             ('                                         ... AN   023   058           

             Record Length:                                            080           

          Record '17'                                       17   001   002           

             COUNTRY OF ORIGIN CODE                         AN   003   003    1ALI01 

             ORDER #                                        AN   006   035    2RFF010

             ..('                                        ') AN   041   040           

             Record Length:                                            080           

          Loop Start (9999 x - End Record '29')                                      

             Record '18'                                    18   001   002           

                BAR CODE SERIAL #                           AN   003   035    1PCI020

                SHIPPING MARKS                              AN   038   035    1PCI020

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '19'                                    19   001   002           

                SHIPPING MARKS                              AN   003   035    1PCI020

                SHIPPING MARKS                              AN   038   035    1PCI020

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '20'                                    20   001   002           

                SHIPPING MARKS                              AN   003   035    1PCI020

                SHIPPING MARKS                              AN   038   035    1PCI020

                FILLER('        ')                          AN   073   008           

                                          4
    Description                                            Type Start Length Element 

                Record Length:                                         080           

             Record '21'                                    21   001   002           

                SHIPPING MARKS                              AN   003   035    1PCI020

                SHIPPING MARKS                              AN   038   035    1PCI020

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '22'                                    22   001   002           

                SHIPPING MARKS                              AN   003   035    1PCI020

                SHIPPING MARKS                              AN   038   035    1PCI021

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '23' (10 x - End Record '23')           23   001   002           

                MEASUREMENT TYPE                            AN   003   003    2MEA020

                UOM                                         AN   006   003    2MEA030

                MEASUREMENT VALUE                           AN   009   018    2MEA030

                ('                                      ... AN   027   054           

                Record Length:                                         080           

             Record '24'                                    24   001   002           

                PRIMARY METALS SHIP QTY                     R    003   014    4QTY010

                UOM                                         AN   017   003    4QTY010

                HEAT CODE                                   AN   020   035    1GIN020

                FILLER('                          ')        AN   055   026           

                Record Length:                                         080           

             Record '25'                                    25   001   002           

                IDENTITY #                                  AN   003   035    1GIN020

                IDENTITY #                                  AN   038   035    1GIN030

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '26'                                    26   001   002           

                IDENTITY #                                  AN   003   035    1GIN030

                IDENTITY #                                  AN   038   035    1GIN040

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '27'                                    27   001   002           

                                          5
    Description                                            Type Start Length Element 

                IDENTITY #                                  AN   003   035    1GIN040

                IDENTITY #                                  AN   038   035    1GIN050

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '28'                                    28   001   002           

                IDENTITY #                                  AN   003   035    1GIN050

                IDENTITY #                                  AN   038   035    1GIN060

                FILLER('        ')                          AN   073   008           

                Record Length:                                         080           

             Record '29'                                    29   001   002           

                IDENTITY #                                  AN   003   035    1GIN060

                ('                                      ... AN   038   043           

                Record Length:                                         080           


*/

set ANSI_Padding on
--ASN Header

declare
--Variables for Flat File


--//Line
		@TradingPartner	char(12),
		@DESADV char(10),
		@ShipperIDHeader char(30),
		@PartialComplete char(1) ,

--Header
		@1BGM010Purpose char(3),
		@1BGM020ShipperID char(55),
		@1BGM030Purpose char(1),
		@1DTM010QualifierASNDate char(3),	
		@1DTM010ASNDate char(12),
		@1DTM010QualifierDateShipped char(3),
		@1DTM010DateShipped char(12),
		@1DTM010QualifierArrivalDate char(3),
		@1DTM010ArrivalDate char(12),
		@3DTMDateTimeFormat char(3),
		@1MEA020QualifierGrossWeight Char(3),
		@1MEA020GrossWeight Char(18),
		@1MEA020GrossWeightUM Char(3),
		@1MEA020QualifierNetWeight Char(3),
		@1MEA020NetWeight Char(18),
		@1MEA020NetWeightUM Char(3),
		@1MEA020QualifierPackCount Char(3),
		@1MEA020PackCount Char(18),
		@1MEA020PackCountUM Char(3),
		@1RFF010REFTypeBMQualifier Char(3),
		@1RFF010REFTypeBM Char(35) ,
		@2RFF010ProNumber Char(35),
		@NADIDCodeType16 char(3) ,
		@NADIDCodeType92 char(3) ,
		@2NAD020MaterialIssuerQualifier char(3),
		@2NAD020MaterialIssuer char(35),
		@2NAD020ShipToIDQualifier char(3),
		@2NAD020ShipToID char(35),
		@1LOC020DockCode char(25),
		@2NAD020SupplierCodeQualifier char(3),
		@2NAD020SupplierCode char(35),
		@1TDT010TransStage char(2),
		@1TDT030TransMode char(3),
		@1TDT050SCAC char(17),
		@1TDT050RespAgency char(3),
		@1TDT070AETCReason char(3),
		@1TDT070AETCResponsibilty char(3),
		@1TDT070AETC char(17) ,
		@1EQD01EquipmentType char(3),
		@1EQD020EquipmentID char(17),
		@1SEL01SealNo char(10),



--Detail
		@2CPS01CPSCounter char(12),
		@2CPS03CPSIndicator char(3),
		@1PAC01PackageCount char(10),
		@1PAC01PackageType char(17),
		@1PCI01MarkingInstructions char(3),
		@3RFF010ProNumber char(35),
		@2LIN01LineItem char(6),
		@2LIN030CustomerPart char(35),
		@1PIAModelYear char(35),
		@2QTY010QtyTypeShipped char(3) ,
		@2QTY010QtyShipped char(14),
		@2QTY010QtyShippedUM char(3) ,
		@2QTY010AccumTypeShipped char(3) ,
		@2QTY010AccumShipped char(14),
		@2QTY010AccumShippedUM char(3),
		@1RFF010CustomerPOType char(3),
		@1RFF010CustomerPO char(25),


	--Variables for Processing Data

	@PackTypeType int,
	@InternalPart varchar(25),
	@PackageType varchar(25),
	@PalletPackageType varchar(25),
	@CPS03Indicator int

	
	Select @1PIAModelYear = SUBSTRING(CONVERT(VARCHAR(25), GETDATE(), 112),3,2)
	Select @DESADV =  'DESADV'
	Select @ShipperIDHeader = @Shipper
	Select @PartialComplete = ''
	Select @1BGM010Purpose = '351'
	Select @1BGM030Purpose  = '9'
	Select @1DTM010QualifierASNDate = '137'
	Select @1DTM010QualifierDateShipped = '11'
	Select @1DTM010QualifierArrivalDate = '132'
	Select @3DTMDateTimeFormat  = '203'
	Select @1MEA020QualifierGrossWeight = 'G'
	Select @1MEA020GrossWeightUM  = 'LBR'
	Select @1MEA020QualifierNetWeight = 'N'
	Select @1MEA020NetWeightUM = 'LBR'
	Select @1MEA020QualifierPackCount = 'SQ'
	Select @1MEA020PackCountUM = 'C62'
	Select @1RFF010REFTypeBMQualifier = 'MB'
	Select @NADIDCodeType16 = '16'
	Select @NADIDCodeType92 = '92'
	Select @2NAD020MaterialIssuerQualifier = 'MI'
	Select @2NAD020ShipToIDQualifier = 'ST'
	Select @2NAD020SupplierCodeQualifier = 'SU'
	Select @1TDT010TransStage = '12'
	Select @1TDT050RespAgency = '182'
	Select @1EQD01EquipmentType = 'TE'

	Select @1PCI01MarkingInstructions = '16'
	Select @2LIN01LineItem = ''
	Select @2QTY010QtyTypeShipped = '12'
	Select @2QTY010QtyShippedUM = 'C62'
	Select @2QTY010AccumTypeShipped = '3'
	Select @2QTY010AccumShippedUM = 'C62'
	Select @1RFF010CustomerPOType = 'ON'





	/*
	@PurposeCode char(2) = '00',	
	@ASNDate char(8),
	@ASNTime char(8),
	@ASNDateTime char(35),
	@ShippedDateQualifier char(3) = '011',
	@ShippedDate char(8),
	@ShippedTime char(8),
	@ShipDateTimeZone char(2),
	@ShippedDateTime char(35),
	@ArrivalDateQualifier char(3) = '017',
	@ArrivalDate char(8),
	@ArrivalTime char(8),
	@ArrivalDateTimeZone char(2),
	@ArrivalDateTime char(35),
	@GrossWeightQualifier char(3),
	@GrossWeightLbs char(22),
	@NetWeightQualifier char(3),
	@NetWeightLbs char(22),
	@TareWeightQualifier char(3),
	@TareWeightLbs char(22),
	@TD101_PackagingCode char(5),
	@TD102_PackCount char(8),
	@TD501_RoutingSequence char(2) = 'B',
	@TD502_IDCodeType char(2) = '2',
	@TD503_SCAC char(78),
	@TD504_TransMode char(2),
	@TD507_LocType char(2) = 'OR',
	@TD508_Location char(30) = 'DTW',
	@EQD_01_TrailerNumberQual char(3) = 'TL',	
	@EQD_02_01_TrailerNumber char(17),
	@REFBMQual char(3),
	@REFPKQual char(3),
	@REFCNQual char(3),
	@REFBMValue char(78),
	@REFPKValue char(78),
	@REFCNValue char(78),
	@FOB01_MethodOfPayment char(2),
	@FOB02_LocType char(2) = 'CA',
	@FOB03_LocDescription char(78) = 'US',
	@FOB04_TransTermsType char(2) = '01',
	@FOB05_TransTermsCode char(3),
	@FOB06_LocationType char(2) = 'AC',
	@FOB07_LocationDesription char(78) = 'TROY, MICHIGAN',
	@N102_SupplierName char(60) = 'Empire Electronics, Inc.',
	@N104_SupplierCode char(78),
	@N102_ShipToName char(60),
	@N104_ShipToID char(78),
	@REF02_DockCode char(78),
	@N104_RemitToCode char(78),
	@N102_RemitToName char(60),
	@TD301_EquipmentDesc  char(2) = 'TL' ,
	@TD302_EquipmentIntial char(4),
	@TD303_EquipmentNumber char(15),
	@TD305_GrossWeight char(12),
	@TD305_GrossWeightUM char(2) ='LB',
	@TDT03_1_TransMode char(5),
	@TD309_SealNumber char(15),
	@TD310_EquipmentType char(4),
	@N104_ContainerCode char(78),
	@N102_ContainerLocation char(60),
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
	@MEAGrossWghtQualfier char(3) = 'G',
	@MEANetWghtQualfier char(3) = 'N',
	@MEATareWghtQualfier char(3) = 'T',
	@MEALadingQtyQualfier char(3) = 'SQ',
	@MEAGrossWghtUMKG char(3) = 'KG',
	@MEANetWghtUMKG char(3) = 'KG',
	@MEALadingQtyUM char(3) = 'C62',
	@MEAGrossWghtKG char(18),
	@MEANetWghtKG  char(18), 
	@MEALadingQty char(18),
	@MEAGrossWghtLBS char(22),
	@MEANetWghtLBS  char(22),
	@MEATareWghtLBS  char(22), 
	@MEAGrossWghtUMLB char(2) = 'LB',
	@MEANetWghtUMLB char(2) = 'LB',
	@MEATareWghtUMLB char(2) = 'LB',
	@REFProNumber char(35),
	@NADBuyerAdd1 char(35) = ' ' ,
	@NADSupplierAdd1 char(35) = '',
	@NADShipToAdd1 char(35) = '',
	@NADShipToID char(35)
*/
	
	select
		@TradingPartner	= coalesce(es.trading_partner_code, 'BFT GM'),
		@1BGM020ShipperID  =  s.id,
		@1DTM010ASNDate = CONVERT(VARCHAR(25), GETDATE(), 112)+LEFT(CONVERT(VARCHAR(25), GETDATE(), 108),2) +SUBSTRING(CONVERT(VARCHAR(25), GETDATE(), 108),4,2),
		@1DTM010DateShipped = CONVERT(VARCHAR(25), s.date_shipped, 112)+LEFT(CONVERT(VARCHAR(25), s.date_shipped, 108),2) +SUBSTRING(CONVERT(VARCHAR(25), s.date_shipped, 108),4,2),
		@1DTM010ArrivalDate = CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),s.date_shipped), 112)+LEFT(CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),s.date_shipped), 108),2) +SUBSTRING(CONVERT(VARCHAR(25), DATEADD(dd, ISNULL(CONVERT(INT,id_code_type),0),s.date_shipped), 108),4,2),
		@1MEA020GrossWeight = convert(int, s.gross_weight),
		@1MEA020NetWeight = convert(int, s.net_weight),
		@1MEA020PackCount = convert(int , s.staged_objs),
		@1RFF010REFTypeBM = coalesce(s.bill_of_lading_number, s.id),
		@2RFF010ProNumber = coalesce(s.pro_number, convert(varchar(15),s.id)),
		@2NAD020MaterialIssuer = coalesce(es.material_issuer,'17501'),
		@2NAD020ShipToID =  coalesce(substring(s.destination,2,10), NULLIF(es.parent_destination,'') ,s.destination ,''),
		@1LOC020DockCode = coalesce(s.shipping_dock,''),
		@2NAD020SupplierCode = coalesce(es.supplier_code,''),
		@1TDT030TransMode = coalesce(s.trans_mode, 'LT'),
		@1TDT050SCAC = Coalesce(s.ship_via,''),
		@1EQD020EquipmentID = Coalesce(s.truck_number, s.id),
		@1TDT070AETCReason = '',-- coalesce(substring(s.aetc_number,1,1),''),
		@1TDT070AETCResponsibilty = '', --coalesce(substring(s.aetc_number,2,1),'') ,
		@1TDT070AETC = '',-- coalesce(substring(s.aetc_number,3,25),''),
		@1SEL01SealNo = coalesce(s.seal_number,'') 
		
		/*@ASNTime = left(replace(convert(char, getdate(), 108), ':', ''),4),
		@ASNDateTime = rtrim(@ASNDate)+rtrim(@ASNTime),
		@ShippedDate = convert(char, s.date_shipped, 112)  ,
		@ShipDateTimeZone = [dbo].[udfGetDSTIndication](s.date_shipped),
		@ShippedTime =  left(replace(convert(char, date_shipped, 108), ':', ''),4),
		@ShippedDateTime = rtrim(@ShippedDate)+rtrim(@ShippedTime),
		@ArrivalDate = convert(char, dateadd(dd,1, s.date_shipped), 112)  ,
		@ArrivalTime =  left(replace(convert(char, date_shipped, 108), ':', ''),4),
		@ArrivalDateTimeZone = [dbo].[udfGetDSTIndication](s.date_shipped),
		@ArrivalDateTime = rtrim(@ArrivalDate)+rtrim(@ArrivalTime),
		@MEAGrossWghtLBS = convert(char,convert(int,s.gross_weight)),
		@MEANetWghtLBS = convert(char,convert(int,s.net_weight)),
		@MEATareWghtLBS = convert(char,convert(int,s.gross_weight-s.net_weight)),
		@MEAGrossWghtKG = convert(char,convert(int,s.gross_weight/2.2)),
		@MEANetWghtKG = convert(char,convert(int,s.net_weight/2.2)),
		@TD101_PackagingCode = 'CNT71' ,
		@TD102_PackCount = s.staged_objs,
		@TD503_SCAC = s.ship_via,
		@TD504_TransMode = coalesce(s.trans_mode,'M'),
		@TD302_EquipmentIntial = left(coalesce(nullif(s.truck_number,''), s.id),3),
		@TD303_EquipmentNumber = coalesce(nullif(s.truck_number,''), s.id),
		@REFBMQual = 'BM' ,
		@REFPKQual = 'PK',
		@REFCNQual = 'CN',
		@REFBMValue = coalesce(bill_of_lading_number, id),
		@REFPKValue = id,
		@REFCNValue = coalesce(pro_number,''),
		@FOB01_MethodOfPayment = case when freight_type =  'Collect' then 'CC' when freight_type in  ('Consignee Billing', 'Third Party Billing') then 'TP' when freight_type  in ('Prepaid-Billed', 'PREPAY AND ADD') then 'PA' when freight_type = 'Prepaid' then 'PP' else '' end ,
		@RoutingCode = 'NA',
		@ConsolidationCenterID  = case when trans_mode like '%A%' then '' else coalesce(pool_code, '') end,
		@ConsolidationCenterName = coalesce((select max(name) from destination where destination = pool_code),''),
		@SoldToID = d.destination,
		@SoldToName =  d.name,
		@N104_ShipToID = coalesce(es.EDIShipToID, es.parent_destination, es.destination) ,
		@REF02_DockCode = coalesce(s.shipping_dock,''),
		@N102_ShipToName =  d.name,
		@SellerID =  coalesce(es.supplier_code,'Empire'),
		@SellerName = 'Empire',
		@N104_SupplierCode =  coalesce(nullif(es.supplier_code,''),'Empire'),	
		@N102_SupplierName = 'Empire',
		@BuyerID = c.customer,
		@BuyerName = 'Yazaki',
		@FOB05_TransTermsCode = case 
						when s.freight_type like '%[*]%' 
						then substring(s.freight_type, patindex('%[*]%',s.freight_type)+1, 3)
						else s.freight_type
						end,
		@TD305_GrossWeight = convert(char,convert(int,s.gross_weight)),
		@TD305_GrossWeightUM = 'LB',
		@TD309_SealNumber = coalesce(s.seal_number,''),
		@TD310_EquipmentType = 'LTRL'
*/

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
				LineData char(78) )

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'//STX12//X12'
				+		@TradingPartner 
				+		@ShipperIDHeader
				+		@PartialComplete
				+		@DESADV 
				+		left(@DESADV,6)
			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'01'
				+		@1BGM020ShipperID
				+		@1BGM030Purpose
				+		@1DTM010ASNDate
						)


INSERT	#ASNFlatFile (LineData)
	SELECT	(	'02'
				+		@1DTM010DateShipped
				+		@1DTM010QualifierArrivalDate
				+		@1DTM010ArrivalDate
				+		@3DTMDateTimeFormat
						)


INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+		@1MEA020QualifierGrossWeight
				+		@1MEA020GrossWeightUM
				+		@1MEA020GrossWeight
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+		@1MEA020QualifierNetWeight
				+		@1MEA020NetWeightUM
				+		@1MEA020NetWeight
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'03'
				+		@1MEA020QualifierPackCount
				+		@1MEA020PackCountUM
				+		@1MEA020PackCount
						)



INSERT	#ASNFlatFile (LineData)
	SELECT	(	'04'
				+ @1RFF010REFTypeBMQualifier
				+ @1RFF010REFTypeBM			
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'05'
				+		@2NAD020MaterialIssuerQualifier
				+		@2NAD020MaterialIssuer
				+		@NADIDCodeType92	
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'05'
				+		@2NAD020ShipToIDQualifier
				+		@2NAD020ShipToID
				+		@NADIDCodeType92	
				+		@1LOC020DockCode
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'05'
				+		@2NAD020SupplierCodeQualifier
				+		@2NAD020SupplierCode
				+		@NADIDCodeType16	
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'06'
				+		@1TDT010TransStage
				+		@1TDT030TransMode
				+		@1TDT050SCAC
				+		@1TDT050RespAgency
				+		@1TDT070AETCReason
				+		@1TDT070AETCResponsibilty
				+		@1TDT070AETC			
						)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'07'
				+		@1EQD01EquipmentType
				+		@1EQD020EquipmentID			)

INSERT	#ASNFlatFile (LineData)
	SELECT	(	'08'
				+		@1SEL01SealNo
						)


 --ASN Detail

declare	@ShipperDetail table (
	ID int identity(1,1),
	Part varchar(25),
	DefaultPackageType varchar(10),
	PartDescription varchar(100),
	PartUnitWeight numeric(20,6),
	CustomerPart varchar(35),
	CustomerPO varchar(35),
	CustomerECL varchar(35),
	DockCode varchar(35),
	QtyShipped int,
	AccumShipped int primary key (ID))
	
insert	@ShipperDetail 
(	Part,
	DefaultPackageType,
	PartDescription,
	PartUnitWeight,
	CustomerPart,
	CustomerPO,
	CustomerECL,
	DockCode,
	QtyShipped,
	AccumShipped
	)
	
select
	part_original,
	case coalesce(returnable,'N') When 'N' then '4' else '1' end,
	p.name,
	pinv.unit_weight,
	sd.customer_part,
	sd.customer_po,
	coalesce(oh.engineering_level,''),
	shipping_dock,
	qty_packed,
	sd.accum_shipped
from
	shipper_detail sd
join
	order_header oh on oh.order_no = sd.order_no
join
	shipper s on s.id = @shipper
join
	part p on sd.part_original = p.part
join
	part_inventory pinv on pinv.part = p.part
left join
		package_materials pm on oh.package_type = pm.code
Where
	sd.shipper = @shipper
	
	
declare	@AuditTrailSerial table (
Part varchar(25),
ObjectPackageType varchar(35),
PalletPackageType varchar(35),
SerialQuantity int,
ParentSerial int,
Serial int, 
id int identity primary key (id))
	
insert	@AuditTrailSerial 
(		Part,
		ObjectPackageType,
		PalletPackageType,	
		SerialQuantity,
		ParentSerial,
		Serial 
)
	
select
	at.part,
	coalesce( pm.name, at.package_type,'0000CART'),
	Coalesce((Select max(package_type) 
		from audit_trail at2
		left join package_materials pm2 on pm2.code =  at2.package_Type
		where		at2.serial = at.parent_serial and
						at2.shipper = convert(varchar(15),@shipper)  and
						at2.type = 'S'and
						at2.part = 'PALLET'
		),'0000PALT'),
	quantity,
	isNull(at.parent_serial,0),
	serial
from
	dbo.audit_trail at
left join
	dbo.package_materials pm on pm.code = at.package_type
Where
	at.shipper = convert(varchar(15),@shipper) and
	at.type = 'S' and
	part != 'Pallet'
order by		isNull(at.parent_serial,0), 
						part, 
						serial

--declare	@AuditTrailPartPackGroupRangeID table (
--Part varchar(25),
--PackageType varchar(35),
--PartPackQty int,
--Serial int,
--RangeID int, primary key (Serial))


--insert	@AuditTrailPartPackGroupRangeID
--(	Part,
--	PackageType,
--	PartPackQty,
--	Serial,
--	RangeID
--)

--Select 
--	atl.part,
--	atl.PackageType,
--	SerialQuantity,
--	Serial,
--	Serial-id
	
--From
--	@AuditTrailSerial atL
--join
--	@AuditTrailPartPackGroup atG on
--	atG.part = atl.part and
--	atg.packageType = atl.PackageType and
--	atg.partPackQty = atl.SerialQuantity



--declare	@AuditTrailPartPackGroupSerialRange table (
--Part varchar(25),
--PackageType varchar(35),
--PartPackQty int,
--SerialRange varchar(50), primary key (SerialRange))


--insert	@AuditTrailPartPackGroupSerialRange
--(	Part,
--	PackageType,
--	PartPackQty,
--	SerialRange
--)

--Select 
--	part,
--	PackageType,
--	PartPackQty,
--	Case when min(serial) = max(serial) 
--		then convert(varchar(15), max(serial)) 
--		else convert(varchar(15), min(serial)) + ':' + convert(varchar(15), max(serial)) end
--From
--	@AuditTrailPartPackGroupRangeID atR

--group by
--	part,
--	PackageType,
--	PartPackQty,
--	RangeID


/*	Select * From @ShipperDetail
	Select * From @AuditTrailLooseSerial
	Select * From @AuditTrailPartPackGroupRangeID
	Select * From @AuditTrailPartPackGroup
	Select * From @AuditTrailPartPackGroupSerialRange
*/


--Delcare Variables for ASN Details		
/*
declare	
	@LineItemID char(6),
	@REF02_PalletSerial char(2),
	@PAL01_PalletPackType char(78),
	@PAL02_PalletTiers char(4),
	@PAL03_PalletBlocks char(4),
	@PAL05_PalletTareWeight char(10),
	@PAL06_PalletTareWeightUM char(2),
	@PAL07_Length char(10),
	@PAL08_Width char(10),
	@PAL09_Height char(10),
	@PAL10_DimUM char(2),
	@PAL11_PalletGrossWeight char(10),
	@PAL12_PalletGrossWeightUM char(2),
	@LIN02_BPIDtype char(2) = 'BP',
	@LIN02_CustomerPart char(48) ,
	@LIN02_VPIDtype char(2) = 'VP',
	@LIN02_VendorPart char(48) ,
	@LIN02_PDIDtype char(2) = 'PD',
	@LIN02_PartDescription char(48) ,
	@LIN02_POIDtype char(2) = 'PD',
	@LIN02_CustomerPO char(48) ,
	@LIN02_CHIDtype char(2) = 'CH',
	@LIN02_CountryOfOrigin char(48) = 'HN' ,
	@SN102_QuantityShipped char(12),
	@SN103_QuantityShippedUM char(2) = 'PC',
	@SN104_AccumQuantityShipped char(17),
	@REF01_PKIDType char(3),
	@REF02_PackingSlipID char(78),
	@REF03_PackingSlipDescription char(78),
	@REF01_IVIDType char(3) = 'IV',
	@REF02_InvoiceIDID char(78),
	@CLD01_LoadCount char(6),
	@CLD02_PackQuantity char(12),
	@CLD03_PackCode char(5),
	@CLD04_PackGrossWeight char(10),
	@CLD05_PackGrossWeightUM char(2) = 'LB',
	@REF02_ObjectSerial char(78) ,
	@REF04_ObjectLot char(78) ,
	@DTM02_ObjectLot char(78) ,
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
Select	@DunnagePackType = 'YazakiDunnage'
Select	@UM = 'C62'
Select  @PCIQualifier = '17'
Select 	@CPS03 = 1
Select	@SupplierPartQual = 'SA'
Select	@CustomerECLQual = 'DR'
Select	@REF02_InvoiceIDID = @shipper
Select	@REF02_PackingSlipID = @shipper
 */
 		
declare
	PartLine cursor local for
select
	InternalPart = Part,
	DefaultPackageType =  DefaultPackageType,
	CustomerPart = customerpart,
	CustomerPO = customerpo,
	QtyShipped = convert(int, QtyShipped),
	AccumShipped = convert(int, AccumShipped)
From
	@ShipperDetail SD

open
	PartLine

while
	1 = 1 begin
	
	fetch
		PartLine
	into
		@InternalPart,
		@2CPS03CPSIndicator,
		@2LIN030CustomerPart,
		@1RFF010CustomerPO,
		@2QTY010QtyShipped,
		@2QTY010AccumShipped
			
	if	@@FETCH_STATUS != 0 begin
		break
	end

	Insert	#ASNFlatFile (LineData)
					Select  '09' 									
							+ @2CPS03CPSIndicator
	
/*
		Insert	#ASNFlatFile (LineData)
		Select '27'
				+		@LIN02_BPIDtype
				+		@LIN02_CustomerPart
				+		@LIN02_VPIDtype

		Insert	#ASNFlatFile (LineData)
		Select '28'
				+		@LIN02_VendorPart
				+		@LIN02_PDIDtype

		Insert	#ASNFlatFile (LineData)
		Select '29'
				+		@LIN02_PartDescription
				+		@LIN02_POIDtype

		Insert	#ASNFlatFile (LineData)
		Select '30'
				+		@LIN02_CustomerPO

		Insert	#ASNFlatFile (LineData)
		Select '34'
				+		space(48)
				+		@LIN02_CHIDtype

		Insert	#ASNFlatFile (LineData)
		Select '35'
				+		@LIN02_CountryOfOrigin

		Insert	#ASNFlatFile (LineData)
		Select '36'
				+		space(48)
				+		@SN102_QuantityShipped
				+		@SN103_QuantityShippedUM

		Insert	#ASNFlatFile (LineData)
		Select '37'
				+		@SN104_AccumQuantityShipped

		Insert	#ASNFlatFile (LineData)
		Select '39'
				+		@REF01_IVIDType

		Insert	#ASNFlatFile (LineData)
		Select '40'
				+		@REF02_InvoiceIDID

		Insert	#ASNFlatFile (LineData)
		Select '39'
				+		@REF01_PKIDType

		Insert	#ASNFlatFile (LineData)
		Select '40'
				+		@REF02_PackingSlipID
*/

		declare PartPack cursor local for
			select
				1,
				count(serial),
				ObjectPackageType				
			From
				@AuditTrailSerial
			where
				part = @InternalPart
				group by
				ObjectPackageType
				union
			 Select
			  2,
				count(Distinct ParentSerial),
				PalletPackageType				
			From
				@AuditTrailSerial
			where
				part = @InternalPart and
				ParentSerial > 0
				group by
				PalletPackageType
				order by 1,2
												
			open
				PartPack

			while
				1 = 1 begin
							
				fetch
					PartPack
				into
					@PackTypeType,
					@1PAC01PackageCount,
					@1PAC01PackageType
					
								
																								
				if	@@FETCH_STATUS != 0 begin
					break
				end
									Insert	#ASNFlatFile (LineData)
										Select  '10' 									
										+ @1PAC01PackageCount
										+ @1PAC01PackageType
							
					end		
					close
						PartPack
					deallocate
						PartPack
						
					

			Insert	#ASNFlatFile (LineData)
										Select  '14' 									
										+ @2LIN030CustomerPart
										+ @1PIAModelYear

			Insert	#ASNFlatFile (LineData)
										Select  '16' 									
										+ @2QTY010QtyTypeShipped
										+ @2QTY010QtyShipped
										+	@2QTY010QtyShippedUM

		Insert			#ASNFlatFile (LineData)
										Select  '16' 									
										+ @2QTY010AccumTypeShipped
										+ @2QTY010AccumShipped
										+	@2QTY010AccumShippedUM

			Insert			#ASNFlatFile (LineData)
										Select  '17' 									
										+ space(3)
										+ @1RFF010CustomerPO
										
end
close
	PartLine	
 
deallocate
	PartLine




select 
	--LineData +convert(char(1), (lineID % 2 ))
	 LineData + right(convert(char(2), (lineID )),2)
From 
	#ASNFlatFile
order by 
	LineID

	
	      
set ANSI_Padding OFF	
End
         







GO
