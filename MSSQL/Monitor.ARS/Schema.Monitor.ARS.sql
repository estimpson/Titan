
/*
Create Schema.Monitor.ARS.sql
*/

use Monitor
go

-- Create the database schema
if	schema_id('ARS') is null begin
	exec sys.sp_executesql N'create schema ARS authorization dbo'
end
go

