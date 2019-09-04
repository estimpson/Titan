SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_LOC]
(	@DictionaryVersion varchar(25)
,	@LocationQualifier varchar(3)
,	@LocationId varchar(25)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC517 xml =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '3225', @LocationId))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'LOC')
			,	EDI_XML.DE(@DictionaryVersion, '3227', @LocationQualifier)
			,	EDI_XML.CE(@dictionaryVersion, 'C517', @DEC517)
			for xml raw ('SEG-LOC'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
