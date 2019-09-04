SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_RFF]
(	@DictionaryVersion varchar(25)
,	@ReferenceQualifier varchar(3)
,	@ReferenceNumber varchar(35)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC506 xml =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '1153', @ReferenceQualifier))
			,	(select EDI_XML.DE(@DictionaryVersion, '1154', @ReferenceNumber))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'RFF')
			,	EDI_XML.CE(@dictionaryVersion, 'C506', @DEC506)
			for xml raw ('SEG-RFF'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
