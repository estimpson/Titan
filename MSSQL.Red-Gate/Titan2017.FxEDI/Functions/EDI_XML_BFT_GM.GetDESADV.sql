SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_BFT_GM].[GetDESADV]
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
		@dictionaryVersion varchar(25) = '00D97A'

	set
		@xmlOutput =
			(	select
					(	select
							EDI_XML.TRN_INFO(@dictionaryVersion, 'DESADV', ah.TradingPartnerID, ah.iConnectID, @ShipperID, @PartialComplete)
						,	EDI_XML_EDIFACT.SEG_BGM(@dictionaryVersion, null, @ShipperID, '9')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '137', ah.ShipDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '11', ah.ShipDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_DTM(@dictionaryVersion, '132', ah.ArrivalDateTime, '203')
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'G', 'LBR', ah.GrossWeight)
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'N', 'LBR', ah.NetWeight)
						,	EDI_XML_EDIFACT.SEG_MEA(@dictionaryVersion, 'AAX', 'SQ', 'C62', ah.BOLQuantity)
						,	(	select
						 			EDI_XML.LOOP_INFO('RFF')
								,	EDI_XML_EDIFACT.SEG_RFF(@dictionaryVersion, 'MB', ah.BOLNumber)
						 		for xml raw ('LOOP-RFF'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NAD(@dictionaryVersion, 'MI', ah.MaterialIssuerCode, null, '92')
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NAD(@dictionaryVersion, 'ST', ah.ShipTo, null, '92')
								,	EDI_XML_EDIFACT.SEG_LOC(@dictionaryVersion, '11', ah.DockCode)
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('NAD')
								,	EDI_XML_EDIFACT.SEG_NAD(@dictionaryVersion, 'SU', ah.SupplierCode, null, '16')
						 		for xml raw ('LOOP-NAD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('TDT')
								,	EDI_XML_EDIFACT.SEG_TDT(@dictionaryVersion, '12', 'C', ah.Carrier, '182')
						 		for xml raw ('LOOP-TDT'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('EQD')
								,	EDI_XML_EDIFACT.SEG_EQD(@dictionaryVersion, 'TE', ah.TruckNumber)
						 		for xml raw ('LOOP-EQD'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('CPS')
								,	EDI_XML_EDIFACT.SEG_CPS(@dictionaryVersion, al.RowNumber, null, 1)
								,	(	select
								 			EDI_XML.LOOP_INFO('PAC')
										,	EDI_XML_EDIFACT.SEG_PAC(@dictionaryVersion, ap.PackCount, ap.PackageType)
								 		from
								 			EDI_XML_BFT_GM.ASNPackages ap
										where
											ap.ShipperID = @ShipperID
											and ap.CustomerPart = al.CustomerPart
										order by
											ap.Type
										for xml raw ('LOOP-PAC'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('LIN')
										,	EDI_XML_EDIFACT.SEG_LIN(@dictionaryVersion, null, al.CustomerPart, 'IN')
										,	EDI_XML_EDIFACT.SEG_PIA(@dictionaryVersion, 1, al.ModelYear, 'RY')
										,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 12, al.QtyPacked, 'C62')
										,	EDI_XML_EDIFACT.SEG_QTY(@dictionaryVersion, 3, al.AccumShipped, 'C62')
										,	(	select
										 			EDI_XML.LOOP_INFO('RFF')
												,	EDI_XML_EDIFACT.SEG_RFF(@dictionaryVersion, 'ON', al.CustomerPO)
										 		for xml raw ('LOOP-RFF'), type
										 	)
								 		for xml raw ('LOOP-LIN'), type
								 	)
								from
									EDI_XML_BFT_GM.ASNLines al
								where
									al.ShipperID = ah.ShipperID
						 		for xml raw ('LOOP-CPS'), type
						 	)
						--,	EDI_XML.SEG_CTT(@dictionaryVersion, ht.LineItems, ht.HashTotal)
						from
							EDI_XML_BFT_GM.ASNHeaders ah
							cross apply
								(	select
										LineItems = count(*) + 1
									,	HashTotal = sum(al.QtyPacked)
									from
										EDI_XML_BFT_GM.ASNLines al
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
