CREATE TABLE [dbo].[PMPDMDTBS]
(
[OBJT] [int] NOT NULL,
[FOOT] [int] NULL,
[HEAD] [int] NULL,
[OPTS] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMDTBS_PK] ON [dbo].[PMPDMDTBS] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
