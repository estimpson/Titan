
/*
Create Schema.FxDependencies.EDI.sql
*/

use FxDependencies
go

-- Create the database schema
if	schema_id('EDI') is null begin
	exec sys.sp_executesql N'create schema EDI authorization dbo'
end
go

