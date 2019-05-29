
/*
Create Procedure.MONITOR.ARS.usp_SteelReleasas_ProcessImport.sql
*/

use MONITOR
go

if	objectproperty(object_id('ARS.usp_SteelReleasas_ProcessImport'), 'IsProcedure') = 1 begin
	drop procedure ARS.usp_SteelReleasas_ProcessImport
end
go

create procedure ARS.usp_SteelReleasas_ProcessImport
	@User varchar(5)
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
						[@User] = @User
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

	set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. ARS.usp_Test
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
		/*	Import releases from ARS.SteelReleases_PO_Import. */
		set @TocMsg = 'Import releases from ARS.SteelReleases_PO_Import'
		begin
			/* statements */
			declare
				@RawReleases table
			(	RawPart varchar(25)
			,	PODate datetime
			,	Quantity numeric(20,6)
			,	PONumber int
			,	RowID int
			)
			
			insert
				@RawReleases
			(	RawPart
			,	PODate
			,	Quantity
			,	PONumber
			,	RowID
			)
			select
				srpi.RawPart
			,	srpi.PoDate
			,	srpi.Quantity
			,	ss.PONumber
			,	srpi.RowID
			from
				ARS.SteelReleases_PO_Import srpi
				join ARS.StampingSetup ss
					on ss.RawPart = srpi.RawPart
			where
				srpi.Status = 0

			delete
				pd
			from
				dbo.po_detail pd
			where
				exists
					(	select
							*
						from
							@RawReleases rr
						where
							rr.PONumber = pd.po_number
							and rr.RawPart = pd.part_number
					)

			insert
				dbo.po_detail
			(	po_number
			,	vendor_code
			,	part_number
			,	description
			,	unit_of_measure
			,	date_due
			,	status
			,	notes
			,	quantity
			,	received
			,	balance
			,	price
			,	row_id
			,	RELEASE_NO
			,	terms
			,	week_no
			,	plant
			,	standard_qty
			,	ship_type
			,	printed
			,	selected_for_print
			,	ship_via
			,	alternate_price
			)
			select
				po_number = rr.PONumber
			,	vendor_code = ph.vendor_code
			,	part_number = rr.RawPart
			,	description = p.name
			,	unit_of_measure = coalesce(ph.std_unit, pv.receiving_um, pInv.standard_unit)
			,	date_due = rr.PODate
			,	status = 'A'
			,	notes = null
			,	quantity = rr.Quantity
			,	received = 0
			,	balance = rr.Quantity
			,	price = coalesce(ph.price, pvpm.price)
			,	row_id = ph.next_seqno + row_number() over (partition by ph.po_number order by rr.PODate) - 1
			,	RELEASE_NO = ph.release_no + 1
			,	terms = ph.terms
			,	week_no = parm.WeekNo
			,	plant = ph.plant
			,	standard_qty = rr.Quantity
			,	ship_type = left(ph.ship_type, 1)
			,	printed = 'N'
			,	selected_for_print = 'N'
			,	ship_via = ph.ship_via
			,	alternate_price = coalesce(ph.price, pvpm.alternate_price)
			from
				@RawReleases rr
				join dbo.po_header ph
					on ph.po_number = rr.PONumber
				left join dbo.part_vendor pv
					on pv.part = rr.RawPart
					and pv.vendor = ph.vendor_code
				join dbo.part p
					on p.part = rr.RawPart
				join dbo.part_inventory pInv
					on pInv.part = rr.RawPart
				cross apply
					(	select top(1)
							*
						from
							dbo.part_vendor_price_matrix pvpm
						where
							pvpm.part = rr.RawPart
							and pvpm.vendor = ph.vendor_code
							and rr.Quantity >= pvpm.break_qty
						order by
							pvpm.break_qty desc
					) pvpm
				cross apply
					(	select
							WeekNo = datediff(week, parm.fiscal_year_begin, @TranDT)
						from
							dbo.parameters parm
					) parm

			update
				ph
			set	ph.release_no = ph.release_no + 1
			,	ph.next_seqno = ph.next_seqno +
					(	select
							count(*)
						from
							@RawReleases rr
						where
							rr.PONumber = ph.po_number
					)
			from
				dbo.po_header ph
			where
				exists
					(	select
							*
						from
							@RawReleases rr
						where
							rr.PONumber = ph.po_number
					)

			update
				srpi
			set
				srpi.ImportDT = @TranDT
			,	srpi.Status = 1
			from
				ARS.SteelReleases_PO_Import srpi
				join @RawReleases rr
					on rr.RowID = srpi.RowID

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
	@FinishedPart varchar(25) = 'ALC0598-HC02'
,	@ParentHeirarchID hierarchyid

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = ARS.usp_SteelReleasas_ProcessImport
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

