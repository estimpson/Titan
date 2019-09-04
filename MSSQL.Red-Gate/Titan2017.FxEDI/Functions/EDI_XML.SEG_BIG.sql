SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_BIG]
(	@DictionaryVersion varchar(25)
,	@TransactionSetPurposeCode char(2)
,	@InvoiceNumber varchar(22)
,	@InvoiceDate datetime
,	@TransactionTypeCode varchar(2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'BIG')
			,	EDI_XML.DE(@dictionaryVersion, '0373', EDI_XML.FormatDate(@dictionaryVersion,@InvoiceDate))
			,	EDI_XML.DE(@dictionaryVersion, '0076', @InvoiceNumber)
			,	EDI_XML.DE(@dictionaryVersion, '0373', null)
			,	EDI_XML.DE(@dictionaryVersion, '0324', null)
			,	EDI_XML.DE(@dictionaryVersion, '0328', null)
			,	EDI_XML.DE(@dictionaryVersion, '0327', null)
			,	EDI_XML.DE(@dictionaryVersion, '0640', @TransactionTypeCode)
			,	EDI_XML.DE(@dictionaryVersion, '0353', @TransactionSetPurposeCode)
			for xml raw ('SEG-BIG'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
