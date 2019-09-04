SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_GIN]
(	@DictionaryVersion varchar(25)
,	@IdentityQualifier varchar(3)
,	@IdentityRange varchar(35)
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
				EDI_XML.SEG_INFO(@dictionaryVersion, 'GIN')
			,	EDI_XML.DE(@DictionaryVersion, '7405', @IdentityQualifier)
			,	EDI_XML.CE(@DictionaryVersion, 'C208', EDI_XML.DE(@DictionaryVersion, '7402', @IdentityRange))
			for xml raw ('SEG-GIN'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
