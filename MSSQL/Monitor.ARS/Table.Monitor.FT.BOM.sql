
/*
Create Table.Monitor.FT.BOM.sql
*/

use Monitor
go

/*
exec FT.sp_DropForeignKeys

drop table FT.BOM

exec FT.sp_AddForeignKeys
*/
if	objectproperty(object_id('FT.BOM'), 'IsTable') is null begin

	create table FT.BOM
	(	BOMID int not null primary key
	,	ParentPart varchar(25) not null
	,	ChildPart varchar(25) not null
	,	StdQty numeric(20,6) not null
	,	ScrapFactor numeric(20,6) not null
	,	Substitute bit not null
	)

	create index BOM on FT.BOM (ParentPart, ChildPart) include(StdQty, ScrapFactor, Substitute, BOMID)

	create index BOM_1 on FT.BOM (ChildPart, ParentPart) include(StdQty, ScrapFactor, Substitute, BOMID)
end
go

