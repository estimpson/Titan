
/*
Create Synonym.FxDependencies.FXSYS.usp_EmailError.sql
*/

use FxDependencies
go

--	drop procedure FXSYS.usp_EmailError
--	select objectpropertyex(object_id('FXSYS.usp_EmailError'), 'BaseType')
if	objectpropertyex(object_id('FXSYS.usp_EmailError'), 'BaseType') = 'P' begin
	drop synonym FXSYS.usp_EmailError
end
go

create synonym FXSYS.usp_EmailError for FxSYS.dbo.usp_EmailError
go

