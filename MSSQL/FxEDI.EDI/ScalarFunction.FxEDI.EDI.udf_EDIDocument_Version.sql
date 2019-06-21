
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_Version.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_Version'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_Version
end
go

create function EDI.udf_EDIDocument_Version
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@version', 'varchar(max)')
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
from
	EDI.EDIDocuments ed