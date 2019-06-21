
/*
Create Synonym.FxDependencies.dbo.shipper_detail.sql
*/

use FxDependencies
go

--	select objectpropertyex(object_id('dbo.shipper_detail'), 'BaseType')
if	objectpropertyex(object_id('dbo.shipper_detail'), 'BaseType') = 'T' begin
	drop synonym dbo.shipper_detail
end
go

create synonym dbo.shipper_detail for MONITOR.dbo.shipper_detail
go

