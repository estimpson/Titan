SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_MODATEK].[Get856_New]
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
		@ASNPackSums table
	(	ShipperID int
	,	CustomerPart varchar(30)
	,	QtyPacked int
	,	Unit char(2)
	,	AccumShipped numeric(20,6)
	,	CustomerPO varchar(25)
	,	PalletSerial int
	,	BoxQty numeric(20,6)
	,	BoxCount int
	,	HL_Outer_ID int
	,	HL_Outer_ParentID int
	,	HL_Inner_ID int
	,	HL_Inner_ParentID int
	)
	insert
		@ASNPackSums
	(	ShipperID
	,	CustomerPart
	,	QtyPacked
	,	Unit
	,	AccumShipped
	,	CustomerPO
	,	PalletSerial
	,	BoxQty
	,	BoxCount
	,	HL_Outer_ID
	,	HL_Outer_ParentID
	,	HL_Inner_ID
	,	HL_Inner_ParentID
	)
	select
		aps.ShipperID
	,	aps.CustomerPart
	,	aps.QtyPacked
	,	aps.Unit
	,	aps.AccumShipped
	,	aps.CustomerPO
	,	aps.PalletSerial
	,	aps.BoxQty
	,	aps.BoxCount
	,	HL_Outer_ID = aps.DenseRankByPart + aps.RankByPart
	,	HL_Outer_ParentID = 1
	,	HL_Inner_ID = aps.DenseRankByPart + aps.RankByPart + aps.PackQtyRowNumber
	,	HL_Inner_ParentID = aps.DenseRankByPart + aps.RankByPart
	from
		EDI_XML_MODATEK.ASNPackSums aps
	where
		aps.ShipperID = @ShipperID

	declare
		@dictionaryVersion varchar(25) = '003060'

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
								,	EDI_XML_MODATEK.SEG_MEA(@dictionaryVersion, 'PD', 'G', ah.GrossWeight, 'LB')
								,	EDI_XML_MODATEK.SEG_MEA(@dictionaryVersion, 'PD', 'N', ah.NetWeight, 'LB')
								,	EDI_XML.SEG_TD1(@dictionaryVersion, 'CNT90', ah.BOLQuantity)
								,	EDI_XML.SEG_TD5(@dictionaryVersion, 'B', '2', ah.Carrier, ah.TransMode)
								,	(	select
								 			EDI_XML.LOOP_INFO('TD3')
										,	EDI_XML.SEG_TD3(@dictionaryVersion, ah.EquipmentType, null, ah.TruckNumber)
								 		for xml raw ('LOOP-TD3'), type
								 	)
								,	EDI_XML.SEG_REF(@dictionaryVersion, 'BM', ah.ShipperID, null, null)
								,	EDI_XML.SEG_REF(@dictionaryVersion, 'PK', ah.ShipperID, null, null)
								,	(	select
								 			EDI_XML.LOOP_INFO('N1')
										,	EDI_XML.SEG_N1(@dictionaryVersion, 'MI', ah.ShipToName, '01', ah.MaterialIssuerCode)
								 		for xml raw ('LOOP-N1'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('N1')
										,	EDI_XML.SEG_N1(@dictionaryVersion, 'SU', ah.CompanyName, '01', ah.SupplierCode)
								 		for xml raw ('LOOP-N1'), type
								 	)
								,	(	select
								 			EDI_XML.LOOP_INFO('N1')
										,	EDI_XML.SEG_N1(@dictionaryVersion, 'ST', ah.ShipToName, '01', ah.ShipTo)
								 		for xml raw ('LOOP-N1'), type
								 	)
						 		for xml raw ('LOOP-HL'), type
						 	)
						,	(	select
						 			(	select
											EDI_XML.LOOP_INFO('HL')
										,	EDI_XML.SEG_HL(@dictionaryVersion, max(aps.HL_Outer_ID), max(aps.HL_Outer_ParentID), 'O')
										,	EDI_XML.SEG_LIN(@dictionaryVersion, null, 'BP', aps.CustomerPart)
										,	EDI_XML.SEG_SN1(@dictionaryVersion, null, max(aps.QtyPacked), 'EA', max(aps.AccumShipped))
										,	EDI_XML.SEG_PRF(@dictionaryVersion, max(aps.CustomerPO))
										for xml raw ('LOOP-HL'), type
									)
								,	(	select
											EDI_XML.LOOP_INFO('HL')
										,	EDI_XML.SEG_HL(@dictionaryVersion, apsInner.HL_Inner_ID, apsInner.HL_Inner_ParentID, 'I')
										,	case when apsInner.PalletSerial > 0 then (select EDI_XML.SEG_REF(@dictionaryVersion, 'LS', apsInner.PalletSerial, null, null)) end
										,	(	select
								 					EDI_XML.LOOP_INFO('CLD')
												,	EDI_XML.SEG_CLD(@dictionaryVersion, apsInner.BoxCount, apsInner.BoxQty, 'CTN90')
												,	(	select
										 					(select EDI_XML.SEG_REF(@dictionaryVersion, 'LS', ab.Serial, null, null))
														from
															EDI_XML_MODATEK.ASNBoxes ab
														where
															ab.ShipperID = @ShipperID
															and ab.CustomerPart = apsInner.CustomerPart
															and coalesce(ab.PalletSerial, -1) = coalesce(apsInner.PalletSerial, -1)
															and ab.BoxQty = apsInner.BoxQty
														order by
															ab.Serial
										 				for xml path (''), type
										 			)
								 				for xml raw ('LOOP-CLD'), type
								 			)
										from
											@ASNPackSums apsInner
										where
											apsInner.CustomerPart = aps.CustomerPart
										for xml raw ('LOOP-HL'), type
									)
					 		from
						 			@ASNPackSums aps
								group by
									aps.CustomerPart
						 		for xml path (''), type
						 	)
						,	EDI_XML.SEG_CTT(@dictionaryVersion, ht.LineItems, ht.HashTotal)
						from
							EDI_XML_MODATEK.ASNHeaders ah
							cross apply
								(	select
										LineItems =
											(	select
													max(aps.HL_Inner_ID)
												from
													@ASNPackSums aps
											)
									,	HashTotal = sum(al.QtyPacked)
									from
										EDI_XML_MODATEK.ASNLines al
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
