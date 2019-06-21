
/*
Create Synonym.FxEDI.FX.CustomerEDI_GenerationLog.sql
*/

use FxEDI
go

--	select objectpropertyex(object_id('FX.CustomerEDI_GenerationLog'), 'BaseType')
if	objectpropertyex(object_id('FX.CustomerEDI_GenerationLog'), 'BaseType') = 'T' begin
	drop synonym FX.CustomerEDI_GenerationLog
end
go

create synonym FX.CustomerEDI_GenerationLog for FxDependencies.dbo.CustomerEDI_GenerationLog
go

