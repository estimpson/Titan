SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_PAC]
(	@DictionaryVersion varchar(25)
,	@NumberOfPackages int
,	@PackageId varchar(17)
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
			,	EDI_XML.DE(@DictionaryVersion, '7224', @NumberOfPackages)
			,	EDI_XML.CE(@dictionaryVersion, 'C531', null)
			,	EDI_XML.CE(@dictionaryVersion, 'C202', EDI_XML.DE(@DictionaryVersion, '7065', @PackageId))
			for xml raw ('SEG-PAC'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
