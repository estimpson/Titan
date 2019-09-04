SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_ISS]
(	@DictionaryVersion varchar(25)
,	@ShipQty int
,	@Unit char(2)
,	@Weight int
,	@WeightUnit char(2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'ISS')
			,	EDI_XML.DE(@dictionaryVersion, '0382', @ShipQty)
			,	EDI_XML.DE(@dictionaryVersion, '0355', @Unit)
			,	EDI_XML.DE(@dictionaryVersion, '0081', @Weight)
			,	EDI_XML.DE(@dictionaryVersion, '0355', @WeightUnit)
			for xml raw ('SEG-ISS'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
