use Monitor
go

create view FT.REFERENTIAL_CONSTRAINTS_COLUMN_USAGE
as
select
	KCU1.CONSTRAINT_CATALOG as 'CONSTRAINT_CATALOG'
,	KCU1.CONSTRAINT_SCHEMA as 'CONSTRAINT_SCHEMA'
,	KCU1.CONSTRAINT_NAME as 'CONSTRAINT_NAME'
,	KCU1.TABLE_CATALOG as 'TABLE_CATALOG'
,	KCU1.TABLE_SCHEMA as 'TABLE_SCHEMA'
,	KCU1.TABLE_NAME as 'TABLE_NAME'
,	KCU1.COLUMN_NAME as 'COLUMN_NAME'
,	KCU1.ORDINAL_POSITION as 'ORDINAL_POSITION'
,	KCU2.CONSTRAINT_CATALOG as 'UNIQUE_CONSTRAINT_CATALOG'
,	KCU2.CONSTRAINT_SCHEMA as 'UNIQUE_CONSTRAINT_SCHEMA'
,	KCU2.CONSTRAINT_NAME as 'UNIQUE_CONSTRAINT_NAME'
,	KCU2.TABLE_CATALOG as 'UNIQUE_TABLE_CATALOG'
,	KCU2.TABLE_SCHEMA as 'UNIQUE_TABLE_SCHEMA'
,	KCU2.TABLE_NAME as 'UNIQUE_TABLE_NAME'
,	KCU2.COLUMN_NAME as 'UNIQUE_COLUMN_NAME'
from
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
	join INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1
		on KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG
		   and KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
		   and KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
	join INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU2
		on KCU2.CONSTRAINT_CATALOG = RC.UNIQUE_CONSTRAINT_CATALOG
		   and KCU2.CONSTRAINT_SCHEMA = RC.UNIQUE_CONSTRAINT_SCHEMA
		   and KCU2.CONSTRAINT_NAME = RC.UNIQUE_CONSTRAINT_NAME
where
	KCU1.ORDINAL_POSITION = KCU2.ORDINAL_POSITION;

GO

create TABLE [FT].[REFERENTIAL_CONSTRAINT_DEFS]
(
[CONSTRAINT_CATALOG] [nvarchar] (128)  NULL,
[CONSTRAINT_SCHEMA] [nvarchar] (128)  NULL,
[CONSTRAINT_NAME] [nvarchar] (128)  NOT NULL,
[TABLE_CATALOG] [nvarchar] (128)  NULL,
[TABLE_SCHEMA] [nvarchar] (128)  NULL,
[TABLE_NAME] [nvarchar] (128)  NOT NULL,
[COLUMN_NAME] [nvarchar] (128)  NULL,
[ORDINAL_POSITION] [int] NOT NULL,
[UNIQUE_CONSTRAINT_CATALOG] [nvarchar] (128)  NULL,
[UNIQUE_CONSTRAINT_SCHEMA] [nvarchar] (128)  NULL,
[UNIQUE_CONSTRAINT_NAME] [nvarchar] (128)  NOT NULL,
[UNIQUE_TABLE_CATALOG] [nvarchar] (128)  NULL,
[UNIQUE_TABLE_SCHEMA] [nvarchar] (128)  NULL,
[UNIQUE_TABLE_NAME] [nvarchar] (128)  NOT NULL,
[UNIQUE_COLUMN_NAME] [nvarchar] (128)  NULL
) ON [PRIMARY]
GO

