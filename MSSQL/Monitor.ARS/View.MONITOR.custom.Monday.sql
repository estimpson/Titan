
/*
Create View.MONITOR.custom.Monday.sql
*/

use MONITOR
go

--drop table custom.Monday
if	objectproperty(object_id('custom.Monday'), 'IsView') = 1 begin
	drop view custom.Monday
end
go

create view custom.Monday
as
select
	ThisMonday = dateadd(week, datediff(week, '2001-01-01', getdate()), '2001-01-01')
go

