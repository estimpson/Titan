SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_HBPO].[GetDESADV]
(	@ShipperID int
,	@Purpose char(2)
,	@PartialComplete int
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	declare
		@dictionaryVersion varchar(25) = '00D05B'
		--@dictionaryVersion varchar(25) = '00D97A'

	set
		@xmlOutput =
			(	select
					(	select
							EDI_XML.TRN_INFO(@dictionaryVersion, 'DESADV', ah.TradingPartnerID, ah.iConnectID, @ShipperID, @PartialComplete)
						,	EDI_XML_EDIFACT.SEG_BGM(@dictionaryVersion, '351', @ShipperID, '9')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '137', ah.ShipDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '11', ah.ShipDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '132', ah.ArrivalDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'G', ah.WeightUnit, ah.GrossWeight)
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'N', ah.WeightUnit, ah.NetWeight)
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'SQ', 'C62', ah.BOLQuantity)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NADx(@dictionaryVersion, 'BY', ah.Buyer, null, '91', ah.TradingPartnerID, ah.BuyerAddress)
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NADx(@dictionaryVersion, 'SU', ah.SupplierCode, null, '92', ah.CompanyName, ah.CompanyAddress)
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NADx(@dictionaryVersion, 'ST', ah.ShipTo, null, '92', ah.ShipToName, ah.ShipToAddress)
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('TDT')
								,	EDI_XML_EDIFACT.SEG_TDT(@dictionaryVersion, '12', ah.TransMode, ah.Carrier, '182')
						 		for xml raw ('LOOP-TDT'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('EQD')
								,	EDI_XML_EDIFACT.SEG_EQD(@dictionaryVersion, ah.EquipmentType, ah.TruckNumber)
						 		for xml raw ('LOOP-EQD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('CPS')
								,	EDI_XML_EDIFACT.SEG_CPS(@dictionaryVersion, al.RowNumber, null, 1)
								,	(	select
						 					EDI_XML.LOOP_INFO('PAC')
										--,	EDI_XML_EDIFACT.SEG_PAC4(@dictionaryVersion, null)
										,	EDI_XML_EDIFACT.SEG_PACx(@dictionaryVersion, null, '37', null, '92')
						 				for xml raw ('LOOP-PAC'), type
						 			)
								,	(	select
								 			EDI_XML.LOOP_INFO('PAC')
										,	EDI_XML_EDIFACT.SEG_PACx(@dictionaryVersion, ap.PackCount, null, ap.PackageType, '92')
										,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 52, ap.PackQty, 'C62')
										,	(	select
										 			EDI_XML.LOOP_INFO('PCI')
												,	EDI_XML_EDIFACT.SEG_PCIx(@dictionaryVersion, '17', 'S')
												,	(	select
												 			EDI_XML.LOOP_INFO('GIN')
														,	EDI_XML_EDIFACT.SEG_GIN(@dictionaryVersion, 'ML', ap.SerialRange)
												 		for xml raw ('LOOP-GIN'), type
												 	)
										 		for xml raw ('LOOP-PCI'), type
										 	)
								 		from
								 			EDI_XML_HBPO.ASNPackages ap
										where
											ap.ShipperID = @ShipperID
											and ap.CustomerPart = al.CustomerPart
										order by
											ap.Type
										for xml raw ('LOOP-PAC'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('LIN')
										,	EDI_XML_EDIFACT.SEG_LIN(@dictionaryVersion, al.RowNumber, al.CustomerPart, 'IN')
										,	EDI_XML_EDIFACT.SEG_PIA(@dictionaryVersion, 1, al.SupplierPart+','+coalesce(al.CustomerECL, ''), 'SA,DR')
										,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 12, al.QtyPacked, null)
										,	(	select
										 			EDI_XML.LOOP_INFO('RFF')
												,	EDI_XML_EDIFACT.SEG_RFF(@dictionaryVersion, 'ON', al.CustomerPO)
										 		for xml raw ('LOOP-RFF'), type
										 	)
								 		for xml raw ('LOOP-LIN'), type
								 	)
								from
									EDI_XML_HBPO.ASNLines al
								where
									al.ShipperID = ah.ShipperID
						 		for xml raw ('LOOP-CPS'), type
						 	)
						--,	(	select
						-- 			EDI_XML.LOOP_INFO('CPS')
						--		,	EDI_XML_EDIFACT.SEG_CPS(@dictionaryVersion, al.RowNumber + 1, 1, 1)
								--,	(	select
						 	--				EDI_XML.LOOP_INFO('PAC')
								--		--,	EDI_XML_EDIFACT.SEG_PAC4(@dictionaryVersion, null)
								--		,	EDI_XML_EDIFACT.SEG_PACx(@dictionaryVersion, null, null, null, '92')
						 	--			for xml raw ('LOOP-PAC'), type
						 	--		)
								--,	(	select
								-- 			EDI_XML.LOOP_INFO('PAC')
								--		,	EDI_XML_EDIFACT.SEG_PACx(@dictionaryVersion, ap.PackCount, null, ap.PackageType, '92')
								--		,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 52, ap.PackQty, 'C62')
								--		,	(	select
								--		 			EDI_XML.LOOP_INFO('PCI')
								--				,	EDI_XML_EDIFACT.SEG_PCIx(@dictionaryVersion, '17', 'S')
								--				,	(	select
								--				 			EDI_XML.LOOP_INFO('GIN')
								--						,	EDI_XML_EDIFACT.SEG_GIN(@dictionaryVersion, 'ML', ap.SerialRange)
								--				 		for xml raw ('LOOP-GIN'), type
								--				 	)
								--		 		for xml raw ('LOOP-PCI'), type
								--		 	)
								-- 		from
								-- 			EDI_XML_HBPO.ASNPackages ap
								--		where
								--			ap.ShipperID = @ShipperID
								--			and ap.CustomerPart = al.CustomerPart
								--		order by
								--			ap.Type
								--		for xml raw ('LOOP-PAC'), type
								-- 	)
								--,	(	select
								-- 			EDI_XML.LOOP_INFO('LIN')
								--		,	EDI_XML_EDIFACT.SEG_LIN(@dictionaryVersion, al.RowNumber, al.CustomerPart, 'IN')
								--		,	EDI_XML_EDIFACT.SEG_PIA(@dictionaryVersion, 1, al.SupplierPart+','+coalesce(al.CustomerECL, ''), 'SA,DR')
								--		,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 12, al.QtyPacked, null)
								--		,	(	select
								--		 			EDI_XML.LOOP_INFO('RFF')
								--				,	EDI_XML_EDIFACT.SEG_RFF(@dictionaryVersion, 'ON', al.CustomerPO)
								--		 		for xml raw ('LOOP-RFF'), type
								--		 	)
								-- 		for xml raw ('LOOP-LIN'), type
								-- 	)
								--from
								--	EDI_XML_HBPO.ASNLines al
								--where
								--	al.ShipperID = ah.ShipperID
						 	--	for xml raw ('LOOP-CPS'), type
						 	--)
						--,	EDI_XML.SEG_CTT(@dictionaryVersion, ht.LineItems, ht.HashTotal)
						from
							EDI_XML_HBPO.ASNHeaders ah
							cross apply
								(	select
										LineItems = count(*)
									,	HashTotal = sum(al.QtyPacked)
									from
										EDI_XML_HBPO.ASNLines al
									where
										al.ShipperID = ah.ShipperID
								) ht
						where
							ah.ShipperID = @ShipperID
						for xml raw ('TRN-DESADV'), type
					)
				for xml raw ('TRN'), type
			)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
