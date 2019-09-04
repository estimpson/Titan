SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_PIA]
(	@DictionaryVersion varchar(25)
,	@ProductIdFunctionQualifier varchar(3)
,	@ItemNumberList varchar(max)
,	@ItemNumberTypeList varchar(max)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	declare
		@itemNumbers table
	(	itemNumber varchar(35)
	,	itemNumberType varchar(3)
	)
	insert
		@itemNumbers
	(	itemNumber
	,	itemNumberType
	)
	select
		itemNumber= items.Value
	,	itemNumberType = itemTypes.Value
	from
		dbo.fn_SplitStringToRows(@ItemNumberList, ',') items
		join dbo.fn_SplitStringToRows(@ItemNumberTypeList, ',') itemTypes
			on itemTypes.ID = items.ID

	declare
		@CE varchar(max) = ''

	select
		@CE += convert
		(	varchar(max)
			,	EDI_XML.CE(@dictionaryVersion, 'C212',
				convert(xml,
					convert(varchar(max), EDI_XML.DE(@DictionaryVersion, '7140', inu.itemNumber))
					+ convert(varchar(max), EDI_XML.DE(@DictionaryVersion, '7143', inu.itemNumberType))
				)
			)
		)
	from
		@itemNumbers inu

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'PIA')
			,	EDI_XML.DE(@DictionaryVersion, '4347', @ProductIdFunctionQualifier)
			,	convert(xml, @CE)
			for xml raw ('SEG-PIA'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
