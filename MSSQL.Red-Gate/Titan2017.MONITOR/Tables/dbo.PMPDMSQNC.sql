CREATE TABLE [dbo].[PMPDMSQNC]
(
[OBJT] [int] NOT NULL,
[OPTS] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMPDMSQNC_PK] ON [dbo].[PMPDMSQNC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
