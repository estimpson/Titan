SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_FOB]
(	@DictionaryVersion varchar(25)
,	@PaymentMethod char(2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'FOB')
			,	EDI_XML.DE(@dictionaryVersion, '0146', @PaymentMethod)
			for xml raw ('SEG-FOB'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
