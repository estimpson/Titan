
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_ControlNumber.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_ControlNumber'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_ControlNumber
end
go

create function EDI.udf_EDIDocument_ControlNumber
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@control_number', 'varchar(max)')
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
,	ControlNumber = EDI.udf_EDIDocument_ControlNumber(ed.HeaderData)
from
	EDI.EDIDocuments ed