CREATE TABLE [dbo].[PMTRFS]
(
[OBJT] [int] NOT NULL,
[OBID] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORGI] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMTRFS_PK] ON [dbo].[PMTRFS] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
