SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_UNT]
(	@dictionaryVersion varchar(25)
,	@unitOfMeasurementCode char(2)
,	@unitPrice numeric(20,14) = null
,	@basisOfUnitPriceCode char(2) = null
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'UNT')
			,	EDI_XML.DE(@dictionaryVersion, '0355', @unitOfMeasurementCode)
			,	case when @unitPrice is not null then EDI_XML.DE(@dictionaryVersion, '0212', @unitPrice) end
			,	case when @basisOfUnitPriceCode is not null then EDI_XML.DE(@dictionaryVersion, '0639', @basisOfUnitPriceCode) end
			for xml raw ('SEG-UNT'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
