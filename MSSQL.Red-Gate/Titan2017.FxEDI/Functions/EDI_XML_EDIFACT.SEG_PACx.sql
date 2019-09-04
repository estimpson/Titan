SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_PACx]
(	@DictionaryVersion varchar(25)
,	@NumberOfPackages int
,	@PackagingDescriptionCode varchar(3)
,	@PackageId varchar(17)
,	@ResponsibleAgency varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC202 xml

	set	@DEC202 =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '7065', @PackageId))
			,	(select EDI_XML.DE(@DictionaryVersion, '1131', null))
			,	(select EDI_XML.DE(@DictionaryVersion, '3055', @ResponsibleAgency))
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'PAC')
			,	EDI_XML.DE(@DictionaryVersion, '7224', @NumberOfPackages)
			,	EDI_XML.CE(@dictionaryVersion, 'C531', case when @PackagingDescriptionCode is not null then EDI_XML.DE(@DictionaryVersion, '7233', @PackagingDescriptionCode) end)
			,	EDI_XML.CE(@dictionaryVersion, 'C202', @DEC202)
			for xml raw ('SEG-PAC'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
