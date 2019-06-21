
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_MessageNumber.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_MessageNumber'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_MessageNumber
end
go

create function EDI.udf_EDIDocument_MessageNumber
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/*[1]/SEG-BGM[1]/CE[@code="C106"][1]/DE[@code="1004"][1]', 'varchar(max)')
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
,	MessageNumber = EDI.udf_EDIDocument_MessageNumber(ed.Data)
from
	EDI.EDIDocuments ed