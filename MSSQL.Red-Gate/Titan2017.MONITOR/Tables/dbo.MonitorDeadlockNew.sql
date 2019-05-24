CREATE TABLE [dbo].[MonitorDeadlockNew]
(
[RowNumber] [int] NOT NULL IDENTITY(1, 1),
[EventClass] [int] NULL,
[TextData] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTUserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProcessID] [int] NULL,
[ApplicationName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPID] [int] NULL,
[Duration] [bigint] NULL,
[StartTime] [datetime] NULL,
[Reads] [bigint] NULL,
[Writes] [bigint] NULL,
[CPU] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MonitorDeadlockNew] ADD CONSTRAINT [PK__MonitorDeadlockN__6EAB62A3] PRIMARY KEY CLUSTERED  ([RowNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
DECLARE @xp int
SELECT @xp=534
EXEC sp_addextendedproperty N'Build', @xp, 'SCHEMA', N'dbo', 'TABLE', N'MonitorDeadlockNew', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=8
EXEC sp_addextendedproperty N'MajorVer', @xp, 'SCHEMA', N'dbo', 'TABLE', N'MonitorDeadlockNew', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=0
EXEC sp_addextendedproperty N'MinorVer', @xp, 'SCHEMA', N'dbo', 'TABLE', N'MonitorDeadlockNew', NULL, NULL
GO
