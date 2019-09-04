SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_IT1]
(	@DictionaryVersion varchar(25)
,	@AssignedIdentification varchar(20)
,	@QtyInvoiced int
,	@Unit char(2)
,	@UnitPrice decimal(10,4)
,	@PriceUnit char(2)
,	@ProductIdQualifier1 char(2)
,	@ProductId1 varchar(40)
,	@ProductIdQualifier2 char(2)
,	@ProductId2 varchar(40)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'IT1')
			,	EDI_XML.DE(@dictionaryVersion, '0350', @AssignedIdentification)
			,	EDI_XML.DE(@dictionaryVersion, '0358', @QtyInvoiced)
			,	EDI_XML.DE(@dictionaryVersion, '0355', @Unit)
			,	EDI_XML.DE(@dictionaryVersion, '0212', @UnitPrice)
			,	EDI_XML.DE(@dictionaryVersion, '0639', @PriceUnit)
			,	EDI_XML.DE(@dictionaryVersion, '0235', @ProductIdQualifier1)
			,	EDI_XML.DE(@dictionaryVersion, '0234', @ProductId1)
			,	EDI_XML.DE(@dictionaryVersion, '0235', @ProductIdQualifier2)
			,	EDI_XML.DE(@dictionaryVersion, '0234', @ProductId2)
			for xml raw ('SEG-IT1'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
