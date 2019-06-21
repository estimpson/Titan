
/*
Create Synonym.MONITOR.custom.Sales.sql
*/

use MONITOR
go

--	select objectpropertyex(object_id('custom.Sales'), 'BaseType')
if	objectpropertyex(object_id('custom.Sales'), 'BaseType') = 'V' begin
	drop synonym custom.Sales
end
go

create synonym custom.Sales for FxDependencies.dbo.Sales
go

select
	*
from
	custom.Sales