CREATE TABLE [dbo].[PMCONT]
(
[OBJT] [int] NOT NULL,
[FOOT] [int] NULL,
[HEAD] [int] NULL,
[OPTS] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMCONT_PK] ON [dbo].[PMCONT] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
