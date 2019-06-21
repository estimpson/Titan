
/*
Create Synonym.FxDependencies.dbo.customer.sql
*/

use FxDependencies
go

--	select objectpropertyex(object_id('dbo.customer'), 'BaseType')
if	objectpropertyex(object_id('dbo.customer'), 'BaseType') = 'U' begin
	drop synonym dbo.customer
end
go

create synonym dbo.customer for MONITOR.dbo.customer
go

