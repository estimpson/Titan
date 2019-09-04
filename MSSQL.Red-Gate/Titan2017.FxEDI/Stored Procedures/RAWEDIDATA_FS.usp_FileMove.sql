SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [RAWEDIDATA_FS].[usp_FileMove]
	@FromFolder sysname = '%'
,	@ToFolder sysname
,	@FileNamePattern sysname
,	@FileAppendPrefix sysname = null
,	@FileAppendSuffix sysname = null
,	@TranDT datetime = null out
,	@Result integer = null out
as
set nocount on
set ansi_warnings off
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. FS.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
else begin
	save tran @ProcName
end
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
declare
	@toFolderName sysname
,	@newPathLocator hierarchyid

select
	@toFolderName = sp.Value
from
	dbo.udf_StringStack_Pop(@ToFolder, '\') sp

select top 1
	@newPathLocator = path_locator
from
	FxEDI.dbo.RawEDIData re
where
	re.name = @toFolderName
	and re.is_directory = 1
	and re.file_stream.GetFileNamespacePath() = @ToFolder

if	@newPathLocator is null begin
	set	@Result = 999998
	RAISERROR ('Error encountered in %s.  Failure: Invalid "ToFolder" specified.  Folder "%s" not found.', 16, 1, @ProcName, @ToFolder)
	rollback tran @ProcName
	return	@Result
end

set ansi_warnings on
declare
	@fromFolderName sysname

select
	@fromFolderName = sp.Value
from
	dbo.udf_StringStack_Pop(@FromFolder, '\') sp

declare
	@fromPathLocator hierarchyid

select top 1
	@fromPathLocator = re.path_locator
from
	FxEDI.dbo.RawEDIData re
where
	re.name = @fromFolderName
	and re.is_directory = 1
	and re.file_stream.GetFileNamespacePath() = @FromFolder

update
	re
set
	path_locator = re.path_locator.GetReparentedValue(@fromPathLocator, @newPathLocator)
,	name = coalesce(@FileAppendPrefix, '') + re.name + coalesce(@FileAppendSuffix, '')
from
	FxEDI.dbo.RawEDIData re
where
	re.parent_path_locator = @fromPathLocator
	and re.is_directory = 0
	and re.name like @FileNamePattern
option (maxdop 1)
--- </Body>

---	<CloseTran AutoCommit=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
---	</CloseTran AutoCommit=Yes>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries
{

}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@FromFolder sysname = '%'
,	@ToFolder sysname
,	@FileNamePattern sysname
,	@FileAppendPrefix sysname = null
,	@FileAppendSuffix sysname = null

set	@FromFolder = '\RawEDIData\Outbound\InProcess'
set @ToFolder = '\RawEDIData\Outbound\Sent'
set @FileNamePattern = '2014-02-17T093521.740.outbound00001.xml'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = RAWEDIDATA_FS.usp_FileMove
	@FromFolder = @FromFolder
,	@ToFolder = @ToFolder
,	@FileNamePattern = @FileNamePattern
,	@FileAppendPrefix = @FileAppendPrefix
,	@FileAppendSuffix = @FileAppendSuffix
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

select
	red.file_stream.GetFileNamespacePath()
,   *
from
	dbo.RawEDIData red
where
	red.name like @FileNamePattern
go

--commit
if	@@trancount > 0 begin
	rollback
end
go

set statistics io off
set statistics time off
go

}

Results {
}
*/
GO
