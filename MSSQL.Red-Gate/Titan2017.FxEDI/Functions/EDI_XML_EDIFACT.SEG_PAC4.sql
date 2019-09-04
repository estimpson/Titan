SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_PAC4]
(	@DictionaryVersion varchar(25)
,	@NumberOfPackages int
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	--,	@DEC040 xml

	--set	@DEC040 =
	--	(	select
	--			(select EDI_XML.DE(@DictionaryVersion, '3127', @CarrierIdentification))
	--		,	(select EDI_XML.DE(@DictionaryVersion, '3055', @CodeListAgency))
	--		for xml path ('')
	--	)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'PAC')
			,	case when @NumberOfPackages is null then null else EDI_XML.DE(@DictionaryVersion, '7224', @NumberOfPackages) end
			for xml raw ('SEG-PAC'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
