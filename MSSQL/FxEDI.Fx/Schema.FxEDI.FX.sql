
/*
Create Schema.FxEDI.FX.sql
*/

use FxEDI
go

-- Create the database schema
if	schema_id('FX') is null begin
	exec sys.sp_executesql N'create schema Fx authorization dbo'
end
go

