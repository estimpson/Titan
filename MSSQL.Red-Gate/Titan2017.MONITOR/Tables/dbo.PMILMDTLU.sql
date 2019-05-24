CREATE TABLE [dbo].[PMILMDTLU]
(
[OBJT] [int] NOT NULL,
[FMOD] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MVAL] [int] NULL,
[SQRY] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PMILMDTLU_PK] ON [dbo].[PMILMDTLU] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
