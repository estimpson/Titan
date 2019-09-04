SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_BENTELER].[Get856]
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
		@dictionaryVersion varchar(25) = '004010'

	set
		@xmlOutput =
			(	select
					(	select
							EDI_XML.TRN_INFO(@dictionaryVersion, '856', ah.TradingPartnerID, ah.iConnectID, @ShipperID, @PartialComplete)
						,	EDI_XML.SEG_BSN(@dictionaryVersion, @Purpose, ah.ShipperID, ah.ShipDate, ah.ShipTime)
						,	EDI_XML.SEG_DTM(@dictionaryVersion, '011', ah.ShipDateTime)
						,	(	select
						 			EDI_XML.LOOP_INFO('HL')
								,	EDI_XML.SEG_HL(@dictionaryVersion, 1, null, 'S')
								,	EDI_XML.SEG_TD1(@dictionaryVersion, null, ah.BOLQuantity)
								,	EDI_XML.SEG_TD5(@dictionaryVersion, 'B', '2', ah.Carrier, ah.TransMode)
								,	(	select
								 			EDI_XML.LOOP_INFO('TD3')
										,	EDI_XML.SEG_TD3(@dictionaryVersion, ah.EquipmentType, null, ah.TruckNumber)
								 		for xml raw ('LOOP-TD3'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('N1')
										,	EDI_XML.SEG_N1(@dictionaryVersion, 'ST', ah.ShipToName, '98', ah.ShipTo)
								 		for xml raw ('LOOP-N1'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('N1')
										,	EDI_XML.SEG_N1(@dictionaryVersion, 'SU', null, '16', ah.SupplierCode)
								 		for xml raw ('LOOP-N1'), type
								 	)
						 		for xml raw ('LOOP-HL'), type
						 	)
						,	(	select
						 			EDI_XML.LOOP_INFO('HL')
								,	EDI_XML.SEG_HL(@dictionaryVersion, al.RowNumber + 1, 1, 'I')
								,	EDI_XML.SEG_LIN(@dictionaryVersion, null, 'BP,EC,PL,PO,RN', al.CustomerPart+','+al.ECLevel+','+al.POLine+','+al.CustomerPO+','+al.ReleaseNumber)
								,	EDI_XML.SEG_SN1(@dictionaryVersion, null, al.QtyPacked, 'PC', null)
								from
									EDI_XML_BENTELER.ASNLines al
								where
									al.ShipperID = ah.ShipperID
						 		for xml raw ('LOOP-HL'), type
						 	)
						,	EDI_XML.SEG_CTT(@dictionaryVersion, ht.LineItems, ht.HashTotal)
						from
							EDI_XML_BENTELER.ASNHeaders ah
							cross apply
								(	select
										LineItems = count(*)
									,	HashTotal = sum(al.QtyPacked)
									from
										EDI_XML_BENTELER.ASNLines al
									where
										al.ShipperID = ah.ShipperID
								) ht
						where
							ah.ShipperID = @ShipperID
						for xml raw ('TRN-856'), type
					)
				for xml raw ('TRN'), type
			)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
