
/*
Create Schema.Monitor.FT.sql
*/

use Monitor
go

-- Create the database schema
if	schema_id('FT') is null begin
	exec sys.sp_executesql N'create schema FT authorization dbo'
end
go

