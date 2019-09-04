SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_PCIx]
(	@DictionaryVersion varchar(25)
,	@MarkingInstructions varchar(3)
,	@MarkingType varchar(3)
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
				EDI_XML.SEG_INFO(@dictionaryVersion, 'PCI')
			,	EDI_XML.DE(@DictionaryVersion, '4233', @MarkingInstructions)
			,	EDI_XML.CE(@DictionaryVersion, 'C210', null)
			,	EDI_XML.DE(@DictionaryVersion, '8275', null)
			,	EDI_XML.CE(@DictionaryVersion, 'C827', EDI_XML.DE(@DictionaryVersion, '7511', @MarkingType))
			for xml raw ('SEG-PCI'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
