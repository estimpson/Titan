
/*
Create ScalarFunction.FxEDI.EDI.udf_EDIDocument_DocNumber.sql
*/

use FxEDI
go

if	objectproperty(object_id('EDI.udf_EDIDocument_DocNumber'), 'IsScalarFunction') = 1 begin
	drop function EDI.udf_EDIDocument_DocNumber
end
go

create function EDI.udf_EDIDocument_DocNumber
(	@XMLData xml
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ReturnValue varchar(max)
		
	set @ReturnValue = @XMLData.value('/TRN-INFO[1]/@doc_number', 'varchar(max)')
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
,	DocNumber = EDI.udf_EDIDocument_DocNumber(ed.HeaderData)
from
	EDI.EDIDocuments ed