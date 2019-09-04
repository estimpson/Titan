CREATE TABLE [EDI].[EDIDocuments]
(
[GUID] [uniqueidentifier] NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__EDIDocume__Statu__65370702] DEFAULT ((0)),
[FileName] [sys].[sysname] NOT NULL,
[HeaderData] [xml] NULL,
[Data] [xml] NULL,
[TradingPartner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDIStandard] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Release] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ControlNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliverySchedule] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageNumber] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowTS] [timestamp] NOT NULL,
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__EDIDocume__RowCr__662B2B3B] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__EDIDocume__RowCr__671F4F74] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__EDIDocume__RowMo__681373AD] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__EDIDocume__RowMo__690797E6] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [EDI].[tr_EDIDocuments_uRowModified] on [EDI].[EDIDocuments] after update
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

set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. EDI.usp_Test
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
GO
ALTER TABLE [EDI].[EDIDocuments] ADD CONSTRAINT [PK__EDIDocum__FFEE74515088FBC2] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [EDI].[EDIDocuments] ADD CONSTRAINT [UQ__EDIDocum__15B69B8FC824BB6B] UNIQUE NONCLUSTERED  ([GUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixRawEDIDocuments_1] ON [EDI].[EDIDocuments] ([Status], [EDIStandard], [Type]) ON [PRIMARY]
GO
CREATE PRIMARY XML INDEX [PXML_EDIData]
ON [EDI].[EDIDocuments] ([Data])
GO
