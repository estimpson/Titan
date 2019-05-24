CREATE TABLE [dbo].[PMILMTREN]
(
[OBJT] [int] NOT NULL,
[ETYP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMILMTREN_PK] ON [dbo].[PMILMTREN] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
