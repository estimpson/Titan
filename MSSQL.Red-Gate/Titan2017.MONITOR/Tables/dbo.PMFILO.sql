CREATE TABLE [dbo].[PMFILO]
(
[OBJT] [int] NOT NULL,
[AFCT] [int] NULL,
[FCNT] [int] NULL,
[FEXT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENE] [int] NULL,
[URLC] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PMFILO_PK] ON [dbo].[PMFILO] ([OBJT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