create procedure FT.sp_DropForeignKeys
as
if	not exists
	(	select
			*
		from
			FT.REFERENTIAL_CONSTRAINT_DEFS) begin

	insert
		FT.REFERENTIAL_CONSTRAINT_DEFS
	select
		*
	from
		FT.REFERENTIAL_CONSTRAINTS_COLUMN_USAGE
	order by
		CONSTRAINT_NAME
	,	ORDINAL_POSITION

	declare
		@ForeignKeyName sysname
	,	@TableSchema sysname
	,	@TableName sysname
	,	@DropForeignKeySyntax nvarchar(max)

	declare	ForeignKeys cursor local for
	select distinct
		CONSTRAINT_NAME
	,	TABLE_SCHEMA
	,	TABLE_NAME
	from
		FT.REFERENTIAL_CONSTRAINT_DEFS

	open
		ForeignKeys

	fetch
		ForeignKeys
	into
		@ForeignKeyName
	,	@TableSchema
	,	@TableName

	while	@@FETCH_STATUS = 0 begin
		
		set	@DropForeignKeySyntax = N'alter table [' + @TableSchema + '].[' + @TableName + '] drop constraint ' + @ForeignKeyName
		
		execute	sp_executesql @DropForeignKeySyntax
		
		fetch
			ForeignKeys
		into
			@ForeignKeyName
		,	@TableSchema
		,	@TableName
	end

	close	ForeignKeys
end

GO

create procedure FT.sp_AddForeignKeys
as
declare
	@ForeignKeyName sysname
,	@TableSchema sysname
,	@TableName sysname
,	@ColumnName sysname
,	@UniqueTableSchema sysname
,	@UniqueTableName sysname
,	@UniqueColumnName sysname
,	@CreateForeignKeySyntax nvarchar(max)
,	@UniqueColumnList nvarchar(max)

declare	ForeignKeys cursor local for
select distinct
	CONSTRAINT_NAME
,	TABLE_SCHEMA
,	TABLE_NAME
,	CONSTRAINT_SCHEMA
,	UNIQUE_TABLE_NAME
from
	FT.REFERENTIAL_CONSTRAINT_DEFS

open
	ForeignKeys

fetch
	ForeignKeys
into
	@ForeignKeyName
,	@TableSchema
,	@TableName
,	@UniqueTableSchema
,	@UniqueTableName

while	@@FETCH_STATUS = 0 begin
	
	set	@CreateForeignKeySyntax = N'alter table [' + @TableSchema + '].[' + @TableName + '] add constraint ' + @ForeignKeyName + ' foreign key ('
	
	declare	ForeignKeyColumns cursor local for
	select
		COLUMN_NAME
	,	UNIQUE_COLUMN_NAME
	from
		FT.REFERENTIAL_CONSTRAINT_DEFS
	where
		CONSTRAINT_NAME = @ForeignKeyName and
		TABLE_NAME = @TableName
	
	open
		ForeignKeyColumns
	
	fetch
		ForeignKeyColumns
	into
		@ColumnName
	,	@UniqueColumnName
		
	set	@CreateForeignKeySyntax = @CreateForeignKeySyntax + @ColumnName
	set	@UniqueColumnList = @UniqueColumnName
	
	fetch
		ForeignKeyColumns
	into
		@ColumnName
	,	@UniqueColumnName
		
	while	@@FETCH_STATUS = 0 begin
		set	@CreateForeignKeySyntax = @CreateForeignKeySyntax + ',' + @ColumnName
		set	@UniqueColumnList = @UniqueColumnList + ',' + @UniqueColumnName
		
		fetch
			ForeignKeyColumns
		into
			@ColumnName
		,	@UniqueColumnName
	end
	
	close
		ForeignKeyColumns
	
	deallocate
		ForeignKeyColumns
	
	set	@CreateForeignKeySyntax = @CreateForeignKeySyntax + ') references [' + @UniqueTableSchema + '].[' + @UniqueTableName + '] (' + @UniqueColumnList + ')'
	
	execute	sp_executesql @CreateForeignKeySyntax
	
	fetch
		ForeignKeys
	into
		@ForeignKeyName
	,	@TableSchema
	,	@TableName
	,	@UniqueTableSchema
	,	@UniqueTableName
	
	set	@CreateForeignKeySyntax = ''
	set	@UniqueColumnList = ''
end

close
	ForeignKeys

truncate table
	FT.REFERENTIAL_CONSTRAINT_DEFS

GO

return
/*
exec FT.sp_DropForeignKeys

select
	*
from
	FT.REFERENTIAL_CONSTRAINT_DEFS rcd
*/