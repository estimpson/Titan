
/*
Create Synonym.FxDependencies.dbo.edi_setups.sql
*/

use FxDependencies
go

--	select objectpropertyex(object_id('dbo.edi_setups'), 'BaseType')
if	objectpropertyex(object_id('dbo.edi_setups'), 'BaseType') = 'T' begin
	drop synonym dbo.edi_setups
end
go

create synonym dbo.edi_setups for MONITOR.dbo.edi_setups
go

