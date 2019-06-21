
/*
Create Schema.FxDependencies.FXSYS.sql
*/

use FxDependencies
go

-- Create the database schema
if	schema_id('FXSYS') is null begin
	exec sys.sp_executesql N'create schema FXSYS authorization dbo'
end
go

