SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_TDT]
(	@DictionaryVersion varchar(25)
,	@TransportStageQualifier varchar(3)
,	@TransportationMode varchar(17)
,	@CarrierIdentification varchar(17)
,	@CodeListAgency varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC040 xml

	set	@DEC040 =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '3127', @CarrierIdentification))
			,	(select EDI_XML.DE(@DictionaryVersion, '1131', null))
			,	(select EDI_XML.DE(@DictionaryVersion, '3055', @CodeListAgency))
			,	(select case when @DictionaryVersion = '00D05B' then EDI_XML.DE(@DictionaryVersion, '3128', @CarrierIdentification) end)
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'TDT')
			,	EDI_XML.DE(@DictionaryVersion, '8051', @TransportStageQualifier)
			,	EDI_XML.DE(@DictionaryVersion, '8028', null)
			,	EDI_XML.CE(@dictionaryVersion, 'C220', EDI_XML.DE(@DictionaryVersion, '8067', @TransportationMode))
			,	EDI_XML.CE(@dictionaryVersion, 'C228', null)
			,	EDI_XML.CE(@dictionaryVersion, 'C040', @DEC040)
			for xml raw ('SEG-TDT'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
