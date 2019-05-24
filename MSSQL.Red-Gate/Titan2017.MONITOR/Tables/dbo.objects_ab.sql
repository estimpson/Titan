CREATE TABLE [dbo].[objects_ab]
(
[name] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [int] NULL,
[uid] [smallint] NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userstat] [smallint] NULL,
[sysstat] [smallint] NULL,
[indexdel] [smallint] NULL,
[schemacnt] [smallint] NULL,
[sysstat2] [smallint] NULL,
[crdate] [datetime] NULL,
[expdate] [datetime] NULL,
[deltrig] [int] NULL,
[instrig] [int] NULL,
[updtrig] [int] NULL,
[seltrig] [int] NULL,
[ckfirst] [int] NULL,
[cache] [smallint] NULL,
[audflags] [int] NULL,
[objspare] [int] NULL
) ON [PRIMARY]
GO
