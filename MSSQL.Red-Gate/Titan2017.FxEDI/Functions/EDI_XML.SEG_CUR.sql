SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_CUR]
(	@DictionaryVersion varchar(25)
,	@Identifier char(2)
,	@CurrencyCode char(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'CUR')
			,	EDI_XML.DE(@dictionaryVersion, '0098', @Identifier)
			,	EDI_XML.DE(@dictionaryVersion, '0100', @CurrencyCode)
			for xml raw ('SEG-CUR'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
