
/*
Create Synonym.MONITOR.dbo.udf_Date.sql
*/

use MONITOR
go

--	select objectpropertyex(object_id('dbo.udf_Date'), 'BaseType')
if	objectpropertyex(object_id('dbo.udf_Date'), 'BaseType') = 'FN' begin
	drop synonym dbo.udf_Date
end
go

create synonym dbo.udf_Date for FxDependencies.dbo.udf_Date
go

