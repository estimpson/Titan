CREATE TABLE [dbo].[PMUPRF]
(
[OBJT] [int] NOT NULL,
[CGLB] [int] NULL,
[FMLY] [int] NULL,
[SFML] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMUPRF_PK] ON [dbo].[PMUPRF] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
