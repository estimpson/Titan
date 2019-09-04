SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_MEA]
(	@DictionaryVersion varchar(25)
,	@MeasurementPurpose varchar(3)
,	@MeasurementProperty varchar(3)
,	@MeasurementUnit varchar(3)
,	@MeasurementValue varchar(18)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC502 xml =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '6313', @MeasurementProperty))
			for xml path ('')
		)
	,	@DEC174 xml =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '6411', @MeasurementUnit))
			,	(select EDI_XML.DE(@DictionaryVersion, '6314', @MeasurementValue))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'MEA')
			,	EDI_XML.DE(@dictionaryVersion, '6311', @MeasurementPurpose)
			,	EDI_XML.CE(@dictionaryVersion, 'C502', @DEC502)
			,	EDI_XML.CE(@dictionaryVersion, 'C174', @DEC174)
			for xml raw ('SEG-MEA'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
