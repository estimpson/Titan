CREATE TABLE [dbo].[PMILMPROC]
(
[OBJT] [int] NOT NULL,
[RPRC] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMILMPROC_PK] ON [dbo].[PMILMPROC] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
