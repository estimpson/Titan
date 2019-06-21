
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_TradingPartner.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_TradingPartner'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_TradingPartner
end
go

create function EDI.udf_EDIDocument_TradingPartner
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@trading_partner', 'varchar(max)')
--- </Body>

---	<Return>
	return
		@ReturnValue
end
go

select
	ed.GUID
,	ed.Status
,	ed.FileName
,	ed.HeaderData
,	TradingPartner = EDI.udf_EDIDocument_TradingPartner(ed.HeaderData)
from
	EDI.EDIDocuments ed