SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_EQD]
(	@DictionaryVersion varchar(25)
,	@EquipmentQualifier varchar(3)
,	@EquipmentIdentification varchar(17)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	--,	@DEC040 xml

	--set	@DEC040 =
	--	(	select
	--			(select EDI_XML.DE(@DictionaryVersion, '3127', @CarrierIdentification))
	--		,	(select EDI_XML.DE(@DictionaryVersion, '3055', @CodeListAgency))
	--		for xml path ('')
	--	)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'EQD')
			,	EDI_XML.DE(@DictionaryVersion, '8053', @EquipmentQualifier)
			,	EDI_XML.CE(@dictionaryVersion, 'C237', EDI_XML.DE(@DictionaryVersion, '8260', @EquipmentIdentification))
			for xml raw ('SEG-EQD'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
