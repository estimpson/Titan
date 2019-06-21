
/*
Create Procedure.FxEDI.FTP.usp_SendCustomerEDI.sql
*/

use FxEDI
go

if	objectproperty(object_id('FTP.usp_SendCustomerEDI'), 'IsProcedure') = 1 begin
	drop procedure FTP.usp_SendCustomerEDI
end
go

create procedure FTP.usp_SendCustomerEDI
	@SendFileFromFolderRoot sysname = '\RawEDIData\CustomerEDI\OutBound'
,	@SendFileNamePattern sysname = '%0-90-90-90-90-9.xml'
,	@TranDT datetime = null out
,	@Result integer = null out
,	@Debug int = 0
,	@DebugMsg varchar(max) = null out
as
begin

	--set xact_abort on
	set nocount on

	--- <TIC>
	declare
		@cDebug int = @Debug + 2 -- Proc level

	if	@Debug & 0x01 = 0x01 begin
		declare
			@TicDT datetime = getdate()
		,	@TocDT datetime
		,	@TimeDiff varchar(max)
		,	@TocMsg varchar(max)
		,	@cDebugMsg varchar(max)

		set @DebugMsg = replicate(' -', (@Debug & 0x3E) / 2) + 'Start ' + user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)
	end
	--- </TIC>

	--- <SP Begin Logging>
	declare
		@LogID int

	insert
		FXSYS.USP_Calls
	(	USP_Name
	,	BeginDT
	,	InArguments
	)
	select
		USP_Name = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)
	,	BeginDT = getdate()
	,	InArguments = convert
			(	varchar(max)
			,	(	select
						[@SendFileFromFolderRoot] = @SendFileFromFolderRoot
					,	[@SendFileNamePattern] = @SendFileNamePattern
					,	[@TranDT] = @TranDT
					,	[@Result] = @Result
					,	[@Debug] = @Debug
					,	[@DebugMsg] = @DebugMsg
					for xml raw			
				)
			)

	set	@LogID = scope_identity()
	--- </SP Begin Logging>

	set	@Result = 999999

	--- <Error Handling>
	declare
		@CallProcName sysname
	,	@TableName sysname
	,	@ProcName sysname
	,	@ProcReturn integer
	,	@ProcResult integer
	,	@Error integer
	,	@RowCount integer

	set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. FTP.usp_Test
	--- </Error Handling>

	/*	Record initial transaction count. */
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount

	begin try

		---	<ArgumentValidation>

		---	</ArgumentValidation>

		--- <Body>
		--- <Tran Allowed=No>
		if	@@trancount > 0 begin
			raiserror('This procedure cannot be run in the context of a transaction.', 16, 1, @ProcName)
		end
		set	@TranDT = coalesce(@TranDT, GetDate())
		--- </Tran>

		--- <Body>
		/*	Begin FTP log. */
		set @TocMsg = 'Begin FTP log'
		
		declare
			@ftpLogID int
		begin
			insert
				FTP.LogHeaders
			(	Type
			,	Description
			)
			select
				Type = 2
			,	Description = 'Send Customer EDI.'

			set @ftpLogID = scope_identity()

			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end

		/*	Validate "In Process" folder is empty. */
		set @TocMsg = 'Validate "In Process" folder is empty'

		declare
			@stagingFolder sysname = @SendFileFromFolderRoot + '\Staging'
		,	@inProcessFolder sysname = @SendFileFromFolderRoot + '\InProcess'
		,	@sentFolder sysname = @SendFileFromFolderRoot + '\Sent'
		,	@errorFolder sysname = @SendFileFromFolderRoot + '\Error'
		,	@moveFilePrefix sysname = Replace(convert(varchar(50), getdate(), 126), ':', '') + '.'

		if	exists
			(	select
					*
				from
					dbo.RawEDIData redInboundFolder
					join dbo.RawEDIData redFiles
						on redFiles.parent_path_locator = redInboundFolder.path_locator
						and redFiles.is_directory = 0
				where
					redInboundFolder.is_directory = 1
					and redInboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder
			)
		begin
			insert
				FTP.LogDetails
			(	FLHRowID
			,	Line
			,	Command
			,	CommandOutput
			)
			select
				FLHRowID = @ftpLogID
			,	Line = -1
			,	Command = 'Input Queue not empty.'
			,	CommandOutput = 'Input Queue not empty.'
			
			--- <Call>
			set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
			execute
				@ProcReturn = RAWEDIDATA_FS.usp_FileMove
					@FromFolder = @inProcessFolder
				,   @ToFolder = @errorFolder
				,   @FileNamePattern = '%'
				,	@FileAppendPrefix = @moveFilePrefix
				,	@TranDT = @TranDT out
				,	@Result = @ProcResult out

			set	@Error = @@Error
			if	@Error != 0 begin
				set	@Result = 900501
				raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
			end
			if	@ProcReturn != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
			if	@ProcResult != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
			end
			--- </Call>
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Move files in "Staging Folder" to "Inprocess Folder".  */
		set @TocMsg = 'Move files in "Staging Folder" to "Inprocess Folder"'
		begin
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
			end
			if	@ProcReturn != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
			if	@ProcResult != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
			end
			--- </Call>
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Update the location of the moved file(s) in the release plan generation log and log. */
		set @TocMsg = 'Update the location of the moved file(s) in the release plan generation log'
		begin
			update
				cegl
			set	CurrentFilePath = redOutboundFiles.file_stream.GetFileNamespacePath()
			from
				FX.CustomerEDI_GenerationLog cegl
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
				FLHRowID = @ftpLogID
			,	Line = 1
			,	Command = 'Output Customer EDI Queue'
			,	CommandOutput = @outboundFileList
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Perform FTP and log. */
		set @TocMsg = 'Perform FTP and log'
		begin
			declare
				@command varchar(8000) = '\\tterp\MSSQLSERVER\FxEDI\RawEDIData\CustomerEDI\FTPCommands\SendOutbound_v2.cmd'
			,	@commandOutput varchar(max)
			
			execute as login = 'sa'

			execute EDI.usp_CommandShell_Execute
					@Command = @command
				,	@CommandOutput = @commandOutput out
				,	@TranDT = @TranDT out
				,	@Result = @Result out

			revert

			insert
				FTP.LogDetails
			(	FLHRowID
			,	Line
			,	Command
			,	CommandOutput
			)
			select
				FLHRowID = @ftpLogID
			,	Line = 2
			,	Command = @command
			,	CommandOutput = @commandOutput
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Check for known error conditions and raise an error. */
		set @TocMsg = 'Check for known error conditions and raise an error'
		begin
			if	@CommandOutput like '%Unknown host%'
			begin
				raiserror ('Error encountered in %s.  Unknown host.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end

			if	@CommandOutput like '%Not connected.%'
			begin
				raiserror ('Error encountered in %s.  Not connected.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end

			if	@CommandOutput not like '%No session.%'
			begin
				raiserror ('Error encountered in %s.  Timeout.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Move outbound folders to archive folder. */
		set @TocMsg = 'Move outbound folders to archive folder'
		begin
			--- <Call>
			set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMovee'
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
			end
			if	@ProcReturn != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
			if	@ProcResult != 0 begin
				set	@Result = 900502
				raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
			end
			--- </Call>
				
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		
		/*	Update the location of the moved file(s) in the release plan generation log. */
		set @TocMsg = 'Update the location of the moved file(s) in the release plan generation log'
		begin
			update
				cegl
			set	CurrentFilePath = redOutboundFiles.file_stream.GetFileNamespacePath()
			from
				FX.CustomerEDI_GenerationLog cegl
				join dbo.RawEDIData redOutboundFolder
					join dbo.RawEDIData redOutboundFiles
						on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
						and redOutboundFiles.is_directory = 0
						and redOutboundFiles.name like @moveFilePrefix + @SendFileNamePattern
					on redOutboundFiles.stream_id = cegl.FileStreamID
			where
				redOutboundFolder.is_directory = 1
				and redOutboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder
			
			--- <TOC>
			if	@Debug & 0x01 = 0x01 begin
				set @TocDT = getdate()
				set @TimeDiff =
					case
						when datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01')) > 1
							then convert(varchar, datediff(day, @TocDT - @TicDT, convert(datetime, '1900-01-01'))) + ' day(s) ' + convert(char(12), @TocDT - @TicDT, 114)
						else
							convert(varchar(12), @TocDT - @TicDT, 114)
					end
				set @DebugMsg = @DebugMsg + char(13) + char(10) + replicate(' -', (@Debug & 0x3E) / 2) + @TocMsg + ': ' + @TimeDiff
				set @TicDT = @TocDT
			end
			set @DebugMsg += coalesce(char(13) + char(10) + @cDebugMsg, N'')
			set @cDebugMsg = null
			--- </TOC>
		end
		--- </Body>

		--- <SP End Logging>
		update
			uc
		set	EndDT = getdate()
		,	OutArguments = convert
				(	varchar(max)
				,	(	select
							[@TranDT] = @TranDT
						,	[@Result] = @Result
						,	[@DebugMsg] = @DebugMsg
						for xml raw			
					)
				)
		from
			FXSYS.USP_Calls uc
		where
			uc.RowID = @LogID
		--- </SP End Logging>

		--- <TIC/TOC END>
		if	@Debug & 0x3F = 0x01 begin
			set @DebugMsg = @DebugMsg + char(13) + char(10)
			print @DebugMsg
		end
		--- </TIC/TOC END>

		---	<Return>
		set	@Result = 0
		return
			@Result
		--- </Return>
	end try
	begin catch
		/*	Move outbound files to error folder. */
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

		update
			cegl
		set	CurrentFilePath = redOutboundFiles.file_stream.GetFileNamespacePath()
		from
			FX.CustomerEDI_GenerationLog cegl
			join dbo.RawEDIData redOutboundFolder
				join dbo.RawEDIData redOutboundFiles
					on redOutboundFiles.parent_path_locator = redOutboundFolder.path_locator
					and redOutboundFiles.is_directory = 0
					and redOutboundFiles.name like @moveFilePrefix + @SendFileNamePattern
				on redOutboundFiles.stream_id = cegl.FileStreamID
		where
			redOutboundFolder.is_directory = 1
			and redOutboundFolder.file_stream.GetFileNamespacePath() = @errorFolder

		declare
			@errorSeverity int
		,	@errorState int
		,	@errorMessage nvarchar(2048)
		,	@xact_state int
	
		select
			@errorSeverity = error_severity()
		,	@errorState = error_state ()
		,	@errorMessage = error_message()
		,	@xact_state = xact_state()

		execute FXSYS.usp_PrintError

		if	@xact_state = -1 begin 
			rollback
			execute FXSYS.usp_LogError
		end
		if	@xact_state = 1 and @TranCount = 0 begin
			rollback
			execute FXSYS.usp_LogError
		end
		if	@xact_state = 1 and @TranCount > 0 begin
			rollback transaction @ProcName
			execute FXSYS.usp_LogError
		end

		raiserror(@errorMessage, @errorSeverity, @errorState)
	end catch
end

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
	@FinishedPart varchar(25) = 'ALC0598-HC02'
,	@ParentHeirarchID hierarchyid

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = FTP.usp_SendCustomerEDI
	@FinishedPart = @FinishedPart
,	@ParentHeirarchID = @ParentHeirarchID
,	@TranDT = @TranDT out
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
go

