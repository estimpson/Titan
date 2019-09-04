SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_CPS]
(	@DictionaryVersion varchar(25)
,	@ID varchar(12)
,	@ParentID varchar(12)
,	@PackagingLevel varchar(3)
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
				EDI_XML.SEG_INFO(@dictionaryVersion, 'CPS')
			,	EDI_XML.DE(@DictionaryVersion, '7164', @ID)
			,	case when @PackagingLevel is not null then EDI_XML.DE(@DictionaryVersion, '7166', @ParentID) end
			,	case when @PackagingLevel is not null then EDI_XML.DE(@DictionaryVersion, '7075', @PackagingLevel) end
			--,	EDI_XML.CE(@dictionaryVersion, 'C237', EDI_XML.DE(@DictionaryVersion, '8260', @EquipmentIdentification))
			for xml raw ('SEG-CPS'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
