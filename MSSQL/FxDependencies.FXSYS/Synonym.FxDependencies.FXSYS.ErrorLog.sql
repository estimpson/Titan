
/*
Create Synonym.FxDependencies.FXSYS.ErrorLog.sql
*/

use FxDependencies
go

--	drop table FXSYS.ErrorLog
--	select objectpropertyex(object_id('FXSYS.ErrorLog'), 'BaseType')
if	objectpropertyex(object_id('FXSYS.ErrorLog'), 'BaseType') = 'U' begin
	drop synonym FXSYS.ErrorLog
end
go

create synonym FXSYS.ErrorLog for FxSYS.dbo.ErrorLog
go

