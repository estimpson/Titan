SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [FTP].[usp_SendSupplierEDI]
	@SendFileFromFolderRoot sysname = '\RawEDIData\SupplierEDI\OutBound'
,	@SendFileNamePattern sysname = '%[0-9][0-9][0-9][0-9][0-9].xml'
,	@TranDT datetime = null out
,	@Result integer = null out
as
set nocount on
set ansi_warnings on
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. EDI.usp_Test
--- </Error Handling>

--- <Tran Allowed=No AutoCreate=No TranDTParm=Yes>
if	@@TRANCOUNT > 0 begin

	RAISERROR ('This procedure cannot be run in the context of a transaction.', 16, 1, @ProcName)
	return
end

set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
declare
	@stagingFolder sysname = @SendFileFromFolderRoot + '\Staging'
,	@inProcessFolder sysname = @SendFileFromFolderRoot + '\InProcess'
,	@sentFolder sysname = @SendFileFromFolderRoot + '\Sent'
,	@errorFolder sysname = @SendFileFromFolderRoot + '\Error'
,	@moveFilePrefix sysname = Replace(convert(varchar(50), getdate(), 126), ':', '') + '.'

declare
	@fhlRow int

insert
	FTP.LogHeaders with (tablockx)
(	Type
,	Description
)
select
	Type = 2
,	Description = 'Send Supplier EDI.'

set	@fhlRow = scope_identity()

if	exists
	(	select
			*
		from
			dbo.RawEDIData redOutboundFolder
			join dbo.RawEDIData redOutboundFiles
				on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
				and redOutboundFiles.is_directory = 0
		where
			redOutboundFolder.is_directory = 1
			and redOutboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder
	) begin

	insert
		FTP.LogDetails
	(	FLHRowID
	,	Line
	,	Command
	,	CommandOutput
	)
	select
		FLHRowID = @fhlRow
	,	Line = -1
	,	Command = 'Output Queue not empty.'
	,	CommandOutput = 'Output Queue not empty.'

	--- <Call>
	set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
	execute
		@ProcReturn = RAWEDIDATA_FS.usp_FileMove
			@FromFolder = @inProcessFolder
		,   @ToFolder = @errorFolder
		,   @FileNamePattern = @SendFileNamePattern
		,   @FileAppendPrefix = @moveFilePrefix
		,   @TranDT = @TranDT out
		,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		goto ERROR_HANDLING
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		goto ERROR_HANDLING
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		goto ERROR_HANDLING
	end
	--- </Call>

	--RAISERROR ('Folder %s\InProcess is not empty.  FTP cannot begin until this is corrected.', 16, 1, @SendFileFromFolderRoot)
	--return
end

--- <Call>
set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
execute
	@ProcReturn = RAWEDIDATA_FS.usp_FileMove
	    @FromFolder = @stagingFolder
	,   @ToFolder = @inProcessFolder
	,   @FileNamePattern = @SendFileNamePattern
	,   @FileAppendPrefix = @moveFilePrefix
	,   @TranDT = @TranDT out
	,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	goto ERROR_HANDLING
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	goto ERROR_HANDLING
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	goto ERROR_HANDLING
end
--- </Call>

/*	Update the location of the moved file(s) in the release plan generation log.*/
update
	cegl
set	CurrentFilePath = redOutboundFiles.file_stream.GetFileNamespacePath()
from
	EEH.SupplierEDI.GenerationLog cegl
	join dbo.RawEDIData redOutboundFolder
		join dbo.RawEDIData redOutboundFiles
			on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
			and redOutboundFiles.is_directory = 0
			and redOutboundFiles.name like @moveFilePrefix + @SendFileNamePattern
		on redOutboundFiles.stream_id = cegl.FileStreamID
where
	redOutboundFolder.is_directory = 1
	and redOutboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder

declare
	@outboundFileList varchar(max) = ''

select
	@outboundFileList += redOutboundFiles.name + ','
from
	dbo.RawEDIData redOutboundFolder
	left join dbo.RawEDIData redOutboundFiles
		on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
		and redOutboundFiles.is_directory = 0
where
	redOutboundFolder.is_directory = 1
	and redOutboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder

insert
	FTP.LogDetails
(	FLHRowID
,	Line
,	Command
,	CommandOutput
)
select
	FLHRowID = @fhlRow
,	Line = 1
,	Command = 'Output Supplier EDI Queue'
,	CommandOutput = @outboundFileList

/*	Use an administrative account. */
execute as login = 'sa'

declare
	@CommandOutput varchar(max)
,	@Command varchar(max) = '\\Eehsql1\mssqlserver\FxEDI\RawEDIData\SupplierEDI\FTPCommands\SendOutbound_v3.cmd'

/*	Perform ftp. */
exec
--	loopback.FxEDI.EDI.usp_CommandShell_Execute
	FxEDI.EDI.usp_CommandShell_Execute
	@Command = @Command
,	@CommandOutput = @CommandOutput out

insert
	FTP.LogDetails
(	FLHRowID
,	Line
,	Command
,	CommandOutput
)
select
	FLHRowID = @fhlRow
,	Line = 2
,	Command = @Command
,	CommandOutput = @CommandOutput

revert

/*	Check for known error conditions and raise an error. */
if	@CommandOutput like '%Unknown host%'
	begin

	raiserror ('Error encountered in %s.  Unknown host.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	goto ERROR_HANDLING
end

if	@CommandOutput like '%Not connected.%'
	begin

	raiserror ('Error encountered in %s.  Not connected.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	goto ERROR_HANDLING
end

if	@CommandOutput not like '%No session.%'
	begin

	raiserror ('Error encountered in %s.  Timeout.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	goto ERROR_HANDLING
end

/*	Move outbound files to archive folder. */
--- <Call>
set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
execute
	@ProcReturn = RAWEDIDATA_FS.usp_FileMove
	    @FromFolder = @inProcessFolder
	,   @ToFolder = @sentFolder
	,   @FileNamePattern = '%'
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	goto ERROR_HANDLING
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	goto ERROR_HANDLING
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	goto ERROR_HANDLING
end
--- </Call>

update
	cegl
set	CurrentFilePath = redOutboundFiles.file_stream.GetFileNamespacePath()
,	FileSendDT = getdate()
from
	EEH.SupplierEDI.GenerationLog cegl
	join dbo.RawEDIData redOutboundFolder
		join dbo.RawEDIData redOutboundFiles
			on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
			and redOutboundFiles.is_directory = 0
			and redOutboundFiles.name like @moveFilePrefix + @SendFileNamePattern
		on redOutboundFiles.stream_id = cegl.FileStreamID
where
	redOutboundFolder.is_directory = 1
	and redOutboundFolder.file_stream.GetFileNamespacePath() = @sentFolder
--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

--	Error handling
ERROR_HANDLING:

/*	Move outbound files to error folder. */
--- <Call>
set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
execute
	@ProcReturn = RAWEDIDATA_FS.usp_FileMove
		@FromFolder = @inProcessFolder
	,   @ToFolder = @errorFolder
	,   @FileNamePattern = '%'
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	return	@Result
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	return	@Result
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	return	@Result
end
--- </Call>
return

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
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = FTP.usp_SendSupplierEDI
	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

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
