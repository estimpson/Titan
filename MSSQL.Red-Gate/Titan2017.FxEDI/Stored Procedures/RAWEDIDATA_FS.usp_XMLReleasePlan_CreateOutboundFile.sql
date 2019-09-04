SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [RAWEDIDATA_FS].[usp_XMLReleasePlan_CreateOutboundFile]
	@TradingPartner varchar(50)
,	@PurchaseOrderList varchar(max)
,	@FunctionName sysname
,	@XMLData varbinary(max)
,	@TestMailBox int
,	@FileGenerationTime datetime = null
,	@TranDT datetime = null out
,	@Result integer = null out
as
set nocount on
set ansi_warnings on
set ansi_nulls on
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. EDISupplier.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
declare
	@fileStreamID table
(	FileStreamID uniqueidentifier
)

declare
	@outboundPath sysname =
		case
			when @TestMailBox = 1 then '\RawEDIData\SupplierEDI_TestMailBox\Outbound\Staging'
			else '\RawEDIData\SupplierEDI\Outbound\Staging'
		end
			
insert
	FxEDI.dbo.RawEDIData
(	file_stream
,	name
,	path_locator
)
output
	inserted.stream_id into @fileStreamID
values
(	@XMLData
,	FxEDI.RAWEDIDATA_FS.udf_GetNextOutboundXMLFileName (@outboundPath)
,	FxEDI.RAWEDIDATA_FS.udf_GetFilePathLocator(@outboundPath)
)
option (maxdop 1)

insert
	EEH.SupplierEDI.GenerationLog
(	FileStreamID
,	Type
,	TradingPartner
,	PurchaseOrderList
,	FunctionName
,	FileGenerationDT
,	OriginalFileName
,	CurrentFilePath
)
select
	FileStreamID = red.stream_id
,	Type = 1
,	@TradingPartner
,	@PurchaseOrderList
,	@FunctionName
,	FileGenerationDT = red.last_write_time
,	OriginalFileName = red.name
,	CurrentFilePath = red.file_stream.GetFileNamespacePath()
from
	FxEDI.dbo.RawEDIData red
	join @fileStreamID fsi
		on fsi.FileStreamID = red.stream_id
--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>
GO
