CREATE TABLE [FT].[XRt]
(
[TopPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BOMID] [int] NULL,
[Sequence] [smallint] NULL,
[BOMLevel] [smallint] NOT NULL CONSTRAINT [DF__XRt__BOMLevel__54E16EFF] DEFAULT ((0)),
[XQty] [float] NOT NULL CONSTRAINT [DF__XRt__XQty__55D59338] DEFAULT ((1)),
[XScrap] [float] NOT NULL CONSTRAINT [DF__XRt__XScrap__56C9B771] DEFAULT ((1)),
[XBufferTime] [float] NOT NULL CONSTRAINT [DF__XRt__XBufferTime__57BDDBAA] DEFAULT ((0)),
[XRunRate] [float] NOT NULL CONSTRAINT [DF__XRt__XRunRate__58B1FFE3] DEFAULT ((0)),
[Hierarchy] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Infinite] [bit] NOT NULL CONSTRAINT [DF__XRt__Infinite__59A6241C] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__XRt__RowCreateDT__5A9A4855] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__XRt__RowCreateUs__5B8E6C8E] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__XRt__RowModified__5C8290C7] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__XRt__RowModified__5D76B500] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [FT].[tr_XRt_uRowModified] on [FT].[XRt] after update
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

set	@ProcName = schema_name(objectproperty(@@procid, 'SchemaID')) + '.' + object_name(@@procid)  -- e.g. FT.usp_Test
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
GO
ALTER TABLE [FT].[XRt] ADD CONSTRAINT [PK__XRt__FFEE7451F6BE5924] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRT_1] ON [FT].[XRt] ([BOMLevel], [ChildPart], [RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRT_2] ON [FT].[XRt] ([ChildPart], [BOMLevel], [RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRT_3] ON [FT].[XRt] ([ChildPart], [TopPart], [RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRT_4] ON [FT].[XRt] ([TopPart], [ChildPart], [Sequence], [RowID]) INCLUDE ([XBufferTime], [XQty], [XRunRate], [XScrap]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRT_5] ON [FT].[XRt] ([TopPart], [Hierarchy], [RowID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[XRt] ADD CONSTRAINT [UQ__XRt__1FDC25FCC1551D8D] UNIQUE NONCLUSTERED  ([TopPart], [Sequence]) ON [PRIMARY]
GO
