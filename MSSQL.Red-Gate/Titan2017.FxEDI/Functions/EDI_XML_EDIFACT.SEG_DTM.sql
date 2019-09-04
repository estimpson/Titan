SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_DTM]
(	@DictionaryVersion varchar(25)
,	@PeriodQualifier varchar(3)
,	@DateTime datetime
,	@FormatQualifier varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DE xml

	set	@DE =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '2005', @PeriodQualifier))
			,	(select EDI_XML.DE(@DictionaryVersion, '2380', EDI_XML.FormatDT('CCYYMMDDHHMM', @DateTime)))
			,	(select EDI_XML.DE(@DictionaryVersion, '2379', @FormatQualifier))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'DTM')
			,	EDI_XML.CE(@dictionaryVersion, 'C507', @DE)
			for xml raw ('SEG-DTM'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
