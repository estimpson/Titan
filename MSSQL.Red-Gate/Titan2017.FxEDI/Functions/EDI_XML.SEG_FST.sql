SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[SEG_FST]
(	@dictionaryVersion varchar(25)
,	@quantity int
,	@forecastQualifier char(1)
,	@forecastTimingQualifier char(1)
,	@date1 datetime
,	@date2 datetime = null
,	@dateTimeQualifier char(3)
,	@time datetime = null
,	@referenceIdentificationQualifier varchar(3) = null
,	@referenceIdentification varchar(30)
,	@planningScheduleTypeCode char(2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	--set	@xmlOutput =
	--	(	select
	--			EDI_XML.SEG_INFO(@dictionaryVersion, 'FST')
	--		,	EDI_XML.DE(@dictionaryVersion, '0380', @quantity)
	--		,	EDI_XML.DE(@dictionaryVersion, '0680', @forecastQualifier)
	--		,	EDI_XML.DE(@dictionaryVersion, '0681', @forecastTimingQualifier)
	--		,	EDI_XML.DE(@dictionaryVersion, '0373', EDI_XML.FormatDate(@dictionaryVersion, @date1))
	--		,	case when @date2 is not null then EDI_XML.DE(@dictionaryVersion, '0373', EDI_XML.FormatDate(@dictionaryVersion, @date2)) end
	--		,	case when @dateTimeQualifier is not null then EDI_XML.DE(@dictionaryVersion, '0374', @dateTimeQualifier) end
	--		,	case when @time is not null then EDI_XML.DE(@dictionaryVersion, '0337', @time) end
	--		,	case when @referenceIdentificationQualifier is not null then EDI_XML.DE(@dictionaryVersion, '0128', @referenceIdentificationQualifier) end
	--		,	case when @referenceIdentification is not null then EDI_XML.DE(@dictionaryVersion, '0127', @referenceIdentification) end
	--		,	case when @planningScheduleTypeCode is not null then EDI_XML.DE(@dictionaryVersion, '0783', @planningScheduleTypeCode) end
	--		for xml raw ('SEG-FST'), type
	--)

	set	@xmlOutput = convert
		(	xml
		,	'
<SEG-FST>
  <SEG-INFO code="FST" name="FORECAST SCHEDULE" />
  <DE code="0380" name="QUANTITY" type="R">' + convert(varchar(12), @quantity) + '</DE>
  <DE code="0680" name="FORECAST QUALIFIER" type="ID" desc="' + case when @forecastQualifier = 'C' then 'Firm' when @forecastQualifier = 'D' then 'Planning' else 'UNK' end + '">' + @forecastQualifier + '</DE>
  <DE code="0681" name="FORECAST TIMING QUALIFIER" type="ID" desc="' + case when @forecastTimingQualifier = 'D' then 'Discrete' when @forecastTimingQualifier = 'W' then 'Weekly Bucket (Monday through Sunday)' else 'UNK' end + '">' + @forecastTimingQualifier + '</DE>
  <DE code="0373" name="DATE" type="DT">' + EDI_XML.FormatDate(@dictionaryVersion, @date1) + '</DE>
</SEG-FST>'
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end
GO
