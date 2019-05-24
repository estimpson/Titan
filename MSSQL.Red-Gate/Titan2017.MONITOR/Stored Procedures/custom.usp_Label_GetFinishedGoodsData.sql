SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [custom].[usp_Label_GetFinishedGoodsData]
	@Serial int
as
declare
	@TranDT datetime
,	@Result integer

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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. custom.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
else begin
	save tran @ProcName
end
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
insert
	dbo.Label_ObjectPrintHistory
(	Serial
,	LabelDataChecksum
--,	LabelDataXML
)
select
	Serial = lfgd.Serial
,	LabelDataChecksum = lfgd.LabelDataCheckSum
/*,	LabelDataXML =
		(	select
		 		*
		 	from
		 		custom.Label_FinishedGoodsData
			where
				Serial = @Serial
			for xml auto
		) */
from
	custom.Label_FinishedGoodsData lfgd
where
	lfgd.Serial = @Serial
--- </Body>

---	<CloseTran AutoCommit=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
---	</CloseTran AutoCommit=Yes>

---	<Return>
select
	*
from
	custom.Label_FinishedGoodsData lfgd
where
	lfgd.Serial = @Serial

set	@Result = 0
return
	@Result
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

declare
	@Serial int
	
set	@Serial = 1291107

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = custom.usp_Label_GetFinishedGoodsData
	@Serial = @Serial
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

select
	*
from
	dbo.Label_ObjectPrintHistory loph
where
	loph.Serial = @Serial
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
