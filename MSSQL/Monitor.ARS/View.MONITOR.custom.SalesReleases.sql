
/*
Create View.MONITOR.custom.SalesReleases.sql
*/

use MONITOR
go

--drop table custom.SalesReleases
if	objectproperty(object_id('custom.SalesReleases'), 'IsView') = 1 begin
	drop view custom.SalesReleases
end
go

create view custom.SalesReleases
as

select
	Customer = oh.customer
,	Destination = od.destination
,	CustomerPart = od.customer_part
,	TitanPart = od.part_number
,	OrderNo = od.order_no
,	DueDT = dateadd(week, datediff(week, max(m.ThisMonday), max(od.due_date)), max(m.ThisMonday))
,	Required = sum(od.quantity)
,	Type = case max(od.type) when 'F' then 'Firm' when 'P' then 'Planned' when 'O' then 'Forecast' end
from
	dbo.order_detail od
	join dbo.order_header oh
		on oh.order_no = od.order_no
	cross join custom.Monday m
where
	od.due_date > m.ThisMonday
	and od.due_date <= m.ThisMonday + 7 * 21
group by
	oh.customer
,	od.destination
,	od.customer_part
,	od.part_number
,	od.order_no
,	datediff(week, m.ThisMonday, od.due_date)
go

select
	*
from
	custom.SalesReleases sr
order by
	1, 2, 4, 6