SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_BGM]
(	@DictionaryVersion varchar(25)
,	@DocumentName varchar(3)
,	@ShipmentId varchar(30)
,	@MessageFunction varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'BGM')
			,	EDI_XML.CE(@dictionaryVersion, 'C002', case when @DocumentName > '' then EDI_XML.DE(@dictionaryVersion, '1001', @DocumentName) end)
			,	case
					when @DictionaryVersion = '00D05B' then EDI_XML.DE(@dictionaryVersion, '1004', @ShipmentId)
					else EDI_XML.CE(@dictionaryVersion, 'C106', EDI_XML.DE(@dictionaryVersion, '1004', @ShipmentId))
				end
			,	EDI_XML.DE(@dictionaryVersion, '1225', @MessageFunction)
			for xml raw ('SEG-BGM'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
