SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [FTP].[usp_ReceiveCustomerEDI]
	@ReceiveFileFromFolderRoot sysname = '\RawEDIData\CustomerEDI\Inbound'
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

		set @DebugMsg = replicate(' -', (@Debug & 0x3E) / 2) + 'Start ' + schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)
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
		USP_Name = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)
	,	BeginDT = getdate()
	,	InArguments = convert
			(	varchar(max)
			,	(	select
						[@ReceiveFileFromFolderRoot] = @ReceiveFileFromFolderRoot
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
		@CallProcName sysname,
		@TableName sysname,
		@ProcName sysname,
		@ProcReturn integer,
		@ProcResult integer,
		@Error integer,
		@RowCount integer

	set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. FTP.usp_Test
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
				Type = 1
			,	Description = 'Receive EDI.'

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
			@inboundFolder sysname = @ReceiveFileFromFolderRoot
		,	@inProcessFolder sysname = @ReceiveFileFromFolderRoot + '\InProcess'
		,	@archiveFolder sysname = @ReceiveFileFromFolderRoot + '\Archive'
		,	@errorFolder sysname = @ReceiveFileFromFolderRoot + '\Error'
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
		
		/*	Check that "Inbound Folder" is empty and execute batch jobs to get new files. */
		set @TocMsg = 'Check that "Inbound Folder" is empty and execute batch jobs to get new files'

		if	not exists
			(	select
					*
				from
					dbo.RawEDIData redInboundFolder
					join dbo.RawEDIData redFiles
						on redFiles.parent_path_locator = redInboundFolder.path_locator
						and redFiles.is_directory = 0
				where
					redInboundFolder.is_directory = 1
					and redInboundFolder.file_stream.GetFileNamespacePath() = @inboundFolder
			)
		begin
			declare
				@command varchar(8000) = '\\tterp\MSSQLSERVER\FxEDI\RawEDIData\CustomerEDI\FTPCommands\ReceiveInbound_v2.cmd'
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
			,	Line = 1
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
		
		/*	Move inbound folders to inprocess folder. */
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
					and redInboundFolder.file_stream.GetFileNamespacePath() = @inboundFolder
			)
		set @TocMsg = 'Move inbound folders to inprocess folder'
		begin
			--- <Call>
			set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
			execute
				@ProcReturn = RAWEDIDATA_FS.usp_FileMove
					@FromFolder = @inboundFolder
				,   @ToFolder = @inProcessFolder
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
		
		/*	Copy data to XML documents table and archive files. */
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
		set @TocMsg = 'Copy data to XML documents table'
		begin
			insert
				EDI.EDIDocuments
			(	GUID
			,	FileName
			,	HeaderData
			,	Data
			,	TradingPartner
			,	Type
			,	Version
			,	EDIStandard
			,	Release
			,	DocNumber
			,	ControlNumber
			,	DeliverySchedule
			,	MessageNumber
				)
			select
				GUID = redFiles.stream_id
			,	FileName = redFiles.name
			,	HeaderData = red.Data.query('/*[1]/TRN-INFO[1]')
			,	Data = red.data
			,	TradingPartner = EDI.udf_EDIDocument_TradingPartner(red.Data.query('/*[1]/TRN-INFO[1]'))
			,	Type = EDI.udf_EDIDocument_Type(red.Data.query('/*[1]/TRN-INFO[1]'))
			,	Version = EDI.udf_EDIDocument_Version(red.Data.query('/*[1]/TRN-INFO[1]'))
			,	EDIStandard = null
			,	Release = null
			,	DocNumber = null
			,	ControlNumber = null
			,	DeliverySchedule = null
			,	MessageNumber = null
			from
				dbo.RawEDIData redInboundFolder
				join dbo.RawEDIData redFiles
					on redFiles.parent_path_locator = redInboundFolder.path_locator
					and redFiles.is_directory = 0
				cross apply
					(	select
							Data = convert(xml, redFiles.file_stream)
					) red
			where
				redInboundFolder.is_directory = 1
				and redInboundFolder.file_stream.GetFileNamespacePath() = @inProcessFolder
				
			--- <Call>
			set	@CallProcName = 'RAWEDIDATA_FS.usp_FileMove'
			execute
				@ProcReturn = RAWEDIDATA_FS.usp_FileMove
					@FromFolder = @inProcessFolder
				,   @ToFolder = @archiveFolder
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
	@ReceiveFileFromFolderRoot sysname = '\RawEDIData\CustomerEDI\Inbound'

--begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer
,	@Debug int = 2
,	@DebugMsg varchar(max) = null

execute
	@ProcReturn = FTP.usp_ReceiveCustomerEDI
	@ReceiveFileFromFolderRoot = @ReceiveFileFromFolderRoot
,	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Debug = @Debug
,	@DebugMsg = @DebugMsg

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult, @Debug, @DebugMsg
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
