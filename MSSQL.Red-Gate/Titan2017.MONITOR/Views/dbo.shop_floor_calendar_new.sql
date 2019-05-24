SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view 
[dbo].[shop_floor_calendar_new] as 
select shop_floor_calendar.machine,
	convert(datetime,begin_datetime) as work_date,
	convert(datetime,begin_datetime) as begin_time,
	convert(numeric(8),datediff(mm,begin_datetime,end_datetime)/60 ) as up_hours,
	convert(numeric(8),0) as down_hours,
	convert(datetime,end_datetime)  as end_time,
	convert(datetime,end_datetime)  as end_date,shop_floor_calendar.crew_size,shop_floor_calendar.labor_code from shop_floor_calendar
GO
