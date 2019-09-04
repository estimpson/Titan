SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_TXI]
(	@DictionaryVersion varchar(25)
,	@TaxTypeCode char(2)
,	@MonetaryAmount numeric(12,2)
,	@Percent int
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'TXI')
			,	EDI_XML.DE(@dictionaryVersion, '0963', @TaxTypeCode)
			,	EDI_XML.DE(@dictionaryVersion, '0782', @MonetaryAmount)
			,	EDI_XML.DE(@dictionaryVersion, '0954', @Percent)
			for xml raw ('SEG-TXI'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
