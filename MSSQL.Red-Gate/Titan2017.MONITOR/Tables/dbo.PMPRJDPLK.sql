CREATE TABLE [dbo].[PMPRJDPLK]
(
[OBJT] [int] NOT NULL,
[DPTP] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMPRJDPLK_PK] ON [dbo].[PMPRJDPLK] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
