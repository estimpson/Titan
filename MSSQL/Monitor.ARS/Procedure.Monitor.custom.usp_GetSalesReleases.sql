
/*
Create Procedure.Monitor.custom.usp_GetSalesReleases.sql
*/

use Monitor
go

if	objectproperty(object_id('custom.usp_GetSalesReleases'), 'IsProcedure') = 1 begin
	drop procedure custom.usp_GetSalesReleases
end
go

create procedure custom.usp_GetSalesReleases
as
set nocount on
set ansi_warnings off

declare
	@StartDate datetime

set
	@StartDate = dateadd(week, datediff(week, '2001-01-01', getdate()), '2001-01-01')

select
	Customer = oh.customer
,	Destination = od.destination
,	CustomerPart = od.customer_part
,	TitanPart = od.part_number
,	OrderNo = od.order_no
,	DueDT = dateadd(week, datediff(week, @StartDate, max(od.due_date)), @StartDate)
,	Required = sum(od.quantity)
,	Type = case max(od.type) when 'F' then 'Firm' when 'P' then 'Planned' when 'O' then 'Forecast' end
from
	dbo.order_detail od
	join dbo.order_header oh
		on oh.order_no = od.order_no
where
	od.due_date > @StartDate
	and od.due_date <= @StartDate + 7 * 21
group by
	oh.customer
,	od.destination
,	od.customer_part
,	od.part_number
,	od.order_no
,	datediff(week, @StartDate, od.due_date)
order by
	1
,	2
,	4
,	6

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
,	@Error integer

execute
	@ProcReturn = custom.usp_GetSalesReleases

set	@Error = @@error

select
	@Error, @ProcReturn
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

