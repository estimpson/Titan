
/*
Create View.Monitor.FT.vwBOM.sql
*/

use Monitor
go


--drop table FT.vwBOM
if objectproperty(object_id('FT.vwBOM'), 'IsView') = 1 begin
	drop view FT.vwBOM
end
go


create view FT.vwBOM
(	BOMID
,	ParentPart
,	ChildPart
,	StdQty
,	ScrapFactor
,	SubstitutePart
)
as
	--	Description:
	--	Use bill_of_material view because it only pulls current records.
	select
		BOMID = row_number() over (order by parent_part, part) -- id
	,	ParentPart = parent_part
	,	ChildPart = part
	,	StdQty = std_qty
	,	ScrapFactor = 0 --scrap_factor
	,	SubstitutePart = convert(bit, case when coalesce(substitute_part, 'N') = 'Y' then 1 else 0 end)
	from
		dbo.bill_of_material
	where
		isnull(std_qty, 0) > 0
go

select
	*
from
	FT.vwBOM vb
