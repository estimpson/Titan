SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_ATH]
(	@dictionaryVersion varchar(25)
,	@resourceAuthorizationCode char(2)
,	@date1 datetime = null
,	@quantity1 int = null
,	@quantity2 int = null
,	@date2 datetime = null
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	--set	@xmlOutput =
	--	(	select
	--			EDI_XML.SEG_INFO(@dictionaryVersion, 'ATH')
	--		,	EDI_XML.DE(@dictionaryVersion, '0672', @resourceAuthorizationCode)
	--		,	EDI_XML.DE(@dictionaryVersion, '0373', EDI_XML.FormatDate(@dictionaryVersion, @date1))
	--		,	EDI_XML.DE(@dictionaryVersion, '0380', @quantity1)
	--		,	EDI_XML.DE(@dictionaryVersion, '0380', @quantity2)
	--		,	EDI_XML.DE(@dictionaryVersion, '0373', EDI_XML.FormatDate(@dictionaryVersion, @date2))
	--		for xml raw ('SEG-ATH'), type
	--	)

	set	@xmlOutput = convert
		(	xml
		,	'
<SEG-ATH>
  <SEG-INFO code="ATH" name="RESOURCE AUTHORIZATION" />
  <DE code="0672" name="RESOURCE AUTHORIZATION CODE" type="ID" desc="' +
	case
		when @resourceAuthorizationCode = 'FI' then 'Finished (Labor, Material, and Overhead/'
		when @resourceAuthorizationCode = 'MT' then 'Material'
		when @resourceAuthorizationCode = 'PQ' then 'Cumulative Quantity Required Prior'
		else 'UNK'
	end + '/">' + @resourceAuthorizationCode + '</DE>
  <DE code="0373" name="DATE" type="DT">' + EDI_XML.FormatDate(@dictionaryVersion, @date1) + '</DE>
  <DE code="0380" name="QUANTITY" type="R">' + convert(varchar(15), @quantity1) + '</DE>' +
	case
		when @quantity2 is not null then '
  <DE code="0380" name="QUANTITY" type="R">' + convert(varchar(15), @quantity2) + '</DE>'
		else ''
	end + '
  <DE code="0373" name="DATE" type="DT">' + EDI_XML.FormatDate(@dictionaryVersion, @date2) + '</DE>
</SEG-ATH>'
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
