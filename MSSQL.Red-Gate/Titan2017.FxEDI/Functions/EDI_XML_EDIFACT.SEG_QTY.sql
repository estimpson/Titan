SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_EDIFACT].[SEG_QTY]
(	@DictionaryVersion varchar(25)
,	@QuantityQualifier varchar(3)
,	@Quantity int
,	@UnitQualifier varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml
	,	@DEC186 xml

	set	@DEC186 =
		(	select
				(select EDI_XML.DE(@DictionaryVersion, '6063', @QuantityQualifier))
			,	(select EDI_XML.DE(@DictionaryVersion, '6060', @Quantity))
			,	(select case when @UnitQualifier is not null then EDI_XML.DE(@DictionaryVersion, '6411', @UnitQualifier) end)
			for xml path ('')
		)

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'QTY')
			--,	EDI_XML.DE(@DictionaryVersion, '1229', @NumberOfPackages)
			,	EDI_XML.CE(@dictionaryVersion, 'C186', @DEC186)
			for xml raw ('SEG-QTY'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
