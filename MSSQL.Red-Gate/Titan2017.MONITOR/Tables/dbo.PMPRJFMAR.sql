CREATE TABLE [dbo].[PMPRJFMAR]
(
[OBJT] [int] NOT NULL,
[HPFL] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMPRJFMAR_PK] ON [dbo].[PMPRJFMAR] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
