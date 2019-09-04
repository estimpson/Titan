SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_N4]
(	@DictionaryVersion varchar(25)
,	@CityName varchar(30)
,	@StateProvince char(2)
,	@PostalCode varchar(15)
,	@CountryCode varchar(3)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO(@dictionaryVersion, 'N4')
			,	EDI_XML.DE(@dictionaryVersion, '0019', @CityName)
			,	EDI_XML.DE(@dictionaryVersion, '0156', @StateProvince)
			,	EDI_XML.DE(@dictionaryVersion, '0116', @PostalCode)
			,	EDI_XML.DE(@dictionaryVersion, '0026', @CountryCode)
			for xml raw ('SEG-N4'), type
		)

--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
