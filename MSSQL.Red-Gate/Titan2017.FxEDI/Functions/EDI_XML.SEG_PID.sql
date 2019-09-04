SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_PID]
(	@dictionaryVersion varchar(25)
,	@itemDescriptionType char(1)
,	@description varchar(80)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'PID')
			,	EDI_XML.DE(@dictionaryVersion, '0349', @itemDescriptionType)
			,	EDI_XML.DE(@dictionaryVersion, '0352', @description)
			for xml raw ('SEG-PID'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
