
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_DeliverySchedule.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_DeliverySchedule'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_DeliverySchedule
end
go

create function EDI.udf_EDIDocument_DeliverySchedule
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/*[1]/SEG-BGM[1]/CE[@code="C002"][1]/DE[@code="1001"][1]', 'varchar(max)')
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
,	DeliverySchedule = EDI.udf_EDIDocument_DeliverySchedule(ed.Data)
from
	EDI.EDIDocuments ed