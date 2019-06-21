
/*
Create Table.FxEDI.EDI.EDIDocuments.sql
*/

use FxEDI
go

/*
exec FT.sp_DropForeignKeys

drop table EDI.EDIDocuments

exec FT.sp_AddForeignKeys
*/
if	objectproperty(object_id('EDI.EDIDocuments'), 'IsTable') is null begin

	create table EDI.EDIDocuments
	(	GUID uniqueidentifier not null
	,	Status int not null default (0)
	,	FileName sysname not null
	,	HeaderData xml null
	,	Data xml null
	,	TradingPartner varchar(50) null
	,	Type varchar(6) null
	,	Version varchar(20) null
	,	EDIStandard varchar(50) null
	,	Release varchar(50) null
	,	DocNumber varchar(50) null
	,	ControlNumber varchar(10) null
	,	DeliverySchedule varchar(8) null
	,	MessageNumber varchar(8) null
	,	RowID int identity(1, 1) primary key clustered
	,	RowTS timestamp not null
	,	RowCreateDT datetime default (getdate())
	,	RowCreateUser sysname default (suser_name())
	,	RowModifiedDT datetime default (getdate())
	,	RowModifiedUser sysname default (suser_name())
	,	unique nonclustered
		(	GUID
		)
	)

	--alter table EDI.EDIDocuments drop column SourceType
	--alter table EDI.EDIDocuments drop column MoparSSDDocument
	--alter table EDI.EDIDocuments drop column VersionEDIFACTorX12

	create nonclustered index ixRawEDIDocuments_1 on EDI.EDIDocuments
	(	Status
	,	EDIStandard
	,	Type
	)

	create primary xml index PXML_EDIData on EDI.EDIDocuments
	(	Data
	)
end
go

/*
Create trigger EDI.tr_EDIDocuments_uRowModified on EDI.EDIDocuments
*/

--use FxEDI
--go

if	objectproperty(object_id('EDI.tr_EDIDocuments_uRowModified'), 'IsTrigger') = 1 begin
	drop trigger EDI.tr_EDIDocuments_uRowModified
end
go

create trigger EDI.tr_EDIDocuments_uRowModified on EDI.EDIDocuments after update
as
declare
	@TranDT datetime
,	@Result int

set xact_abort off
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. EDI.usp_Test
--- </Error Handling>

begin try
	--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount
	set	@TranDT = coalesce(@TranDT, GetDate())
	save tran @ProcName
	--- </Tran>

	---	<ArgumentValidation>

	---	</ArgumentValidation>
	
	--- <Body>
	if	not update(RowModifiedDT) begin
		--- <Update rows="*">
		set	@TableName = 'EDI.EDIDocuments'
		
		update
			GUID
		set	RowModifiedDT = getdate()
		,	RowModifiedUser = suser_name()
		from
			EDI.EDIDocuments GUID
			join inserted i
				on i.RowID = GUID.RowID
		
		select
			@Error = @@Error,
			@RowCount = @@Rowcount
		
		if	@Error != 0 begin
			set	@Result = 999999
			RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			rollback tran @ProcName
			return
		end
		--- </Update>
		
		--- </Body>
	end
end try
begin catch
	declare
		@errorName int
	,	@errorSeverity int
	,	@errorState int
	,	@errorLine int
	,	@errorProcedures sysname
	,	@errorMessage nvarchar(2048)
	,	@xact_state int
	
	select
		@errorName = error_number()
	,	@errorSeverity = error_severity()
	,	@errorState = error_state ()
	,	@errorLine = error_line()
	,	@errorProcedures = error_procedure()
	,	@errorMessage = error_message()
	,	@xact_state = xact_state()

	if	xact_state() = -1 begin
		print 'Error number: ' + convert(varchar, @errorName)
		print 'Error severity: ' + convert(varchar, @errorSeverity)
		print 'Error state: ' + convert(varchar, @errorState)
		print 'Error line: ' + convert(varchar, @errorLine)
		print 'Error procedure: ' + @errorProcedures
		print 'Error message: ' + @errorMessage
		print 'xact_state: ' + convert(varchar, @xact_state)
		
		rollback transaction
	end
	else begin
		/*	Capture any errors in SP Logging. */
		rollback tran @ProcName
	end
end catch

---	<Return>
set	@Result = 0
return
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

begin transaction Test
go

insert
	EDI.EDIDocuments
...

update
	...
from
	EDI.EDIDocuments
...

delete
	...
from
	EDI.EDIDocuments
...
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

