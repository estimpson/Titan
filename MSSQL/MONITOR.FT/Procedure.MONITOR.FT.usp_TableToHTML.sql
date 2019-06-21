
/*
Create Synonym.MONITOR.FT.usp_TableToHTML.sql
*/

use MONITOR
go

--	drop procedure FT.usp_TableToHTML
--	select objectpropertyex(object_id('FT.usp_TableToHTML'), 'BaseType')
if	objectpropertyex(object_id('FT.usp_TableToHTML'), 'BaseType') = 'P' begin
	drop synonym FT.usp_TableToHTML
end
go

create synonym FT.usp_TableToHTML for FxSYS.dbo.usp_TableToHTML
go

