
/*
Create Procedure.FxDependencies.dbo.usp_CustomerEDI_SendShipNotices.sql
*/

use FxDependencies
go

if	objectproperty(object_id('dbo.usp_CustomerEDI_SendShipNotices'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_CustomerEDI_SendShipNotices
end
go

create procedure dbo.usp_CustomerEDI_SendShipNotices
	@ShipperList varchar(max) = null
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
		MONITOR.FXSYS.USP_Calls
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
						[@ShipperList] = @ShipperList
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

	set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
	--- </Error Handling>

	/*	Record initial transaction count. */
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount

	begin try

		---	<ArgumentValidation>

		---	</ArgumentValidation>

		--- <Body>
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
		/*	Get the list of Ship Notices to send. */
		set @TocMsg = 'Get the list of Ship Notices to send'
		begin
			declare	@PendingShipNotices table
			(	ShipperID int
			,	FunctionName sysname
			)

			if	@ShipperList > '' begin
				insert
					@PendingShipNotices
				select
					s.id
				,	xsnadrf.FunctionName
				from
					dbo.shipper s
					join dbo.edi_setups es
						on es.destination = s.destination
					join EDI.XMLShipNotice_ASNDataRootFunction xsnadrf
						on xsnadrf.ASNOverlayGroup = es.asn_overlay_group
				where
					s.id in
						(	select
								convert(int, ltrim(rtrim(fsstr.Value)))
							from
								dbo.fn_SplitStringToRows(@ShipperList, ',') fsstr
							where
								ltrim(rtrim(fsstr.Value)) like '%[0-9]%'
								and ltrim(rtrim(fsstr.Value)) not like '%[^0-9]%'
						)
			end
			else begin
				insert
					@PendingShipNotices
				select
					s.id
				,	xsnadrf.FunctionName
				from
					dbo.shipper s
					join dbo.edi_setups es
						on es.destination = s.destination
					join EDI.XMLShipNotice_ASNDataRootFunction xsnadrf
						on xsnadrf.ASNOverlayGroup = es.asn_overlay_group
				where
					coalesce(s.type, 'N') = 'N'
					and s.status = 'C'
					and s.date_shipped > getdate() - 8
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

		/*	Loop through pending ship notices to generate XML data and files. */
		set @TocMsg = 'Loop through pending ship notices'
		begin
			declare
				PendingShipNotices cursor local for
			select
				*
			from
				@PendingShipNotices psn

			open
				PendingShipNotices

			while
				1 = 1 begin

				declare
					@ShipperID int
				,	@XMLShipNotice_FunctionName sysname
				,	@XMLShipNotice xml

				fetch
					PendingShipNotices
				into
					@ShipperID
				,	@XMLShipNotice_FunctionName

				if	@@FETCH_STATUS != 0 begin
					break
				end

				select
					ShipperID = @ShipperID
				,	XMLShipNotice_FunctionName = @XMLShipNotice_FunctionName

				--- <Call>	
				set	@CallProcName = 'EDI.usp_XMLShipNotice_GetShipNoticeXML'
				execute
					@ProcReturn = EDI.usp_XMLShipNotice_GetShipNoticeXML
					@ShipperID = @ShipperID
				,	@XMLShipNotice_FunctionName = @XMLShipNotice_FunctionName
				,	@PurposeCode = '00'
				,	@Complete = 1
				,	@XMLOutput = @XMLShipNotice out
				,	@TranDT = @TranDT out
				,	@Result = @ProcResult out
	
				set @Error = @@Error
				if @Error != 0 begin
					set @Result = 900501
					raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
				end
				if @ProcReturn != 0 begin
					set @Result = 900502
					raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
				end
				if @ProcResult != 0 begin
					set @Result = 900502
					raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
				end
				--- </Call>

				/*	Generate file for each Ship Notice.*/
				--- <Call>	
				set @CallProcName = 'EDI.usp_CreateCustomerOutboundFile'
				execute
					@ProcReturn = EDI.usp_CreateCustomerOutboundFile
					@XMLData = @XMLShipNotice
				,	@ShipperID = @ShipperID
				,	@TranDT = @TranDT out
				,	@Result = @ProcResult out
	
				set @Error = @@Error
				if @Error != 0 begin
					set @Result = 900501
					raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
				end
				if @ProcReturn != 0 begin
					set @Result = 900502
					raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
				end
				if @ProcResult != 0 begin
					set @Result = 900502
					raiserror ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
				end
				--- </Call>
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

		/*	Send customer EDI. */
		set @TocMsg = 'Send customer EDI'
		begin
			---	<CloseTran AutoCommit=Yes>
			commit tran @ProcName
			---	</CloseTran AutoCommit=Yes>

			--- <Call>	
			set @CallProcName = 'FxEDI.FTP.usp_SendCustomerEDI'
			execute
				@ProcReturn = FxEDI.FTP.usp_SendCustomerEDI
				@SendFileFromFolderRoot = '\RawEDIData\CustomerEDI\OutBound'
			,	@SendFileNamePattern = '%[0-9][0-9][0-9][0-9][0-9].xml'
			,	@TranDT = @TranDT out
			,	@Result = @ProcResult out
			,	@Debug = @cDebug
			,	@DebugMsg = @cDebugMsg out

			set @Error = @@Error
			if	@Error != 0 begin
				set @Result = 900501
				raiserror ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
			end
			if	@ProcReturn != 0 begin
				set @Result = 900502
				raiserror ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
			end
			if	@ProcResult != 0 begin
				set @Result = 900502
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

		/*	Start a transaction from here... */
		--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
		set @TranCount = @@TranCount
		if @TranCount = 0 begin
			begin tran @ProcName
		end
		else begin
			save tran @ProcName
		end
		set @TranDT = coalesce(@TranDT, getdate())
		--- </Tran>

		/*	Mark shippers as EDI Sent. */
		set @TocMsg = 'Mark shippers as EDI Sent'
		begin
			--- <Update rows="*">
			set @TableName = 'dbo.shipper'

			update
				s
			set	
				s.status = 'Z'
			from
				dbo.shipper s
				join @PendingShipNotices psn
					on psn.ShipperID = s.id

			select
				@Error = @@Error
			,	@RowCount = @@Rowcount

			if	@Error != 0 begin
				set @Result = 999999
				raiserror ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
				rollback tran @ProcName
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
			MONITOR.FXSYS.USP_Calls uc
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
	@FinishedPart varchar(25) = 'ALC0598-HC02'
,	@ParentHeirarchID hierarchyid

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_CustomerEDI_SendShipNotices
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

