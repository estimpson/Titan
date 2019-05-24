
/*
Create View.Monitor.FT.vwPRt.sql
*/

use Monitor
go


--drop table FT.vwPRt
if objectproperty(object_id('FT.vwPRt'), 'IsView') = 1 begin
	drop view FT.vwPRt
end
go


create view FT.vwPRt
(	Part
,	BufferTime
,	RunRate
,	CrewSize
)
as
	--	Description:
	--	Use part_mfg view because it only pulls primary machine.
	select
		Part = Part.part
	,	BufferTime = 1
	,	RunRate = coalesce(min(1 / nullif(part_machine.parts_per_hour, 0)), 9999)
	,	CrewSize = coalesce(min(part_machine.crew_size), 0)
	from
		dbo.part Part
		left outer join dbo.part_machine part_machine
			on Part.part = part_machine.part
			   and part_machine.sequence = 1
	group by
		Part.part
	having
		count(1) = 1
go

select
	*
from
	FT.vwPRt vpr
go

