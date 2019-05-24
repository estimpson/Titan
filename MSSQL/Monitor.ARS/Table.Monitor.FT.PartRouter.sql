
/*
Create Table.Monitor.FT.PartRouter.sql
*/

use Monitor
go

/*
exec FT.sp_DropForeignKeys

drop table FT.PartRouter

exec FT.sp_AddForeignKeys
*/
if	objectproperty(object_id('FT.PartRouter'), 'IsTable') is null begin

	create table FT.PartRouter
	(	Part varchar(25) not null primary key
	,	BufferTime numeric(20,6) not null
	,	RunRate numeric(20,6) null
	,	CrewSize numeric(20,6) null
	)

	create index PartRouter_1 on FT.PartRouter (Part) include (BufferTime, RunRate)
end
go

