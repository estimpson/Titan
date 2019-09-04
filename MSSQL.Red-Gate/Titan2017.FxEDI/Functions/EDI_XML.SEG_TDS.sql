SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_TDS]
(	@DictionaryVersion varchar(25)
,	@InvoiceAmount numeric(15,2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'TDS')
			,	EDI_XML.DE(@dictionaryVersion, '0610', @InvoiceAmount)
			for xml raw ('SEG-TDS'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
