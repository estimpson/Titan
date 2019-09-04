SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_LIN]
(	@DictionaryVersion varchar(25)
,	@LineItemNumber varchar(6)
,	@ItemNumber varchar(35)
,	@ItemNumberType varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC212 xml

	set	@DEC212 =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '7140', @ItemNumber))
			,	(select EDI_XML.DE(@DictionaryVersion, '7143', @ItemNumberType))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'LIN')
			,	EDI_XML.DE(@DictionaryVersion, '1082', @LineItemNumber)
			,	EDI_XML.DE(@DictionaryVersion, '1229', null)
			,	EDI_XML.CE(@dictionaryVersion, 'C212', @DEC212)
			for xml raw ('SEG-LIN'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
