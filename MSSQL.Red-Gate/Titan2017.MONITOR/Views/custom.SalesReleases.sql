SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [custom].[SalesReleases]
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
	od.due_date > m.ThisMonday - 7 * 12
	and od.due_date <= m.ThisMonday + 7 * 21
group by
	oh.customer
,	od.destination
,	od.customer_part
,	od.part_number
,	od.order_no
,	datediff(week, m.ThisMonday, od.due_date)
GO
