SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [EDI].[usp_ProcessIConnectAcknowledgements]
	@TranDT datetime = null out
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
						[@TranDT] = @TranDT
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

	set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. EDI.usp_Test
	--- </Error Handling>

	/*	Record initial transaction count. */
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount

	begin try

		---	<ArgumentValidation>

		---	</ArgumentValidation>

		--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
		if	@TranCount = 0 begin
			begin tran @ProcName
		end
		else begin
			save tran @ProcName
		end
		set	@TranDT = coalesce(@TranDT, GetDate())
		--- </Tran>

		--- <Body>
		/*	Move new/reprocessed documents to in process otherwise done. */
		set @TocMsg = 'Move new/reprocessed documents to in process otherwise done'
		if	exists
				(	select
						*
					from
						FxEDI.EDI.EDIDocuments ed
					where
						ed.Status in (0,2)
						and 
						(	ed.Data.exist('D_856') = 1
							or ed.Data.exist('D_DESADV') = 1
						)
				)
		begin
			--- <Update rows="1+">
			set	@TableName = 'EDI.EDIDocuments'

			update
				ed
			set
				Status = 100
			from
				FxEDI.EDI.EDIDocuments ed
			where
				ed.Status in (0,2)
				and 
				(	ed.Data.exist('D_856') = 1
					or ed.Data.exist('D_DESADV') = 1
				)

			select
				@Error = @@Error,
				@RowCount = @@Rowcount

			if	@Error != 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			end
			if	@RowCount <= 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
			end
			--- </Update>

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
		else begin
			goto done
		end

		/*	Prepare ship notice acknowledgements. */
		set @TocMsg = 'Prepare ship notice acknowledgements'
		begin
			declare
				@shipNoticeAcknowledgement table
			(	RawDocumentGUID uniqueidentifier
			,	ASNNumber varchar(50)
			,	ShipDate varchar(50)
			,	SupplierCode varchar(50)
			,	Status varchar(50)
			)

			insert
				@shipNoticeAcknowledgement
			(	RawDocumentGUID
			,	ASNNumber
			,	ShipDate
			,	SupplierCode
			,	Status
			)
			select
				RawDocumentGUID = ed.GUID
			,	ASNNumber = ed.Data.value('(*/Field[@Name="ASN Num"]/@Value)[1]', 'varchar(50)')
			,	ShipDate = ed.Data.value('(*/Field[@Name="Ship Date"]/@Value)[1]', 'varchar(50)')
			,	SupplierCode = ed.Data.value('(*/Field[@Name="Supplier Code"]/@Value)[1]', 'varchar(50)')
			,	Status = ed.Data.value('(*/Field[@Name="Status"]/@Value)[1]', 'varchar(50)')
			from
				FxEDI.EDI.EDIDocuments ed
			where
				ed.Status = 100
				and 
				(	ed.Data.exist('D_856') = 1
					or ed.Data.exist('D_DESADV') = 1
				)
			
			if	@Debug & 0x01 = 0x01 begin	
				select 'shipNoticeAcknowledgement', * from @shipNoticeAcknowledgement sna
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
		
		/*	Write to acknowledgement history table. */
		set @TocMsg = 'Write to acknowledgement history table. '
		begin
			insert
				EDI.ShipNoticeAcknowledgements
			(	RawDocumentGUID
			,	ASNNumber
			,	ShipDate
			,	SupplierCode
			,	iConnectStatus
			)
			select
				sna.RawDocumentGUID
			,	sna.ASNNumber
			,	ShipDate =
					case
						when len(sna.ShipDate) = 8 then convert(datetime, sna.ShipDate)
						when len(sna.ShipDate) = 12 then convert(datetime, left(sna.ShipDate, 8) + ' ' + substring(sna.ShipDate, 9, 2) + ':' + right(sna.ShipDate, 2))
					end
			,	sna.SupplierCode
			,	sna.Status
			from
				@shipNoticeAcknowledgement sna
			
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
		
		/*	Update status on EDI generation log. */
		set @TocMsg = 'Update status on EDI generation log'
		begin
			update
				cegl
			set	cegl.Status =
					case
						when sna.Status = 1 then 2
						else -2
					end
			,	cegl.FileAcknowledgementDT = @TranDT
			from
				FX.CustomerEDI_GenerationLog cegl
				join @shipNoticeAcknowledgement sna
					on sna.ASNNumber = cegl.ShipperID
			where
				cegl.Status in (1, -2)
				
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

		/*	Generate email. */
		set @TocMsg = 'Generate email'
		begin
			select
				Shipper_ID = cegl.ShipperID
			,	Ship_To = max(s.destination)
			,	Shipped_DT = max(s.date_shipped)
			,	ASN_Send_DT = max(coalesce(cegl.FileSendDT, cegl.FileGenerationDT))
			,	File_Acknowledgement_DT = max(cegl.FileAcknowledgementDT)
			,	XML_Ship_Notice_Function_Name = max(cegl.XMLShipNotice_FunctionName)
			,	Message =
					case
						when sna.Status = 1 then 'SUCCESS: File sent without errors.'
						else 'ERROR: File has errors.  Review in iExchange draft folder'
					end
			into
				#ShipNoticeAcknodgementEmail
			from
				FX.CustomerEDI_GenerationLog cegl
				join @shipNoticeAcknowledgement sna
					on sna.ASNNumber = cegl.ShipperID
				join Fx.shipper s
					on s.id = cegl.ShipperID
			group by
				cegl.ShipperID
			,	sna.Status

			declare
				@html nvarchar(max)
			
			--- <Call>	
			set	@CallProcName = 'FXSYS.usp_TableToHTML'
			execute
				@ProcReturn = FXSYS.usp_TableToHTML
					@TableName = '#ShipNoticeAcknodgementEmail'
				,	@OrderBy = null
				,	@Html = @html out
				,	@IncludeRowNumber = 0
				,	@CamelCaseHeaders = 1
			
			set	@Error = @@Error
			if	@Error != 0 begin
				set	@Result = 900501
				RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
			end
			if	@ProcReturn != 0 begin
				set	@Result = 900502
				RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
			if	@ProcResult != 0 begin
				set	@Result = 900502
				RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
			end
			--- </Call>

			if	@Debug & 0x01 = 0x01 begin
				exec FXSYS.usp_LongPrint @html
			end
			
			declare
				@emailHeader nvarchar(max) = N'Ship Notice - iConnect Acknowledgment'
			declare
				@emailBody nvarchar(max) = N'<H1>' + @emailHeader + N'</H1>' + @html
			,	@profileName sysname
			,	@recipients sysname
			,	@copyRecipients sysname

			select top(1)
				@profileName = aed.DBMailProfileName
			,	@recipients = aed.RecipientsList
			,	@copyRecipients = aed.CopyList
			from
				FxEDI.EDI.AlertEmailDefinition aed
			order by
				aed.RowID desc

			exec msdb.dbo.sp_send_dbmail
				@profile_name = @profileName
			,	@recipients = @recipients
			,	@copy_recipients = @copyRecipients
			,	@subject = @emailHeader
			,	@body = @emailBody
			,	@body_format = 'HTML'
			,	@importance = 'HIGH'
				
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
		
		/*	Set in process documents to processed. */
		set @TocMsg = 'Set in process documents to processed'
		begin
			--- <Update rows="1+">
			set	@TableName = 'EDI.EDIDocuments'
			
			update
				ed
			set
				Status = 1
			from
				FxEDI.EDI.EDIDocuments ed
			where
				ed.Status = 100
				and 
				(	ed.Data.exist('D_856') = 1
					or ed.Data.exist('D_DESADV') = 1
				)
			
			select
				@Error = @@Error,
				@RowCount = @@Rowcount
			
			if	@Error != 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			end
			if	@RowCount <= 0 begin
				set	@Result = 999999
				RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
			end
			--- </Update>
				
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

		done:
		---	<CloseTran AutoCommit=Yes>
		if	@TranCount = 0 begin
			commit tran @ProcName
		end
		---	</CloseTran AutoCommit=Yes>

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

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = EDI.usp_ProcessIConnectAcknowledgements
	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Debug = 1

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
