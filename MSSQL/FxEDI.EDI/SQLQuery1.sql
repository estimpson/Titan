
select
	ed.GUID
,	ed.Status
,	ed.FileName
,	ed.HeaderData
,	TradingPartner = EDI.udf_EDIDocument_TradingPartner(ed.HeaderData)
,	Type = EDI.udf_EDIDocument_Type(ed.HeaderData)
,	Version = EDI.udf_EDIDocument_Version(ed.HeaderData)
,	Release = EDI.udf_EDIDocument_Release(ed.HeaderData)
,	DocNumber = EDI.udf_EDIDocument_DocNumber(ed.HeaderData)
,	ControlNumber = EDI.udf_EDIDocument_ControlNumber(ed.HeaderData)
,	DeliverySchedule = EDI.udf_EDIDocument_DeliverySchedule(ed.Data)
,	MessageNumber = EDI.udf_EDIDocument_MessageNumber(ed.Data)
from
	EDI.EDIDocuments ed

update
	ed
set
	TradingPartner = EDI.udf_EDIDocument_TradingPartner(ed.HeaderData)
,	Type = EDI.udf_EDIDocument_Type(ed.HeaderData)
,	Version = EDI.udf_EDIDocument_Version(ed.HeaderData)
,	Release = EDI.udf_EDIDocument_Release(ed.HeaderData)
,	DocNumber = EDI.udf_EDIDocument_DocNumber(ed.HeaderData)
,	ControlNumber = EDI.udf_EDIDocument_ControlNumber(ed.HeaderData)
from
	EDI.EDIDocuments ed


update
	ed
set
	ed.EDIStandard =
		case
			when 
from
	EDI.EDIDocuments ed


select
	*
from
	EDI.EDIDocuments ed
