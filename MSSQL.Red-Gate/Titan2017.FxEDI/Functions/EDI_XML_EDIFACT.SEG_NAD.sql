SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_NAD]
(	@DictionaryVersion varchar(25)
,	@PartyQualifier varchar(3)
,	@PartyID varchar(35)
,	@CodeListQualifier varchar(3)
,	@ResponsibleAgency varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC082 xml =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '3039', @PartyID))
			,	(select EDI_XML.DE(@DictionaryVersion, '1131', @CodeListQualifier))
			,	(select EDI_XML.DE(@DictionaryVersion, '3055', @ResponsibleAgency))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'NAD')
			,	EDI_XML.DE(@DictionaryVersion, '3035', @PartyQualifier)
			,	EDI_XML.CE(@dictionaryVersion, 'C082', @DEC082)
			for xml raw ('SEG-NAD'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
