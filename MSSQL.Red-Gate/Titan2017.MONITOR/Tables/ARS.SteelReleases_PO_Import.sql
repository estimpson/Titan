CREATE TABLE [ARS].[SteelReleases_PO_Import]
(
[Status] [int] NOT NULL CONSTRAINT [DF__SteelRele__Statu__56FEC19B] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__SteelRelea__Type__57F2E5D4] DEFAULT ((0)),
[RawPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODate] [datetime] NOT NULL,
[Quantity] [numeric] (20, 6) NOT NULL,
[Note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDT] [datetime] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__SteelRele__RowCr__58E70A0D] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__SteelRele__RowCr__59DB2E46] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__SteelRele__RowMo__5ACF527F] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__SteelRele__RowMo__5BC376B8] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [ARS].[tr_SteelReleases_PO_Import_uRowModified] on [ARS].[SteelReleases_PO_Import] after update
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

set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. ARS.usp_Test
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
		set	@TableName = 'ARS.SteelReleases_PO_Import'
		
		update
			srpi
		set	RowModifiedDT = getdate()
		,	RowModifiedUser = suser_name()
		from
			ARS.SteelReleases_PO_Import srpi
			join inserted i
				on i.RowID = srpi.RowID
		
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
	ARS.SteelReleases_PO_Import
...

update
	...
from
	ARS.SteelReleases_PO_Import
...

delete
	...
from
	ARS.SteelReleases_PO_Import
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
GO
ALTER TABLE [ARS].[SteelReleases_PO_Import] ADD CONSTRAINT [PK__SteelRel__FFEE74514ED6C290] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
