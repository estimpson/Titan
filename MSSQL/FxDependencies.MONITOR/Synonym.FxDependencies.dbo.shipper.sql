
/*
Create Synonym.FxDependencies.dbo.shipper.sql
*/

use FxDependencies
go

--	select objectpropertyex(object_id('dbo.shipper'), 'BaseType')
if	objectpropertyex(object_id('dbo.shipper'), 'BaseType') = 'T' begin
	drop synonym dbo.shipper
end
go

create synonym dbo.shipper for MONITOR.dbo.shipper
go

