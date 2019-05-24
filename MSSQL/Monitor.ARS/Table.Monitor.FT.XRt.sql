
/*
Create Table.Monitor.FT.XRt.sql
*/

use Monitor
go

/*
exec FT.sp_DropForeignKeys

drop table FT.XRt

exec FT.sp_AddForeignKeys
*/
if	objectproperty(object_id('FT.XRt'), 'IsTable') is null begin

	create table FT.XRt
	(	TopPart varchar(25) not null
	,	ChildPart varchar(25) not null
	,	BOMID int null
	,	Sequence smallint null
	,	BOMLevel smallint not null default(0)
	,	XQty float not null default(1)
	,	XScrap float not null default(1)
	,	XBufferTime float not null default(0)
	,	XRunRate float not null default(0)
	,	Hierarchy varchar(500) not null
	,	Infinite bit not null default(0)
	,	RowID int identity(1,1) primary key clustered
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	unique
		(	TopPart
		,	Sequence
		)
	)

	create index XRT_1 on FT.XRt (BOMLevel, ChildPart, RowID)
	create index XRT_2 on FT.XRt (ChildPart, BOMLevel, RowID)
	create index XRT_3 on FT.XRt (ChildPart, TopPart, RowID)
	create index XRT_4 on FT.XRt (TopPart, ChildPart, Sequence, RowID) include(XQty, XScrap, XBufferTime, XRunRate)
	create index XRT_5 on FT.XRt (TopPart, Hierarchy, RowID)
end
go

/*
Create trigger FT.tr_XRt_uRowModified on FT.XRt
*/

--use Monitor
--go

if	objectproperty(object_id('FT.tr_XRt_uRowModified'), 'IsTrigger') = 1 begin
	drop trigger FT.tr_XRt_uRowModified
end
go

create trigger FT.tr_XRt_uRowModified on FT.XRt after update
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. FT.usp_Test
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
		set	@TableName = 'FT.XRt'
		
		update
			xr
		set	RowModifiedDT = getdate()
		,	RowModifiedUser = suser_name()
		from
			FT.XRt xr
			join inserted i
				on i.RowID = xr.RowID
		
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
	FT.XRt
...

update
	...
from
	FT.XRt
...

delete
	...
from
	FT.XRt
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

