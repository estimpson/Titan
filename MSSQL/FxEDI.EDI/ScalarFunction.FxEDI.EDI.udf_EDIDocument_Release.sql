
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_Release.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_Release'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_Release
end
go

create function EDI.udf_EDIDocument_Release
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@release', 'varchar(max)')
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
,	Version = EDI.udf_EDIDocument_Version(ed.HeaderData)
,	Release = EDI.udf_EDIDocument_Release(ed.HeaderData)
from
	EDI.EDIDocuments ed