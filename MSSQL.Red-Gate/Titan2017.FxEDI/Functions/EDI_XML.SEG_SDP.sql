SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_SDP]
(	@dictionaryVersion varchar(25)
,	@deliveryPatternCode varchar(2)
,	@deliveryPatternTimeCode char(1)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'SDP')
			,	EDI_XML.DE(@dictionaryVersion, '0678', @deliveryPatternCode)
			,	EDI_XML.DE(@dictionaryVersion, '0679', @deliveryPatternTimeCode)
			for xml raw ('SEG-SDP'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
